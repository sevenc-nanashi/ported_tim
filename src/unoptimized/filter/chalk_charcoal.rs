pub fn chalk_charcoal(
    image_buffer: &mut [u8],
    width: usize,
    height: usize,
    length: i32,
    r1: i32,
    g1: i32,
    b1: i32,
    r2: i32,
    g2: i32,
    b2: i32,
) {
    let pixel_count = width.saturating_mul(height);
    let required = pixel_count.saturating_mul(4);
    if image_buffer.len() < required || width == 0 || height == 0 {
        return;
    }

    let mut base = vec![0i32; pixel_count];
    for i in 0..pixel_count {
        base[i] = image_buffer[i * 4] as i32;
    }

    let d = (length.clamp(1, 10) as f64) * 0.5;
    let p2 = (1.0 - d).round() as i32;
    let p1 = d.round() as i32;

    let mut max_map = vec![0i32; pixel_count];
    let mut min_map = vec![0i32; pixel_count];

    if p2 <= p1 {
        for x in 0..width as i32 {
            for y in 0..height as i32 {
                let mut local_max = 0x7f;
                let mut local_min = 0x80;
                let mut local_c = -1 - p2;
                let mut local_8 = p2 - 1;
                let mut count = p1 - p2 + 1;
                while count > 0 {
                    let i_var4 = local_8 + 1 + y;
                    let mut i_var5 = local_c + x;
                    for _ in 0..3 {
                        let sx = i_var5.clamp(0, width as i32 - 1) as usize;
                        let sy = i_var4.clamp(0, height as i32 - 1) as usize;
                        let v = base[sy * width + sx];
                        if local_max < v {
                            local_max = v;
                        }
                        i_var5 += 1;
                    }

                    let i_var5b = local_8 + 1 + y;
                    let mut i_var6 = local_8 + x;
                    for _ in 0..3 {
                        let sx = i_var6.clamp(0, width as i32 - 1) as usize;
                        let sy = i_var5b.clamp(0, height as i32 - 1) as usize;
                        let v = base[sy * width + sx];
                        if v < local_min {
                            local_min = v;
                        }
                        i_var6 += 1;
                    }

                    local_c -= 1;
                    local_8 += 1;
                    count -= 1;
                }

                let idx = y as usize * width + x as usize;
                max_map[idx] = local_max;
                min_map[idx] = local_min;
            }
        }
    }

    for i in 0..pixel_count {
        let p = i * 4;
        let mut v = min_map[i];
        if v == 0x80 {
            v = max_map[i];
        }
        let inv = 0xff - v;
        let a = image_buffer[p + 3] as i32;

        let out_b = ((inv * b1 + v * b2) / 0xff).clamp(0, 255) as u8;
        let out_g = ((inv * g1 + v * g2) / 0xff).clamp(0, 255) as u8;
        let out_r = ((inv * r1 + v * r2) / 0xff).clamp(0, 255) as u8;

        image_buffer[p] = out_b;
        image_buffer[p + 1] = out_g;
        image_buffer[p + 2] = out_r;
        image_buffer[p + 3] = a.clamp(0, 255) as u8;
    }
}
