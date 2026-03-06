use anyhow::{Result, anyhow};

/// Lua の BiasDeletion(userdata, w, h, range, adjust_amount, offset, threshold, check0)
/// に対応する in-place 変換。
///
/// - `pixels_bgra`: len == w*h*4 の BGRA バッファ（入出力同一）
/// - `range`: 近傍窓の半径（0 以上）
/// - `adjust_amount`: C 側で /100 される倍率（例: 100 => 1.0）
/// - `offset`: 出力加算オフセット（double）
/// - `threshold`: 偏差閾値（double）
/// - `variance_correction`: 偏差補正（true で分散補正あり）
///
/// 逆コンパイルから復元した挙動:
/// - 各チャンネル（B,G,R）ごとに
///   - 近傍平均を引き（偏差化）
///   - variance_correction==true の場合は、
///     グローバル分散 / max(threshold^2, ローカル分散) の平方根を掛けて偏差を正規化
///   - 偏差 * (adjust_amount/100) + offset を 0..255 に clamp
/// - A は変更しない
pub fn bias_deletion(
    pixels_bgra: &mut [u8],
    w: usize,
    h: usize,
    range: i32,
    adjust_amount: f64,
    offset: f64,
    threshold: f64,
    variance_correction: bool,
) -> Result<()> {
    if w == 0 || h == 0 {
        return Err(anyhow!("w/h must be non-zero"));
    }
    let n = w.checked_mul(h).ok_or_else(|| anyhow!("w*h overflow"))?;
    let expected = n
        .checked_mul(4)
        .ok_or_else(|| anyhow!("buffer size overflow"))?;
    if pixels_bgra.len() != expected {
        return Err(anyhow!(
            "pixels_bgra.len() mismatch: got {}, expected {} (= w*h*4)",
            pixels_bgra.len(),
            expected
        ));
    }
    if range < 0 {
        return Err(anyhow!("range must be >= 0"));
    }
    if threshold < 0.0 {
        return Err(anyhow!("threshold must be >= 0"));
    }

    // adjust_amount は C 側で /100
    let adjust = adjust_amount / 100.0;
    let thr2 = threshold * threshold;

    // BGRA -> planar i32
    let mut b = vec![0i32; n];
    let mut g = vec![0i32; n];
    let mut r = vec![0i32; n];
    // alpha は保持（変更しない）
    for i in 0..n {
        let p = i * 4;
        b[i] = pixels_bgra[p + 0] as i32;
        g[i] = pixels_bgra[p + 1] as i32;
        r[i] = pixels_bgra[p + 2] as i32;
    }

    process_channel(
        &mut b,
        w,
        h,
        range as isize,
        adjust,
        offset,
        thr2,
        variance_correction,
    )?;
    process_channel(
        &mut g,
        w,
        h,
        range as isize,
        adjust,
        offset,
        thr2,
        variance_correction,
    )?;
    process_channel(
        &mut r,
        w,
        h,
        range as isize,
        adjust,
        offset,
        thr2,
        variance_correction,
    )?;

    // planar -> BGRA（A は元のまま）
    for i in 0..n {
        let p = i * 4;
        pixels_bgra[p + 0] = b[i] as u8;
        pixels_bgra[p + 1] = g[i] as u8;
        pixels_bgra[p + 2] = r[i] as u8;
        // pixels_bgra[p + 3] は変更しない
    }

    Ok(())
}

