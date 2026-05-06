//! Maximum/minimum color filter implementation.

use anyhow::{Result, anyhow, bail};
use rayon::prelude::*;

const RGB_MASK: u32 = 0x00FF_FFFF;
const RED_MASK: u32 = 0x00FF_0000;
const GREEN_MASK: u32 = 0x0000_FF00;
const BLUE_MASK: u32 = 0x0000_00FF;

#[derive(Debug, Clone, Default)]
pub struct MinimaxCache {
    cached_width: usize,
    cached_height: usize,
    cached_input: Option<Vec<u32>>,
    cached_output: Option<Vec<u32>>,
    cached_params: Option<[f64; 10]>,
}

#[derive(Debug, Clone, Copy)]
pub struct MinimaxCheckParams {
    pub max_min: u8,  // 1..=2
    pub channel: u8,  // 1..=4
    pub range: usize, // 1..=
    pub angle_deg: f64,
    pub horizontal: bool,
    pub vertical: bool,
    pub aspect_ratio: f64,
    pub symmetric: bool,
    pub save_color: bool,
    pub fig: u8, // caller comment says [0..4]
}

impl MinimaxCheckParams {
    fn as_cache_key(self) -> [f64; 10] {
        [
            self.max_min as f64,
            self.channel as f64,
            self.range as f64,
            self.angle_deg,
            self.horizontal as u8 as f64,
            self.vertical as u8 as f64,
            self.aspect_ratio,
            self.symmetric as u8 as f64,
            self.save_color as u8 as f64,
            self.fig as f64,
        ]
    }
}

#[derive(Debug, Clone, Copy)]
pub struct MinimaxRotParams {
    pub original_width: usize,
    pub original_height: usize,
    pub angle_rad: f64,
    pub rotated_90_first: bool,
    pub max_min: u8, // 1=max, 2=min
}

#[derive(Debug, Clone, Copy)]
pub struct MinimaxParams {
    pub max_min: u8,  // 1..=2
    pub range: usize, // >= 1
    pub channel: u8,  // 1..=4
    pub horizontal: bool,
    pub vertical: bool,
    pub symmetric: bool,
    pub aspect_ratio: f64,
    pub save_color: bool,
    pub fig: u8,
    pub alpha_expand: bool,
}

#[derive(Debug, Clone, Copy)]
struct Extent {
    width: usize,
    height: usize,
}

impl Extent {
    fn new(width: usize, height: usize) -> Self {
        Self { width, height }
    }

    fn len(self) -> Result<usize> {
        self.width
            .checked_mul(self.height)
            .ok_or_else(|| anyhow!("width * height overflow"))
    }

    fn byte_len(self) -> Result<usize> {
        self.len()?
            .checked_mul(4)
            .ok_or_else(|| anyhow!("buffer size overflow"))
    }

    fn validate_bgra(self, bgra: &[u8]) -> Result<()> {
        let expected = self.byte_len()?;
        if bgra.len() != expected {
            bail!(
                "invalid BGRA buffer length: got {}, expected {}",
                bgra.len(),
                expected
            );
        }
        Ok(())
    }

    fn is_empty(self) -> bool {
        self.width == 0 || self.height == 0
    }

    #[inline]
    fn idx(self, x: usize, y: usize) -> usize {
        y * self.width + x
    }
}

#[derive(Debug, Clone, Copy)]
enum Direction {
    Horizontal,
    Vertical,
}

#[derive(Debug, Clone, Copy)]
struct KernelSize {
    horizontal: usize,
    vertical: usize,
    horizontal_even_adjust: bool,
    vertical_even_adjust: bool,
}

#[derive(Debug, Clone)]
struct Planes {
    color: Vec<u32>,
    source_color: Vec<u32>,
    alpha: Vec<u32>,
}

impl Planes {
    fn from_bgra(bgra: &[u8], extent: Extent, max_min: u8) -> Result<Self> {
        extent.validate_bgra(bgra)?;

        let alpha = bgra.par_chunks_exact(4).map(|px| px[3] as u32).collect();
        let color = bgra
            .par_chunks_exact(4)
            .map(|chunk| {
                let px = pixel_from_bytes(chunk);
                if alpha_of(px) == 0 {
                    0
                } else if max_min == 1 {
                    rgb_of(px)
                } else {
                    RGB_MASK - rgb_of(px)
                }
            })
            .collect::<Vec<_>>();

        Ok(Self {
            source_color: color.clone(),
            color,
            alpha,
        })
    }

