use anyhow::{Result, anyhow, bail};

#[inline]
fn clamp_u8(v: i32) -> u8 {
    v.clamp(0, 255) as u8
}

fn rgb_to_hsv_255(r: u8, g: u8, b: u8) -> (u8, u8, u8) {
    let rf = r as f64 / 255.0;
    let gf = g as f64 / 255.0;
    let bf = b as f64 / 255.0;
    let max = rf.max(gf).max(bf);
    let min = rf.min(gf).min(bf);
    let delta = max - min;

    let mut h_deg = 0.0f64;
    if delta > 0.0 {
        if (max - rf).abs() < f64::EPSILON {
            h_deg = 60.0 * (((gf - bf) / delta) % 6.0);
        } else if (max - gf).abs() < f64::EPSILON {
            h_deg = 60.0 * (((bf - rf) / delta) + 2.0);
        } else {
            h_deg = 60.0 * (((rf - gf) / delta) + 4.0);
        }
    }
    if h_deg < 0.0 {
        h_deg += 360.0;
    }

    let s = if max <= 0.0 {
        0.0
    } else {
        (delta / max) * 100.0
    };
    let v = max * 100.0;

    let h255 = ((h_deg * 255.0) / 360.0).round() as i32;
    let s255 = ((s * 255.0) / 100.0).round() as i32;
    let v255 = ((v * 255.0) / 100.0).round() as i32;
    (clamp_u8(h255), clamp_u8(s255), clamp_u8(v255))
}

#[inline]
fn pick(ch: &[u8; 7], idx: i32) -> u8 {
    let i = idx.clamp(0, 6) as usize;
    ch[i]
}

pub fn shift_channels(
    userdata: &mut [u8],
    width: usize,
    height: usize,
    alpha_src: i32,
    red_src: i32,
    green_src: i32,
    blue_src: i32,
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

    for px in userdata.chunks_exact_mut(4) {
        let b = px[0];
        let g = px[1];
        let r = px[2];
        let a = px[3];
        let (h, s, v) = rgb_to_hsv_255(r, g, b);
        let src = [a, r, g, b, h, s, v];

        let out_a = pick(&src, alpha_src);
        let out_r = pick(&src, red_src);
        let out_g = pick(&src, green_src);
        let out_b = pick(&src, blue_src);

        px[0] = out_b;
        px[1] = out_g;
        px[2] = out_r;
        px[3] = out_a;
    }

    Ok(())
}
