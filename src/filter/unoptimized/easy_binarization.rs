pub fn easy_binarization(image_buffer: &mut [u8], width: usize, height: usize, threshold: i32) {
    let pixel_count = width.saturating_mul(height);
    let required = pixel_count.saturating_mul(4);
    if image_buffer.len() < required {
        return;
    }

    let threshold_sum = threshold.saturating_mul(3);
    for i in 0..pixel_count {
        let p = i * 4;
        let b = image_buffer[p] as i32;
        let g = image_buffer[p + 1] as i32;
        let r = image_buffer[p + 2] as i32;
        let a = image_buffer[p + 3];
        let v = if r + g + b <= threshold_sum { 0 } else { 255 };
        image_buffer[p] = v;
        image_buffer[p + 1] = v;
        image_buffer[p + 2] = v;
        image_buffer[p + 3] = a;
    }
}
