use anyhow::{Result, bail};

pub fn color_reduction(buf: &mut [u8], shift: u8) -> Result<()> {
    if !buf.len().is_multiple_of(4) {
        bail!("buffer length is not a multiple of 4: {}", buf.len());
    }

    // 元コードの意味:
    // B,G,R をそれぞれ
    //   (channel >> shift) << shift
    // に丸める。A はそのまま。
    //
    // shift >= 8 の場合、Cのシフトは未定義/実装依存になりうるので、
    // ここでは安全側で拒否する。
    if shift >= 8 {
        bail!("track_color/shift must be in 0..=7, got {}", shift);
    }

    for px in buf.chunks_exact_mut(4) {
        let [b, g, r, a] = px else {
            unreachable!("chunks_exact_mut(4) always yields 4-byte chunks");
        };

        *b = (*b >> shift) << shift;
        *g = (*g >> shift) << shift;
        *r = (*r >> shift) << shift;
        let _ = a; // Aは不変
    }

    Ok(())
}
