fn cvt_f64_to_i32_like_dll(v: f64) -> i32 {
    (v as f32) as i32
}

fn build_lut(divide: f64) -> [u8; 256] {
    let mut lut = [0x80u8; 256];
    let scale = divide * 0.5 * 255.0;
    let low = cvt_f64_to_i32_like_dll(127.5 - scale);
    let high = cvt_f64_to_i32_like_dll((127.5 - scale) + 127.5);

    if low > 0 {
        let low_u = low as usize;
        for (src, dst) in lut.iter_mut().enumerate().take(low_u.min(256)) {
            let mapped = ((src as i32) * 128) / low;
            *dst = mapped.clamp(0, 255) as u8;
        }
    }

    if high < 256 {
        let den = 256 - high;
        if den > 0 {
            let start = high.max(0) as usize;
            for (k, src) in (start..256).enumerate() {
                let mapped = 128 + (((k as i32) + 1) * 127) / den;
                lut[src] = mapped.clamp(0, 255) as u8;
            }
        }
    }

    lut
}

pub fn flattening(image_buffer: &mut [u8], width: usize, height: usize, divide: f64) {
    let pixel_count = width.saturating_mul(height);
    let required = pixel_count.saturating_mul(4);
    if image_buffer.len() < required || pixel_count == 0 {
        return;
    }

    let lut = build_lut(divide);
    for px in image_buffer.chunks_exact_mut(4) {
        px[0] = lut[px[0] as usize];
        px[1] = lut[px[1] as usize];
        px[2] = lut[px[2] as usize];
    }
}