    fn write_to_bgra(&self, bgra: &mut [u8], extent: Extent, max_min: u8) -> Result<()> {
        extent.validate_bgra(bgra)?;
        let len = extent.len()?;
        if self.color.len() != len || self.alpha.len() != len {
            bail!("plane length mismatch");
        }

        bgra.par_chunks_exact_mut(4)
            .enumerate()
            .for_each(|(i, chunk)| {
                let rgb = if max_min == 1 {
                    self.color[i] & RGB_MASK
                } else {
                    RGB_MASK - (self.color[i] & RGB_MASK)
                };
                let alpha = (self.alpha[i] & 0xFF) as u8;
                chunk.copy_from_slice(&with_alpha(rgb, alpha).to_le_bytes());
            });

        Ok(())
    }
}

pub fn minimax_check(
    cache: &mut MinimaxCache,
    userdata: &mut [u8],
    width: usize,
    height: usize,
    params: MinimaxCheckParams,
) -> Result<bool> {
    let extent = Extent::new(width, height);
    let current_params = params.as_cache_key();
    let same_size = width == cache.cached_width && height == cache.cached_height;
    let same_params = cache.cached_params == Some(current_params);

    if same_size && same_params {
        let current_input = read_snapshot(userdata, extent)?;
        if cache.cached_input.as_ref() == Some(&current_input) {
            let cached_output = cache
                .cached_output
                .as_ref()
                .ok_or_else(|| anyhow!("cached output is missing"))?;
            write_snapshot(cached_output, userdata, extent)?;
            return Ok(true);
        }
    }

    cache.cached_width = width;
    cache.cached_height = height;
    cache.cached_params = Some(current_params);
    cache.cached_input = Some(read_snapshot(userdata, extent)?);
    Ok(false)
}

pub fn minimax_save(
    cache: &mut MinimaxCache,
    userdata: &[u8],
    width: usize,
    height: usize,
) -> Result<()> {
    cache.cached_output = Some(read_snapshot(userdata, Extent::new(width, height))?);
    Ok(())
}

pub fn minimax_impl(
    userdata: &mut [u8],
    width: usize,
    height: usize,
    params: MinimaxParams,
) -> Result<()> {
    let extent = Extent::new(width, height);
    validate_params(params)?;
    extent.validate_bgra(userdata)?;

    if extent.is_empty() || params.range <= 1 {
        return Ok(());
    }
    if params.fig == 0 && !params.horizontal && !params.vertical {
        return Ok(());
    }
    if params.fig != 0 && (params.range.saturating_sub(1)) / 2 == 0 {
        return Ok(());
    }

    let mut planes = Planes::from_bgra(userdata, extent, params.max_min)?;
    if params.fig == 0 {
        apply_rectangular_kernel(&mut planes, extent, params);
    } else {
        apply_shaped_kernel(&mut planes, extent, params);
    }
    planes.write_to_bgra(userdata, extent, params.max_min)
}

pub fn minimax_rot(
    userdata: &mut [u8],
    width: usize,
    height: usize,
    params: MinimaxRotParams,
) -> Result<()> {
    let extent = Extent::new(width, height);
    extent.validate_bgra(userdata)?;

    if !(1..=2).contains(&params.max_min) {
        bail!("max_min must be 1 or 2");
    }
    if extent.is_empty() || params.original_width == 0 || params.original_height == 0 {
        return Ok(());
    }
    if params.original_width > width || params.original_height > height {
        bail!("original size exceeds destination size");
    }

    if params.max_min == 2 {
        invert_rgb_buffer_in_place(userdata, extent)?;
    }

    rotate_original_region(userdata, extent, params);

    if params.max_min == 2 {
        invert_rgb_buffer_in_place(userdata, extent)?;
    }

    Ok(())
}

fn validate_params(params: MinimaxParams) -> Result<()> {
    if !(1..=2).contains(&params.max_min) {
        bail!("max_min must be 1 or 2");
    }
    if !(1..=4).contains(&params.channel) {
        bail!("channel must be in 1..=4");
    }
    if params.range == 0 {
        bail!("range must be >= 1");
    }
    Ok(())
}

