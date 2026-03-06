use anyhow::{Result, anyhow, bail};

#[inline]
fn clamp_u8(v: i32) -> u8 {
    v.clamp(0, 255) as u8
}

pub fn channel_mixer(
    userdata: &mut [u8],
    width: usize,
    height: usize,
    rr: i32,
    rg: i32,
    rb: i32,
    rc: i32,
    gr: i32,
    gg: i32,
    gb: i32,
    gc: i32,
    br: i32,
    bg: i32,
    bb: i32,
    bc: i32,
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
        let b = px[0] as i32;
        let g = px[1] as i32;
        let r = px[2] as i32;

        let out_r = (r * rr + g * rg + b * rb) / 100 + rc;
        let out_g = (r * gr + g * gg + b * gb) / 100 + gc;
        let out_b = (r * br + g * bg + b * bb) / 100 + bc;

        px[2] = clamp_u8(out_r);
        px[1] = clamp_u8(out_g);
        px[0] = clamp_u8(out_b);
    }

    Ok(())
}
