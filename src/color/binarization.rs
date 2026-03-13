use aviutl2::anyhow::{self, Result, bail};
use rayon::prelude::*;

pub(crate) fn calculate_threshold(
    userdata: &[u8],
    w: usize,
    h: usize,
    track_threshold: u8,
    track_gray_process: u8,
    track_auto_detect: u8,
) -> Result<f64> {
    let px_count = validate_inputs(userdata.len(), w, h, track_gray_process, track_auto_detect)?;
    if track_auto_detect == 0 {
        return Ok(track_threshold as f64);
    }

    let mut gray = vec![0.0; px_count];
    fill_grayscale_buffer_parallel(userdata, &mut gray, track_gray_process);
    auto_threshold_parallel(w, h, &gray, userdata, track_auto_detect)
}

pub(crate) fn grayscale_value(r: f64, g: f64, b: f64, track_gray_process: u8) -> f64 {
    match track_gray_process {
        0 => (r + g + b) / 3.0,
        1 => r * 0.298_912 + g * 0.586_61 + b * 0.114_478,
        2 => {
            let inv255 = 1.0 / 255.0;
            let rgb_lin = (b * inv255).powf(2.2) * 0.071_33
                + (g * inv255).powf(2.2) * 0.706_655
                + (r * inv255).powf(2.2) * 0.222_015;
            255.0 * rgb_lin.powf(1.0 / 2.2)
        }
        _ => unreachable!("track_gray_process validated to 0..=2"),
    }
}

pub(crate) fn validate_inputs(
    len: usize,
    w: usize,
    h: usize,
    track_gray_process: u8,
    track_auto_detect: u8,
) -> Result<usize> {
    if w == 0 || h == 0 {
        bail!("w/h must be > 0");
    }
    let px_count = w
        .checked_mul(h)
        .ok_or_else(|| anyhow::anyhow!("w*h overflow"))?;
    let needed = px_count
        .checked_mul(4)
        .ok_or_else(|| anyhow::anyhow!("pixel byte size overflow"))?;
    if len != needed {
        bail!(
            "userdata length mismatch: expected {} bytes (w*h*4), got {}",
            needed,
            len
        );
    }
    if track_gray_process > 2 {
        bail!("track_gray_process must be 0..2");
    }
    if track_auto_detect > 6 {
        bail!("track_auto_detect must be 0..6");
    }

    Ok(px_count)
}

fn fill_grayscale_buffer_parallel(userdata: &[u8], gray: &mut [f64], track_gray_process: u8) {
    userdata
        .par_chunks_exact(4)
        .zip(gray.par_iter_mut())
        .for_each(|(pixel, gray_value)| {
            let b = pixel[0] as f64;
            let g = pixel[1] as f64;
            let r = pixel[2] as f64;
            *gray_value = grayscale_value(r, g, b, track_gray_process).clamp(0.0, 255.0);
        });
}

