fn frac01(x: f64) -> f64 {
    x - x.floor()
}

fn hsv_to_rgb(h: f64, s: f64, v: f64) -> (u8, u8, u8) {
    let h = frac01(h) * 6.0;
    let sector = h.floor() as i32;
    let mut t = h - sector as f64;

    // DLL の境界補正(dc)は各区間の線形遷移幅を調整しているため、
    // ここでは区間内補間率にのみ適用する。
    if s.is_nan() {
        t = 0.0;
    }

    let p = v * (1.0 - s);
    let q = v * (1.0 - s * t);
    let u = v * (1.0 - s * (1.0 - t));

    let (r, g, b) = match sector.rem_euclid(6) {
        0 => (v, u, p),
        1 => (q, v, p),
        2 => (p, v, u),
        3 => (p, q, v),
        4 => (u, p, v),
        _ => (v, p, q),
    };

    (
        (r * 255.0).round().clamp(0.0, 255.0) as u8,
        (g * 255.0).round().clamp(0.0, 255.0) as u8,
        (b * 255.0).round().clamp(0.0, 255.0) as u8,
    )
}

fn apply_boundary_correction(t: f64, dc: f64) -> f64 {
    if dc <= 0.0 {
        return t;
    }
    let dc = dc.min(0.49);
    let span = 1.0 - dc * 2.0;
    if span <= 0.0 {
        return 0.5;
    }
    ((t - dc) / span).clamp(0.0, 1.0)
}

pub fn r_gradation_line(
    image_buffer: &mut [u8],
    width: usize,
    height: usize,
    mix_strength: f64,
    shrink_rate: f64,
    rotation_rad: f64,
    reverse: bool,
    circular: bool,
    shift: f64,
    repeat: bool,
    boundary_correction: f64,
) {
    if width == 0 || height == 0 {
        return;
    }
    let len = match width.checked_mul(height).and_then(|v| v.checked_mul(4)) {
        Some(v) => v,
        None => return,
    };
    if image_buffer.len() < len {
        return;
    }

    let w = width as f64;
    let h = height as f64;
    let hw = w * 0.5;
    let hh = h * 0.5;

    let sin_r = rotation_rad.sin();
    let cos_r = rotation_rad.cos();

    // DLL 互換: S と shift は 0.01 倍してから使用。
    let sat = (mix_strength * 0.01).clamp(0.0, 1.0);
    let shift01 = shift * 0.01;
    let shrink = shrink_rate;
    let dc = boundary_correction.max(0.0);

    // linear mode の除算項。
    let linear_den = (h * h * sin_r * sin_r) + (w * w * cos_r * cos_r);

    for y in 0..height {
        let yf = y as f64;
        let dy = yf - hh;
        for x in 0..width {
            let xf = x as f64;
            let dx = xf - hw;

            let base = if !circular {
                if linear_den == 0.0 {
                    0.5
                } else {
                    let n = sin_r * h * (sin_r * hh + dy) + cos_r * w * (cos_r * hw + dx);
                    n / linear_den
                }
            } else {
                // DLL の circular 分岐は回転項を使わず、正規化楕円距離の sqrt。
                let ny = if hh > 0.0 { dy / hh } else { 0.0 };
                let nx = if hw > 0.0 { dx / hw } else { 0.0 };
                (nx * nx + ny * ny).sqrt()
            };

            let mut t = (base - 0.5) * shrink + 0.5;

            if repeat {
                t = frac01(t);
            } else {
                t = t.clamp(0.0, 1.0);
            }

            t = if reverse {
                (1.0 - t) + shift01
            } else {
                t - shift01
            };
            let mut phase = frac01(t);

            let segment = phase * 6.0;
            let seg_i = segment.floor() as i32;
            let seg_t = apply_boundary_correction(segment - seg_i as f64, dc);
            phase = (seg_i as f64 + seg_t) / 6.0;

            let (r, g, b) = hsv_to_rgb(phase, sat, 1.0);
            let idx = (y * width + x) * 4;
            image_buffer[idx] = b;
            image_buffer[idx + 1] = g;
            image_buffer[idx + 2] = r;
        }
    }
}
