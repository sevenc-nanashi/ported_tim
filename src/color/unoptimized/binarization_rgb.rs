/// Port of `T_Color_Module.binarizationRGB(userdata, w, h, r_th, g_th, b_th, auto_detect)`
///
/// Assumptions (from the disassembly):
/// - `userdata` is BGRA (bytes: B,G,R,A) for each pixel, little-endian layout in memory.
/// - Output is per-channel binary: for each channel independently, set to 255 if (value > threshold) else 0.
/// - `auto_detect > 0` recomputes the threshold per-channel using only pixels whose alpha != 0 as a mask.
/// - Single-threaded.
/// - Abort (panic) on invalid inputs (length mismatch, invalid auto_detect, etc.).
pub fn binarization_rgb(
    userdata: &mut [u8],
    w: usize,
    h: usize,
    r_threshold: u8,
    g_threshold: u8,
    b_threshold: u8,
    auto_detect: u8,
) {
    let pixels = w
        .checked_mul(h)
        .unwrap_or_else(|| panic!("w*h overflow: w={w}, h={h}"));
    let need_len = pixels
        .checked_mul(4)
        .unwrap_or_else(|| panic!("w*h*4 overflow: w={w}, h={h}"));

    if userdata.len() < need_len {
        panic!(
            "userdata too short: need {} bytes ({}x{}x4), got {}",
            need_len,
            w,
            h,
            userdata.len()
        );
    }
    if w == 0 || h == 0 {
        return;
    }
    if auto_detect > 6 {
        panic!("auto_detect out of range (expected 0..=6): {auto_detect}");
    }

    // Pre-extract alpha mask (A != 0) used only for auto-thresholding.
    let mut alpha_mask = vec![0u8; pixels];
    for i in 0..pixels {
        alpha_mask[i] = userdata[i * 4 + 3];
    }

    // Compute per-channel thresholds (f64 for parity with the C code's doubles).
    let (mut thr_r, mut thr_g, mut thr_b) =
        (r_threshold as f64, g_threshold as f64, b_threshold as f64);

    if auto_detect > 0 {
        thr_r = auto_threshold_channel(userdata, &alpha_mask, w, h, Channel::R, auto_detect);
        thr_g = auto_threshold_channel(userdata, &alpha_mask, w, h, Channel::G, auto_detect);
        thr_b = auto_threshold_channel(userdata, &alpha_mask, w, h, Channel::B, auto_detect);
    }

    // Apply: if (value > threshold) set channel to 255 else 0 (no alpha masking during apply).
    for i in 0..pixels {
        let base = i * 4;

        // BGRA
        let b = userdata[base] as f64;
        let g = userdata[base + 1] as f64;
        let r = userdata[base + 2] as f64;

        userdata[base + 2] = if r > thr_r { 255 } else { 0 };
        userdata[base + 1] = if g > thr_g { 255 } else { 0 };
        userdata[base] = if b > thr_b { 255 } else { 0 };
    }
}

#[derive(Copy, Clone)]
enum Channel {
    B,
    G,
    R,
}