fn read_snapshot(bgra: &[u8], extent: Extent) -> Result<Vec<u32>> {
    extent.validate_bgra(bgra)?;
    Ok(bgra.par_chunks_exact(4).map(pixel_from_bytes).collect())
}

fn write_snapshot(snapshot: &[u32], bgra: &mut [u8], extent: Extent) -> Result<()> {
    extent.validate_bgra(bgra)?;
    let len = extent.len()?;
    if snapshot.len() != len {
        bail!(
            "invalid snapshot length: got {}, expected {}",
            snapshot.len(),
            len
        );
    }

    bgra.par_chunks_exact_mut(4)
        .zip(snapshot.par_iter())
        .for_each(|(chunk, pixel)| chunk.copy_from_slice(&pixel.to_le_bytes()));

    Ok(())
}

fn apply_rectangular_kernel(planes: &mut Planes, extent: Extent, params: MinimaxParams) {
    if !params.horizontal && !params.vertical {
        return;
    }

    let size = rectangular_kernel_size(params);

    if params.alpha_expand {
        let mut alpha_rgb = alpha_plane_as_rgb(&planes.alpha);
        if params.horizontal {
            alpha_rgb = line_max_rgb(&alpha_rgb, extent, size.horizontal, Direction::Horizontal);
        }
        if params.vertical {
            alpha_rgb = line_max_rgb(&alpha_rgb, extent, size.vertical, Direction::Vertical);
        }
        planes.alpha = alpha_rgb.par_iter().map(|px| px & 0xFF).collect();
    }

    if params.save_color {
        apply_rectangular_metric(planes, extent, params, size);
    } else {
        apply_rectangular_color(planes, extent, params, size);
    }
}

fn rectangular_kernel_size(params: MinimaxParams) -> KernelSize {
    let aspect = if params.aspect_ratio.is_finite() && params.aspect_ratio > 0.0 {
        params.aspect_ratio
    } else {
        1.0
    };

    let mut vertical = round_like_c(params.range as f64 * aspect).max(1) as usize;
    let mut horizontal = params.range;
    let mut horizontal_even_adjust = false;
    let mut vertical_even_adjust = false;

    if params.symmetric {
        if vertical & 1 == 0 {
            vertical_even_adjust = true;
            vertical -= 1;
        }
        if horizontal & 1 == 0 {
            horizontal_even_adjust = true;
            horizontal -= 1;
        }
    }

    KernelSize {
        horizontal,
        vertical,
        horizontal_even_adjust,
        vertical_even_adjust,
    }
}

fn apply_rectangular_metric(
    planes: &mut Planes,
    extent: Extent,
    params: MinimaxParams,
    size: KernelSize,
) {
    let mut metric = planes
        .source_color
        .par_iter()
        .map(|&px| metric_for_channel(px, params.channel))
        .collect::<Vec<_>>();

    if params.horizontal {
        metric = line_max_u8(&metric, extent, size.horizontal, Direction::Horizontal);
    }
    if params.vertical {
        metric = line_max_u8(&metric, extent, size.vertical, Direction::Vertical);
    }

    planes
        .color
        .par_iter_mut()
        .enumerate()
        .for_each(|(i, color)| {
            *color = apply_metric_preserve_color(planes.source_color[i], params.channel, metric[i]);
        });
}

fn apply_rectangular_color(
    planes: &mut Planes,
    extent: Extent,
    params: MinimaxParams,
    size: KernelSize,
) {
    if params.horizontal {
        planes.color = if params.channel == 1 {
            line_max_rgb(
                &planes.color,
                extent,
                size.horizontal,
                Direction::Horizontal,
            )
        } else {
            line_max_masked_rgb(
                &planes.color,
                extent,
                size.horizontal,
                Direction::Horizontal,
                channel_mask(params.channel),
            )
        };
    }

    if params.vertical {
        planes.color = if params.channel == 1 {
            line_max_rgb(&planes.color, extent, size.vertical, Direction::Vertical)
        } else {
            line_max_masked_rgb(
                &planes.color,
                extent,
                size.vertical,
                Direction::Vertical,
                channel_mask(params.channel),
            )
        };
    }

    if size.horizontal_even_adjust || size.vertical_even_adjust {
        planes.color = even_size_adjust_rgb(
            &planes.color,
            extent,
            size.horizontal_even_adjust,
            size.vertical_even_adjust,
            params.channel,
        );
    }
}

