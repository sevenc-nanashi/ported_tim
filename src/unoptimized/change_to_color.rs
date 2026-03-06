use anyhow::{Result, bail};

/// Lua:
/// T_Color_Module.ChangeToColor(
///     userdata, w, h,
///     col1, col2,
///     track_hue_range,
///     track_saturation_range,
///     pS2 * 0.01,
///     track_luminance_adjust * 0.01,
///     track_boundary_adjust
/// )
///
/// - `buffer` is BGRA in-place.
/// - `col1` / `col2` are 0xRRGGBB.
/// - `hue_range` corresponds to track_hue_range.
/// - `saturation_range` corresponds to track_saturation_range in the original Lua UI,
///   but the C code compares it against HSV saturation in [0, 100].
///   This function preserves the decompiled C behavior as-is.
/// - `saturation_scale` is pS2 * 0.01.
/// - `luminance_scale` is track_luminance_adjust * 0.01.
/// - `boundary_adjust` is track_boundary_adjust.
pub fn change_to_color(
    buffer: &mut [u8],
    width: usize,
    height: usize,
    col1: u32,
    col2: u32,
    hue_range: f64,
    saturation_range: f64,
    saturation_scale: f64,
    luminance_scale: f64,
    boundary_adjust: f64,
) -> Result<()> {
    let pixel_count = width
        .checked_mul(height)
        .ok_or_else(|| anyhow::anyhow!("image size overflow"))?;
    let required_len = pixel_count
        .checked_mul(4)
        .ok_or_else(|| anyhow::anyhow!("buffer size overflow"))?;

    if buffer.len() < required_len {
        bail!(
            "buffer too small: got {}, need at least {}",
            buffer.len(),
            required_len
        );
    }

    if boundary_adjust == 0.0 {
        bail!("boundary_adjust must not be 0");
    }

    let (src_r, src_g, src_b) = split_rgb_u32(col1);
    let (dst_r, dst_g, dst_b) = split_rgb_u32(col2);

    let (src_h, src_s, _src_v) = rgb_to_hsv_i32(src_r, src_g, src_b);
    let (dst_h, _dst_s, _dst_v) = rgb_to_hsv_i32(dst_r, dst_g, dst_b);

    for i in 0..pixel_count {
        let base = i * 4;

        // BGRA
        let b = buffer[base] as i32;
        let g = buffer[base + 1] as i32;
        let r = buffer[base + 2] as i32;
        let a = buffer[base + 3];

        let orig_r = r as f64;
        let orig_g = g as f64;
        let orig_b = b as f64;

        let (mut pix_h, mut pix_s, mut pix_v) = rgb_to_hsv_i32(r, g, b);

        let hue_diff = circular_hue_diff_decompiled(pix_h, src_h);

        let hue_distance = ((hue_diff * hue_diff) as f64).sqrt() - hue_range;
        let hue_excess = if hue_distance < 0.0 {
            0.0
        } else {
            hue_distance
        };

        let sat_distance = (((pix_s - src_s) * (pix_s - src_s)) as f64).sqrt() - saturation_range;
        let sat_excess = if sat_distance < 0.0 {
            0.0
        } else {
            sat_distance
        };

        if hue_excess == 0.0 && sat_excess == 0.0 {
            pix_v = trunc_to_i32((pix_v as f64) * luminance_scale);
            pix_s = trunc_to_i32((pix_s as f64) * saturation_scale);

            let new_h = (dst_h + hue_diff + 3600).rem_euclid(360);
            pix_h = new_h;

            if pix_s > 100 {
                pix_s = 100;
            }
            if pix_v > 100 {
                pix_v = 100;
            }
        }

        let (mut out_r, mut out_g, mut out_b) = hsv_to_rgb_255(pix_h, pix_s, pix_v);

        if hue_excess == 0.0 && sat_excess == 0.0 {
            let abs_hue_diff = hue_diff.abs() as f64;
            let blend = ((abs_hue_diff - hue_range) / boundary_adjust + 1.0).clamp(0.0, 1.0);
            let inv_blend = 1.0 - blend;

            out_r = out_r * inv_blend + orig_r * blend;
            out_g = out_g * inv_blend + orig_g * blend;
            out_b = out_b * inv_blend + orig_b * blend;
        }

        buffer[base] = clamp_to_u8(out_b);
        buffer[base + 1] = clamp_to_u8(out_g);
        buffer[base + 2] = clamp_to_u8(out_r);
        buffer[base + 3] = a;
    }

    Ok(())
}

