use anyhow::{Result, bail};

#[inline]
fn clamp_to_u8_i32(v: i32) -> u8 {
    if v < 0 {
        0
    } else if v > 255 {
        255
    } else {
        v as u8
    }
}

#[inline]
fn color_r(color: u32) -> u8 {
    ((color >> 16) & 0xff) as u8
}

#[inline]
fn color_g(color: u32) -> u8 {
    ((color >> 8) & 0xff) as u8
}

#[inline]
fn color_b(color: u32) -> u8 {
    (color & 0xff) as u8
}

/// C の `standard_color_impl` + `sub_10018BD0` 相当。
///
/// Lua 側の呼び出し:
/// T_Color_Module.StandardColor(
///     userdata,
///     w,
///     h,
///     col1,
///     col2,
///     track_change / 100,
///     track_count,
///     track_scale,
///     check0
/// )
///
/// `pixels` は BGRA 8bit x 4 の生バッファ。
/// 処理は in-place。
pub fn standard_color(
    pixels: &mut [u8],
    width: usize,
    height: usize,
    col1: u32,
    col2: u32,
    change: f64,
    count: f64,
    scale: f64,
    use_distance_from_specified_color: bool,
) -> Result<()> {
    let pixel_count = width
        .checked_mul(height)
        .ok_or_else(|| anyhow::anyhow!("width * height overflow"))?;

    let expected_len = pixel_count
        .checked_mul(4)
        .ok_or_else(|| anyhow::anyhow!("buffer size overflow"))?;

    if pixels.len() != expected_len {
        bail!(
            "buffer length mismatch: got {}, expected {} ({}x{}x4)",
            pixels.len(),
            expected_len,
            width,
            height
        );
    }

    let t = change;
    let inv_t = 1.0 - t;

    let target_r = color_r(col1) as f64 * inv_t + color_r(col2) as f64 * t;
    let target_g = color_g(col1) as f64 * inv_t + color_g(col2) as f64 * t;
    let target_b = color_b(col1) as f64 * inv_t + color_b(col2) as f64 * t;

    let scale = scale / 100.0;
    let offset = count;

    for px in pixels.chunks_exact_mut(4) {
        let b = px[0];
        let g = px[1];
        let r = px[2];
        let a = px[3];

        let new_r = if use_distance_from_specified_color {
            ((r as f64 - target_r).abs() * scale + offset) as i32
        } else {
            (((r as f64 - target_r) * scale) + offset) as i32
        };

        let new_g = if use_distance_from_specified_color {
            ((g as f64 - target_g).abs() * scale + offset) as i32
        } else {
            (((g as f64 - target_g) * scale) + offset) as i32
        };

        let new_b = if use_distance_from_specified_color {
            ((b as f64 - target_b).abs() * scale + offset) as i32
        } else {
            (((b as f64 - target_b) * scale) + offset) as i32
        };

        px[0] = clamp_to_u8_i32(new_b);
        px[1] = clamp_to_u8_i32(new_g);
        px[2] = clamp_to_u8_i32(new_r);
        px[3] = a;
    }

    Ok(())
}
