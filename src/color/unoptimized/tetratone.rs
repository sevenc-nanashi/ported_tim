use anyhow::{Result, bail};

pub fn tetratone(
    pixels: &mut [u8],
    width: usize,
    height: usize,
    col1: u32, // 0xRRGGBB: shadow
    col2: u32, // 0xRRGGBB: midtone 1
    col3: u32, // 0xRRGGBB: midtone 2
    col4: u32, // 0xRRGGBB: highlight
    n1: u8,
    midpoint1: u8,
    midpoint2: u8,
    n2: u8,
) -> Result<()> {
    let expected_len = width
        .checked_mul(height)
        .and_then(|px| px.checked_mul(4))
        .ok_or_else(|| anyhow::anyhow!("image size overflow"))?;

    if pixels.len() != expected_len {
        bail!(
            "buffer length mismatch: got {}, expected {}",
            pixels.len(),
            expected_len
        );
    }

    // Lua 側では table.sort(p) してから渡している。
    // 同じ実用上の挙動にするため、ここでも昇順に整列して使う。
    let mut points = [n1, midpoint1, midpoint2, n2];
    points.sort_unstable();
    let [n1, midpoint1, midpoint2, n2] = points;

    let c1 = rgb_from_u32(col1);
    let c2 = rgb_from_u32(col2);
    let c3 = rgb_from_u32(col3);
    let c4 = rgb_from_u32(col4);

    // 元コードは 2048 要素の LUT を作ってから画素変換している。
    // LUT も BGRA ではなく、色成分のみを B,G,R の順で保持する。
    let mut lut = vec![[0u8; 3]; 2048];

    for i in 0..2048usize {
        let x = (i as f64) * 255.0 / 2047.0;

        let rgb = match () {
            _ if x <= n1 as f64 => c1,
            _ if x <= midpoint1 as f64 => lerp_rgb(c1, c2, x, n1 as f64, midpoint1 as f64),
            _ if x <= midpoint2 as f64 => lerp_rgb(c2, c3, x, midpoint1 as f64, midpoint2 as f64),
            _ if x <= n2 as f64 => lerp_rgb(c3, c4, x, midpoint2 as f64, n2 as f64),
            _ if x <= 255.0 => c4,
            _ => unreachable!("LUT input must stay within [0, 255]"),
        };

        lut[i] = [rgb.b, rgb.g, rgb.r];
    }

    for px in pixels.chunks_exact_mut(4) {
        let b = px[0] as f64;
        let g = px[1] as f64;
        let r = px[2] as f64;
        let a = px[3];

        // 元コードと同じ係数
        let luma = r * 0.298_912 + g * 0.586_61 + b * 0.114_478;
        let idx = ((luma * 2047.0) / 255.0) as usize;

        let mapped = lut[idx];
        px[0] = mapped[0]; // B
        px[1] = mapped[1]; // G
        px[2] = mapped[2]; // R
        px[3] = a; // A は保持
    }

    Ok(())
}

#[derive(Copy, Clone, Debug)]
struct Rgb {
    r: u8,
    g: u8,
    b: u8,
}

fn rgb_from_u32(color: u32) -> Rgb {
    Rgb {
        r: ((color >> 16) & 0xff) as u8,
        g: ((color >> 8) & 0xff) as u8,
        b: (color & 0xff) as u8,
    }
}

fn lerp_rgb(a: Rgb, b: Rgb, x: f64, x0: f64, x1: f64) -> Rgb {
    if x1 <= x0 {
        // Lua 側では sort 済みのため本来ここには来ない。
        // 同一点が渡された場合は前側の色を返す。
        return a;
    }

    let t = (x - x0) / (x1 - x0);

    Rgb {
        r: lerp_u8(a.r, b.r, t),
        g: lerp_u8(a.g, b.g, t),
        b: lerp_u8(a.b, b.b, t),
    }
}

fn lerp_u8(a: u8, b: u8, t: f64) -> u8 {
    let af = a as f64;
    let bf = b as f64;
    let v = af + (bf - af) * t;

    if v <= 0.0 {
        0
    } else if v >= 255.0 {
        255
    } else {
        v as u8
    }
}
