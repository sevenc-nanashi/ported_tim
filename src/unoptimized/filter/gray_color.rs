pub fn gray_color(
    image_buffer: &mut [u8],
    width: usize,
    height: usize,
    r1: i32,
    g1: i32,
    b1: i32,
    r2: i32,
    g2: i32,
    b2: i32,
) {
    let pixel_count = width.saturating_mul(height);
    let required = pixel_count.saturating_mul(4);
    if image_buffer.len() < required {
        return;
    }

    for i in 0..pixel_count {
        let p = i * 4;
        let px = image_buffer[p] as i32;
        let inv = 255 - px;

        let b = ((inv * b1 + px * b2) / 255).clamp(0, 255) as u8;
        let g = ((inv * g1 + px * g2) / 255).clamp(0, 255) as u8;
        let r = ((inv * r1 + px * r2) / 255).clamp(0, 255) as u8;

        image_buffer[p] = b;
        image_buffer[p + 1] = g;
        image_buffer[p + 2] = r;
    }
}
