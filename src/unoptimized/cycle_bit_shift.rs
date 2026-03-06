use anyhow::{Result, anyhow, bail};

#[inline]
fn euclid_mod_i32(v: i32, m: i32) -> i32 {
    let mut r = v % m;
    if r < 0 {
        r += m;
    }
    r
}

#[inline]
fn normalize_shift8(v: i32) -> u8 {
    if v < 1 {
        euclid_mod_i32(-v, 8) as u8
    } else {
        let r = euclid_mod_i32(v, 8) as u8;
        8u8.wrapping_sub(r)
    }
}

#[inline]
fn normalize_shift24(v: i32) -> u8 {
    if v < 1 {
        euclid_mod_i32(-v, 24) as u8
    } else {
        ((((v / 24) + 1) * 24) - v) as u8
    }
}

pub fn cycle_bit_shift(
    userdata: &mut [u8],
    width: usize,
    height: usize,
    red_shift: i32,
    green_shift: i32,
    blue_shift: i32,
    cycle_24bit: bool,
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

    if cycle_24bit {
        let s = normalize_shift24(red_shift) & 0x1f;
        for px in userdata.chunks_exact_mut(4) {
            let rgb = ((px[2] as u32) << 16) | ((px[1] as u32) << 8) | (px[0] as u32);
            let rotated = ((rgb >> s) | (rgb << ((24u8.wrapping_sub(s)) & 0x1f))) & 0x00ff_ffff;
            px[0] = (rotated & 0xff) as u8;
            px[1] = ((rotated >> 8) & 0xff) as u8;
            px[2] = ((rotated >> 16) & 0xff) as u8;
        }
        return Ok(());
    }

    // FUN_10012990 の引数順: (blue, green, red)
    let sb = normalize_shift8(blue_shift) & 0x1f;
    let sg = normalize_shift8(green_shift) & 0x1f;
    let sr = normalize_shift8(red_shift) & 0x1f;

    for px in userdata.chunks_exact_mut(4) {
        let b = px[0] as u16;
        let g = px[1] as u16;
        let r = px[2] as u16;

        let out_b = (((b << 8) | b) >> sb) as u8;
        let out_g = (((g << 8) | g) >> sg) as u8;
        let out_r = (((r << 8) | r) >> sr) as u8;

        px[0] = out_b;
        px[1] = out_g;
        px[2] = out_r;
    }

    Ok(())
}
