use anyhow::{Result, anyhow, bail};

#[inline]
fn clamp_u8(v: f64) -> u8 {
    v.round().clamp(0.0, 255.0) as u8
}

fn rgb_to_hsv(r: u8, g: u8, b: u8) -> (f64, f64, f64) {
    let rf = r as f64 / 255.0;
    let gf = g as f64 / 255.0;
    let bf = b as f64 / 255.0;
    let max = rf.max(gf).max(bf);
    let min = rf.min(gf).min(bf);
    let d = max - min;

    let mut h = 0.0;
    if d > 0.0 {
        if (max - rf).abs() < f64::EPSILON {
            h = 60.0 * (((gf - bf) / d) % 6.0);
        } else if (max - gf).abs() < f64::EPSILON {
            h = 60.0 * (((bf - rf) / d) + 2.0);
        } else {
            h = 60.0 * (((rf - gf) / d) + 4.0);
        }
    }
    if h < 0.0 {
        h += 360.0;
    }
    let s = if max <= 0.0 { 0.0 } else { d / max };
    let v = max;
    (h, s, v)
}

fn rgb_to_lab(r: u8, g: u8, b: u8) -> (f64, f64, f64) {
    let srgb = |u: u8| {
        let x = u as f64 / 255.0;
        if x <= 0.04045 {
            x / 12.92
        } else {
            ((x + 0.055) / 1.055).powf(2.4)
        }
    };
    let r = srgb(r);
    let g = srgb(g);
    let b = srgb(b);

    let x = r * 0.4124564 + g * 0.3575761 + b * 0.1804375;
    let y = r * 0.2126729 + g * 0.7151522 + b * 0.0721750;
    let z = r * 0.0193339 + g * 0.1191920 + b * 0.9503041;

    let xr = x / 0.95047;
    let yr = y / 1.0;
    let zr = z / 1.08883;
    let f = |t: f64| {
        if t > 0.008856 {
            t.cbrt()
        } else {
            7.787 * t + 16.0 / 116.0
        }
    };
    let fx = f(xr);
    let fy = f(yr);
    let fz = f(zr);
    let l = 116.0 * fy - 16.0;
    let a = 500.0 * (fx - fy);
    let b = 200.0 * (fy - fz);
    (l, a, b)
}

pub fn leave_color(
    userdata: &mut [u8],
    width: usize,
    height: usize,
    ref_r: u8,
    ref_g: u8,
    ref_b: u8,
    color_cut_amount: f64,
    color_difference_range: i32,
    edge: i32,
    matching_method: i32,
) -> Result<()> {
    let pixel_count = width
        .checked_mul(height)
        .ok_or_else(|| anyhow!("width * height overflow"))?;
    let expected_len = pixel_count
        .checked_mul(4)
        .ok_or_else(|| anyhow!("buffer size overflow"))?;
    if userdata.len() != expected_len {
        bail!(
            "invalid BGRA buffer length: got {}, expected {}",
            userdata.len(),
            expected_len
        );
    }

    let cut = (color_cut_amount * 0.01).clamp(0.0, 1.0);
    let range = color_difference_range.max(1) as f64;
    let edge = edge as f64;

    let (ref_h, _ref_s, _ref_v) = rgb_to_hsv(ref_r, ref_g, ref_b);
    let (ref_l, ref_a, ref_bb) = rgb_to_lab(ref_r, ref_g, ref_b);

    for px in userdata.chunks_exact_mut(4) {
        let b = px[0];
        let g = px[1];
        let r = px[2];
        let a = px[3];
        if a == 0 {
            continue;
        }

        let dist = match matching_method {
            2 => {
                let (_l, aa, bb) = rgb_to_lab(r, g, b);
                ((aa - ref_a).powi(2) + (bb - ref_bb).powi(2)).sqrt()
            }
            3 => {
                let (l, aa, bb) = rgb_to_lab(r, g, b);
                ((l - ref_l).powi(2) + (aa - ref_a).powi(2) + (bb - ref_bb).powi(2)).sqrt()
            }
            4 => {
                let (h, _s, _v) = rgb_to_hsv(r, g, b);
                (h - ref_h).abs()
            }
            _ => {
                let dr = r as f64 - ref_r as f64;
                let dg = g as f64 - ref_g as f64;
                let db = b as f64 - ref_b as f64;
                (dr * dr + dg * dg + db * db).sqrt()
            }
        };

        let keep_raw = 1.0 - ((dist / range) - 1.0) * (2.0 * edge + 1.0) * 0.5;
        let keep = keep_raw.clamp(0.0, 1.0);

        let avg = (r as f64 + g as f64 + b as f64) / 3.0;
        let mixed_r = r as f64 * keep + (1.0 - keep) * avg;
        let mixed_g = g as f64 * keep + (1.0 - keep) * avg;
        let mixed_b = b as f64 * keep + (1.0 - keep) * avg;

        let out_r = (mixed_r * cut) + (1.0 - cut) * r as f64;
        let out_g = (mixed_g * cut) + (1.0 - cut) * g as f64;
        let out_b = (mixed_b * cut) + (1.0 - cut) * b as f64;

        px[2] = clamp_u8(out_r);
        px[1] = clamp_u8(out_g);
        px[0] = clamp_u8(out_b);
    }

    Ok(())
}
