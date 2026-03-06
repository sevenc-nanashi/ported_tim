use anyhow::{Result, anyhow};

pub fn posterize(
    pixels: &mut [u8],
    width: usize,
    height: usize,
    r_count: usize,
    g_count: usize,
    b_count: usize,
    error_diffusion: bool,
) -> Result<()> {
    let pixel_count = width
        .checked_mul(height)
        .ok_or_else(|| anyhow!("image size overflow"))?;

    let expected_len = pixel_count
        .checked_mul(4)
        .ok_or_else(|| anyhow!("buffer size overflow"))?;

    if pixels.len() != expected_len {
        return Err(anyhow!(
            "buffer length mismatch: got {}, expected {}",
            pixels.len(),
            expected_len
        ));
    }

    let lut = build_posterize_lut(r_count, g_count, b_count);

    if error_diffusion {
        posterize_with_error_diffusion(pixels, width, height, &lut);
    } else {
        posterize_without_error_diffusion(pixels, &lut);
    }

    Ok(())
}

fn build_posterize_lut(r_count: usize, g_count: usize, b_count: usize) -> [[u8; 3]; 256] {
    let mut lut = [[0u8; 3]; 256];

    for i in 0..256usize {
        lut[i][0] = quantize_index(i, r_count);
        lut[i][1] = quantize_index(i, g_count);
        lut[i][2] = quantize_index(i, b_count);
    }

    lut
}

fn quantize_index(value: usize, levels: usize) -> u8 {
    debug_assert!(levels >= 2);
    debug_assert!(levels <= 256);
    debug_assert!(value <= 255);

    let steps = levels - 1;
    let bucket = (value * steps + 127) / 255;
    let quantized = (bucket * 255) / steps;

    quantized as u8
}

fn posterize_without_error_diffusion(pixels: &mut [u8], lut: &[[u8; 3]; 256]) {
    for px in pixels.chunks_exact_mut(4) {
        let b = px[0] as usize;
        let g = px[1] as usize;
        let r = px[2] as usize;
        let a = px[3];

        px[0] = lut[b][2];
        px[1] = lut[g][1];
        px[2] = lut[r][0];
        px[3] = a;
    }
}

fn posterize_with_error_diffusion(
    pixels: &mut [u8],
    width: usize,
    height: usize,
    lut: &[[u8; 3]; 256],
) {
    let pixel_count = width * height;

    // C 実装と同様に R/G/B を平面分離して double で保持
    let mut plane_r = vec![0.0f64; pixel_count];
    let mut plane_g = vec![0.0f64; pixel_count];
    let mut plane_b = vec![0.0f64; pixel_count];

    for i in 0..pixel_count {
        let base = i * 4;
        plane_b[i] = pixels[base] as f64;
        plane_g[i] = pixels[base + 1] as f64;
        plane_r[i] = pixels[base + 2] as f64;
    }

    diffuse_plane(&mut plane_r, width, height, 0, lut);
    diffuse_plane(&mut plane_g, width, height, 1, lut);
    diffuse_plane(&mut plane_b, width, height, 2, lut);

    for i in 0..pixel_count {
        let base = i * 4;
        let a = pixels[base + 3];

        pixels[base] = clamp_to_u8_trunc(plane_b[i]);
        pixels[base + 1] = clamp_to_u8_trunc(plane_g[i]);
        pixels[base + 2] = clamp_to_u8_trunc(plane_r[i]);
        pixels[base + 3] = a;
    }
}

fn diffuse_plane(
    plane: &mut [f64],
    width: usize,
    height: usize,
    channel_index: usize, // 0 = R, 1 = G, 2 = B
    lut: &[[u8; 3]; 256],
) {
    debug_assert!(channel_index < 3);

    for y in 0..height {
        for x in 0..width {
            let idx = y * width + x;

            let current_index = clamp_to_u8_index(plane[idx]);
            let quantized = lut[current_index][channel_index] as f64;
            let error = plane[idx] - quantized;

            if x + 1 < width {
                plane[idx + 1] += error * (7.0 / 16.0);
            }

            if y + 1 < height {
                let next_row = idx + width;

                if x > 0 {
                    plane[next_row - 1] += error * (3.0 / 16.0);
                }

                plane[next_row] += error * (5.0 / 16.0);

                if x + 1 < width {
                    plane[next_row + 1] += error * (1.0 / 16.0);
                }
            }

            plane[idx] = quantized;
        }
    }
}

fn clamp_to_u8_index(v: f64) -> usize {
    if v < 0.0 {
        0
    } else if v > 255.0 {
        255
    } else {
        v as usize
    }
}

fn clamp_to_u8_trunc(v: f64) -> u8 {
    if v < 0.0 {
        0
    } else if v > 255.0 {
        255
    } else {
        v as u8
    }
}
