use aviutl2::anyhow;
use std::sync::{LazyLock, Mutex};

pub(crate) static RG_LINE_STATE: LazyLock<Mutex<crate::rgline::unoptimized::RgLineState>> =
    LazyLock::new(|| Mutex::new(crate::rgline::unoptimized::RgLineState::new()));

pub struct RgLineState {
    width: usize,
    height: usize,
    public_image: Option<Vec<u8>>,
    map_sum: Option<Vec<u16>>,
}

impl RgLineState {
    pub const fn new() -> Self {
        Self {
            width: 0,
            height: 0,
            public_image: None,
            map_sum: None,
        }
    }

    pub fn set_public_image(
        &mut self,
        image_buffer: &[u8],
        width: usize,
        height: usize,
    ) -> anyhow::Result<bool> {
        let required = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        if image_buffer.len() < required {
            anyhow::bail!("Input buffer too small");
        }
        self.width = width;
        self.height = height;
        self.public_image = Some(image_buffer[..required].to_vec());
        Ok(true)
    }

    pub fn set_map_image(
        &mut self,
        image_buffer: &[u8],
        width: usize,
        height: usize,
    ) -> anyhow::Result<bool> {
        let required = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        if image_buffer.len() < required {
            anyhow::bail!("Input buffer too small");
        }

        let mut map_sum = vec![0u16; width * height];
        for i in 0..(width * height) {
            let p = i * 4;
            let b = image_buffer[p] as u16;
            let g = image_buffer[p + 1] as u16;
            let r = image_buffer[p + 2] as u16;
            let a = image_buffer[p + 3];
            // DLL(FUN_10006140): alpha=0 のとき 0x2fd を使って長さ倍率1.0を維持
            map_sum[i] = if a == 0 { 0x2fd } else { b + g + r };
        }

        self.map_sum = Some(map_sum);
        Ok(true)
    }
}

fn rgb_to_bgr(color: u32) -> (u8, u8, u8) {
    let r = ((color >> 16) & 0xff) as u8;
    let g = ((color >> 8) & 0xff) as u8;
    let b = (color & 0xff) as u8;
    (b, g, r)
}

fn build_lut(scale: f64) -> Option<[i32; 1024]> {
    if (scale - 1.0).abs() <= f64::EPSILON {
        return None;
    }
    let mut lut = [0i32; 1024];
    for (i, v) in lut.iter_mut().enumerate() {
        let x = (i as f64) / 1024.0;
        *v = (x.powf(scale) * 65280.0).clamp(0.0, 65280.0) as i32;
    }
    Some(lut)
}

fn extract_edge_strength(
    public_image: &[u8],
    current_image: &[u8],
    threshold_cmp: i32,
    lut: Option<&[i32; 1024]>,
) -> Vec<i32> {
    let pixels = public_image.len() / 4;
    let mut out = vec![0i32; pixels];

    for i in 0..pixels {
        let p = i * 4;
        if current_image[p + 3] == 0 {
            out[i] = 0;
            continue;
        }

        let cur_b = current_image[p] as i32;
        let cur_g = current_image[p + 1] as i32;
        let cur_r = current_image[p + 2] as i32;
        let cur_l = cur_b * 0x1d + cur_g * 0x96 + cur_r * 0x4d;

        let mut ratio = if cur_l == 0 {
            0xff00
        } else {
            let pub_b = public_image[p] as i32;
            let pub_g = public_image[p + 1] as i32;
            let pub_r = public_image[p + 2] as i32;
            let v = ((pub_b * 0x1d00 + pub_g * 0x9600 + pub_r * 0x4d00) / cur_l) * 0xff;
            v.min(0xff00)
        };

        if ratio > threshold_cmp {
            ratio = 0xff00;
        }
        if let Some(t) = lut {
            let idx = (((ratio * 0x3ff) / 0xff00) as usize).min(1023);
            ratio = t[idx];
        }

        out[i] = 0xff00 - ratio;
    }

    out
}

fn map_length(base_length: i32, map_sum: Option<&[u16]>, idx: usize) -> i32 {
    let base = base_length.max(0);
    if let Some(map) = map_sum
        && idx < map.len() {
            let s = map[idx] as i32;
            return (base * s) / 0x2fd;
        }
    base
}

