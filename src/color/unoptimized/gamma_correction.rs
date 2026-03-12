use anyhow::{Result, anyhow};

/// Build LUTs for channel mapping, matching the decompiled C:
/// - entries for 0..=254 (255 entries)
/// - 255 handled as passthrough
fn build_lut_0_254(exp_r: f64, exp_g: f64, exp_b: f64) -> ([u8; 255], [u8; 255], [u8; 255]) {
    let mut lut_r = [0u8; 255];
    let mut lut_g = [0u8; 255];
    let mut lut_b = [0u8; 255];

    for i in 0u32..=254u32 {
        let x = (i as f64) / 255.0;

        // C: floor(pow(x, exp) * 255.0)
        let fr = (x.powf(exp_r) * 255.0).floor();
        let fg = (x.powf(exp_g) * 255.0).floor();
        let fb = (x.powf(exp_b) * 255.0).floor();

        // Clamp into 0..=255 then to u8 (0..=254 indices only)
        let cr = fr.max(0.0).min(255.0) as u8;
        let cg = fg.max(0.0).min(255.0) as u8;
        let cb = fb.max(0.0).min(255.0) as u8;

        lut_r[i as usize] = cr;
        lut_g[i as usize] = cg;
        lut_b[i as usize] = cb;
    }

    (lut_r, lut_g, lut_b)
}

pub fn gamma_correction(
    buf: &mut [u8],
    w: usize,
    h: usize,
    exp_r: f64,
    exp_g: f64,
    exp_b: f64,
) -> Result<()> {
    let pixel_count = w.checked_mul(h).ok_or_else(|| anyhow!("w*h overflow"))?;
    let needed = pixel_count
        .checked_mul(4)
        .ok_or_else(|| anyhow!("(w*h)*4 overflow"))?;
    if buf.len() < needed {
        return Err(anyhow!(
            "buffer too small: need {} bytes for {}x{} BGRA, got {}",
            needed,
            w,
            h,
            buf.len()
        ));
    }

    let (lut_r, lut_g, lut_b) = build_lut_0_254(exp_r, exp_g, exp_b);

    // In-place BGRA. Preserve A, map B/G/R through LUT.
    // Decomp C reads bytes [B,G,R,A] and packs back as BGRA.
    for px in 0..pixel_count {
        let o = px * 4;
        let b = buf[o];
        let g = buf[o + 1];
        let r = buf[o + 2];
        // let a = buf[o + 3]; // preserved

        let nb = if b == 255 { 255 } else { lut_b[b as usize] };
        let ng = if g == 255 { 255 } else { lut_g[g as usize] };
        let nr = if r == 255 { 255 } else { lut_r[r as usize] };

        buf[o] = nb;
        buf[o + 1] = ng;
        buf[o + 2] = nr;
        // buf[o + 3] unchanged
    }

    Ok(())
}