fn apply_shaped_kernel(planes: &mut Planes, extent: Extent, params: MinimaxParams) {
    let radius = (params.range.saturating_sub(1)) / 2;
    if radius == 0 {
        return;
    }

    if params.alpha_expand {
        let alpha_metric = planes
            .alpha
            .par_iter()
            .map(|&a| (a & 0xFF) as u8)
            .collect::<Vec<_>>();
        planes.alpha = shaped_max_u8(
            &alpha_metric,
            extent,
            radius,
            params.fig,
            params.aspect_ratio,
        )
        .into_par_iter()
        .map(u32::from)
        .collect();
    }

    if params.save_color {
        let metric = planes
            .source_color
            .par_iter()
            .map(|&px| metric_for_channel(px, params.channel))
            .collect::<Vec<_>>();
        let metric = shaped_max_u8(&metric, extent, radius, params.fig, params.aspect_ratio);
        planes
            .color
            .par_iter_mut()
            .enumerate()
            .for_each(|(i, color)| {
                *color =
                    apply_metric_preserve_color(planes.source_color[i], params.channel, metric[i]);
            });
    } else {
        planes.color = shaped_max_rgb(
            &planes.source_color,
            extent,
            radius,
            params.channel,
            params.fig,
            params.aspect_ratio,
        );
    }
}

fn line_max_u8(src: &[u8], extent: Extent, size: usize, direction: Direction) -> Vec<u8> {
    if size <= 1 {
        return src.to_vec();
    }

    let radius = (size - 1) / 2;
    let mut dst = vec![0; src.len()];
    dst.par_chunks_mut(extent.width)
        .enumerate()
        .for_each(|(y, row)| {
            for (x, cell) in row.iter_mut().enumerate() {
                *cell = max_in_line(extent, x, y, radius, direction, |i| src[i]);
            }
        });
    dst
}

fn line_max_rgb(src: &[u32], extent: Extent, size: usize, direction: Direction) -> Vec<u32> {
    if size <= 1 {
        return src.to_vec();
    }

    let radius = (size - 1) / 2;
    let mut dst = vec![0; src.len()];
    dst.par_chunks_mut(extent.width)
        .enumerate()
        .for_each(|(y, row)| {
            for (x, cell) in row.iter_mut().enumerate() {
                *cell = max_rgb_in_line(src, extent, x, y, radius, direction, RGB_MASK);
            }
        });
    dst
}

fn line_max_masked_rgb(
    src: &[u32],
    extent: Extent,
    size: usize,
    direction: Direction,
    mask: u32,
) -> Vec<u32> {
    if size <= 1 {
        return src.to_vec();
    }

    let radius = (size - 1) / 2;
    let mut dst = src.to_vec();
    dst.par_chunks_mut(extent.width)
        .enumerate()
        .for_each(|(y, row)| {
            for (x, cell) in row.iter_mut().enumerate() {
                let i = extent.idx(x, y);
                let acc = max_rgb_in_line(src, extent, x, y, radius, direction, mask);
                *cell = (src[i] & !mask) | (acc & mask);
            }
        });
    dst
}

fn max_in_line<T, F>(
    extent: Extent,
    x: usize,
    y: usize,
    radius: usize,
    direction: Direction,
    mut value_at: F,
) -> T
where
    T: Ord + Copy + Default,
    F: FnMut(usize) -> T,
{
    let mut acc = T::default();
    match direction {
        Direction::Horizontal => {
            let x0 = x.saturating_sub(radius);
            let x1 = (x + radius).min(extent.width - 1);
            for xx in x0..=x1 {
                acc = acc.max(value_at(extent.idx(xx, y)));
            }
        }
        Direction::Vertical => {
            let y0 = y.saturating_sub(radius);
            let y1 = (y + radius).min(extent.height - 1);
            for yy in y0..=y1 {
                acc = acc.max(value_at(extent.idx(x, yy)));
            }
        }
    }
    acc
}

