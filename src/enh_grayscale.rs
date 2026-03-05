use aviutl2::anyhow::{self, Context};
/// Single-threaded port of `enh_grayscale_impl` + its worker functions.
/// Input pixel format: BGRA (4 bytes per pixel), row-major, length = w*h*4.
///
/// Lua call shape (13 args):
///   enh_grayscale(userdata, w, h,
///                red, green, blue, cyan, magenta, yellow, white,
///                gamma_exp, ck, col)
///
/// Notes:
/// - `gamma_exp` is used as exponent: gray = gray.powf(gamma_exp) when gamma_exp != 1.0.
/// - `ck == 1` uses HSV colorization with hue/sat derived from `col` (0xRRGGBB).
/// - otherwise uses grayscale * RGB(col) scaling (preserves alpha).
/// - Aborts (returns Err) on any missing/invalid inputs (length mismatch, NaN, etc.).
#[allow(clippy::too_many_arguments)]
pub fn enh_grayscale(
    userdata_bgra: &mut [u8],
    w: usize,
    h: usize,
    red: f64,
    green: f64,
    blue: f64,
    cyan: f64,
    magenta: f64,
    yellow: f64,
    white: f64,
    gamma_exp: f64,
    col: Option<u32>,
) -> anyhow::Result<()> {
    let px_count = w.checked_mul(h).context("w*h overflow")?;
    let need_len = px_count.checked_mul(4).context("w*h*4 overflow")?;
    if userdata_bgra.len() != need_len {
        return Err(anyhow::anyhow!(
            "userdata length mismatch: expected {}, got {}",
            need_len,
            userdata_bgra.len()
        ));
    }

    // Abort on NaN/Inf (undefined/invalid numeric inputs).
    for (name, v) in [
        ("red", red),
        ("green", green),
        ("blue", blue),
        ("cyan", cyan),
        ("magenta", magenta),
        ("yellow", yellow),
        ("white", white),
        ("gamma_exp", gamma_exp),
    ] {
        if !v.is_finite() {
            return Err(anyhow::anyhow!("{name} must be finite"));
        }
    }

    // 1) Build grayscale buffer (normalized 0..1), exactly following sub_1001A3F0.
    let mut gray: Vec<f64> = vec![0.0; px_count];
    for (i, g) in gray.iter_mut().enumerate() {
        let p = i * 4;
        let b0 = userdata_bgra[p] as f64; // B
        let g0 = userdata_bgra[p + 1] as f64; // G
        let r0 = userdata_bgra[p + 2] as f64; // R

        let m = b0.min(g0).min(r0);

        let dr = r0 - m;
        let db = b0 - m;
        let dg = g0 - m;

        let v31 = db.min(dg); // v31
        let v35 = dr.min(db); // v35
        let v37 = dr.min(dg); // v37

        // v38..v47 composition (weights assumed in Lua order):
        // a2=red, a3=green, a4=blue, a5=cyan, a6=magenta, a7=yellow, a8=white
        let v38 = (dr - (v35 - v37).abs()) * white;
        let v39 = dg - (v31 - v37).abs();
        let v40 = (db - (v31 - v35).abs()) * magenta;

        let v41 = v37 * green;
        let v42 = m * red;
        let v43 = v35 * blue;
        let v44 = v31 * cyan;

        let v45 = v38 + v43 + v41 + v42;
        let v46 = v41 + v39 * yellow + v44 + v42;
        let v47 = v42 + v43 + v40 + v44;

        // Clamp like the C (to [0,255])
        let c45 = v45.clamp(0.0, 255.0);
        let c46 = v46.clamp(0.0, 255.0);
        let c47 = v47.clamp(0.0, 255.0);

        // Pick based on dominant original channel:
        // if max==R => use c45, else if max==G => use c46, else => use c47
        let maxc = r0.max(g0).max(b0);
        let chosen = if maxc == r0 {
            c45
        } else if g0 == maxc {
            c46
        } else {
            c47
        };

        *g = chosen / 255.0;
    }

    // 2) Gamma (sub_1001A620): pow(gray, gamma_exp) when gamma_exp != 1.0
    if gamma_exp != 1.0 {
        for v in &mut gray {
            // gray is in [0,1], powf is fine
            *v = v.powf(gamma_exp);
        }
    }

    // 3) Colorize into userdata (sub_1001A680 or sub_1001A830)
    // Extract color bytes from 0xRRGGBB (as in C: low=BB, mid=GG, high=RR).

    if let Some(col) = col {
        let cb = (col & 0xFF) as f64;
        let cg = ((col >> 8) & 0xFF) as f64;
        let cr = ((col >> 16) & 0xFF) as f64;
        // Derive hue/sat from RGB(col); then apply HSV(h, s, v=gray) -> RGB.
        let (h_deg, s) = rgb_to_hs(cr / 255.0, cg / 255.0, cb / 255.0);

        for (i, v) in gray.iter().enumerate() {
            let p = i * 4;
            let a = userdata_bgra[p + 3];

            let v = v.clamp(0.0, 1.0);
            let (rr, gg, bb) = hsv_to_rgb(h_deg, s, v);

            userdata_bgra[p] = (bb * 255.0).round().clamp(0.0, 255.0) as u8;
            userdata_bgra[p + 1] = (gg * 255.0).round().clamp(0.0, 255.0) as u8;
            userdata_bgra[p + 2] = (rr * 255.0).round().clamp(0.0, 255.0) as u8;
            userdata_bgra[p + 3] = a; // preserve alpha
        }
    } else {
        // If ck == 0, the original C forces col=0xFFFFFF. That policy is done in the caller.
        // Here we just do linear scaling by the selected color bytes.
        for (i, v) in gray.iter().enumerate() {
            let p = i * 4;
            let a = userdata_bgra[p + 3];

            let v = v.clamp(0.0, 1.0);
            userdata_bgra[p] = v as u8; // B
            userdata_bgra[p + 1] = v as u8; // G
            userdata_bgra[p + 2] = v as u8; // R
            userdata_bgra[p + 3] = a; // preserve alpha
        }
    }

    Ok(())
}

