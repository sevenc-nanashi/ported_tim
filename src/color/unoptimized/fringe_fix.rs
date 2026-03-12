use anyhow::{Result, anyhow, bail};

fn build_alpha_lut(alpha_min: i32, alpha_max: i32) -> [u8; 256] {
    let mut lut = [0u8; 256];
    if alpha_min == alpha_max {
        for a in 0..=255i32 {
            lut[a as usize] = if a < alpha_min { 0 } else { 255 };
        }
        return lut;
    }
    for a in 0..=255i32 {
        let mut v = ((a - alpha_min) * 255) / (alpha_max - alpha_min);
        v = v.clamp(0, 255);
        lut[a as usize] = v as u8;
    }
    lut
}

pub fn fringe_fix(
    userdata: &mut [u8],
    width: usize,
    height: usize,
    bg_color: u32,
    adjust_method: i32,
    alpha_upper_limit: i32,
    alpha_lower_limit: i32,
    apply_alpha_after: bool,
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

    let mut hi = alpha_upper_limit;
    let mut lo = alpha_lower_limit;
    if hi < lo {
        std::mem::swap(&mut hi, &mut lo);
    }
    let alpha_lut = build_alpha_lut(lo, hi);

    let bg_b = (bg_color & 0xff) as i32;
    let bg_g = ((bg_color >> 8) & 0xff) as i32;
    let bg_r = ((bg_color >> 16) & 0xff) as i32;

    for px in userdata.chunks_exact_mut(4) {
        let mut b = px[0] as i32;
        let mut g = px[1] as i32;
        let mut r = px[2] as i32;
        let mut a = px[3] as i32;

        if !apply_alpha_after {
            a = alpha_lut[a.clamp(0, 255) as usize] as i32;
        }

        if (1..=254).contains(&a) {
            match adjust_method {
                1 => {
                    let inv = 255 - a;
                    b = (b * 255 - inv * bg_b) / a;
                    g = (g * 255 - inv * bg_g) / a;
                    r = (r * 255 - inv * bg_r) / a;
                    b = b.clamp(0, 255);
                    g = g.clamp(0, 255);
                    r = r.clamp(0, 255);
                }
                2 => {
                    b = bg_b;
                    g = bg_g;
                    r = bg_r;
                }
                3 => {
                    let inv = 255 - a;
                    b = (inv * bg_b + b * a) / 255;
                    g = (inv * bg_g + g * a) / 255;
                    r = (inv * bg_r + r * a) / 255;
                }
                _ => {}
            }
        }

        if apply_alpha_after {
            a = alpha_lut[a.clamp(0, 255) as usize] as i32;
        }

        px[0] = b.clamp(0, 255) as u8;
        px[1] = g.clamp(0, 255) as u8;
        px[2] = r.clamp(0, 255) as u8;
        px[3] = a.clamp(0, 255) as u8;
    }

    Ok(())
}