fn extend_directional(
    edge: &[i32],
    width: usize,
    height: usize,
    length: i32,
    direction_mask: i32,
    direction_threshold: i32,
    map_sum: Option<&[u16]>,
    screen_blend: bool,
) -> Vec<i32> {
    fn blend_direction(dst: &mut i32, src: i32, screen_blend: bool) {
        let src = src.clamp(0, 0xff00);
        if screen_blend {
            *dst = 0xff00 - ((((0xff00 - *dst).max(0)) >> 8) * (0xff00 - src)) / 0xff;
        } else if src > *dst {
            *dst = src;
        }
    }

    fn sample(edge: &[i32], width: usize, height: usize, x: isize, y: isize) -> i32 {
        let xx = x.clamp(0, width as isize - 1) as usize;
        let yy = y.clamp(0, height as isize - 1) as usize;
        edge[yy * width + xx]
    }

    fn classify_directions(
        edge: &[i32],
        width: usize,
        height: usize,
        direction_mask: i32,
        threshold: i32,
    ) -> Vec<i8> {
        let mut out = vec![-1i8; width * height];

        for y in 0..height {
            for x in 0..width {
                let xi = x as isize;
                let yi = y as isize;
                let mut best_dir = -1i8;
                let mut best_val = threshold;

                let a = sample(edge, width, height, xi - 2, yi - 2);
                let b = sample(edge, width, height, xi - 1, yi - 2);
                let c = sample(edge, width, height, xi, yi - 2);
                let d = sample(edge, width, height, xi + 1, yi - 2);
                let e = sample(edge, width, height, xi + 2, yi - 2);
                let f = sample(edge, width, height, xi - 2, yi - 1);
                let g = sample(edge, width, height, xi - 1, yi - 1);
                let h = sample(edge, width, height, xi, yi - 1);
                let i = sample(edge, width, height, xi + 1, yi - 1);
                let j = sample(edge, width, height, xi + 2, yi - 1);
                let k = sample(edge, width, height, xi - 2, yi);
                let l = sample(edge, width, height, xi - 1, yi);
                let m = sample(edge, width, height, xi, yi);
                let n = sample(edge, width, height, xi + 1, yi);
                let o = sample(edge, width, height, xi + 2, yi);
                let p = sample(edge, width, height, xi - 2, yi + 1);
                let q = sample(edge, width, height, xi - 1, yi + 1);
                let r = sample(edge, width, height, xi, yi + 1);
                let s = sample(edge, width, height, xi + 1, yi + 1);
                let t = sample(edge, width, height, xi + 2, yi + 1);
                let u = sample(edge, width, height, xi - 2, yi + 2);
                let v = sample(edge, width, height, xi - 1, yi + 2);
                let w = sample(edge, width, height, xi, yi + 2);
                let xx = sample(edge, width, height, xi + 1, yi + 2);
                let yy = sample(edge, width, height, xi + 2, yi + 2);

                let total = a
                    + b
                    + c
                    + d
                    + e
                    + f
                    + g
                    + h
                    + i
                    + j
                    + k
                    + l
                    + m
                    + n
                    + o
                    + p
                    + q
                    + r
                    + s
                    + t
                    + u
                    + v
                    + w
                    + xx
                    + yy;

                let responses = [
                    (h + c + m + r + w) * 5 - total,
                    (k + l + m + n + o) * 5 - total,
                    (a + g + m + s + yy) * 5 - total,
                    (e + i + m + q + u) * 5 - total,
                    ((g + l + n + s + (t + m + f) * 2) * 5 - total * 2) / 2,
                    ((g + h + r + s + (xx + m + b) * 2) * 5 - total * 2) / 2,
                    ((h + i + q + r + (v + m + d) * 2) * 5 - total * 2) / 2,
                    ((i + l + n + q + (p + m + j) * 2) * 5 - total * 2) / 2,
                ];

                for (dir, response) in responses.iter().enumerate() {
                    if (direction_mask & (1 << dir)) == 0 {
                        continue;
                    }
                    if *response > best_val {
                        best_val = *response;
                        best_dir = dir as i8;
                    }
                }

                out[y * width + x] = best_dir;
            }
        }
        out
    }

    fn build_direction_maps(
        edge: &[i32],
        direction_hint: &[i8],
        width: usize,
        height: usize,
    ) -> [Vec<i32>; 8] {
        let mut maps = std::array::from_fn(|_| vec![0i32; width * height]);
        for y in 0..height {
            for x in 0..width {
                let idx = y * width + x;
                let dir = direction_hint[idx];
                if dir >= 0 {
                    maps[dir as usize][idx] = edge[idx];
                }
            }
        }
        maps
    }

    fn vertical_blur(
        src: &[i32],
        dst: &mut [i32],
        width: usize,
        height: usize,
        radius: i32,
        map_sum: Option<&[u16]>,
        screen_blend: bool,
    ) {
        let mut prefix = vec![0i32; (height + 1) * width];
        for y in 0..height {
            let row = y * width;
            let next = (y + 1) * width;
            let prev = y * width;
            for x in 0..width {
                prefix[next + x] = prefix[prev + x] + src[row + x];
            }
        }

        for y in 0..height {
            for x in 0..width {
                let idx = y * width + x;
                let r = map_length(radius, map_sum, idx).max(0) as usize;
                let top = y.saturating_sub(r);
                let bottom = (y + r).min(height - 1);
                let sum = prefix[(bottom + 1) * width + x] - prefix[top * width + x];
                let avg = sum / (r as i32 * 2 + 1);
                blend_direction(&mut dst[idx], avg, screen_blend);
            }
        }
    }

    fn horizontal_blur(
        src: &[i32],
        dst: &mut [i32],
        width: usize,
        height: usize,
        radius: i32,
        map_sum: Option<&[u16]>,
        screen_blend: bool,
    ) {
        let mut prefix = vec![0i32; height * (width + 1)];
        for y in 0..height {
            let row_prefix = y * (width + 1);
            let row_src = y * width;
            for x in 0..width {
                prefix[row_prefix + x + 1] = prefix[row_prefix + x] + src[row_src + x];
            }
        }

        for y in 0..height {
            for x in 0..width {
                let idx = y * width + x;
                let r = map_length(radius, map_sum, idx).max(0) as usize;
                let left = x.saturating_sub(r);
                let right = (x + r).min(width - 1);
                let row_prefix = y * (width + 1);
                let sum = prefix[row_prefix + right + 1] - prefix[row_prefix + left];
                let avg = sum / (r as i32 * 2 + 1);
                blend_direction(&mut dst[idx], avg, screen_blend);
            }
        }
    }

    fn diagonal_main_blur(
        src: &[i32],
        dst: &mut [i32],
        width: usize,
        height: usize,
        radius: i32,
        map_sum: Option<&[u16]>,
        screen_blend: bool,
    ) {
        let mut prefix = vec![0i32; width * height];
        for y in 0..height {
            for x in 0..width {
                let idx = y * width + x;
                let prev = if x > 0 && y > 0 {
                    prefix[(y - 1) * width + (x - 1)]
                } else {
                    0
                };
                prefix[idx] = src[idx] + prev;
            }
        }

        for y in 0..height {
            for x in 0..width {
                let idx = y * width + x;
                let r = map_length(radius, map_sum, idx).max(0) as usize;
                let end_step = r.min(width - 1 - x).min(height - 1 - y);
                let ex = x + end_step;
                let ey = y + end_step;
                let mut sum = prefix[ey * width + ex];
                let sx = x as isize - r as isize - 1;
                let sy = y as isize - r as isize - 1;
                if sx >= 0 && sy >= 0 {
                    sum -= prefix[sy as usize * width + sx as usize];
                }
                let avg = sum / (r as i32 * 2 + 1);
                blend_direction(&mut dst[idx], avg, screen_blend);
            }
        }
    }

    fn diagonal_anti_blur(
        src: &[i32],
        dst: &mut [i32],
        width: usize,
        height: usize,
        radius: i32,
        map_sum: Option<&[u16]>,
        screen_blend: bool,
    ) {
        let mut prefix = vec![0i32; width * height];
        for y in 0..height {
            for x in (0..width).rev() {
                let idx = y * width + x;
                let prev = if x + 1 < width && y > 0 {
                    prefix[(y - 1) * width + (x + 1)]
                } else {
                    0
                };
                prefix[idx] = src[idx] + prev;
            }
        }

        for y in 0..height {
            for x in 0..width {
                let idx = y * width + x;
                let r = map_length(radius, map_sum, idx).max(0) as usize;
                let end_step = r.min(x).min(height - 1 - y);
                let ex = x - end_step;
                let ey = y + end_step;
                let mut sum = prefix[ey * width + ex];
                let sy = y as isize - r as isize - 1;
                let sx = x + r + 1;
                if sy >= 0 && sx < width {
                    sum -= prefix[sy as usize * width + sx];
                }
                let avg = sum / (r as i32 * 2 + 1);
                blend_direction(&mut dst[idx], avg, screen_blend);
            }
        }
    }

    fn build_oblique_prefix(
        src: &[i32],
        start: isize,
        step_major: isize,
        step_minor: isize,
        outer_count: usize,
        inner_count: usize,
    ) -> Vec<i32> {
        let mut prefix = vec![0i32; outer_count * inner_count];
        if outer_count == 0 || inner_count == 0 {
            return prefix;
        }

        for inner in 0..inner_count {
            let src_idx = (start + step_minor * inner as isize) as usize;
            prefix[inner] = src[src_idx] * 2;
        }

        if outer_count > 1 {
            for outer in 1..outer_count {
                let row_base = outer * inner_count;
                let src_base = start + step_major * outer as isize;
                prefix[row_base] = src[src_base as usize] * 2;
                if inner_count > 1 {
                    let prev_src = (start + step_major * (outer as isize - 1)) as usize;
                    let cur_src = src_base as usize;
                    let cur_next = (src_base + step_minor) as usize;
                    prefix[row_base + 1] = src[prev_src] + src[cur_next] * 2 + src[cur_src];
                }
            }
        }

        if inner_count > 2 {
            for outer in 1..outer_count {
                let row_base = outer * inner_count;
                let prev_row_base = (outer - 1) * inner_count;
                for inner in 2..inner_count {
                    let cur = (start + step_major * outer as isize + step_minor * inner as isize)
                        as usize;
                    let cur_prev =
                        (start + step_major * outer as isize + step_minor * (inner as isize - 1))
                            as usize;
                    let prev_prev = (start
                        + step_major * (outer as isize - 1)
                        + step_minor * (inner as isize - 1))
                        as usize;
                    prefix[row_base + inner] = src[cur_prev]
                        + src[cur] * 2
                        + src[prev_prev]
                        + prefix[prev_row_base + inner - 2];
                }
            }
        }

        prefix
    }

    fn oblique_blur(
        src: &[i32],
        dst: &mut [i32],
        prefix: &[i32],
        start: isize,
        step_major: isize,
        step_minor: isize,
        outer_count: usize,
        inner_count: usize,
        radius: i32,
        map_sum: Option<&[u16]>,
        screen_blend: bool,
    ) {
        for outer in 0..outer_count {
            let outer_rem = (outer_count - outer) * 2 - 2;
            for inner in 0..inner_count {
                let dst_idx =
                    (start + step_major * outer as isize + step_minor * inner as isize) as usize;
                let r = map_length(radius, map_sum, dst_idx).max(0) as usize;
                let inner_rem = inner_count - inner - 1;
                let mut end_inner = inner + r;
                let mut end_outer = outer + r / 2;
                let back_inner = inner as isize - r as isize - 1;
                let back_outer = outer as isize - r.div_ceil(2) as isize;

                if end_inner >= inner_count || end_outer >= outer_count {
                    let t = inner_rem.min(outer_rem);
                    end_inner = inner + t;
                    end_outer = outer + t / 2;
                }

                let mut sum = if (r & 1) == 0 {
                    prefix[end_outer * inner_count + end_inner]
                } else {
                    let next_outer = (end_outer + 1).min(outer_count - 1);
                    let idx0 = (start
                        + step_major * end_outer as isize
                        + step_minor * end_inner as isize) as usize;
                    let idx1 = (start
                        + step_major * next_outer as isize
                        + step_minor * end_inner as isize) as usize;
                    let mut value = src[idx0] + src[idx1];
                    if end_inner > 0 {
                        value += prefix[end_outer * inner_count + end_inner - 1];
                    }
                    value
                };

                if back_inner >= 0 && back_outer >= 0 {
                    if (r & 1) == 0 {
                        let src_idx =
                            (start + step_major * back_outer + step_minor * (inner - r) as isize)
                                as usize;
                        sum += src[src_idx] * 2
                            - prefix[back_outer as usize * inner_count + back_inner as usize + 1];
                    } else {
                        sum -= prefix[back_outer as usize * inner_count + back_inner as usize];
                    }
                }

                let avg = (sum >> 1) / (r as i32 * 2 + 1);
                blend_direction(&mut dst[dst_idx], avg, screen_blend);
            }
        }
    }

    let mut out = vec![0i32; edge.len()];
    let direction_threshold = ((direction_threshold.max(0) * 10000) / 9).max(0);
    let direction_hint =
        classify_directions(edge, width, height, direction_mask, direction_threshold);
    let direction_maps = build_direction_maps(edge, &direction_hint, width, height);
    let diagonal_radius = (length.max(0) * 0x197) / 0x241;
    let oblique_radius = (length.max(0) * 0x131) / 0x155;

    if (direction_mask & 1) != 0 {
        vertical_blur(
            &direction_maps[0],
            &mut out,
            width,
            height,
            length,
            map_sum,
            screen_blend,
        );
    }
    if (direction_mask & 2) != 0 {
        horizontal_blur(
            &direction_maps[1],
            &mut out,
            width,
            height,
            length,
            map_sum,
            screen_blend,
        );
    }
    if (direction_mask & 4) != 0 {
        diagonal_main_blur(
            &direction_maps[2],
            &mut out,
            width,
            height,
            diagonal_radius,
            map_sum,
            screen_blend,
        );
    }
    if (direction_mask & 8) != 0 {
        diagonal_anti_blur(
            &direction_maps[3],
            &mut out,
            width,
            height,
            diagonal_radius,
            map_sum,
            screen_blend,
        );
    }
    if (direction_mask & 0x10) != 0 {
        let prefix = build_oblique_prefix(&direction_maps[4], 0, width as isize, 1, height, width);
        oblique_blur(
            &direction_maps[4],
            &mut out,
            &prefix,
            0,
            width as isize,
            1,
            height,
            width,
            oblique_radius,
            map_sum,
            screen_blend,
        );
    }
    if (direction_mask & 0x20) != 0 {
        let prefix = build_oblique_prefix(&direction_maps[5], 0, 1, width as isize, width, height);
        oblique_blur(
            &direction_maps[5],
            &mut out,
            &prefix,
            0,
            1,
            width as isize,
            width,
            height,
            oblique_radius,
            map_sum,
            screen_blend,
        );
    }
    if (direction_mask & 0x40) != 0 {
        let start = width as isize - 1;
        let prefix =
            build_oblique_prefix(&direction_maps[6], start, -1, width as isize, width, height);
        oblique_blur(
            &direction_maps[6],
            &mut out,
            &prefix,
            start,
            -1,
            width as isize,
            width,
            height,
            oblique_radius,
            map_sum,
            screen_blend,
        );
    }
    if (direction_mask & 0x80) != 0 {
        let start = width as isize - 1;
        let prefix =
            build_oblique_prefix(&direction_maps[7], start, width as isize, -1, height, width);
        oblique_blur(
            &direction_maps[7],
            &mut out,
            &prefix,
            start,
            width as isize,
            -1,
            height,
            width,
            oblique_radius,
            map_sum,
            screen_blend,
        );
    }

    out
}

