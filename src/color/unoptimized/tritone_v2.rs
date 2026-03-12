use anyhow::{Result, anyhow, bail};

#[inline]
fn clamp_u8(v: f64) -> u8 {
    v.round().clamp(0.0, 255.0) as u8
}

#[inline]
fn lerp(a: u8, b: u8, t: f64) -> u8 {
    clamp_u8((a as f64) * (1.0 - t) + (b as f64) * t)
}

pub fn tritone_v2(
    userdata: &mut [u8],
    width: usize,
    height: usize,
    r1: u8,
    g1: u8,
    b1: u8,
    r2: u8,
    g2: u8,
    b2: u8,
    r3: u8,
    g3: u8,
    b3: u8,
    p1: u8,
    p2: u8,
    p3: u8,
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

    let mut lut = [[0u8; 3]; 256];
    for (i, out) in lut.iter_mut().enumerate() {
        let x = i as i32;
        let c = if x >= p1 as i32 {
            [r1, g1, b1]
        } else if x <= p3 as i32 {
            [r3, g3, b3]
        } else if x <= p2 as i32 {
            let denom = (p2 as i32 - p3 as i32).max(1) as f64;
            let t = (x - p3 as i32) as f64 / denom;
            [lerp(r3, r2, t), lerp(g3, g2, t), lerp(b3, b2, t)]
        } else {
            let denom = (p1 as i32 - p2 as i32).max(1) as f64;
            let t = (x - p2 as i32) as f64 / denom;
            [lerp(r2, r1, t), lerp(g2, g1, t), lerp(b2, b1, t)]
        };
        *out = c;
    }

    for px in userdata.chunks_exact_mut(4) {
        let b = px[0] as f64;
        let g = px[1] as f64;
        let r = px[2] as f64;
        let a = px[3];
        let lum = (r * 0.298_912 + g * 0.586_61 + b * 0.114_478)
            .round()
            .clamp(0.0, 255.0) as usize;
        let c = lut[lum];
        px[2] = c[0];
        px[1] = c[1];
        px[0] = c[2];
        px[3] = a;
    }

    Ok(())
}
