use aviutl2::anyhow::{self, Result, bail};
use rayon::prelude::*;

pub(crate) fn calculate_thresholds(
    userdata: &[u8],
    w: usize,
    h: usize,
    r_threshold: u8,
    g_threshold: u8,
    b_threshold: u8,
    auto_detect: u8,
) -> Result<[u8; 3]> {
    validate_inputs(userdata.len(), w, h, auto_detect)?;
    if auto_detect == 0 {
        return Ok([r_threshold, g_threshold, b_threshold]);
    }

    let alpha_mask = userdata
        .chunks_exact(4)
        .map(|pixel| pixel[3])
        .collect::<Vec<u8>>();
    let thresholds = [Channel::R, Channel::G, Channel::B]
        .into_par_iter()
        .map(|channel| auto_threshold_channel(userdata, &alpha_mask, w, h, channel, auto_detect))
        .collect::<Vec<f64>>();

    Ok([
        thresholds[0].round().clamp(0.0, 255.0) as u8,
        thresholds[1].round().clamp(0.0, 255.0) as u8,
        thresholds[2].round().clamp(0.0, 255.0) as u8,
    ])
}

fn validate_inputs(len: usize, w: usize, h: usize, auto_detect: u8) -> Result<usize> {
    if w == 0 || h == 0 {
        bail!("w/h must be > 0");
    }
    let pixels = w
        .checked_mul(h)
        .ok_or_else(|| anyhow::anyhow!("w*h overflow: w={w}, h={h}"))?;
    let needed = pixels
        .checked_mul(4)
        .ok_or_else(|| anyhow::anyhow!("w*h*4 overflow: w={w}, h={h}"))?;
    if len != needed {
        bail!(
            "userdata length mismatch: expected {} bytes ({}x{}x4), got {}",
            needed,
            w,
            h,
            len
        );
    }
    if auto_detect > 6 {
        bail!("auto_detect out of range (expected 0..=6): {auto_detect}");
    }
    Ok(pixels)
}

#[derive(Copy, Clone)]
enum Channel {
    B,
    G,
    R,
}

fn chan_offset(channel: Channel) -> usize {
    match channel {
        Channel::B => 0,
        Channel::G => 1,
        Channel::R => 2,
    }
}

