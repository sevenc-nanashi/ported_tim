use aviutl2::anyhow::{self, Result, bail};

/// Single-threaded port of Lua-callable `T_Color_Module.binarization(...)`.
///
/// Lua parameter order (same as original):
/// 1) userdata  -> `&mut [u8]` (BGRA, 4 bytes/pixel)
/// 2) w         -> `u32`
/// 3) h         -> `u32`
/// 4) threshold -> `u32` (0..255)  [used only when auto_detect==0]
/// 5) gray_proc -> `u32` (0..2)
/// 6) auto_det  -> `u32` (0..6)
/// 7) check0    -> `bool`
/// 8) col1      -> `u32` (0xRRGGBB)
/// 9) col2      -> `u32` (0xRRGGBB)
///
/// Buffers:
/// - Input/Output is BGRA bytes.
/// - We preserve the original A.
/// - Colors (col1/col2) are interpreted as 0xRRGGBB and written into BGRA output.
pub fn binarization(
    userdata: &mut [u8],
    w: usize,
    h: usize,
    track_threshold: u8,
    track_gray_process: u8,
    track_auto_detect: u8,
    check0: bool,
    col1: u32,
    col2: u32,
) -> Result<()> {
    if w == 0 || h == 0 {
        bail!("w/h must be > 0");
    }
    let px_count = w
        .checked_mul(h)
        .ok_or_else(|| anyhow::anyhow!("w*h overflow"))?;
    let needed = px_count
        .checked_mul(4)
        .ok_or_else(|| anyhow::anyhow!("pixel byte size overflow"))?;
    if userdata.len() != needed {
        bail!(
            "userdata length mismatch: expected {} bytes (w*h*4), got {}",
            needed,
            userdata.len()
        );
    }

    if track_gray_process > 2 {
        bail!("track_gray_process must be 0..2");
    }
    if track_auto_detect > 6 {
        bail!("track_auto_detect must be 0..6");
    }

    // If not colorizing, force (bright=white, dark=black) like the C.
    let (bright_rgb, dark_rgb) = if check0 {
        (col1 & 0x00FF_FFFF, col2 & 0x00FF_FFFF)
    } else {
        (0x00FF_FFFF, 0x0000_0000)
    };

    // --- Step 1: grayscale buffer (f64, like C double) ---
    let mut gray: Vec<f64> = vec![0.0; px_count];

    for i in 0..px_count {
        // BGRA input
        let b = userdata[i * 4 + 0] as f64;
        let g = userdata[i * 4 + 1] as f64;
        let r = userdata[i * 4 + 2] as f64;

        let v = match track_gray_process {
            0 => (r + g + b) / 3.0,
            1 => r * 0.298_912 + g * 0.586_61 + b * 0.114_478,
            2 => {
                // Decomp math:
                // v16 = 255 * pow( pow(B/255,2.2)*0.07133
                //              + pow(G/255,2.2)*0.706655
                //              + pow(R/255,2.2)*0.222015, 1/2.2 )
                let inv255 = 1.0 / 255.0;
                let rgb_lin = (b * inv255).powf(2.2) * 0.071_33
                    + (g * inv255).powf(2.2) * 0.706_655
                    + (r * inv255).powf(2.2) * 0.222_015;
                255.0 * rgb_lin.powf(1.0 / 2.2)
            }
            _ => unreachable!("track_gray_process validated to 0..=2"),
        };

        gray[i] = v.clamp(0.0, 255.0);
    }

    // --- Step 2: threshold ---
    let threshold = if track_auto_detect == 0 {
        track_threshold as f64
    } else {
        auto_threshold(w, h, &gray, userdata, track_auto_detect)?
    };

    // --- Step 3: apply binarization, preserve alpha, write BGRA ---
    for i in 0..px_count {
        let a = userdata[i * 4 + 3];

        // C logic: if (*a5 < gray[i]) choose a3 else a4, where a3=dark, a4=bright in the call site.
        // Our threshold is `threshold`; choose bright if gray > threshold.
        let rgb = if threshold < gray[i] {
            bright_rgb
        } else {
            dark_rgb
        };

        // rgb is 0xRRGGBB; write BGRA.
        userdata[i * 4] = (rgb & 0xFF) as u8; // B
        userdata[i * 4 + 1] = ((rgb >> 8) & 0xFF) as u8; // G
        userdata[i * 4 + 2] = ((rgb >> 16) & 0xFF) as u8; // R
        userdata[i * 4 + 3] = a; // preserve A
    }

    Ok(())
}

fn auto_threshold(w: usize, h: usize, gray: &[f64], pixels_bgra: &[u8], mode: u8) -> Result<f64> {
    if gray.len() != w * h || pixels_bgra.len() != w * h * 4 {
        bail!("auto_threshold: buffer size mismatch");
    }

    #[inline(always)]
    fn alpha_nonzero(p: &[u8], idx: usize) -> bool {
        p[idx * 4 + 3] != 0
    }

    // Modes 5/6: per-intensity "energy" accumulation on 0..255 bins then argmax.
    if mode == 5 || mode == 6 {
        let mut energy = [0.0f64; 256];

        if w >= 3 && h >= 3 {
            for y in 1..(h - 1) {
                for x in 1..(w - 1) {
                    let idx = y * w + x;
                    if !alpha_nonzero(pixels_bgra, idx) {
                        continue;
                    }

                    let c = gray[idx];
                    let l = gray[idx - 1];
                    let r = gray[idx + 1];
                    let u = gray[idx - w];
                    let d = gray[idx + w];

                    let e = if mode == 5 {
                        // Closest practical reading of the decompiled max-of-neighbor-diffs logic.
                        (c - l)
                            .abs()
                            .max((c - r).abs())
                            .max((c - u).abs())
                            .max((c - d).abs())
                    } else {
                        // mode == 6: Laplacian magnitude (matches decompiled intent).
                        (4.0 * c - (l + r + u + d)).abs()
                    };

                    let bin = c.round().clamp(0.0, 255.0) as usize;
                    energy[bin] += e;
                }
            }
        }

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

    // Histogram modes: 0.25-step bins => 1021 bins (0..255.0 with quarter steps).
    const BINS: usize = 1021;
    let mut hist = [0u32; BINS];
    let mut count: u32 = 0;

    for idx in 0..(w * h) {
        if !alpha_nonzero(pixels_bgra, idx) {
            continue;
        }
        let b = (gray[idx] * 4.0).floor() as i32;
        let b = b.clamp(0, (BINS - 1) as i32) as usize;
        hist[b] += 1;
        count += 1;
    }

    if count == 0 {
        return Ok(0.0);
    }

    let mut cdf = [0u32; BINS];
    {
        let mut run = 0u32;
        for i in 0..BINS {
            run = run.wrapping_add(hist[i]);
            cdf[i] = run;
        }
    }

    match mode {
        1 => {
            // Mean bin index * 0.25
            let mut sum = 0f64;
            for i in 0..BINS {
                sum += (hist[i] as f64) * (i as f64);
            }
            Ok((sum / (count as f64)) * 0.25)
        }
        2 => {
            // Median (CDF) with simple interpolation.
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
            // Otsu on quarter-step bins.
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
            // Kittler-Illingworth-like criterion (log-based), consistent with the decompiled structure.
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

                if best_score.map_or(true, |bs| score > bs) {
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