fn chan_offset(c: Channel) -> usize {
    match c {
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
    ch: Channel,
    method: u8, // 1..=6
) -> f64 {
    let pixels = w * h;
    let off = chan_offset(ch);

    // Methods 5/6: edge/second-derivative accumulators over intensity 0..255.
    if method == 5 || method == 6 {
        if w < 3 || h < 3 {
            // No interior pixels. Fall back to a simple statistic on masked pixels.
            return mean_threshold_256(userdata, alpha_mask, off);
        }

        let mut score = [0f64; 256];

        for y in 1..(h - 1) {
            for x in 1..(w - 1) {
                let idx = y * w + x;
                if alpha_mask[idx] == 0 {
                    continue;
                }

                let base = idx * 4;
                let v = userdata[base + off] as usize;

                let idx_l = idx - 1;
                let idx_r = idx + 1;
                let idx_u = idx - w;
                let idx_d = idx + w;

                let vl = userdata[idx_l * 4 + off] as f64;
                let vr = userdata[idx_r * 4 + off] as f64;
                let vu = userdata[idx_u * 4 + off] as f64;
                let vd = userdata[idx_d * 4 + off] as f64;
                let vc = userdata[base + off] as f64;

                let s = if method == 5 {
                    // Approximation of the disassembly's max-of-neighbor diffs.
                    let d1 = (vr - vc).abs();
                    let d2 = (vl - vc).abs();
                    let d3 = (vu - vc).abs();
                    let d4 = (vd - vc).abs();
                    d1.max(d2).max(d3).max(d4)
                } else {
                    // Approximation of abs(center*4 - (left+right+up+down)).
                    (vc * 4.0 - (vl + vr + vu + vd)).abs()
                };

                score[v] += s;
            }
        }

        // Return argmax intensity (0..255).
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

    // Methods 1..4: histogram/statistics over masked pixels.
    // Use 256-bin histogram on intensity 0..255 (the C code used 0..1020 with *0.25 scaling).
    let mut hist = [0u32; 256];
    let mut n: u64 = 0;
    for i in 0..pixels {
        if alpha_mask[i] == 0 {
            continue;
        }
        let v = userdata[i * 4 + off] as usize;
        hist[v] += 1;
        n += 1;
    }
    if n == 0 {
        return 0.0;
    }

    match method {
        1 => mean_from_hist(&hist, n),
        2 => median_from_hist(&hist, n),
        3 => otsu_from_hist(&hist, n),
        4 => kittler_illingworth_from_hist(&hist, n),
        _ => panic!("unreachable: method={method}"),
    }
}

fn mean_threshold_256(userdata: &[u8], alpha_mask: &[u8], off: usize) -> f64 {
    let mut sum: u64 = 0;
    let mut n: u64 = 0;
    for i in 0..alpha_mask.len() {
        if alpha_mask[i] == 0 {
            continue;
        }
        sum += userdata[i * 4 + off] as u64;
        n += 1;
    }
    if n == 0 {
        0.0
    } else {
        (sum as f64) / (n as f64)
    }
}

fn mean_from_hist(hist: &[u32; 256], n: u64) -> f64 {
    let mut sum = 0f64;
    for (i, &c) in hist.iter().enumerate() {
        sum += (i as f64) * (c as f64);
    }
    sum / (n as f64)
}

fn median_from_hist(hist: &[u32; 256], n: u64) -> f64 {
    let half = (n as f64) * 0.5;
    let mut cum: u64 = 0;
    for i in 0..256 {
        cum += hist[i] as u64;
        if (cum as f64) >= half {
            return i as f64;
        }
    }
    255.0
}

fn otsu_from_hist(hist: &[u32; 256], n: u64) -> f64 {
    // Standard Otsu on 256 bins.
    let n_f = n as f64;

    let mut sum_total = 0f64;
    for i in 0..256 {
        sum_total += (i as f64) * (hist[i] as f64);
    }

    let mut sum_b = 0f64;
    let mut w_b = 0f64;
    let mut best_t = 0usize;
    let mut best_var = -1.0f64;

    for t in 0..256 {
        let h = hist[t] as f64;
        w_b += h;
        if w_b == 0.0 {
            continue;
        }

        let w_f = n_f - w_b;
        if w_f == 0.0 {
            break;
        }

        sum_b += (t as f64) * h;

        let m_b = sum_b / w_b;
        let m_f = (sum_total - sum_b) / w_f;

        let between = w_b * w_f * (m_b - m_f) * (m_b - m_f);
        if between > best_var {
            best_var = between;
            best_t = t;
        }
    }

    best_t as f64
}

fn kittler_illingworth_from_hist(hist: &[u32; 256], n: u64) -> f64 {
    // Kittler-Illingworth minimum error threshold (common discrete formulation).
    // We minimize:
    // J(t) = 1 + 2*(p1*ln(s1) + p2*ln(s2)) - 2*(p1*ln(p1) + p2*ln(p2))
    // where p1,p2 are class probabilities and s1,s2 are class stddevs.
    let n_f = n as f64;

    // Prefix sums for counts, sums, and squared sums.
    let mut pref_c = [0f64; 257];
    let mut pref_s = [0f64; 257];
    let mut pref_s2 = [0f64; 257];

    for i in 0..256 {
        let c = hist[i] as f64;
        let x = i as f64;
        pref_c[i + 1] = pref_c[i] + c;
        pref_s[i + 1] = pref_s[i] + c * x;
        pref_s2[i + 1] = pref_s2[i] + c * x * x;
    }

    let eps = 1e-12;
    let mut best_t = 0usize;
    let mut best_j = f64::INFINITY;

    for t in 1..255 {
        let c1 = pref_c[t + 1];
        let c2 = n_f - c1;
        if c1 <= 0.0 || c2 <= 0.0 {
            continue;
        }

        let p1 = c1 / n_f;
        let p2 = c2 / n_f;

        let m1 = pref_s[t + 1] / c1;
        let m2 = (pref_s[256] - pref_s[t + 1]) / c2;

        let v1 = (pref_s2[t + 1] / c1) - m1 * m1;
        let v2 = ((pref_s2[256] - pref_s2[t + 1]) / c2) - m2 * m2;

        let s1 = v1.max(0.0).sqrt().max(eps);
        let s2 = v2.max(0.0).sqrt().max(eps);

        let j = 1.0 + 2.0 * (p1 * s1.ln() + p2 * s2.ln())
            - 2.0 * (p1.max(eps).ln() * p1 + p2.max(eps).ln() * p2);

        if j < best_j {
            best_j = j;
            best_t = t;
        }
    }

    best_t as f64
}
