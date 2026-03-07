use anyhow::{Result, anyhow, bail};

#[derive(Debug, Clone, Default)]
pub struct MinimaxCache {
    /// dword_1002A8F8
    cached_width: usize,
    /// dword_1002A8FC
    cached_height: usize,
    /// dword_1002A884
    cached_input: Option<Vec<u32>>,
    /// dbl_1002A888
    cached_output: Option<Vec<u32>>,
    /// dbl_1002A890
    cached_params: Option<[f64; 12]>,
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
    pub reserved0: f64,
    pub reserved1: f64,
}

impl MinimaxCheckParams {
    fn as_f64_array(self) -> [f64; 12] {
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
            self.reserved0,
            self.reserved1,
        ]
    }
}

/// BGRA 生バイト列を u32 単位のスナップショットに変換する。
/// 各ピクセルはメモリ上の 4 バイトをそのまま保持する。
fn read_u32_pixels(bgra: &[u8], width: usize, height: usize) -> Result<Vec<u32>> {
    let pixel_count = width
        .checked_mul(height)
        .ok_or_else(|| anyhow!("width * height overflow"))?;
    let expected_len = pixel_count
        .checked_mul(4)
        .ok_or_else(|| anyhow!("pixel buffer size overflow"))?;

    if bgra.len() != expected_len {
        bail!(
            "invalid buffer length: got {}, expected {}",
            bgra.len(),
            expected_len
        );
    }

    let mut out = Vec::with_capacity(pixel_count);
    for chunk in bgra.chunks_exact(4) {
        out.push(u32::from_le_bytes([chunk[0], chunk[1], chunk[2], chunk[3]]));
    }
    Ok(out)
}

/// u32 スナップショットを BGRA 生バイト列へ書き戻す。
fn write_u32_pixels(src: &[u32], bgra: &mut [u8], width: usize, height: usize) -> Result<()> {
    let pixel_count = width
        .checked_mul(height)
        .ok_or_else(|| anyhow!("width * height overflow"))?;
    let expected_len = pixel_count
        .checked_mul(4)
        .ok_or_else(|| anyhow!("pixel buffer size overflow"))?;

    if src.len() != pixel_count {
        bail!(
            "invalid snapshot length: got {}, expected {}",
            src.len(),
            pixel_count
        );
    }
    if bgra.len() != expected_len {
        bail!(
            "invalid buffer length: got {}, expected {}",
            bgra.len(),
            expected_len
        );
    }

    for (pixel, chunk) in src.iter().zip(bgra.chunks_exact_mut(4)) {
        let bytes = pixel.to_le_bytes();
        chunk.copy_from_slice(&bytes);
    }

    Ok(())
}

/// C の sub_100187B0 / sub_100186F0 相当:
/// 現在の BGRA バッファを丸ごと u32 スナップショットへコピーする。
fn copy_current_buffer(bgra: &[u8], width: usize, height: usize) -> Result<Vec<u32>> {
    read_u32_pixels(bgra, width, height)
}

/// 未提示の sub_10018810 の推定実装:
/// 保存済み結果バッファを現在の BGRA バッファへ復元する。
fn restore_saved_result(
    saved_output: &[u32],
    bgra: &mut [u8],
    width: usize,
    height: usize,
) -> Result<()> {
    write_u32_pixels(saved_output, bgra, width, height)
}

/// Lua の:
/// T_Color_Module.MinimaxCheck(userdata, w, h, ...)
///
/// に対応する Rust 版。
///
/// 戻り値:
/// - Ok(true): 同条件かつ入力画像も一致したため、保存済み結果を復元した
/// - Ok(false): 条件不一致または入力不一致なので、比較用キャッシュを更新した
pub fn minimax_check(
    cache: &mut MinimaxCache,
    userdata: &mut [u8],
    width: usize,
    height: usize,
    params: MinimaxCheckParams,
) -> Result<bool> {
    let current_params = params.as_f64_array();

    let same_size = width == cache.cached_width && height == cache.cached_height;
    let same_params = cache
        .cached_params
        .as_ref()
        .map(|p| *p == current_params)
        .unwrap_or(false);

    if same_size && same_params {
        let current_input = read_u32_pixels(userdata, width, height)?;

        if let Some(cached_input) = cache.cached_input.as_ref()
            && *cached_input == current_input
        {
            // C の sub_10018810 は未提示。
            // 呼び出し文脈から「保存済み結果を userdata に復元」と推定。
            if let Some(cached_output) = cache.cached_output.as_ref() {
                restore_saved_result(cached_output, userdata, width, height)?;
            } else {
                bail!("cached output is missing; sub_10018810 target buffer is undefined");
            }
            return Ok(true);
        }
    }

    // 条件不一致または入力不一致: 比較用キャッシュを更新
    cache.cached_width = width;
    cache.cached_height = height;
    cache.cached_params = Some(current_params);
    cache.cached_input = Some(copy_current_buffer(userdata, width, height)?);

    Ok(false)
}

