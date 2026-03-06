use anyhow::{Result, anyhow};

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

/// C の sub_10015000 相当
/// 1024 段階の LUT を作る。
#[inline]
fn build_monochromatic2_lut(u: f64, v: f64) -> [[u8; 3]; 1024] {
    let mut lut = [[0u8; 3]; 1024];

    let r_bias = u * 357.663;
    let g_u = v * 87.822;
    let g_v = u * 181.407;
    let b_bias = v * 441.915;

    for i in 0..1024usize {
        let base = i as f64 * 0.25;

        let r = clamp_to_u8_i32((r_bias + base) as i32);
        let g = clamp_to_u8_i32((base - g_u - g_v) as i32);
        let b = clamp_to_u8_i32((base + b_bias) as i32);

        // C 側の配置は [R, G, B]
        lut[i] = [r, g, b];
    }

    lut
}

/// C の sub_10015100 相当
///
/// - `pixels` は BGRA
/// - 1 pixel = 4 bytes
/// - alpha は保持
pub fn monochromatic2(
    pixels: &mut [u8],
    width: usize,
    height: usize,
    u: f64,
    v: f64,
    gamma: f64,
) -> Result<()> {
    let pixel_count = width
        .checked_mul(height)
        .ok_or_else(|| anyhow!("image size overflow: {} * {}", width, height))?;

    let expected_len = pixel_count
        .checked_mul(4)
        .ok_or_else(|| anyhow!("buffer size overflow: {} * 4", pixel_count))?;

    if pixels.len() != expected_len {
        return Err(anyhow!(
            "invalid buffer length: got {}, expected {}",
            pixels.len(),
            expected_len
        ));
    }

    if gamma <= 0.0 {
        return Err(anyhow!("gamma must be > 0, got {}", gamma));
    }

    let lut = build_monochromatic2_lut(u, v);
    let inv_gamma = 1.0 / gamma;
    let max_luma = 1023.0;

    for px in pixels.chunks_exact_mut(4) {
        let b: u8 = px[0];
        let g: u8 = px[1];
        let r: u8 = px[2];
        let a: u8 = px[3];

        // C:
        // v12 = pow((B*0.456 + G*2.348 + R*1.196) / 1023.0, 1/gamma) * 1023.0;
        let src = (b as f64 * 0.456 + g as f64 * 2.348 + r as f64 * 1.196) / max_luma;
        let idx_f = src.powf(inv_gamma) * max_luma;

        // C は (int) キャストなので truncate
        let idx_i = idx_f as i32;
        let idx = if idx_i < 0 {
            0usize
        } else if idx_i > 1023 {
            1023usize
        } else {
            idx_i as usize
        };

        let [out_r, out_g, out_b] = lut[idx];

        // 出力も BGRA
        px[0] = out_b;
        px[1] = out_g;
        px[2] = out_r;
        px[3] = a;
    }

    Ok(())
}