fn max_rgb_in_line(
    src: &[u32],
    extent: Extent,
    x: usize,
    y: usize,
    radius: usize,
    direction: Direction,
    mask: u32,
) -> u32 {
    let mut acc = 0;
    match direction {
        Direction::Horizontal => {
            let x0 = x.saturating_sub(radius);
            let x1 = (x + radius).min(extent.width - 1);
            for xx in x0..=x1 {
                acc = max_rgb(acc, src[extent.idx(xx, y)] & mask);
            }
        }
        Direction::Vertical => {
            let y0 = y.saturating_sub(radius);
            let y1 = (y + radius).min(extent.height - 1);
            for yy in y0..=y1 {
                acc = max_rgb(acc, src[extent.idx(x, yy)] & mask);
            }
        }
    }
    acc
}

fn even_size_adjust_rgb(
    src: &[u32],
    extent: Extent,
    horizontal_adjust: bool,
    vertical_adjust: bool,
    channel: u8,
) -> Vec<u32> {
    let mut dst = src.to_vec();
    dst.par_chunks_mut(extent.width)
        .enumerate()
        .for_each(|(y, row)| {
            for (x, cell) in row.iter_mut().enumerate() {
                let cur = src[extent.idx(x, y)];
                let mut max_r = cur & RED_MASK;
                let mut max_g = cur & GREEN_MASK;
                let mut max_b = cur & BLUE_MASK;

                let mut visit = |nx: usize, ny: usize| {
                    let p = src[extent.idx(nx, ny)];
                    if channel == 1 || channel == 2 {
                        max_r = max_r.max(p & RED_MASK);
                    }
                    if channel == 1 || channel == 3 {
                        max_g = max_g.max(p & GREEN_MASK);
                    }
                    if channel == 1 || channel == 4 {
                        max_b = max_b.max(p & BLUE_MASK);
                    }
                };

                let xl = x.saturating_sub(1);
                let xr = (x + 1).min(extent.width - 1);
                let yu = y.saturating_sub(1);
                let yd = (y + 1).min(extent.height - 1);

                if horizontal_adjust && vertical_adjust {
                    visit(xl, yu);
                    visit(xl, yd);
                    visit(xr, yu);
                    visit(xr, yd);
                }
                if vertical_adjust {
                    visit(x, yu);
                    visit(x, yd);
                }
                if horizontal_adjust {
                    visit(xl, y);
                    visit(xr, y);
                }

                *cell = (((max_b + (cur & BLUE_MASK)) & 0x0000_01FE) >> 1)
                    | (((max_g + (cur & GREEN_MASK)) & 0x0001_FE00) >> 1)
                    | (((max_r + (cur & RED_MASK)) & 0x01FE_0000) >> 1);
            }
        });
    dst
}

fn shaped_max_u8(src: &[u8], extent: Extent, radius: usize, fig: u8, aspect_ratio: f64) -> Vec<u8> {
    let aspect = normalized_aspect(aspect_ratio);
    let radius = radius as i32;
    let mut dst = vec![0; src.len()];

    dst.par_chunks_mut(extent.width)
        .enumerate()
        .for_each(|(y, row)| {
            for (x, cell) in row.iter_mut().enumerate() {
                let mut acc = 0;
                visit_shape(extent, x, y, radius, fig, aspect, |i| {
                    acc = acc.max(src[i]);
                });
                *cell = acc;
            }
        });

    dst
}

fn shaped_max_rgb(
    src: &[u32],
    extent: Extent,
    radius: usize,
    channel: u8,
    fig: u8,
    aspect_ratio: f64,
) -> Vec<u32> {
    let aspect = normalized_aspect(aspect_ratio);
    let radius = radius as i32;
    let mask = channel_mask(channel);
    let mut dst = src.to_vec();

    dst.par_chunks_mut(extent.width)
        .enumerate()
        .for_each(|(y, row)| {
            for (x, cell) in row.iter_mut().enumerate() {
                let source = src[extent.idx(x, y)];
                let mut acc = if channel == 1 { 0 } else { source };
                visit_shape(extent, x, y, radius, fig, aspect, |i| {
                    let p = src[i];
                    acc = if channel == 1 {
                        max_rgb(acc, p)
                    } else {
                        (acc & !mask) | (max_rgb(acc & mask, p & mask) & mask)
                    };
                });
                *cell = acc;
            }
        });

    dst
}