/// Lua の:
/// T_Color_Module.MinimaxSave(userdata, w, h)
///
/// に対応する Rust 版。
pub fn minimax_save(
    cache: &mut MinimaxCache,
    userdata: &[u8],
    width: usize,
    height: usize,
) -> Result<()> {
    cache.cached_output = Some(copy_current_buffer(userdata, width, height)?);
    Ok(())
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
    pub fig: u8, // this implementation only supports fig == 0
    pub alpha_expand: bool,
}

#[inline]
fn pixel_count(width: usize, height: usize) -> Result<usize> {
    width
        .checked_mul(height)
        .ok_or_else(|| anyhow!("width * height overflow"))
}

#[inline]
fn expected_len(width: usize, height: usize) -> Result<usize> {
    pixel_count(width, height)?
        .checked_mul(4)
        .ok_or_else(|| anyhow!("buffer size overflow"))
}

#[inline]
fn validate_bgra(buf: &[u8], width: usize, height: usize) -> Result<()> {
    let len = expected_len(width, height)?;
    if buf.len() != len {
        bail!(
            "invalid BGRA buffer length: got {}, expected {}",
            buf.len(),
            len
        );
    }
    Ok(())
}

#[inline]
fn load_px(buf: &[u8], idx: usize) -> u32 {
    let i = idx * 4;
    u32::from_le_bytes([buf[i], buf[i + 1], buf[i + 2], buf[i + 3]])
}

#[inline]
fn store_px(buf: &mut [u8], idx: usize, px: u32) {
    let i = idx * 4;
    buf[i..i + 4].copy_from_slice(&px.to_le_bytes());
}

#[inline]
fn alpha_of(px: u32) -> u8 {
    ((px >> 24) & 0xFF) as u8
}

#[inline]
fn rgb_of(px: u32) -> u32 {
    px & 0x00FF_FFFF
}

#[inline]
fn with_alpha(rgb: u32, a: u8) -> u32 {
    ((a as u32) << 24) | (rgb & 0x00FF_FFFF)
}

#[inline]
fn invert_rgb_preserve_alpha(px: u32) -> u32 {
    (px & 0xFF00_0000) | (0x00FF_FFFF - (px & 0x00FF_FFFF))
}

#[inline]
fn clamp_i32(v: i32, lo: i32, hi: i32) -> i32 {
    v.max(lo).min(hi)
}

#[inline]
fn round_like_c(v: f64) -> i64 {
    // Ghidra の FUN_1001ae80 相当の完全再現ではないが、
    // この用途では「最近接整数」相当で十分近い。
    v.round() as i64
}

#[inline]
fn max_rgb(a: u32, b: u32) -> u32 {
    let ar = (a >> 16) & 0xFF;
    let ag = (a >> 8) & 0xFF;
    let ab = a & 0xFF;

    let br = (b >> 16) & 0xFF;
    let bg = (b >> 8) & 0xFF;
    let bb = b & 0xFF;

    ((ar.max(br)) << 16) | ((ag.max(bg)) << 8) | ab.max(bb)
}

#[inline]
fn channel_mask(channel: u8) -> u32 {
    match channel {
        1 => 0x00FF_FFFF,
        2 => 0x00FF_0000,
        3 => 0x0000_FF00,
        4 => 0x0000_00FF,
        _ => unreachable!(),
    }
}

