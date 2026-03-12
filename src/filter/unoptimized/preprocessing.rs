fn cvt_f64_to_i32_like_dll(v: f64) -> i32 {
    (v as f32) as i32
}

fn clamp_u8_i32(v: i32) -> i32 {
    v.clamp(0, 255)
}

fn build_threshold_lut(threshold: i32) -> [i32; 256] {
    let mut lut = [0i32; 256];

    if threshold > 0 {
        let th = threshold as f64;
        let upper = threshold.min(256) as usize;
        for (i, dst) in lut.iter_mut().enumerate().take(upper) {
            *dst = cvt_f64_to_i32_like_dll(i as f64 * 128.0 / th);
        }
    }

    if threshold < 256 {
        let den = (255 - threshold).max(1) as f64;
        let start = threshold.max(0) as usize;
        for (i, dst) in lut.iter_mut().enumerate().skip(start) {
            let t = (i as i32 - threshold) as f64;
            let v = 128.0 - cvt_f64_to_i32_like_dll(t * -127.5 / den) as f64;
            *dst = v as i32;
        }
    }

    lut
}

fn build_curve_lut_a(pen_scale: f64, charcoal_exp: f64) -> [i32; 256] {
    let mut lut = [0i32; 256];
    for (i, dst) in lut.iter_mut().enumerate() {
        let x = i as f64 / 255.0;
        let base = ((x.powf(charcoal_exp) as f32) as f64) * 255.0;
        let y = (base - 127.5) * pen_scale + 127.5;
        *dst = clamp_u8_i32(cvt_f64_to_i32_like_dll(y));
    }
    lut
}

fn build_curve_lut_b(pen_scale: f64, chalk_exp: f64) -> [i32; 256] {
    let mut lut = [0i32; 256];
    for (i, dst) in lut.iter_mut().enumerate() {
        let x = 1.0 - (i as f64 / 255.0);
        let p = (x.powf(chalk_exp) as f32) as f64;
        let base = 255.0 * (1.0 - p);
        let y = (base - 127.5) * pen_scale + 127.5;
        *dst = clamp_u8_i32(cvt_f64_to_i32_like_dll(y));
    }
    lut
}

pub fn preprocessing(
    image_buffer: &mut [u8],
    width: usize,
    height: usize,
    charcoal_apply: f64,
    chalk_apply: f64,
    pen_pressure: f64,
    threshold: i32,
    auto_threshold: bool,
) {
    if width == 0 || height == 0 {
        return;
    }

    let pixel_count = width.saturating_mul(height);
    let required = pixel_count.saturating_mul(4);
    if image_buffer.len() < required {
        return;
    }

    let mut gray = vec![0i32; pixel_count];
    for (i, dst) in gray.iter_mut().enumerate() {
        *dst = image_buffer[i * 4] as i32;
    }

    let mut th = threshold;
    if auto_threshold {
        let sum: i64 = gray.iter().map(|&v| v as i64).sum();
        let avg = if pixel_count == 0 {
            0.0
        } else {
            sum as f64 / pixel_count as f64
        };
        th = cvt_f64_to_i32_like_dll(avg);
    }
    th = th.clamp(0, 255);

    let lut1 = build_threshold_lut(th);
    let lut2 = build_curve_lut_a(pen_pressure + 0.5, charcoal_apply + 1.0);
    let lut3 = build_curve_lut_b(pen_pressure + 0.5, chalk_apply + 1.0);

    if threshold == 0 {
        for v in &mut gray {
            let v0 = (*v).clamp(0, 255) as usize;
            let v1 = lut1[v0] as usize;
            let v2 = lut3[v1.clamp(0, 255)] as usize;
            *v = lut2[v2.clamp(0, 255)];
        }
    } else {
        for i in 0..pixel_count {
            let src = image_buffer[i * 4] as usize;
            let v1 = lut1[src];
            let v2 = lut3[v1.clamp(0, 255) as usize];
            gray[i] = lut2[v2.clamp(0, 255) as usize];
        }
    }

    for i in 0..pixel_count {
        let p = i * 4;
        let v = gray[i].clamp(0, 255) as u8;
        let a = image_buffer[p + 3];
        image_buffer[p] = v;
        image_buffer[p + 1] = v;
        image_buffer[p + 2] = v;
        image_buffer[p + 3] = a;
    }
}