fn visit_shape(
    extent: Extent,
    x: usize,
    y: usize,
    radius: i32,
    fig: u8,
    aspect: f64,
    mut f: impl FnMut(usize),
) {
    let max_x = (extent.width - 1) as i32;
    let max_y = (extent.height - 1) as i32;
    for oy in -radius..=radius {
        for ox in -radius..=radius {
            if shape_contains(fig, ox, oy, radius, aspect) {
                let nx = (x as i32 + ox).clamp(0, max_x) as usize;
                let ny = (y as i32 + oy).clamp(0, max_y) as usize;
                f(extent.idx(nx, ny));
            }
        }
    }
}

fn shape_contains(fig: u8, dx: i32, dy: i32, radius: i32, aspect: f64) -> bool {
    let rx = radius.max(1) as f64;
    let ry = (rx * aspect).round().max(1.0);
    let x = dx.unsigned_abs() as f64;
    let y = dy.unsigned_abs() as f64;

    match fig {
        2 => (x * x) / (rx * rx) + (y * y) / (ry * ry) <= 1.0,
        3 => x + (y / ry * rx) <= rx,
        4 => (x * x) + ((y / ry * rx) * (y / ry * rx)) <= rx * rx,
        _ => x <= rx && y <= ry,
    }
}

fn rotate_original_region(userdata: &mut [u8], extent: Extent, params: MinimaxRotParams) {
    let angle = if params.rotated_90_first {
        params.angle_rad - core::f64::consts::FRAC_PI_2
    } else {
        params.angle_rad
    };
    let cos = angle.cos();
    let sin = angle.sin();
    let src = userdata.to_vec();
    let mut out = vec![0; extent.width * extent.height];
    let mut filled = vec![false; extent.width * extent.height];

    for sy in 0..params.original_height {
        for sx in 0..params.original_width {
            let src_idx = extent.idx(sx, sy);
            let src_px = load_px(&src, src_idx);

            let src_x = 2.0 * sx as f64 - params.original_width as f64 + 1.0;
            let src_y = 2.0 * sy as f64 - params.original_height as f64 + 1.0;
            let tx = (src_x * cos - src_y * sin + extent.width as f64 - 1.0) * 0.5;
            let ty = (src_x * sin + src_y * cos + extent.height as f64 - 1.0) * 0.5;
            let xi = round_like_c(tx) as i32;
            let yi = round_like_c(ty) as i32;
            if xi < 0 || yi < 0 || xi >= extent.width as i32 || yi >= extent.height as i32 {
                continue;
            }

            let dst_idx = extent.idx(xi as usize, yi as usize);
            out[dst_idx] = if filled[dst_idx] {
                blend_max_alpha(out[dst_idx], src_px)
            } else {
                filled[dst_idx] = true;
                src_px
            };
        }
    }

    for y in 0..extent.height {
        for x in 0..extent.width {
            let dst_idx = extent.idx(x, y);
            if filled[dst_idx] {
                continue;
            }

            let dst_x = 2.0 * x as f64 - extent.width as f64 + 1.0;
            let dst_y = 2.0 * y as f64 - extent.height as f64 + 1.0;
            let sx = (dst_x * cos + dst_y * sin + params.original_width as f64 - 1.0) * 0.5;
            let sy = (-dst_x * sin + dst_y * cos + params.original_height as f64 - 1.0) * 0.5;
            let xi = round_like_c(sx) as i32;
            let yi = round_like_c(sy) as i32;

            out[dst_idx] = if xi < 0
                || yi < 0
                || xi >= params.original_width as i32
                || yi >= params.original_height as i32
            {
                0
            } else {
                load_px(&src, extent.idx(xi as usize, yi as usize))
            };
        }
    }

    userdata
        .par_chunks_exact_mut(4)
        .zip(out.par_iter())
        .for_each(|(chunk, px)| chunk.copy_from_slice(&px.to_le_bytes()));
}

fn blend_max_alpha(dst: u32, src: u32) -> u32 {
    let dst_a = alpha_of(dst) as u32;
    let src_a = alpha_of(src) as u32;
    let out_a = dst_a.max(src_a);
    if out_a == 0 {
        return 0;
    }

    let (dr, dg, db) = split_rgb(dst);
    let (sr, sg, sb) = split_rgb(src);
    let r = (dr * dst_a).max(sr * src_a) / out_a;
    let g = (dg * dst_a).max(sg * src_a) / out_a;
    let b = (db * dst_a).max(sb * src_a) / out_a;
    with_alpha(compose_rgb(r, g, b), out_a as u8)
}

