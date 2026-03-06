use anyhow::{Result, ensure};

#[inline]
fn clamp_u8_from_i32(v: i32) -> u8 {
    if v <= 0 {
        0
    } else if v >= 255 {
        255
    } else {
        v as u8
    }
}

/// C の sub_100151F0 + sub_10015240 相当:
/// lut[0..=255]   = 0..=255
/// lut[256..=511] = 255
fn build_monochromatic_lut() -> [u8; 512] {
    let mut lut = [0u8; 512];

    for i in 0..=255usize {
        lut[i] = i as u8;
    }
    for i in 256..=511usize {
        lut[i] = 255;
    }

    lut
}

/// C の sub_10015290 相当を、単一スレッド・BGRA 前提でそのまま Rust 化したもの。
///
/// 各ピクセルについて:
/// - 元の B,G,R から NTSC 風重みでグレースケールを算出
/// - B = min(gray + track_b, 255)
/// - G = min(gray + track_g, 255)
/// - R = min(gray + track_r, 255)
/// - A は保持
///
/// `track_r/g/b` は Lua 側定義どおり 0..=255 想定。
pub fn monochromatic(
    userdata: &mut [u8],
    w: usize,
    h: usize,
    track_r: u8,
    track_g: u8,
    track_b: u8,
) -> Result<()> {
    ensure!(
        userdata.len()
            == w.checked_mul(h)
                .and_then(|px| px.checked_mul(4))
                .unwrap_or(usize::MAX),
        "userdata length does not match w * h * 4"
    );

    let lut = build_monochromatic_lut();

    let pixel_count = w
        .checked_mul(h)
        .ok_or_else(|| anyhow::anyhow!("w * h overflow"))?;

    for i in 0..pixel_count {
        let base = i * 4;

        // BGRA
        let b = userdata[base] as f64;
        let g = userdata[base + 1] as f64;
        let r = userdata[base + 2] as f64;
        let a = userdata[base + 3];

        // C:
        // gray = (int)(r * 0.298912 + g * 0.58661 + b * 0.114478);
        let gray = (r * 0.298_912 + g * 0.586_61 + b * 0.114_478) as usize;

        // C の LUT 参照:
        // byte0(B) = lut[track_b + gray]
        // byte1(G) = lut[gray + track_g]
        // byte2(R) = lut[gray + track_r]
        //
        // track_* は 0..=255、gray も 0..=255 のため index は 0..=510 になり安全。
        let new_b = lut[gray + track_b as usize];
        let new_g = lut[gray + track_g as usize];
        let new_r = lut[gray + track_r as usize];

        userdata[base] = new_b;
        userdata[base + 1] = new_g;
        userdata[base + 2] = new_r;
        userdata[base + 3] = a;
    }

    Ok(())
}
