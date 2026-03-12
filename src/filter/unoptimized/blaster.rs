fn clamp_i32_to_u8(value: i32) -> u8 {
    value.clamp(0, 255) as u8
}

fn direction_kernel(direction: i32) -> [i32; 8] {
    match direction {
        0 => [2, 1, 0, 1, -1, 0, -1, -2],
        1 => [1, 2, 1, 0, 0, -1, -2, -1],
        2 => [0, 1, 2, -1, 1, -2, -1, 0],
        3 => [-1, 0, 1, -2, 2, -1, 0, 1],
        4 => [-2, -1, 0, -1, 1, 0, 1, 2],
        5 => [-1, -2, -1, 0, 0, 1, 2, 1],
        6 => [0, -1, -2, 1, -1, 2, 1, 0],
        7 => [1, 0, -1, 2, -2, 1, 0, -1],
        _ => [0; 8],
    }
}

pub fn blaster(image_buffer: &mut [u8], width: usize, height: usize, direction: i32, edge: f64) {
    if width == 0 || height == 0 {
        return;
    }
    let pixel_count = width.saturating_mul(height);
    let required = pixel_count.saturating_mul(4);
    if image_buffer.len() < required {
        return;
    }

    let mut lut = [0i32; 256];
    for (i, dst) in lut.iter_mut().enumerate() {
        *dst = (((i as i32) * 2) - 128).clamp(0, 255);
    }

    let mut alpha = vec![0i32; pixel_count];
    let mut blue = vec![0i32; pixel_count];
    let mut edge_map = vec![0i32; pixel_count];
    let mut src_packed = vec![0i32; pixel_count];

    for i in 0..pixel_count {
        let p = i * 4;
        blue[i] = image_buffer[p] as i32;
        alpha[i] = image_buffer[p + 3] as i32;
        src_packed[i] = i32::from_le_bytes([
            image_buffer[p],
            image_buffer[p + 1],
            image_buffer[p + 2],
            image_buffer[p + 3],
        ]);
    }

    let k = direction_kernel(direction);
    if width >= 7 && height >= 7 {
        for x in 3..(width - 3) {
            for y in 3..(height - 3) {
                let idx = y * width + x;

                let top = idx - width;
                let bottom = idx + width;

                let v = src_packed[top - 1]
                    .wrapping_mul(k[0])
                    .wrapping_add(src_packed[top].wrapping_mul(k[1]))
                    .wrapping_add(src_packed[top + 1].wrapping_mul(k[2]))
                    .wrapping_add(src_packed[idx - 1].wrapping_mul(k[3]))
                    .wrapping_add(src_packed[idx + 1].wrapping_mul(k[4]))
                    .wrapping_add(src_packed[bottom - 1].wrapping_mul(k[5]))
                    .wrapping_add(src_packed[bottom].wrapping_mul(k[6]))
                    .wrapping_add(src_packed[bottom + 1].wrapping_mul(k[7]));
                edge_map[idx] = v;
            }
        }
    }

    let scale = edge * -0.00001_f64;
    for v in &mut edge_map {
        let converted = ((*v as f64) * scale) as i32;
        let idx = (128 - converted).clamp(0, 255) as usize;
        *v = lut[idx];
    }

    for i in 0..pixel_count {
        let mapped = lut[((edge_map[i] * blue[i]) / 255).clamp(0, 255) as usize];
        edge_map[i] = mapped;
        if blue[i] == 255 && mapped == 128 {
            alpha[i] = 0;
        }
    }

    if width >= 7 && height >= 7 {
        let mut alpha_blur = blue.clone();
        for x in 3..(width - 3) {
            for y in 3..(height - 3) {
                let mut sum = 0i32;
                for ky in -3..=3 {
                    for kx in -3..=3 {
                        let idx =
                            ((y as isize + ky) as usize) * width + ((x as isize + kx) as usize);
                        sum += alpha[idx];
                    }
                }
                alpha_blur[y * width + x] = sum / 49;
            }
        }
        blue = alpha_blur;
    }

    for i in 0..pixel_count {
        let gray = clamp_i32_to_u8(edge_map[i]);
        let a = clamp_i32_to_u8(blue[i]);
        let p = i * 4;
        image_buffer[p] = gray;
        image_buffer[p + 1] = gray;
        image_buffer[p + 2] = gray;
        image_buffer[p + 3] = a;
    }
}
