use anyhow::{Result, anyhow};

const HIST_SIZE: usize = 1021;

pub fn equalize(buffer: &mut [u8], width: usize, height: usize, calc_method: u8) -> Result<()> {
    let pixel_count = width
        .checked_mul(height)
        .ok_or_else(|| anyhow!("image size overflow"))?;

    if pixel_count == 0 {
        return Ok(());
    }

    let expected_len = pixel_count
        .checked_mul(4)
        .ok_or_else(|| anyhow!("buffer size overflow"))?;

    if buffer.len() != expected_len {
        return Err(anyhow!(
            "buffer length mismatch: got {}, expected {}",
            buffer.len(),
            expected_len
        ));
    }

    let (min_v, max_v) = match calc_method {
        1 => (0.0_f64, 255.0_f64),
        0 => {
            let mut min_v = 255.0_f64;
            let mut max_v = 0.0_f64;
            let mut has_opaque = false;

            for px in buffer.chunks_exact(4) {
                let b: u8 = px[0];
                let g: u8 = px[1];
                let r: u8 = px[2];
                let a: u8 = px[3];

                if a == 0 {
                    continue;
                }

                has_opaque = true;

                let bf = b as f64;
                let gf = g as f64;
                let rf = r as f64;

                min_v = min_v.min(bf).min(gf).min(rf);
                max_v = max_v.max(bf).max(gf).max(rf);
            }

            if !has_opaque {
                return Ok(());
            }

            (min_v, max_v)
        }
        _ => unreachable!("validated by macros: calc_method must be 0 or 1"),
    };

    let range = max_v - min_v;
    if range == 0.0 {
        return Err(anyhow!(
            "equalize failed: min == max for opaque pixels, division by zero would occur"
        ));
    }

    let mut u_buf = vec![0.0_f64; pixel_count];
    let mut v_buf = vec![0.0_f64; pixel_count];
    let mut y_buf = vec![0.0_f64; pixel_count];
    let mut hist = vec![0.0_f64; HIST_SIZE];

    for (idx, px) in buffer.chunks_exact(4).enumerate() {
        let b: u8 = px[0];
        let g: u8 = px[1];
        let r: u8 = px[2];
        let a: u8 = px[3];

        if a == 0 {
            continue;
        }

        let b_scaled = ((b as f64) - min_v) * 255.0 / range;
        let g_scaled = ((g as f64) - min_v) * 255.0 / range;
        let r_scaled = ((r as f64) - min_v) * 255.0 / range;

        let y = (r_scaled * 0.298_912 + g_scaled * 0.586_61 + b_scaled * 0.114_478) * 4.0;
        let u = b_scaled * 0.436 - (g_scaled * 0.289 + r_scaled * 0.147);
        let v = r_scaled * 0.615 - g_scaled * 0.515 - b_scaled * 0.1;

        y_buf[idx] = y;
        u_buf[idx] = u;
        v_buf[idx] = v;

        let bucket = (y as usize).min(HIST_SIZE - 1);
        hist[bucket] += 1.0;
    }

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

    for (idx, px) in buffer.chunks_exact_mut(4).enumerate() {
        let a: u8 = px[3];
        if a == 0 {
            continue;
        }

        let y = y_buf[idx];
        let u = u_buf[idx];
        let v = v_buf[idx];

        let y_floor = y.floor() as usize;
        let y0 = y_floor.min(HIST_SIZE - 1);
        let y1 = (y_floor + 1).min(HIST_SIZE - 1);
        let frac = y - (y_floor as f64);

        let y_eq = (1.0 - frac) * hist[y0] + frac * hist[y1];

        let r = clamp_to_u8(y_eq + v * 1.14);
        let g = clamp_to_u8(y_eq - u * 0.394 - v * 0.581);
        let b = clamp_to_u8(y_eq + u * 2.032);

        px[0] = b;
        px[1] = g;
        px[2] = r;
        px[3] = a;
    }

    Ok(())
}

#[inline]
fn clamp_to_u8(v: f64) -> u8 {
    if v <= 0.0 {
        0
    } else if v >= 255.0 {
        255
    } else {
        v as u8
    }
}
/// `equalize_rgb_impl` 相当
pub fn equalize_rgb(buffer: &mut [u8], width: usize, height: usize) -> Result<()> {
    let pixel_count = width
        .checked_mul(height)
        .ok_or_else(|| anyhow!("image size overflow"))?;

    if pixel_count == 0 {
        return Ok(());
    }

    let mut min_v = 255.0_f64;
    let mut max_v = 0.0_f64;
    let mut has_opaque = false;

    for px in buffer.chunks_exact(4) {
        let b: u8 = px[0];
        let g: u8 = px[1];
        let r: u8 = px[2];
        let a: u8 = px[3];

        if a == 0 {
            continue;
        }
        has_opaque = true;

        let rf = r as f64;
        let gf = g as f64;
        let bf = b as f64;

        min_v = min_v.min(rf).min(gf).min(bf);
        max_v = max_v.max(rf).max(gf).max(bf);
    }

    if !has_opaque {
        return Ok(());
    }

    let range = max_v - min_v;
    if range == 0.0 {
        return Err(anyhow!(
            "equalize_rgb failed: min == max for opaque pixels, division by zero would occur"
        ));
    }

    // sub_10015470 相当
    for px in buffer.chunks_exact_mut(4) {
        let a: u8 = px[3];
        if a == 0 {
            continue;
        }

        let b = (((px[0] as f64) - min_v) * 255.0 / range).clamp(0.0, 255.0) as u8;
        let g = (((px[1] as f64) - min_v) * 255.0 / range).clamp(0.0, 255.0) as u8;
        let r = (((px[2] as f64) - min_v) * 255.0 / range).clamp(0.0, 255.0) as u8;

        px[0] = b;
        px[1] = g;
        px[2] = r;
        px[3] = a;
    }

    Ok(())
}