fn invert_rgb_buffer_in_place(userdata: &mut [u8], extent: Extent) -> Result<()> {
    extent.validate_bgra(userdata)?;
    userdata.par_chunks_exact_mut(4).for_each(|chunk| {
        let px = pixel_from_bytes(chunk);
        chunk.copy_from_slice(&invert_rgb_preserve_alpha(px).to_le_bytes());
    });
    Ok(())
}

fn alpha_plane_as_rgb(alpha: &[u32]) -> Vec<u32> {
    alpha
        .par_iter()
        .map(|&a| {
            let a = a & 0xFF;
            a | (a << 8) | (a << 16)
        })
        .collect()
}

#[inline]
fn pixel_from_bytes(bytes: &[u8]) -> u32 {
    u32::from_le_bytes([bytes[0], bytes[1], bytes[2], bytes[3]])
}

#[inline]
fn load_px(buf: &[u8], idx: usize) -> u32 {
    let i = idx * 4;
    pixel_from_bytes(&buf[i..i + 4])
}

#[inline]
fn alpha_of(px: u32) -> u8 {
    ((px >> 24) & 0xFF) as u8
}

#[inline]
fn rgb_of(px: u32) -> u32 {
    px & RGB_MASK
}

#[inline]
fn with_alpha(rgb: u32, alpha: u8) -> u32 {
    ((alpha as u32) << 24) | (rgb & RGB_MASK)
}

#[inline]
fn invert_rgb_preserve_alpha(px: u32) -> u32 {
    (px & 0xFF00_0000) | (RGB_MASK - rgb_of(px))
}

#[inline]
fn round_like_c(v: f64) -> i64 {
    v.round() as i64
}

#[inline]
fn normalized_aspect(aspect_ratio: f64) -> f64 {
    if aspect_ratio.is_finite() {
        aspect_ratio.abs().clamp(0.01, 1.0)
    } else {
        1.0
    }
}

#[inline]
fn channel_mask(channel: u8) -> u32 {
    match channel {
        1 => RGB_MASK,
        2 => RED_MASK,
        3 => GREEN_MASK,
        4 => BLUE_MASK,
        _ => unreachable!(),
    }
}

#[inline]
fn max_rgb(a: u32, b: u32) -> u32 {
    let (ar, ag, ab) = split_rgb(a);
    let (br, bg, bb) = split_rgb(b);
    compose_rgb(ar.max(br), ag.max(bg), ab.max(bb))
}

#[inline]
fn split_rgb(rgb: u32) -> (u32, u32, u32) {
    ((rgb >> 16) & 0xFF, (rgb >> 8) & 0xFF, rgb & 0xFF)
}

#[inline]
fn compose_rgb(r: u32, g: u32, b: u32) -> u32 {
    ((r & 0xFF) << 16) | ((g & 0xFF) << 8) | (b & 0xFF)
}

#[inline]
fn metric_for_channel(rgb: u32, channel: u8) -> u8 {
    let (r, g, b) = split_rgb(rgb);
    match channel {
        1 => r.max(g).max(b) as u8,
        2 => r as u8,
        3 => g as u8,
        4 => b as u8,
        _ => 0,
    }
}

#[inline]
fn apply_metric_preserve_color(rgb: u32, channel: u8, metric: u8) -> u32 {
    let (r, g, b) = split_rgb(rgb);
    if channel == 1 {
        let source_metric = r.max(g).max(b);
        if source_metric == 0 {
            return 0;
        }

        let scale = metric as f64 / source_metric as f64;
        return compose_rgb(
            (r as f64 * scale).round().clamp(0.0, 255.0) as u32,
            (g as f64 * scale).round().clamp(0.0, 255.0) as u32,
            (b as f64 * scale).round().clamp(0.0, 255.0) as u32,
        );
    }

    match channel {
        2 => compose_rgb(metric as u32, g, b),
        3 => compose_rgb(r, metric as u32, b),
        4 => compose_rgb(r, g, metric as u32),
        _ => rgb,
    }
}
