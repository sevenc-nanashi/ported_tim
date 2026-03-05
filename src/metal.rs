pub enum GrayMode {
    Average = 0,
    Lightness = 1,
    Luminance = 2,
}

pub fn metal(image_buffer: &mut [u8], flip_upper: u8, flip_lower: u8, gray_mode: GrayMode) {
    let (flip_lower, flip_upper) = if flip_upper < flip_lower {
        (flip_upper, flip_lower)
    } else {
        (flip_lower, flip_upper)
    };

    let lut = build_lut(flip_upper, flip_lower);

    process_pixels(&lut, gray_mode, image_buffer);
}

fn build_lut(upper: u8, lower: u8) -> [u8; 1021] {
    let mut lut = [0u8; 1021];

    lut.iter_mut().enumerate().for_each(|(i, v)| {
        let mut x = (i as f64) * 0.25;
        if x > 255.0 {
            x = 255.0;
        }

        let y = if x >= lower as f64 {
            if upper as f64 > x {
                // lower <= x < upper
                if upper == lower {
                    0.0
                } else {
                    (upper as f64 - x) * 255.0 / ((upper - lower) as f64)
                }
            } else {
                // x >= upper
                if upper == 255 {
                    255.0
                } else {
                    (x - upper as f64) * 255.0 / ((255 - upper) as f64)
                }
            }
        } else {
            // x < lower
            if lower == 0 {
                255.0
            } else {
                x * 255.0 / (lower as f64)
            }
        };

        let yi = y as i32;
        let yi = yi.clamp(0, 255) as u8;

        *v = yi;
    });

    lut
}
fn process_pixels(lut: &[u8; 1021], mode: GrayMode, pixels: &mut [u8]) {
    let count = pixels.len() / 4;

    for i in 0..count {
        let idx = i * 4;

        let r_rgba = pixels[idx] as f64;
        let g_rgba = pixels[idx + 1] as f64;
        let b_rgba = pixels[idx + 2] as f64;
        let a = pixels[idx + 3];

        let b = r_rgba;
        let g = g_rgba;
        let r = b_rgba;

        let gray = match mode {
            GrayMode::Average => (r + g + b) / 3.0,
            GrayMode::Lightness => r * 0.298912 + g * 0.58661 + b * 0.114478,
            GrayMode::Luminance => {
                let lr = (r / 255.0).powf(2.2);
                let lg = (g / 255.0).powf(2.2);
                let lb = (b / 255.0).powf(2.2);
                let y = lb * 0.07133 + lg * 0.706655 + lr * 0.222015;
                y.powf(1.0 / 2.2) * 255.0
            }
        };

        let mut li = (gray * 4.0) as i32;
        li = li.clamp(0, 1020);
        let v = lut[li as usize];

        pixels[idx] = v;
        pixels[idx + 1] = v;
        pixels[idx + 2] = v;
        pixels[idx + 3] = a;
    }
}
