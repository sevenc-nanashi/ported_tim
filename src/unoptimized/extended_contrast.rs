use anyhow::{Result, bail};

/// Lua 側の呼び出しと同じ並びを想定:
/// ExtendedContrast(userdata, w, h, center, intensity, brightness, smooth, show_curve)
///
/// - `buffer` は BGRA 8bit x 4 の画素列
/// - `w`, `h` はピクセル単位
/// - `center`, `intensity`, `brightness`, `smooth` は Lua からそのまま渡される想定
/// - `show_curve == true` の場合は画像処理ではなくカーブ表示を描画する
pub fn extended_contrast(
    buffer: &mut [u8],
    w: usize,
    h: usize,
    center: f64,
    intensity: f64,
    brightness: f64,
    smooth: f64,
    show_curve: bool,
) -> Result<()> {
    let expected_len = w
        .checked_mul(h)
        .and_then(|px| px.checked_mul(4))
        .ok_or_else(|| anyhow::anyhow!("buffer size overflow"))?;

    if buffer.len() != expected_len {
        bail!(
            "invalid buffer length: got {}, expected {} ({}x{}x4)",
            buffer.len(),
            expected_len,
            w,
            h
        );
    }

    let lut = build_extended_contrast_lut(center, intensity, brightness, smooth);

    if show_curve {
        draw_curve_preview(buffer, w, h, &lut);
    } else {
        apply_lut_in_place(buffer, &lut);
    }

    Ok(())
}

fn build_extended_contrast_lut(
    center: f64,
    intensity: f64,
    brightness: f64,
    smooth: f64,
) -> [u8; 256] {
    let mut lut = [0u8; 256];

    let inv_smooth = 1.0 - smooth;
    let center_offset = -128.0 - center;

    for i in 0u16..=255 {
        let x = i as usize;

        let shifted = center_offset + i as f64;
        let mut v = shifted * intensity + 128.0;
        v = v.clamp(0.0, 255.0);

        let t = v / 255.0;
        let curved = (t * inv_smooth + (3.0 - t * 2.0) * (t * t) * smooth) * 255.0 + brightness;

        lut[x] = clamp_to_u8(curved);
    }

    lut
}

fn apply_lut_in_place(buffer: &mut [u8], lut: &[u8; 256]) {
    for px in buffer.chunks_exact_mut(4) {
        let b = px[0] as usize;
        let g = px[1] as usize;
        let r = px[2] as usize;
        let a = px[3];

        px[0] = lut[b];
        px[1] = lut[g];
        px[2] = lut[r];
        px[3] = a;
    }
}

fn draw_curve_preview(buffer: &mut [u8], w: usize, h: usize, lut: &[u8; 256]) {
    const BGRA_RED: u32 = 0xFFFF0000;
    const BGRA_BLACK: u32 = 0xFF000000;
    const BGRA_WHITE: u32 = 0xFFFFFFFF;

    if h == 0 || w == 0 {
        return;
    }

    for y in 0..h {
        let row_value = 255usize.saturating_mul(h.saturating_sub(y).saturating_sub(3));

        let row_curve_y = if h > 5 { row_value / (h - 5) } else { 0 };

        for x in 0..w {
            let color = if x < 2 || x > w.saturating_sub(3) || y < 2 || y > h.saturating_sub(3) {
                BGRA_RED
            } else {
                let col_value = 255usize.saturating_mul(x).saturating_sub(510);

                let curve_index = if w > 5 { col_value / (w - 5) } else { 0 };

                let lut_y = lut[curve_index.min(255)] as usize;

                if row_curve_y > lut_y {
                    BGRA_BLACK
                } else {
                    BGRA_WHITE
                }
            };

            write_bgra_u32(buffer, w, x, y, color);
        }
    }
}

fn write_bgra_u32(buffer: &mut [u8], w: usize, x: usize, y: usize, color: u32) {
    let idx = (y * w + x) * 4;
    let bytes = color.to_le_bytes();

    buffer[idx] = bytes[0];
    buffer[idx + 1] = bytes[1];
    buffer[idx + 2] = bytes[2];
    buffer[idx + 3] = bytes[3];
}

fn clamp_to_u8(v: f64) -> u8 {
    if v <= 0.0 {
        0
    } else if v >= 255.0 {
        255
    } else {
        v as u8
    }
}