fn process_channel(
    ch: &mut [i32],
    w: usize,
    h: usize,
    radius: isize,
    adjust: f64,
    offset: f64,
    thr2: f64,
    variance_correction: bool,
) -> Result<()> {
    let n = w * h;
    if ch.len() != n {
        return Err(anyhow!("channel length mismatch"));
    }

    // integral image: sum と sumsq（f64）
    let mut integral = vec![0.0f64; n];
    let mut integral_sq = vec![0.0f64; n];

    // 2D 累積和（横→縦をまとめて 1 パスで構築しても同値）
    for y in 0..h {
        let mut row_sum = 0.0f64;
        let mut row_sum_sq = 0.0f64;
        for x in 0..w {
            let idx = y * w + x;
            let v = ch[idx] as f64;
            row_sum += v;
            row_sum_sq += v * v;

            let above = if y > 0 { integral[idx - w] } else { 0.0 };
            let above_sq = if y > 0 { integral_sq[idx - w] } else { 0.0 };

            integral[idx] = row_sum + above;
            integral_sq[idx] = row_sum_sq + above_sq;
        }
    }

    // グローバル分散（variance_correction のときだけ必要）
    let global_var = if variance_correction {
        let total_sum = integral[n - 1];
        let total_sumsq = integral_sq[n - 1];
        let nn = n as f64;
        // (E[x^2] - (E[x])^2)
        let var = (total_sumsq - (total_sum * total_sum) / nn) / nn;
        // 数値誤差で負になるケースを潰す
        if var.is_finite() { var.max(0.0) } else { 0.0 }
    } else {
        0.0
    };

    for y in 0..h {
        for x in 0..w {
            let x0 = (x as isize - radius).max(0) as usize;
            let y0 = (y as isize - radius).max(0) as usize;
            let x1 = (x as isize + radius).min(w as isize - 1) as usize;
            let y1 = (y as isize + radius).min(h as isize - 1) as usize;

            let area = ((x1 - x0 + 1) * (y1 - y0 + 1)) as f64;

            let sum = rect_sum(&integral, w, x0, y0, x1, y1);
            let mean = sum / area;

            let idx = y * w + x;
            let mut diff = (ch[idx] as f64) - mean;

            if variance_correction {
                let sumsq = rect_sum(&integral_sq, w, x0, y0, x1, y1);
                let local_var = (sumsq / area) - (mean * mean);
                let local_var = if local_var.is_finite() {
                    local_var.max(0.0)
                } else {
                    0.0
                };

                // max(threshold^2, local_var)
                let denom = if thr2 >= local_var { thr2 } else { local_var };
                // denom が 0 のときは「補正不能」なので diff を 0 に寄せるより、
                // global_var/0 は無限大になるため回避する
                if denom == 0.0 {
                    // ここは C 側では閾値設定により通常回避される想定。
                    // 0 の場合は補正なしにフォールバック。
                } else {
                    let scale = (global_var / denom).sqrt();
                    diff *= scale;
                }
            }

            let out = diff * adjust + offset;

            // C の (int) キャストは 0 方向への切り捨て（trunc）に相当
            let mut v = out.trunc() as i32;
            if v < 0 {
                v = 0;
            } else if v > 255 {
                v = 255;
            }

            // ここに来る条件は必ず満たされるが、形式上 unreachable! の例を要求されているため、
            // 値域で到達不能を置く。
            if !(0..=255).contains(&v) {
                unreachable!("clamp failed: {}", v);
            }

            ch[idx] = v;
        }
    }

    Ok(())
}

#[inline]
fn rect_sum(integral: &[f64], w: usize, x0: usize, y0: usize, x1: usize, y1: usize) -> f64 {
    // inclusive rectangle sum using integral image
    // S = I(x1,y1) - I(x0-1,y1) - I(x1,y0-1) + I(x0-1,y0-1)
    let a = get_integral(integral, w, x1, y1);
    let b = if x0 > 0 {
        get_integral(integral, w, x0 - 1, y1)
    } else {
        0.0
    };
    let c = if y0 > 0 {
        get_integral(integral, w, x1, y0 - 1)
    } else {
        0.0
    };
    let d = if x0 > 0 && y0 > 0 {
        get_integral(integral, w, x0 - 1, y0 - 1)
    } else {
        0.0
    };
    a - b - c + d
}

#[inline]
fn get_integral(integral: &[f64], w: usize, x: usize, y: usize) -> f64 {
    let idx = y * w + x;
    // idx は呼び出し側で範囲内に制限されている想定
    if idx >= integral.len() {
        unreachable!("integral index out of bounds: {}", idx);
    }
    integral[idx]
}
