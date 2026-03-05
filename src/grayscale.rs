pub fn grayscale(
    userdata: &mut [u8],
    w: usize,
    h: usize,
    gray_mode: i32,
    bright_color: u32,
    dark_color: u32,
    gamma_scale: f64,
) {
    let pixel_count = w.saturating_mul(h);
    let needed = pixel_count.saturating_mul(4);
    if userdata.len() < needed || pixel_count == 0 {
        return;
    }

    // Colors are assumed to be 0xRRGGBB (Lua side typically uses this).
    let br = ((bright_color >> 16) & 0xFF) as f64;
    let bg = ((bright_color >> 8) & 0xFF) as f64;
    let bb = (bright_color & 0xFF) as f64;

    let dr = ((dark_color >> 16) & 0xFF) as f64;
    let dg = ((dark_color >> 8) & 0xFF) as f64;
    let db = (dark_color & 0xFF) as f64;

    // In the decompiled code: a5 = a5 / 255.0; then grayscale_value *= a5;
    // with Lua passing gamma_scale = 100/gamma, this becomes scale = gamma_scale/255.
    let scale = gamma_scale / 255.0;

    for i in 0..pixel_count {
        let p = i * 4;

        // userdata is BGRA
        let b = userdata[p] as f64;
        let g = userdata[p + 1] as f64;
        let r = userdata[p + 2] as f64;
        let a = userdata[p + 3];

        // Compute luminance in [0, ~gamma_scale] then clamp to [0, 1].
        // This mirrors:
        //  - mode 0: ((r+g+b)/3) * scale
        //  - mode 1: (r*0.298912 + g*0.58661 + b*0.114478) * scale
        //  - mode 2: gamma-correct luminance, then * gamma_scale
        let mut t = match gray_mode {
            0 => ((r + g + b) / 3.0) * scale,
            1 => (r * 0.298_912 + g * 0.586_61 + b * 0.114_478) * scale,
            2 => {
                let rf = r / 255.0;
                let gf = g / 255.0;
                let bf = b / 255.0;

                // Decompiled constants:
                //   0.222015 (R), 0.706655 (G), 0.07133 (B), gamma 2.2 and 1/2.2
                let lin =
                    rf.powf(2.2) * 0.222_015 + gf.powf(2.2) * 0.706_655 + bf.powf(2.2) * 0.071_33;
                gamma_scale * lin.max(0.0).powf(1.0 / 2.2)
            }
            _ => (r * 0.298_912 + g * 0.586_61 + b * 0.114_478) * scale,
        };

        if !t.is_finite() {
            t = 0.0;
        }
        t = t.clamp(0.0, 1.0);

        // Lerp dark->bright by t, write back as BGRA, preserve alpha.
        let out_r = (dr + (br - dr) * t).round().clamp(0.0, 255.0) as u8;
        let out_g = (dg + (bg - dg) * t).round().clamp(0.0, 255.0) as u8;
        let out_b = (db + (bb - db) * t).round().clamp(0.0, 255.0) as u8;

        userdata[p] = out_b;
        userdata[p + 1] = out_g;
        userdata[p + 2] = out_r;
        userdata[p + 3] = a;
    }
}
