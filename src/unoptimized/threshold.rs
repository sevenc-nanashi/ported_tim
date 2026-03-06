use anyhow::{Result, anyhow, bail};

#[inline]
fn round_like_c(v: f64) -> i32 {
    v.round() as i32
}

#[inline]
fn clamp_u8_i32(v: i32) -> u8 {
    v.clamp(0, 255) as u8
}

pub fn threshold(
    userdata: &mut [u8],
    width: usize,
    height: usize,
    threshold_1: f64,
    threshold_2: f64,
    detect_method: i32,
    opacity: f64,
    replace_color: u32,
    invert_range: bool,
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

    let (w_b, w_g, w_r): (i32, i32, i32) = match detect_method {
        0 => (0x155, 0x156, 0x155),
        1 => (0x75, 0x259, 0x132),
        2 => (0, 0, 0x400),
        3 => (0, 0x400, 0),
        _ => (0x400, 0, 0),
    };

    // threshold_impl は閾値を 1024 倍スケール（0x400）で判定する。
    let t1 = round_like_c(threshold_1 * 1024.0);
    let t2 = round_like_c(threshold_2 * 1024.0);
    let (range_min, range_max) = if t1 <= t2 { (t1, t2) } else { (t2, t1) };

    // decompile の dStack_18 / dStack_20 相当
    let mut out_scale = 1.0f64;
    let in_scale = if opacity <= 0.0 {
        out_scale = 1.0 + (opacity / 100.0);
        1.0
    } else {
        1.0 - (opacity / 100.0)
    };

    for px in userdata.chunks_exact_mut(4) {
        let b = px[0] as i32;
        let g = px[1] as i32;
        let r = px[2] as i32;
        let a = px[3] as i32;
        if a == 0 {
            continue;
        }

        let metric = g * w_g + r * w_r + b * w_b;
        let mut in_range = range_min <= metric && metric <= range_max;
        if invert_range {
            in_range = !in_range;
        }

        if in_range {
            let na = clamp_u8_i32(round_like_c(a as f64 * in_scale));
            px[0] = (replace_color & 0xFF) as u8;
            px[1] = ((replace_color >> 8) & 0xFF) as u8;
            px[2] = ((replace_color >> 16) & 0xFF) as u8;
            px[3] = na;
        } else {
            let na = clamp_u8_i32(round_like_c(a as f64 * out_scale));
            px[3] = na;
        }
    }

    Ok(())
}
