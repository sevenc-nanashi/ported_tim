pub fn flat_rgb(image_buffer: &mut [u8], width: usize, height: usize, mode: i32) {
    let pixel_count = width.saturating_mul(height);
    let required = pixel_count.saturating_mul(4);
    if image_buffer.len() < required || pixel_count == 0 {
        return;
    }

    for i in 0..pixel_count {
        let p = i * 4;
        let b = image_buffer[p];
        let g = image_buffer[p + 1];
        let r = image_buffer[p + 2];

        match mode {
            // Keep R as displacement channel, center others.
            1 => {
                image_buffer[p] = 0x80;
                image_buffer[p + 1] = 0x80;
                image_buffer[p + 2] = r;
            }
            // Keep G as displacement channel, center others.
            2 => {
                image_buffer[p] = 0x80;
                image_buffer[p + 1] = g;
                image_buffer[p + 2] = 0x80;
            }
            // Keep B as displacement channel, center others.
            _ => {
                image_buffer[p] = b;
                image_buffer[p + 1] = 0x80;
                image_buffer[p + 2] = 0x80;
            }
        }
    }
}
