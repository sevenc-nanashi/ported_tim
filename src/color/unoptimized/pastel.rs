// Pastel filter port (BGRA in-place), based on the cleaned C version.
// - bgra: mutable pixel buffer, 4 bytes per pixel, order B,G,R,A
// - w, h: dimensions
// - saturation_pct, brightness_pct, threshold_pct: 0..100 (treated as percentages)
// - shw: threshold soft width (>=0), in luma units (0..255 space)

#[inline]
fn clamp01(x: f64) -> f64 {
    x.clamp(0.0, 1.0)
}

#[inline]
fn clamp_u8_round(x: f64) -> u8 {
    if x <= 0.0 {
        0
    } else if x >= 255.0 {
        255
    } else {
        // round-to-nearest
        (x + 0.5) as u8
    }
}

#[inline]
fn rgb_to_hsv(r: f64, g: f64, b: f64) -> (f64, f64, f64) {
    // r,g,b in [0..255]
    let mut mx = r;
    if g > mx {
        mx = g;
    }
    if b > mx {
        mx = b;
    }

    let mut mn = r;
    if g < mn {
        mn = g;
    }
    if b < mn {
        mn = b;
    }

    let delta = mx - mn;

    if mx <= 0.0 {
        return (0.0, 0.0, 0.0);
    }

    let v = mx / 255.0;

    if delta == 0.0 {
        return (0.0, 0.0, v);
    }

    let s = delta / mx;

    // Use canonical HSV hue sectors to avoid channel-rotated hues.
    let mut h = if mx == r {
        (g - b) * 60.0 / delta
    } else if mx == g {
        (b - r) * 60.0 / delta + 120.0
    } else {
        (r - g) * 60.0 / delta + 240.0
    };

    if h < 0.0 {
        h += 360.0;
    }

    (h, s, v)
}

#[inline]
fn hsv_to_rgb(h_deg: f64, s: f64, v: f64) -> (f64, f64, f64) {
    // h in degrees, s,v in [0..1]. outputs r,g,b in [0..255]
    if s <= 0.0 {
        let x = v * 255.0;
        return (x, x, x);
    }

    // normalize h to [0,360)
    let mut h = h_deg % 360.0;
    if h < 0.0 {
        h += 360.0;
    }

    let hh = h / 60.0;
    let sector = hh.floor() as i32; // 0..5
    let f = hh - (sector as f64);

    let p = (1.0 - s) * v;
    let q = (1.0 - s * f) * v;
    let t = (1.0 - s * (1.0 - f)) * v;

    let (rr, gg, bb) = match sector {
        0 => (v, t, p),
        1 => (q, v, p),
        2 => (p, v, t),
        3 => (p, q, v),
        4 => (t, p, v),
        _ => (v, p, q), // 5
    };

    (rr * 255.0, gg * 255.0, bb * 255.0)
}

/// In-place pastel filter on BGRA buffer.
///
/// `bgra.len()` must be at least `w*h*4`.
pub fn pastel_bgra(
    bgra: &mut [u8],
    w: usize,
    h: usize,
    saturation_pct: f64,
    brightness_pct: f64,
    threshold_pct: f64,
    mut shw: f64,
) {
    if w == 0 || h == 0 {
        return;
    }
    let n = w.saturating_mul(h);
    let need = n.saturating_mul(4);
    if bgra.len() < need {
        return;
    }

    let mut sat_scale = saturation_pct / 100.0;
    let mut bright_amt = brightness_pct / 100.0;
    let thr = (threshold_pct / 100.0) * 255.0;

    sat_scale = clamp01(sat_scale);
    bright_amt = clamp01(bright_amt);
    if shw < 0.0 {
        shw = 0.0;
    }

    for i in 0..n {
        let idx = i * 4;

        let b0 = bgra[idx] as f64;
        let g0 = bgra[idx + 1] as f64;
        let r0 = bgra[idx + 2] as f64;
        let a = bgra[idx + 3];
        if a == 0 {
            continue;
        }

        // Luma-like measure (coefficients match the decompile)
        let luma = r0 * 0.298_912 + g0 * 0.586_61 + b0 * 0.114_478;
        let diff = luma - thr;

        let (h_deg, mut s, mut v) = rgb_to_hsv(r0, g0, b0);

        // Apply saturation scale and brighten by mixing V toward 1.0
        s = clamp01(s * sat_scale);
        v = clamp01((1.0 - bright_amt) * v + bright_amt);

        let (r1, g1, b1) = hsv_to_rgb(h_deg, s, v);

        // Soft threshold blend
        let (out_r, out_g, out_b) = if shw <= 0.0 || diff > shw {
            (r1, g1, b1)
        } else if diff <= 0.0 {
            (r0, g0, b0)
        } else {
            let t = diff / shw; // 0..1
            (
                (1.0 - t) * r0 + t * r1,
                (1.0 - t) * g0 + t * g1,
                (1.0 - t) * b0 + t * b1,
            )
        };

        bgra[idx + 2] = clamp_u8_round(out_r);
        bgra[idx + 1] = clamp_u8_round(out_g);
        bgra[idx] = clamp_u8_round(out_b);
        bgra[idx + 3] = a;
    }
}