fn auto_threshold_channel(
    userdata: &[u8],
    alpha_mask: &[u8],
    w: usize,
    h: usize,
    channel: Channel,
    method: u8,
) -> f64 {
    let pixels = w * h;
    let offset = chan_offset(channel);

    if method == 5 || method == 6 {
        if w < 3 || h < 3 {
            return mean_threshold_256(userdata, alpha_mask, offset);
        }

        let score = (1..(h - 1))
            .into_par_iter()
            .map(|y| {
                let mut local = vec![0.0f64; 256];
                for x in 1..(w - 1) {
                    let idx = y * w + x;
                    if alpha_mask[idx] == 0 {
                        continue;
                    }

                    let base = idx * 4;
                    let value = userdata[base + offset] as usize;

                    let idx_l = idx - 1;
                    let idx_r = idx + 1;
                    let idx_u = idx - w;
                    let idx_d = idx + w;

                    let vl = userdata[idx_l * 4 + offset] as f64;
                    let vr = userdata[idx_r * 4 + offset] as f64;
                    let vu = userdata[idx_u * 4 + offset] as f64;
                    let vd = userdata[idx_d * 4 + offset] as f64;
                    let vc = userdata[base + offset] as f64;

                    let weight = if method == 5 {
                        let d1 = (vr - vc).abs();
                        let d2 = (vl - vc).abs();
                        let d3 = (vu - vc).abs();
                        let d4 = (vd - vc).abs();
                        d1.max(d2).max(d3).max(d4)
                    } else {
                        (vc * 4.0 - (vl + vr + vu + vd)).abs()
                    };

                    local[value] += weight;
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
            );

        let mut best_i = 0usize;
        let mut best_v = score[0];
        for (i, &score) in score.iter().enumerate().skip(1) {
            if score > best_v {
                best_v = score;
                best_i = i;
            }
        }
        return best_i as f64;
    }

    let (hist, count) = (0..pixels)
        .into_par_iter()
        .fold(
            || (vec![0u32; 256], 0u64),
            |(mut hist, mut count), idx| {
                if alpha_mask[idx] != 0 {
                    let value = userdata[idx * 4 + offset] as usize;
                    hist[value] += 1;
                    count += 1;
                }
                (hist, count)
            },
        )
        .reduce(
            || (vec![0u32; 256], 0u64),
            |(mut lhs_hist, lhs_count), (rhs_hist, rhs_count)| {
                for (lhs_value, rhs_value) in lhs_hist.iter_mut().zip(rhs_hist) {
                    *lhs_value += rhs_value;
                }
                (lhs_hist, lhs_count + rhs_count)
            },
        );
    if count == 0 {
        return 0.0;
    }

    match method {
        1 => mean_from_hist(&hist, count),
        2 => median_from_hist(&hist, count),
        3 => otsu_from_hist(&hist, count),
        4 => kittler_illingworth_from_hist(&hist, count),
        _ => unreachable!("auto_detect validated to 0..=6"),
    }
}

fn mean_threshold_256(userdata: &[u8], alpha_mask: &[u8], offset: usize) -> f64 {
    let mut sum: u64 = 0;
    let mut count: u64 = 0;
    for (idx, &alpha) in alpha_mask.iter().enumerate() {
        if alpha == 0 {
            continue;
        }
        sum += userdata[idx * 4 + offset] as u64;
        count += 1;
    }
    if count == 0 {
        0.0
    } else {
        (sum as f64) / (count as f64)
    }
}

fn mean_from_hist(hist: &[u32], count: u64) -> f64 {
    let mut sum = 0.0;
    for (i, &value_count) in hist.iter().enumerate() {
        sum += (i as f64) * (value_count as f64);
    }
    sum / (count as f64)
}

fn median_from_hist(hist: &[u32], count: u64) -> f64 {
    let half = (count as f64) * 0.5;
    let mut cumulative: u64 = 0;
    for (i, &value_count) in hist.iter().enumerate() {
        cumulative += value_count as u64;
        if (cumulative as f64) >= half {
            return i as f64;
        }
    }
    255.0
}

fn otsu_from_hist(hist: &[u32], count: u64) -> f64 {
    let total = count as f64;
    let mut sum_total = 0.0;
    for (i, &value_count) in hist.iter().enumerate() {
        sum_total += (i as f64) * (value_count as f64);
    }

    let mut sum_background = 0.0;
    let mut weight_background = 0.0;
    let mut best_threshold = 0usize;
    let mut best_variance = -1.0f64;

    for (threshold, &value_count) in hist.iter().enumerate() {
        let value_count = value_count as f64;
        weight_background += value_count;
        if weight_background == 0.0 {
            continue;
        }

        let weight_foreground = total - weight_background;
        if weight_foreground == 0.0 {
            break;
        }

        sum_background += (threshold as f64) * value_count;
        let mean_background = sum_background / weight_background;
        let mean_foreground = (sum_total - sum_background) / weight_foreground;
        let between = weight_background
            * weight_foreground
            * (mean_background - mean_foreground)
            * (mean_background - mean_foreground);

        if between > best_variance {
            best_variance = between;
            best_threshold = threshold;
        }
    }

    best_threshold as f64
}

fn kittler_illingworth_from_hist(hist: &[u32], count: u64) -> f64 {
    let total = count as f64;

    let mut pref_c = vec![0.0f64; hist.len() + 1];
    let mut pref_s = vec![0.0f64; hist.len() + 1];
    let mut pref_s2 = vec![0.0f64; hist.len() + 1];

    for (i, &value_count) in hist.iter().enumerate() {
        let value_count = value_count as f64;
        let value = i as f64;
        pref_c[i + 1] = pref_c[i] + value_count;
        pref_s[i + 1] = pref_s[i] + value_count * value;
        pref_s2[i + 1] = pref_s2[i] + value_count * value * value;
    }

    let eps = 1e-12;
    let mut best_threshold = 0usize;
    let mut best_score = f64::INFINITY;

    for threshold in 1..(hist.len() - 1) {
        let class1 = pref_c[threshold + 1];
        let class2 = total - class1;
        if class1 <= 0.0 || class2 <= 0.0 {
            continue;
        }

        let p1 = class1 / total;
        let p2 = class2 / total;
        let mean1 = pref_s[threshold + 1] / class1;
        let mean2 = (pref_s[hist.len()] - pref_s[threshold + 1]) / class2;
        let var1 = (pref_s2[threshold + 1] / class1) - mean1 * mean1;
        let var2 = ((pref_s2[hist.len()] - pref_s2[threshold + 1]) / class2) - mean2 * mean2;
        let sigma1 = var1.max(0.0).sqrt().max(eps);
        let sigma2 = var2.max(0.0).sqrt().max(eps);

        let score = 1.0 + 2.0 * (p1 * sigma1.ln() + p2 * sigma2.ln())
            - 2.0 * (p1.max(eps).ln() * p1 + p2.max(eps).ln() * p2);
        if score < best_score {
            best_score = score;
            best_threshold = threshold;
        }
    }

    best_threshold as f64
}