/// Convert RGB -> (Hue degrees, Saturation), ignoring Value.
/// This matches the intent of `sub_10001370` usage in the decomp (feeding hue/sat into HSV->RGB).
fn rgb_to_hs(r: f64, g: f64, b: f64) -> (f64, f64) {
    let max = r.max(g).max(b);
    let min = r.min(g).min(b);
    let delta = max - min;

    let s = if max <= 0.0 { 0.0 } else { delta / max };

    let h = if delta <= 0.0 {
        0.0
    } else if max == r {
        60.0 * (((g - b) / delta) % 6.0)
    } else if max == g {
        60.0 * (((b - r) / delta) + 2.0)
    } else {
        60.0 * (((r - g) / delta) + 4.0)
    };

    let mut h_deg = h;
    if h_deg < 0.0 {
        h_deg += 360.0;
    }
    (h_deg, s.clamp(0.0, 1.0))
}

/// Standard HSV->RGB with h in degrees, s/v in [0,1].
/// Channel order returned: (R,G,B).
fn hsv_to_rgb(h_deg: f64, s: f64, v: f64) -> (f64, f64, f64) {
    let h = (h_deg % 360.0 + 360.0) % 360.0;
    let c = v * s;
    let x = c * (1.0 - (((h / 60.0) % 2.0) - 1.0).abs());
    let m = v - c;

    let (rp, gp, bp) = match (h / 60.0).floor() as i32 {
        0 => (c, x, 0.0),
        1 => (x, c, 0.0),
        2 => (0.0, c, x),
        3 => (0.0, x, c),
        4 => (x, 0.0, c),
        _ => (c, 0.0, x), // 5
    };

    ((rp + m), (gp + m), (bp + m))
}
