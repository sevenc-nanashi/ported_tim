use anyhow::{Result, bail};
use std::f64::consts::PI;

/// T_burning_Module.dll の ExtendedContrast 相当。
///
/// `ecw` は DLL と同様に `[-200, 200]` へ丸めてから
/// `tan(pi * ecw * 0.0025)` へ変換し、
/// `v = clamp((i - 128 - t) * coeff + 128)` の LUT を作成して
/// RGB 各チャンネルへ適用する。アルファは保持。
pub fn burning_extended_contrast(
    buffer: &mut [u8],
    width: usize,
    height: usize,
    t: f64,
    ecw: f64,
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

    // DLL 側は t を整数化して使用する (lua_tonumber -> FUN_10005c50)。
    let t_i32 = t.round() as i32;

    let ecw_clamped = ecw.clamp(-200.0, 200.0);
    let coeff = (PI * ecw_clamped * 0.0025).tan();

    let mut lut = [0u8; 256];
    for (i, out) in lut.iter_mut().enumerate() {
        let shifted = (i as i32) - 128 - t_i32;
        let v = ((shifted as f64) * coeff + 128.0).round();
        *out = v.clamp(0.0, 255.0) as u8;
    }

    for px in buffer.chunks_exact_mut(4) {
        px[0] = lut[px[0] as usize];
        px[1] = lut[px[1] as usize];
        px[2] = lut[px[2] as usize];
    }

    Ok(())
}