fn remap_strength(
    values: &mut [i32],
    intensity_lower: i32,
    intensity_upper: i32,
    gamma_scale: f64,
) {
    let mut lo = intensity_lower * 0x100;
    let mut hi = intensity_upper * 0x100;
    if hi < lo {
        std::mem::swap(&mut lo, &mut hi);
    }

    let slope = if hi != lo {
        255.0 / ((hi - lo) as f64)
    } else {
        1.0
    };

    let lut = build_lut(gamma_scale);

    for v in values.iter_mut() {
        let x = ((*v - lo) as f64 * 255.0 * slope).clamp(0.0, 65280.0);
        let mut q = x.round() as i32;
        if let Some(t) = &lut {
            let idx = (((q * 0x3ff) / 0xff00) as usize).min(1023);
            q = t[idx];
        }
        *v = q;
    }
}

fn compose_line_only(
    image_buffer: &mut [u8],
    public_image: &[u8],
    line_strength: &[i32],
    line_color: u32,
    width: usize,
    height: usize,
) {
    let (lb, lg, lr) = rgb_to_bgr(line_color);
    for i in 0..(width * height) {
        let p = i * 4;
        let src_a = public_image[p + 3] as i32;
        let alpha = ((line_strength[i] * src_a) / 0xff00).clamp(0, 255) as u8;
        image_buffer[p] = lb;
        image_buffer[p + 1] = lg;
        image_buffer[p + 2] = lr;
        image_buffer[p + 3] = alpha;
    }
}

