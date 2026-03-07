use anyhow::{Result, bail};

/// T_burning_Module.dll の ShiftChannels 相当。
///
/// 各ピクセルを `A=R, B=0, G=0, R=0` に置換する。
pub fn shift_channels(buffer: &mut [u8], width: usize, height: usize) -> Result<()> {
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

    for px in buffer.chunks_exact_mut(4) {
        let red = px[2];
        px[0] = 0;
        px[1] = 0;
        px[2] = 0;
        px[3] = red;
    }

    Ok(())
}
