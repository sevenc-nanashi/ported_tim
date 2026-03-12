use anyhow::{Result, anyhow};

#[inline]
fn clamp_u8(x: f64) -> u8 {
    if x <= 0.0 {
        0
    } else if x >= 255.0 {
        255
    } else {
        x as u8
    }
}

/// Port of the Lua-callable `T_Color_Module.BiasDeletion(...)`, single-threaded.
/// - Input buffer: BGRA (len must be w*h*4)
/// - Output buffer: BGRA (in-place; alpha preserved)
///
/// Parameters match the Lua call:
///   (userdata, w, h, track_range, track_adjust_amount, track_offset, track_threshold, check0)
pub fn bias_deletion(
    userdata: &mut [u8],
    w: usize,
    h: usize,
    track_range: i32,
    track_adjust_amount: f64,
    track_offset: f64,
    track_threshold: f64,
    check0: bool,
) -> Result<()> {
    let expected = w
        .checked_mul(h)
        .and_then(|p| p.checked_mul(4))
        .ok_or_else(|| anyhow!("w*h*4 overflow"))?;
    if userdata.len() != expected {
        return Err(anyhow!(
            "userdata length mismatch: got {}, expected {}",
            userdata.len(),
            expected
        ));
    }

    let r = track_range.max(0) as usize;
    let adjust = track_adjust_amount / 100.0;
    // The decompiled code applies a post-transform offset; a practical mapping is base 128 + user offset.
    let out_bias = 128.0 + track_offset;
    let thr2 = track_threshold * track_threshold;

    // Process B,G,R independently; keep A unchanged.
    for chan in 0..3 {
        let chan_offset = match chan {
            0 => 0, // B
            1 => 1, // G
            2 => 2, // R
            _ => unreachable!("channel index must be 0..=2"),
        };

        // Integral images sized (w+1)*(h+1)
        let iw = w + 1;
        let ih = h + 1;
        let mut integ = vec![0.0f64; iw * ih];
        let mut integ2 = if check0 {
            Some(vec![0.0f64; iw * ih])
        } else {
            None
        };

        // Build prefix sums (and squares if needed)
        for y in 0..h {
            let mut row_sum = 0.0f64;
            let mut row_sum2 = 0.0f64;

            for x in 0..w {
                let idx = (y * w + x) * 4 + chan_offset;
                let v = userdata[idx] as f64;

                row_sum += v;
                let above = integ[y * iw + (x + 1)];
                integ[(y + 1) * iw + (x + 1)] = above + row_sum;

                if let Some(ref mut i2) = integ2 {
                    row_sum2 += v * v;
                    let above2 = i2[y * iw + (x + 1)];
                    i2[(y + 1) * iw + (x + 1)] = above2 + row_sum2;
                }
            }
        }

        // Global variance (used as normalization target when check0==true)
        let n_all = (w as f64) * (h as f64);
        let sum_all = integ[h * iw + w];
        let mean_all = sum_all / n_all;
        let global_var = if let Some(ref i2) = integ2 {
            let sum2_all = i2[h * iw + w];
            let v = (sum2_all / n_all) - (mean_all * mean_all);
            if v.is_finite() && v > 0.0 { v } else { 0.0 }
        } else {
            0.0
        };

        // Apply filter
        for y in 0..h {
            let y0 = y.saturating_sub(r);
            let y1 = (y + r).min(h - 1);

            for x in 0..w {
                let x0 = x.saturating_sub(r);
                let x1 = (x + r).min(w - 1);

                // integral rectangle uses +1 indexing
                let xa = x0;
                let xb = x1 + 1;
                let ya = y0;
                let yb = y1 + 1;

                let rect_sum = {
                    let a = integ[ya * iw + xa];
                    let b = integ[ya * iw + xb];
                    let c = integ[yb * iw + xa];
                    let d = integ[yb * iw + xb];
                    d - b - c + a
                };

                let area = ((x1 - x0 + 1) as f64) * ((y1 - y0 + 1) as f64);
                let mean = rect_sum / area;

                let src_idx = (y * w + x) * 4 + chan_offset;
                let v = userdata[src_idx] as f64;
                let dev = v - mean;

                let corrected = if check0 {
                    // local variance from integral of squares
                    let i2 = integ2
                        .as_ref()
                        .expect("integ2 must exist when check0==true");
                    let rect_sum2 = {
                        let a = i2[ya * iw + xa];
                        let b = i2[ya * iw + xb];
                        let c = i2[yb * iw + xa];
                        let d = i2[yb * iw + xb];
                        d - b - c + a
                    };
                    let local_var = (rect_sum2 / area) - (mean * mean);
                    let local_var = if local_var.is_finite() && local_var > 0.0 {
                        local_var
                    } else {
                        0.0
                    };

                    // threshold logic mirrors the decompiled intent: denom = max(local_var, threshold^2)
                    let denom = local_var.max(thr2);
                    if denom <= 0.0 || global_var <= 0.0 {
                        0.0
                    } else {
                        let k = (global_var / denom).sqrt();
                        k * dev
                    }
                } else {
                    dev
                };

                let out = corrected * adjust + out_bias;
                userdata[src_idx] = clamp_u8(out);
            }
        }
    }

    Ok(())
}