#[inline]
fn split_rgb_u32(color: u32) -> (i32, i32, i32) {
    let r = ((color >> 16) & 0xff) as i32;
    let g = ((color >> 8) & 0xff) as i32;
    let b = (color & 0xff) as i32;
    (r, g, b)
}

/// Decompiled `sub_10001220` equivalent.
/// Input/Output:
/// - input: RGB in [0,255]
/// - output: H in [0,360), S in [0,100], V in [0,100]
#[inline]
fn rgb_to_hsv_i32(r: i32, g: i32, b: i32) -> (i32, i32, i32) {
    let max_v = r.max(g).max(b);
    let min_v = r.min(g).min(b);

    if max_v == 0 {
        return (0, 0, 0);
    }

    if max_v == min_v {
        let v = trunc_to_i32((max_v as f64) * 100.0 / 255.0);
        return (0, 0, v);
    }

    let delta = (max_v - min_v) as f64;

    let mut h = if max_v == r {
        ((g - b) as f64) * 60.0 / delta
    } else if max_v == g {
        ((b - r) as f64) * 60.0 / delta + 120.0
    } else {
        ((r - g) as f64) * 60.0 / delta + 240.0
    };

    if h < 0.0 {
        h += 360.0;
    }

    let s = trunc_to_i32(delta * 100.0 / (max_v as f64));
    let v = trunc_to_i32(100.0 * (max_v as f64) / 255.0);

    (trunc_to_i32(h), s, v)
}

/// Decompiled hue difference logic:
///
/// if (pix_h <= src_h + 180) {
///     diff = pix_h - src_h;
///     if (src_h > pix_h + 180) diff += 360;
/// } else {
///     diff = pix_h - src_h - 360;
/// }
#[inline]
fn circular_hue_diff_decompiled(pix_h: i32, src_h: i32) -> i32 {
    if pix_h <= src_h + 180 {
        let mut diff = pix_h - src_h;
        if src_h > pix_h + 180 {
            diff += 360;
        }
        diff
    } else {
        pix_h - src_h - 360
    }
}

/// Recreates the decompiled HSV->RGB path closely:
/// - H in degrees
/// - S in [0,100]
/// - V in [0,100]
/// - returns RGB in [0,255] as f64
#[inline]
fn hsv_to_rgb_255(h: i32, s: i32, v: i32) -> (f64, f64, f64) {
    let s_f = (s as f64) * 0.01;
    let v_f = (v as f64) * 0.01;

    let h_norm = (h.rem_euclid(360)) as f64 / 60.0;
    let sector = h_norm.floor() as i32;
    let frac = h_norm - (sector as f64);

    let p = (1.0 - s_f) * v_f;
    let q = (1.0 - frac * s_f) * v_f;
    let t = (1.0 - s_f * (1.0 - frac)) * v_f;

    let (r, g, b) = match sector {
        0 => (v_f, t, p),
        1 => (q, v_f, p),
        2 => (p, v_f, t),
        3 => (p, q, v_f),
        4 => (t, p, v_f),
        5 => (v_f, p, q),
        _ => unreachable!(),
    };

    (r * 255.0, g * 255.0, b * 255.0)
}

#[inline]
fn trunc_to_i32(x: f64) -> i32 {
    x as i32
}

#[inline]
fn clamp_to_u8(x: f64) -> u8 {
    if x <= 0.0 {
        0
    } else if x >= 255.0 {
        255
    } else {
        x as u8
    }
}