fn compose_normal(
    image_buffer: &mut [u8],
    public_image: &[u8],
    line_strength: &[i32],
    line_color: u32,
    bg_color: u32,
    original_alpha: i32,
    background_alpha: i32,
    width: usize,
    height: usize,
) {
    let (line_b, line_g, line_r) = rgb_to_bgr(line_color);
    let (bg_b, bg_g, bg_r) = rgb_to_bgr(bg_color);

    let orig_alpha01 = (original_alpha.clamp(0, 100) as f64) / 100.0;
    let keep_orig = orig_alpha01;
    let use_bg = 1.0 - orig_alpha01;
    let keep_bg = 1.0 - (background_alpha.clamp(0, 100) as f64) / 100.0;

    for i in 0..(width * height) {
        let p = i * 4;
        let a = (line_strength[i] as f64 / 65280.0).clamp(0.0, 1.0);
        let d = 1.0 - (1.0 - a) * (1.0 - keep_bg);

        if d <= 0.0 {
            image_buffer[p] = 0;
            image_buffer[p + 1] = 0;
            image_buffer[p + 2] = 0;
            image_buffer[p + 3] = 0;
            continue;
        }

        let bgmix_b = (bg_b as f64 * use_bg + public_image[p] as f64 * keep_orig).round();
        let bgmix_g = (bg_g as f64 * use_bg + public_image[p + 1] as f64 * keep_orig).round();
        let bgmix_r = (bg_r as f64 * use_bg + public_image[p + 2] as f64 * keep_orig).round();

        let k = (1.0 - a) * keep_bg;

        let out_b = ((line_b as f64 * a + bgmix_b * k) / d)
            .round()
            .clamp(0.0, 255.0) as u8;
        let out_g = ((line_g as f64 * a + bgmix_g * k) / d)
            .round()
            .clamp(0.0, 255.0) as u8;
        let out_r = ((line_r as f64 * a + bgmix_r * k) / d)
            .round()
            .clamp(0.0, 255.0) as u8;
        let out_a = ((public_image[p + 3] as f64) * d).round().clamp(0.0, 255.0) as u8;

        image_buffer[p] = out_b;
        image_buffer[p + 1] = out_g;
        image_buffer[p + 2] = out_r;
        image_buffer[p + 3] = out_a;
    }
}

