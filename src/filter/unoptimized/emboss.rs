fn clamp_u8(v: f64) -> u8 {
    if !v.is_finite() || v <= 0.0 {
        0
    } else if v >= 255.0 {
        255
    } else {
        v.round() as u8
    }
}

fn direction_kernels() -> [[i32; 9]; 8] {
    [
        [-2, -1, 0, -1, 0, 1, 0, 1, 2],
        [-1, -2, -1, 0, 0, 0, 1, 2, 1],
        [0, -1, -2, 1, 0, -1, 2, 1, 0],
        [1, 0, -1, 2, 0, -2, 1, 0, -1],
        [2, 1, 0, 1, 0, -1, 0, -1, -2],
        [1, 2, 1, 0, 0, 0, -1, -2, -1],
        [0, 1, 2, -1, 0, 1, -2, -1, 0],
        [-1, 0, 1, -2, 0, 2, -1, 0, 1],
    ]
}

pub fn emboss(image_buffer: &mut [u8], width: usize, height: usize, strength: f64, direction: i32) {
    if width < 3 || height < 3 {
        return;
    }

    let pixel_count = width.saturating_mul(height);
    let required = pixel_count.saturating_mul(4);
    if image_buffer.len() < required {
        return;
    }

    let src = image_buffer.to_vec();
    let kernels = direction_kernels();
    let kernel = kernels[(direction.rem_euclid(8)) as usize];
    let s = strength.clamp(-10.0, 10.0);

    for y in 1..(height - 1) {
        for x in 1..(width - 1) {
            let idx = (y * width + x) * 4;
            let alpha = src[idx + 3];

            for channel in 0..3 {
                let center = src[idx + channel] as f64;
                let mut conv = 0.0;
                let mut k = 0usize;
                for oy in -1..=1 {
                    for ox in -1..=1 {
                        let ny = (y as isize + oy) as usize;
                        let nx = (x as isize + ox) as usize;
                        let nidx = (ny * width + nx) * 4 + channel;
                        conv += src[nidx] as f64 * kernel[k] as f64;
                        k += 1;
                    }
                }
                image_buffer[idx + channel] = clamp_u8(center + conv * s);
            }

            image_buffer[idx + 3] = alpha;
        }
    }
}