fn extract_alpha_plane(userdata: &[u8], width: usize, height: usize) -> Result<Vec<u32>> {
    validate_bgra(userdata, width, height)?;
    let n = pixel_count(width, height)?;
    let mut out = vec![0u32; n];
    for i in 0..n {
        out[i] = alpha_of(load_px(userdata, i)) as u32;
    }
    Ok(out)
}

fn extract_color_plane(
    userdata: &[u8],
    width: usize,
    height: usize,
    max_min: u8,
) -> Result<Vec<u32>> {
    validate_bgra(userdata, width, height)?;
    let n = pixel_count(width, height)?;
    let mut out = vec![0u32; n];
    for i in 0..n {
        let px = load_px(userdata, i);
        let a = alpha_of(px);
        if a == 0 {
            out[i] = 0;
        } else if max_min == 1 {
            out[i] = rgb_of(px);
        } else {
            out[i] = 0x00FF_FFFF - rgb_of(px);
        }
    }
    Ok(out)
}

fn write_planes_back(
    userdata: &mut [u8],
    width: usize,
    height: usize,
    color_plane: &[u32],
    alpha_plane: &[u32],
    max_min: u8,
) -> Result<()> {
    let n = pixel_count(width, height)?;
    if color_plane.len() != n || alpha_plane.len() != n {
        bail!("plane length mismatch");
    }

    for i in 0..n {
        let rgb = if max_min == 1 {
            color_plane[i] & 0x00FF_FFFF
        } else {
            0x00FF_FFFF - (color_plane[i] & 0x00FF_FFFF)
        };
        let a = (alpha_plane[i] & 0xFF) as u8;
        store_px(userdata, i, with_alpha(rgb, a));
    }

    Ok(())
}

fn invert_rgb_buffer_in_place(userdata: &mut [u8], width: usize, height: usize) -> Result<()> {
    validate_bgra(userdata, width, height)?;
    let n = pixel_count(width, height)?;
    for i in 0..n {
        let px = load_px(userdata, i);
        store_px(userdata, i, invert_rgb_preserve_alpha(px));
    }
    Ok(())
}

fn alpha_to_rgb_replicated(userdata: &[u8], width: usize, height: usize) -> Result<Vec<u32>> {
    let n = pixel_count(width, height)?;
    let mut out = vec![0u32; n];
    for i in 0..n {
        let a = alpha_of(load_px(userdata, i)) as u32;
        out[i] = a | (a << 8) | (a << 16);
    }
    Ok(out)
}

fn alpha_rgb_to_alpha_plane(alpha_rgb: &[u32]) -> Vec<u32> {
    alpha_rgb.iter().map(|&v| v & 0xFF).collect()
}

fn line_max_all_rgb(
    src: &[u32],
    width: usize,
    height: usize,
    size: usize,
    vertical: bool,
) -> Vec<u32> {
    if size <= 1 {
        return src.to_vec();
    }
    let radius = (size - 1) / 2;
    let mut dst = vec![0u32; width * height];

    if vertical {
        for y in 0..height {
            let y0 = y.saturating_sub(radius);
            let y1 = (y + radius).min(height - 1);
            for x in 0..width {
                let mut acc = 0u32;
                for yy in y0..=y1 {
                    acc = max_rgb(acc, src[yy * width + x]);
                }
                dst[y * width + x] = acc;
            }
        }
    } else {
        for y in 0..height {
            for x in 0..width {
                let x0 = x.saturating_sub(radius);
                let x1 = (x + radius).min(width - 1);
                let mut acc = 0u32;
                for xx in x0..=x1 {
                    acc = max_rgb(acc, src[y * width + xx]);
                }
                dst[y * width + x] = acc;
            }
        }
    }

    dst
}

