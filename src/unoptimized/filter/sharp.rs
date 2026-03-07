fn clamp_u8(v: f64) -> u8 {
    if !v.is_finite() || v <= 0.0 {
        0
    } else if v >= 255.0 {
        255
    } else {
        v.round() as u8
    }
}

pub fn sharp(image_buffer: &mut [u8], width: usize, height: usize, strength: f64) {
    if width < 3 || height < 3 {
        return;
    }

    let pixel_count = width.saturating_mul(height);
    let required = pixel_count.saturating_mul(4);
    if image_buffer.len() < required {
        return;
    }

    let src = image_buffer.to_vec();
    let amount = strength.clamp(0.0, 10.0);

    for y in 1..(height - 1) {
        for x in 1..(width - 1) {
            let idx = (y * width + x) * 4;
            let alpha = src[idx + 3];

            for channel in 0..3 {
                let center = src[idx + channel] as f64;
                let north = src[idx - width * 4 + channel] as f64;
                let south = src[idx + width * 4 + channel] as f64;
                let west = src[idx - 4 + channel] as f64;
                let east = src[idx + 4 + channel] as f64;

                let laplacian = 4.0 * center - north - south - west - east;
                let value = center + laplacian * amount;
                image_buffer[idx + channel] = clamp_u8(value);
            }

            image_buffer[idx + 3] = alpha;
        }
    }
}
