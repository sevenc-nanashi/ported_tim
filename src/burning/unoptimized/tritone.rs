use anyhow::{Result, bail};

const LUMA_R: f64 = 0.298_912;
const LUMA_G: f64 = 0.586_61;
const LUMA_B: f64 = 0.114_478;

#[inline]
fn split_rgb(rgb: u32) -> (u8, u8, u8) {
    (
        ((rgb >> 16) & 0xff) as u8,
        ((rgb >> 8) & 0xff) as u8,
        (rgb & 0xff) as u8,
    )
}

#[inline]
fn lerp_u8(a: u8, b: u8, t: f64) -> u8 {
    ((a as f64) * (1.0 - t) + (b as f64) * t)
        .round()
        .clamp(0.0, 255.0) as u8
}

/// T_burning_Module.dll の Tritone 相当。
///
/// 2 色から中間色を作り、輝度 200..255 の範囲のみ補間して着色する。
pub fn tritone(
    buffer: &mut [u8],
    width: usize,
    height: usize,
    color1: u32,
    color2: u32,
) -> Result<()> {
    let expected_len = width
        .checked_mul(height)
        .and_then(|px| px.checked_mul(4))
        .ok_or_else(|| anyhow::anyhow!("buffer size overflow"))?;

    if buffer.len() != expected_len {
        bail!(
            "invalid buffer length: got {}, expected {} ({}x{}x4)",
            buffer.len(),
            expected_len,
            width,
            height
        );
    }

    let (r1, g1, b1) = split_rgb(color1);
    let (r2, g2, b2) = split_rgb(color2);
    let mid = (
        ((r1 as u16 + r2 as u16) / 2) as u8,
        ((g1 as u16 + g2 as u16) / 2) as u8,
        ((b1 as u16 + b2 as u16) / 2) as u8,
    );

    let mut lut = [[0u8; 3]; 2048];
    for (i, out) in lut.iter_mut().enumerate() {
        let lum = (i as f64) * 255.0 / 2047.0;
        if lum <= 200.0 {
            *out = [r2, g2, b2];
        } else {
            let t = ((lum - 200.0) / 55.0).clamp(0.0, 1.0);
            *out = [
                lerp_u8(r2, mid.0, t),
                lerp_u8(g2, mid.1, t),
                lerp_u8(b2, mid.2, t),
            ];
        }
    }

    for px in buffer.chunks_exact_mut(4) {
        let b = px[0] as f64;
        let g = px[1] as f64;
        let r = px[2] as f64;
        let a = px[3];

        let lum = ((r * LUMA_R + g * LUMA_G + b * LUMA_B) * (2047.0 / 255.0))
            .round()
            .clamp(0.0, 2047.0) as usize;
        let [rr, gg, bb] = lut[lum];

        px[0] = bb;
        px[1] = gg;
        px[2] = rr;
        px[3] = a;
    }

    Ok(())
}