fn line_max_masked_rgb(
    src: &[u32],
    width: usize,
    height: usize,
    size: usize,
    mask: u32,
    vertical: bool,
) -> Vec<u32> {
    if size <= 1 {
        return src.to_vec();
    }
    let radius = (size - 1) / 2;
    let mut dst = src.to_vec();

    if vertical {
        for y in 0..height {
            let y0 = y.saturating_sub(radius);
            let y1 = (y + radius).min(height - 1);
            for x in 0..width {
                let mut acc = 0u32;
                for yy in y0..=y1 {
                    acc = max_rgb(acc, src[yy * width + x] & mask);
                }
                let i = y * width + x;
                dst[i] = (dst[i] & !mask) | (acc & mask);
            }
        }
    } else {
        for y in 0..height {
            for x in 0..width {
                let x0 = x.saturating_sub(radius);
                let x1 = (x + radius).min(width - 1);
                let mut acc = 0u32;
                for xx in x0..=x1 {
                    acc = max_rgb(acc, src[y * width + xx] & mask);
                }
                let i = y * width + x;
                dst[i] = (dst[i] & !mask) | (acc & mask);
            }
        }
    }

    dst
}

fn even_size_adjust_rgb(
    src: &[u32],
    width: usize,
    height: usize,
    horizontal_even_adjust: bool,
    vertical_even_adjust: bool,
    channel: u8,
) -> Vec<u32> {
    let mut dst = src.to_vec();

    for y in 0..height {
        for x in 0..width {
            let cur = src[y * width + x];

            let xl = x.saturating_sub(1);
            let xr = (x + 1).min(width - 1);
            let yu = y.saturating_sub(1);
            let yd = (y + 1).min(height - 1);

            let mut max_r = cur & 0x00FF_0000;
            let mut max_g = cur & 0x0000_FF00;
            let mut max_b = cur & 0x0000_00FF;

            let mut visit = |nx: usize, ny: usize| {
                let p = src[ny * width + nx];
                if channel == 1 || channel == 2 {
                    max_r = max_r.max(p & 0x00FF_0000);
                }
                if channel == 1 || channel == 3 {
                    max_g = max_g.max(p & 0x0000_FF00);
                }
                if channel == 1 || channel == 4 {
                    max_b = max_b.max(p & 0x0000_00FF);
                }
            };

            if horizontal_even_adjust && vertical_even_adjust {
                visit(xl, yu);
                visit(xl, yd);
                visit(xr, yu);
                visit(xr, yd);
            }
            if vertical_even_adjust {
                visit(x, yu);
                visit(x, yd);
            }
            if horizontal_even_adjust {
                visit(xl, y);
                visit(xr, y);
            }

            let out = (((max_b + (cur & 0x0000_00FF)) & 0x0000_01FE) >> 1)
                | (((max_g + (cur & 0x0000_FF00)) & 0x0001_FE00) >> 1)
                | (((max_r + (cur & 0x00FF_0000)) & 0x01FE_0000) >> 1);

            dst[y * width + x] = out;
        }
    }

    dst
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
fn apply_metric_preserve_color(rgb: u32, channel: u8, new_metric: u8) -> u32 {
    let (r, g, b) = split_rgb(rgb);
    if channel == 1 {
        let src_metric = r.max(g).max(b);
        if src_metric == 0 {
            return 0;
        }
        let scale = new_metric as f64 / src_metric as f64;
        let nr = (r as f64 * scale).round().clamp(0.0, 255.0) as u32;
        let ng = (g as f64 * scale).round().clamp(0.0, 255.0) as u32;
        let nb = (b as f64 * scale).round().clamp(0.0, 255.0) as u32;
        compose_rgb(nr, ng, nb)
    } else {
        match channel {
            2 => compose_rgb(new_metric as u32, g, b),
            3 => compose_rgb(r, new_metric as u32, b),
            4 => compose_rgb(r, g, new_metric as u32),
            _ => rgb,
        }
    }
}

fn line_max_metric(
    src: &[u8],
    width: usize,
    height: usize,
    size: usize,
    vertical: bool,
) -> Vec<u8> {
    if size <= 1 {
        return src.to_vec();
    }
    let radius = (size - 1) / 2;
    let mut dst = vec![0u8; width * height];
    if vertical {
        for y in 0..height {
            let y0 = y.saturating_sub(radius);
            let y1 = (y + radius).min(height - 1);
            for x in 0..width {
                let mut acc = 0u8;
                for yy in y0..=y1 {
                    acc = acc.max(src[yy * width + x]);
                }
                dst[y * width + x] = acc;
            }
        }
    } else {
        for y in 0..height {
            for x in 0..width {
                let x0 = x.saturating_sub(radius);
                let x1 = (x + radius).min(width - 1);
                let mut acc = 0u8;
                for xx in x0..=x1 {
                    acc = acc.max(src[y * width + xx]);
                }
                dst[y * width + x] = acc;
            }
        }
    }
    dst
}

fn shape_contains(fig: u8, dx: i32, dy: i32, radius: i32, aspect: f64) -> bool {
    let rr = radius.max(1) as f64;
    let ry = (rr * aspect).round().max(1.0);
    let adx = dx.unsigned_abs() as f64;
    let ady = dy.unsigned_abs() as f64;
    match fig {
        2 => (adx * adx) / (rr * rr) + (ady * ady) / (ry * ry) <= 1.0,
        3 => adx + (ady / ry * rr) <= rr,
        4 => (adx * adx) + ((ady / ry * rr) * (ady / ry * rr)) <= rr * rr,
        _ => adx <= rr && ady <= ry,
    }
}

fn shaped_max_rgb(
    src: &[u32],
    width: usize,
    height: usize,
    radius: usize,
    channel: u8,
    fig: u8,
    aspect_ratio: f64,
) -> Vec<u32> {
    if radius == 0 {
        return src.to_vec();
    }
    let aspect = aspect_ratio.abs().min(1.0).max(0.01);
    let r = radius as i32;
    let mut dst = src.to_vec();
    for y in 0..height {
        for x in 0..width {
            let mut acc = if channel == 1 {
                0u32
            } else {
                src[y * width + x]
            };
            for oy in -r..=r {
                for ox in -r..=r {
                    if !shape_contains(fig, ox, oy, r, aspect) {
                        continue;
                    }
                    let nx = clamp_i32(x as i32 + ox, 0, (width - 1) as i32) as usize;
                    let ny = clamp_i32(y as i32 + oy, 0, (height - 1) as i32) as usize;
                    let p = src[ny * width + nx];
                    acc = if channel == 1 {
                        max_rgb(acc, p)
                    } else {
                        let mask = channel_mask(channel);
                        (acc & !mask) | (max_rgb(acc & mask, p & mask) & mask)
                    };
                }
            }
            dst[y * width + x] = acc;
        }
    }
    dst
}

fn shaped_max_metric(
    src: &[u8],
    width: usize,
    height: usize,
    radius: usize,
    fig: u8,
    aspect_ratio: f64,
) -> Vec<u8> {
    if radius == 0 {
        return src.to_vec();
    }
    let aspect = aspect_ratio.abs().min(1.0).max(0.01);
    let r = radius as i32;
    let mut dst = vec![0u8; width * height];
    for y in 0..height {
        for x in 0..width {
            let mut acc = 0u8;
            for oy in -r..=r {
                for ox in -r..=r {
                    if !shape_contains(fig, ox, oy, r, aspect) {
                        continue;
                    }
                    let nx = clamp_i32(x as i32 + ox, 0, (width - 1) as i32) as usize;
                    let ny = clamp_i32(y as i32 + oy, 0, (height - 1) as i32) as usize;
                    acc = acc.max(src[ny * width + nx]);
                }
            }
            dst[y * width + x] = acc;
        }
    }
    dst
}

/// Ghidra: `FUN_10006b80` (`minmax_impl`) の Rust 版。
///
/// 備考:
/// - `save_color == true` は `FUN_100070c0` 系列の近似移植。
/// - `fig != 0` は `FUN_10007e00` 系列の近似移植。
pub fn minimax_impl(
    userdata: &mut [u8],
    width: usize,
    height: usize,
    params: MinimaxParams,
) -> Result<()> {
    validate_bgra(userdata, width, height)?;

    if !(1..=2).contains(&params.max_min) {
        bail!("max_min must be 1 or 2");
    }
    if !(1..=4).contains(&params.channel) {
        bail!("channel must be in 1..=4");
    }
    if params.range == 0 {
        bail!("range must be >= 1");
    }
    if params.range <= 1 {
        return Ok(());
    }

    let aspect = if params.aspect_ratio.is_finite() && params.aspect_ratio > 0.0 {
        params.aspect_ratio
    } else {
        1.0
    };

    // C の local_18 相当: 縦方向サイズ(概ね range * aspect_ratio)
    let mut vertical_size = round_like_c(params.range as f64 * aspect).clamp(1, i64::MAX) as usize;
    let mut horizontal_size = params.range;

    // C の local_20 / bVar1 相当: 偶数サイズ時の後段補正フラグ
    let mut horizontal_even_adjust = false;
    let mut vertical_even_adjust = false;
    if params.symmetric {
        if (vertical_size & 1) == 0 {
            vertical_even_adjust = true;
            vertical_size -= 1;
        }
        if (horizontal_size & 1) == 0 {
            horizontal_even_adjust = true;
            horizontal_size -= 1;
        }
    }

    let mut alpha_plane = extract_alpha_plane(userdata, width, height)?;
    let src_color_plane = extract_color_plane(userdata, width, height, params.max_min)?;
    let mut color_plane = src_color_plane.clone();

    if params.fig == 0 {
        if !params.horizontal && !params.vertical {
            return Ok(());
        }

        if params.alpha_expand {
            let mut alpha_rgb = alpha_to_rgb_replicated(userdata, width, height)?;
            if params.horizontal {
                alpha_rgb = line_max_all_rgb(&alpha_rgb, width, height, horizontal_size, false);
            }
            if params.vertical {
                alpha_rgb = line_max_all_rgb(&alpha_rgb, width, height, vertical_size, true);
            }
            alpha_plane = alpha_rgb_to_alpha_plane(&alpha_rgb);
        }

        if params.save_color {
            let mut metric: Vec<u8> = src_color_plane
                .iter()
                .map(|&px| metric_for_channel(px, params.channel))
                .collect();
            if params.horizontal {
                metric = line_max_metric(&metric, width, height, horizontal_size, false);
            }
            if params.vertical {
                metric = line_max_metric(&metric, width, height, vertical_size, true);
            }
            for i in 0..metric.len() {
                color_plane[i] =
                    apply_metric_preserve_color(src_color_plane[i], params.channel, metric[i]);
            }
        } else {
            if params.horizontal {
                if params.channel == 1 {
                    color_plane =
                        line_max_all_rgb(&color_plane, width, height, horizontal_size, false);
                } else {
                    color_plane = line_max_masked_rgb(
                        &color_plane,
                        width,
                        height,
                        horizontal_size,
                        channel_mask(params.channel),
                        false,
                    );
                }
            }
            if params.vertical {
                if params.channel == 1 {
                    color_plane =
                        line_max_all_rgb(&color_plane, width, height, vertical_size, true);
                } else {
                    color_plane = line_max_masked_rgb(
                        &color_plane,
                        width,
                        height,
                        vertical_size,
                        channel_mask(params.channel),
                        true,
                    );
                }
            }

            if horizontal_even_adjust || vertical_even_adjust {
                color_plane = even_size_adjust_rgb(
                    &color_plane,
                    width,
                    height,
                    horizontal_even_adjust,
                    vertical_even_adjust,
                    params.channel,
                );
            }
        }
    } else {
        // `FUN_10007e00` 系列: 図形カーネルベースの2D拡張
        let radius = (params.range.saturating_sub(1)) / 2;
        if radius == 0 {
            return Ok(());
        }

        if params.alpha_expand {
            let alpha_metric: Vec<u8> = alpha_plane.iter().map(|&a| (a & 0xFF) as u8).collect();
            let alpha_max = shaped_max_metric(
                &alpha_metric,
                width,
                height,
                radius,
                params.fig,
                params.aspect_ratio,
            );
            alpha_plane = alpha_max.into_iter().map(|a| a as u32).collect();
        }

        if params.save_color {
            let metric: Vec<u8> = src_color_plane
                .iter()
                .map(|&px| metric_for_channel(px, params.channel))
                .collect();
            let metric = shaped_max_metric(
                &metric,
                width,
                height,
                radius,
                params.fig,
                params.aspect_ratio,
            );
            for i in 0..metric.len() {
                color_plane[i] =
                    apply_metric_preserve_color(src_color_plane[i], params.channel, metric[i]);
            }
        } else {
            color_plane = shaped_max_rgb(
                &src_color_plane,
                width,
                height,
                radius,
                params.channel,
                params.fig,
                params.aspect_ratio,
            );
        }
    }

    write_planes_back(
        userdata,
        width,
        height,
        &color_plane,
        &alpha_plane,
        params.max_min,
    )
}

pub fn minimax_rot(
    userdata: &mut [u8],
    width: usize,
    height: usize,
    params: MinimaxRotParams,
) -> Result<()> {
    validate_bgra(userdata, width, height)?;

    if !(1..=2).contains(&params.max_min) {
        bail!("max_min must be 1 or 2");
    }
    if params.original_width == 0 || params.original_height == 0 {
        return Ok(());
    }
    if params.original_width > width || params.original_height > height {
        bail!("original size exceeds destination size");
    }

    // sub_10013A90
    if params.max_min == 2 {
        invert_rgb_buffer_in_place(userdata, width, height)?;
    }

    let angle = if params.rotated_90_first {
        params.angle_rad - core::f64::consts::FRAC_PI_2
    } else {
        params.angle_rad
    };
    let cos_v = angle.cos();
    let sin_v = angle.sin();

    let src = userdata.to_vec();
    let mut out = vec![0u32; width * height];
    let mut filled = vec![false; width * height];

    let cx = (params.original_width as f64 - 1.0) * 0.5;
    let cy = (params.original_height as f64 - 1.0) * 0.5;

    let blend_max_alpha = |dst: u32, src_px: u32| -> u32 {
        let da = ((dst >> 24) & 0xFF) as u32;
        let sa = ((src_px >> 24) & 0xFF) as u32;
        let out_a = da.max(sa);
        if out_a == 0 {
            return 0;
        }
        let dr = ((dst >> 16) & 0xFF) * da;
        let dg = ((dst >> 8) & 0xFF) * da;
        let db = (dst & 0xFF) * da;
        let sr = ((src_px >> 16) & 0xFF) * sa;
        let sg = ((src_px >> 8) & 0xFF) * sa;
        let sb = (src_px & 0xFF) * sa;
        let rr = dr.max(sr) / out_a;
        let rg = dg.max(sg) / out_a;
        let rb = db.max(sb) / out_a;
        ((out_a & 0xFF) << 24) | ((rr & 0xFF) << 16) | ((rg & 0xFF) << 8) | (rb & 0xFF)
    };

    // Forward map: original領域だけを回転して拡張キャンバスへ散布。
    for sy in 0..params.original_height {
        for sx in 0..params.original_width {
            let src_idx = sy * width + sx;
            let spx = load_px(&src, src_idx);
            if spx == 0 {
                continue;
            }
            let dx = sx as f64 - cx;
            let dy = sy as f64 - cy;
            let tx = dx * cos_v - dy * sin_v + cx;
            let ty = dx * sin_v + dy * cos_v + cy;
            let xi = round_like_c(tx) as i32;
            let yi = round_like_c(ty) as i32;
            if xi < 0 || yi < 0 || xi >= width as i32 || yi >= height as i32 {
                continue;
            }
            let di = yi as usize * width + xi as usize;
            if !filled[di] {
                out[di] = spx;
                filled[di] = true;
            } else {
                out[di] = blend_max_alpha(out[di], spx);
            }
        }
    }

    // Hole fill: 未到達ピクセルは逆写像で nearest を引く。
    for y in 0..height {
        for x in 0..width {
            let di = y * width + x;
            if filled[di] {
                continue;
            }
            let dx = x as f64 - cx;
            let dy = y as f64 - cy;
            let sx = dx * cos_v + dy * sin_v + cx;
            let sy = -dx * sin_v + dy * cos_v + cy;
            let xi = round_like_c(sx) as i32;
            let yi = round_like_c(sy) as i32;
            if xi < 0
                || yi < 0
                || xi >= params.original_width as i32
                || yi >= params.original_height as i32
            {
                out[di] = 0;
            } else {
                out[di] = load_px(&src, yi as usize * width + xi as usize);
            }
        }
    }

    for (i, px) in out.iter().enumerate() {
        store_px(userdata, i, *px);
    }

    if params.max_min == 2 {
        invert_rgb_buffer_in_place(userdata, width, height)?;
    }

    Ok(())
}