fn auto_threshold_parallel(
    w: usize,
    h: usize,
    gray: &[f64],
    pixels_bgra: &[u8],
    mode: u8,
) -> Result<f64> {
    if gray.len() != w * h || pixels_bgra.len() != w * h * 4 {
        bail!("auto_threshold: buffer size mismatch");
    }

    if mode == 5 || mode == 6 {
        let energy = if w >= 3 && h >= 3 {
            (1..(h - 1))
                .into_par_iter()
                .map(|y| {
                    let mut local = vec![0.0f64; 256];
                    for x in 1..(w - 1) {
                        let idx = y * w + x;
                        if pixels_bgra[idx * 4 + 3] == 0 {
                            continue;
                        }

                        let c = gray[idx];
                        let l = gray[idx - 1];
                        let r = gray[idx + 1];
                        let u = gray[idx - w];
                        let d = gray[idx + w];

                        let energy = if mode == 5 {
                            (c - l)
                                .abs()
                                .max((c - r).abs())
                                .max((c - u).abs())
                                .max((c - d).abs())
                        } else {
                            (4.0 * c - (l + r + u + d)).abs()
                        };

                        let bin = c.round().clamp(0.0, 255.0) as usize;
                        local[bin] += energy;
                    }
                    local
                })
                .reduce(
                    || vec![0.0f64; 256],
                    |mut lhs, rhs| {
                        for (lhs_value, rhs_value) in lhs.iter_mut().zip(rhs) {
                            *lhs_value += rhs_value;
                        }
                        lhs
                    },
                )
        } else {
            vec![0.0f64; 256]
        };

        let mut best_i = 0usize;
        let mut best_v = energy[0];
        for (i, &energy) in energy.iter().enumerate().skip(1) {
            if energy > best_v {
                best_v = energy;
                best_i = i;
            }
        }
        return Ok(best_i as f64);
    }

    const BINS: usize = 1021;
    let (hist, count) = gray
        .par_iter()
        .zip(pixels_bgra.par_chunks_exact(4))
        .fold(
            || (vec![0u32; BINS], 0u32),
            |(mut hist, mut count), (gray_value, pixel)| {
                if pixel[3] != 0 {
                    let bin = (gray_value * 4.0).floor() as i32;
                    let bin = bin.clamp(0, (BINS - 1) as i32) as usize;
                    hist[bin] += 1;
                    count += 1;
                }
                (hist, count)
            },
        )
        .reduce(
            || (vec![0u32; BINS], 0u32),
            |(mut lhs_hist, lhs_count), (rhs_hist, rhs_count)| {
                for (lhs_value, rhs_value) in lhs_hist.iter_mut().zip(rhs_hist) {
                    *lhs_value += rhs_value;
                }
                (lhs_hist, lhs_count + rhs_count)
            },
        );

    if count == 0 {
        return Ok(0.0);
    }

    let mut cdf = vec![0u32; BINS];
    {
        let mut run = 0u32;
        for i in 0..BINS {
            run = run.wrapping_add(hist[i]);
            cdf[i] = run;
        }
    }

    match mode {
        1 => {
            let mut sum = 0f64;
            for i in 0..BINS {
                sum += (hist[i] as f64) * (i as f64);
            }
            Ok((sum / (count as f64)) * 0.25)
        }
        2 => {
            let half = (count as f64) * 0.5;
            let mut i = 0usize;
            while i < BINS && (cdf[i] as f64) < half {
                i += 1;
            }
            if i == 0 {
                return Ok(0.0);
            }
            let c_i = cdf[i] as f64;
            let c_prev = cdf[i - 1] as f64;
            let denom = (c_i - c_prev).max(1.0);
            let t = (i as f64 - 1.0) + (half - c_prev) / denom;
            Ok(t * 0.25)
        }
        3 => {
            let total = count as f64;
            let mut sum_all = 0.0;
            for i in 0..BINS {
                sum_all += (i as f64) * (hist[i] as f64);
            }

            let mut sum_b = 0.0;
            let mut w_b = 0.0;
            let mut best_t = 0usize;
            let mut best_var = -1.0f64;

            for t in 0..(BINS - 1) {
                w_b += hist[t] as f64;
                sum_b += (t as f64) * (hist[t] as f64);

                if w_b <= 0.0 {
                    continue;
                }
                let w_f = total - w_b;
                if w_f <= 0.0 {
                    break;
                }

                let m_b = sum_b / w_b;
                let m_f = (sum_all - sum_b) / w_f;

                let between = w_b * w_f * (m_b - m_f) * (m_b - m_f);
                if between > best_var {
                    best_var = between;
                    best_t = t;
                }
            }

            Ok((best_t as f64) * 0.25)
        }
        4 => {
            let total = count as f64;

            let mut pw = vec![0.0f64; BINS + 1];
            let mut ps = vec![0.0f64; BINS + 1];
            let mut ps2 = vec![0.0f64; BINS + 1];

            for i in 0..BINS {
                let w_i = hist[i] as f64;
                let x = i as f64;
                pw[i + 1] = pw[i] + w_i;
                ps[i + 1] = ps[i] + w_i * x;
                ps2[i + 1] = ps2[i] + w_i * x * x;
            }

            let mut best_t = 0usize;
            let mut best_score: Option<f64> = None;

            for t in 0..(BINS - 1) {
                let w0 = pw[t + 1];
                let w1 = total - w0;
                if w0 <= 0.0 || w1 <= 0.0 {
                    continue;
                }

                let s0 = ps[t + 1];
                let s1 = ps[BINS] - s0;
                let s20 = ps2[t + 1];
                let s21 = ps2[BINS] - s20;

                let m0 = s0 / w0;
                let m1 = s1 / w1;

                let v0 = (s20 / w0) - m0 * m0;
                let v1 = (s21 / w1) - m1 * m1;

                let sigma0 = v0.max(1e-12).sqrt();
                let sigma1 = v1.max(1e-12).sqrt();

                let score = w0 * (sigma0 / w0).ln() + w1 * (sigma1 / w1).ln();
                if best_score.is_none_or(|current| score > current) {
                    best_score = Some(score);
                    best_t = t;
                }
            }

            Ok((best_t as f64) * 0.25)
        }
        5 | 6 => unreachable!("mode 5/6 handled earlier"),
        _ => unreachable!("track_auto_detect validated to 0..=6"),
    }
}
