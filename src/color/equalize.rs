use anyhow::{Result, anyhow};
use rayon::prelude::*;

const HIST_SIZE: usize = 1021;

pub fn prepare_equalize_lut(
    image_buffer: &[u8],
    width: usize,
    height: usize,
    lut_buffer: &mut [u8],
    lut_width: usize,
    lut_height: usize,
    calc_method: u8,
) -> Result<Vec<f64>> {
    validate_buffer(image_buffer, width, height, "image")?;
    validate_buffer(lut_buffer, lut_width, lut_height, "lut")?;

    if calc_method > 2 {
        return Err(anyhow!("calc_method must be 0, 1, or 2"));
    }

    if lut_width < HIST_SIZE || lut_height == 0 {
        return Err(anyhow!(
            "lut buffer is too small: got {}x{}, expected at least {}x1",
            lut_width,
            lut_height,
            HIST_SIZE
        ));
    }

    lut_buffer.fill(0);

    if width == 0 || height == 0 {
        return Ok(vec![0.0, 255.0, 0.0]);
    }

    let Some((min_v, max_v)) = minmax_opaque(image_buffer, calc_method) else {
        return Ok(vec![0.0, 255.0, 0.0]);
    };

    let range = max_v - min_v;
    if range == 0.0 {
        return Err(anyhow!(
            "equalize failed: min == max for opaque pixels, division by zero would occur"
        ));
    }

    if calc_method == 2 {
        return Ok(vec![min_v, max_v, 1.0]);
    }

    let mut hist = image_buffer
        .par_chunks_exact(4)
        .fold(
            || vec![0.0_f64; HIST_SIZE],
            |mut local_hist, px| {
                if px[3] != 0 {
                    let b = ((px[0] as f64) - min_v) * 255.0 / range;
                    let g = ((px[1] as f64) - min_v) * 255.0 / range;
                    let r = ((px[2] as f64) - min_v) * 255.0 / range;
                    let y = (r * 0.298_912 + g * 0.586_61 + b * 0.114_478) * 4.0;
                    let bucket = (y as usize).min(HIST_SIZE - 1);
                    local_hist[bucket] += 1.0;
                }
                local_hist
            },
        )
        .reduce(
            || vec![0.0_f64; HIST_SIZE],
            |mut left, right| {
                for (left, right) in left.iter_mut().zip(right) {
                    *left += right;
                }
                left
            },
        );

    let first_nonzero = hist
        .iter()
        .position(|&x| x != 0.0)
        .ok_or_else(|| anyhow!("equalize failed: histogram is empty"))?;

    for i in 1..HIST_SIZE {
        hist[i] += hist[i - 1];
    }

    let total = hist[HIST_SIZE - 1];
    if total == 0.0 {
        return Err(anyhow!("equalize failed: histogram total is zero"));
    }

    for value in &mut hist {
        *value = *value * 255.0 / total;
    }

    let cdf_min = hist[first_nonzero];
    let denom = 255.0 - cdf_min;
    if denom == 0.0 {
        return Err(anyhow!(
            "equalize failed: CDF normalization denominator became zero"
        ));
    }

    for value in &mut hist {
        *value = (*value - cdf_min) * 255.0 / denom;
    }

    for (idx, value) in hist.into_iter().enumerate() {
        let encoded = (value.clamp(0.0, 255.0) * 256.0).round() as u32;
        let hi = (encoded / 256).min(255) as u8;
        let lo = (encoded % 256) as u8;
        let offset = idx * 4;
        lut_buffer[offset] = 0;
        lut_buffer[offset + 1] = lo;
        lut_buffer[offset + 2] = hi;
        lut_buffer[offset + 3] = 255;
    }

    Ok(vec![min_v, max_v, 1.0])
}

fn validate_buffer(buffer: &[u8], width: usize, height: usize, name: &str) -> Result<usize> {
    let pixel_count = width
        .checked_mul(height)
        .ok_or_else(|| anyhow!("{name} size overflow"))?;
    let expected_len = pixel_count
        .checked_mul(4)
        .ok_or_else(|| anyhow!("{name} buffer size overflow"))?;

    if buffer.len() != expected_len {
        return Err(anyhow!(
            "{name} buffer length mismatch: got {}, expected {}",
            buffer.len(),
            expected_len
        ));
    }

    Ok(pixel_count)
}

fn minmax_opaque(buffer: &[u8], calc_method: u8) -> Option<(f64, f64)> {
    if calc_method == 1 {
        return Some((0.0, 255.0));
    }

    buffer
        .par_chunks_exact(4)
        .filter(|px| px[3] != 0)
        .map(|px| {
            let b = px[0] as f64;
            let g = px[1] as f64;
            let r = px[2] as f64;
            (b.min(g).min(r), b.max(g).max(r))
        })
        .reduce_with(|left, right| (left.0.min(right.0), left.1.max(right.1)))
}
