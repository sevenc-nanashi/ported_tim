use aviutl2::anyhow::{self, Result, bail};
use rayon::prelude::*;

pub(crate) fn posterize_error_diffusion(
    pixels: &mut [u8],
    width: usize,
    height: usize,
    r_count: usize,
    g_count: usize,
    b_count: usize,
) -> Result<()> {
    let pixel_count = validate_inputs(pixels.len(), width, height, r_count, g_count, b_count)?;
    let lut = build_posterize_lut(r_count, g_count, b_count);

    let mut plane_r = vec![0.0f64; pixel_count];
    let mut plane_g = vec![0.0f64; pixel_count];
    let mut plane_b = vec![0.0f64; pixel_count];

    pixels
        .par_chunks_exact(4)
        .zip(
            plane_r
                .par_iter_mut()
                .zip(plane_g.par_iter_mut())
                .zip(plane_b.par_iter_mut()),
        )
        .for_each(|(px, ((r, g), b))| {
            *b = f64::from(px[0]);
            *g = f64::from(px[1]);
            *r = f64::from(px[2]);
        });

    let ((), ((), ())) = rayon::join(
        || diffuse_plane(&mut plane_r, width, height, 0, &lut),
        || {
            rayon::join(
                || diffuse_plane(&mut plane_g, width, height, 1, &lut),
                || diffuse_plane(&mut plane_b, width, height, 2, &lut),
            )
        },
    );

    pixels
        .par_chunks_exact_mut(4)
        .zip(
            plane_r
                .par_iter()
                .zip(plane_g.par_iter())
                .zip(plane_b.par_iter()),
        )
        .for_each(|(px, ((r, g), b))| {
            let a = px[3];
            px[0] = clamp_to_u8_trunc(*b);
            px[1] = clamp_to_u8_trunc(*g);
            px[2] = clamp_to_u8_trunc(*r);
            px[3] = a;
        });

    Ok(())
}

fn validate_inputs(
    len: usize,
    width: usize,
    height: usize,
    r_count: usize,
    g_count: usize,
    b_count: usize,
) -> Result<usize> {
    let pixel_count = width
        .checked_mul(height)
        .ok_or_else(|| anyhow::anyhow!("image size overflow"))?;
    let expected_len = pixel_count
        .checked_mul(4)
        .ok_or_else(|| anyhow::anyhow!("buffer size overflow"))?;

    if len != expected_len {
        bail!(
            "buffer length mismatch: got {}, expected {}",
            len,
            expected_len
        );
    }
    if !(2..=256).contains(&r_count)
        || !(2..=256).contains(&g_count)
        || !(2..=256).contains(&b_count)
    {
        bail!("posterize level counts must be 2..=256");
    }

    Ok(pixel_count)
}

fn build_posterize_lut(r_count: usize, g_count: usize, b_count: usize) -> [[u8; 3]; 256] {
    let mut lut = [[0u8; 3]; 256];

    for (i, channels) in lut.iter_mut().enumerate() {
        channels[0] = quantize_index(i, r_count);
        channels[1] = quantize_index(i, g_count);
        channels[2] = quantize_index(i, b_count);
    }

    lut
}

fn quantize_index(value: usize, levels: usize) -> u8 {
    debug_assert!((2..=256).contains(&levels));
    debug_assert!(value <= 255);

    let steps = levels - 1;
    let bucket = (value * steps + 127) / 255;
    let quantized = (bucket * 255) / steps;

    quantized as u8
}

fn diffuse_plane(
    plane: &mut [f64],
    width: usize,
    height: usize,
    channel_index: usize,
    lut: &[[u8; 3]; 256],
) {
    debug_assert!(channel_index < 3);

    for y in 0..height {
        for x in 0..width {
            let idx = y * width + x;

            let current_index = clamp_to_u8_index(plane[idx]);
            let quantized = f64::from(lut[current_index][channel_index]);
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

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn quantize_index_matches_existing_formula() {
        assert_eq!(quantize_index(0, 2), 0);
        assert_eq!(quantize_index(127, 2), 0);
        assert_eq!(quantize_index(128, 2), 255);
        assert_eq!(quantize_index(85, 4), 85);
        assert_eq!(quantize_index(170, 4), 170);
        assert_eq!(quantize_index(255, 256), 255);
    }

    #[test]
    fn error_diffusion_preserves_alpha_and_quantizes_channels() {
        let mut pixels = vec![
            10, 20, 30, 40, //
            120, 130, 140, 150, //
            220, 230, 240, 250, //
        ];
        let alpha = [pixels[3], pixels[7], pixels[11]];

        posterize_error_diffusion(&mut pixels, 3, 1, 2, 2, 2).unwrap();

        assert_eq!([pixels[3], pixels[7], pixels[11]], alpha);
        for px in pixels.chunks_exact(4) {
            assert!(matches!(px[0], 0 | 255));
            assert!(matches!(px[1], 0 | 255));
            assert!(matches!(px[2], 0 | 255));
        }
    }
}