#[allow(clippy::too_many_arguments)]
pub fn line_ext(
    state: &mut RgLineState,
    image_buffer: &mut [u8],
    width: usize,
    height: usize,
    length: i32,
    intensity_upper: i32,
    intensity_lower: i32,
    threshold: i32,
    edge_strength: i32,
    edge_threshold: i32,
    line_only: bool,
    original_alpha: i32,
    background_alpha: i32,
    line_color: u32,
    bg_color: u32,
    screen_blend: bool,
    line_gamma: f64,
    direction_mask_seed: i32,
) -> anyhow::Result<()> {
    let required = width
        .checked_mul(height)
        .and_then(|v| v.checked_mul(4))
        .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
    if image_buffer.len() < required {
        anyhow::bail!("Input buffer too small");
    }

    let Some(public_image) = state.public_image.as_ref() else {
        return Ok(());
    };
    if state.width != width || state.height != height || public_image.len() < required {
        return Ok(());
    }

    let extraction_gamma = ((edge_strength.max(1) as f64) / 100.0).max(0.01);
    let extraction_lut = build_lut(extraction_gamma);
    let threshold_cmp = (0xff - edge_threshold.clamp(0, 255)) * 0x100;

    let edge = extract_edge_strength(
        public_image,
        image_buffer,
        threshold_cmp,
        extraction_lut.as_ref(),
    );

    let mut line_strength = extend_directional(
        &edge,
        width,
        height,
        length,
        direction_mask_seed,
        threshold,
        state.map_sum.as_deref(),
        screen_blend,
    );

    let line_gamma_scale = if line_gamma <= 1.0 {
        1.0
    } else {
        100.0 / line_gamma
    }
    .max(0.01);
    remap_strength(
        &mut line_strength,
        intensity_lower,
        intensity_upper,
        line_gamma_scale,
    );

    if line_only {
        compose_line_only(
            image_buffer,
            public_image,
            &line_strength,
            line_color,
            width,
            height,
        );
    } else {
        compose_normal(
            image_buffer,
            public_image,
            &line_strength,
            line_color,
            bg_color,
            original_alpha,
            background_alpha,
            width,
            height,
        );
    }

    state.public_image = None;
    state.map_sum = None;
    state.width = 0;
    state.height = 0;
    Ok(())
}
