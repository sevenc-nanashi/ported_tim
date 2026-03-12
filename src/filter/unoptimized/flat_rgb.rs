pub fn flat_rgb(image_buffer: &mut [u8], width: usize, height: usize, mode: i32) {
    let pixel_count = width.saturating_mul(height);
    let required = pixel_count.saturating_mul(4);
    if image_buffer.len() < required || pixel_count == 0 {
        return;
    }

    for px in image_buffer.chunks_exact_mut(4).take(pixel_count) {
        let packed = u32::from_le_bytes([px[0], px[1], px[2], px[3]]);
        let converted = match mode {
            // mode=1: (A,R) を保持し B/G を 0x80 固定
            1 => (packed & 0xff00_0000) | (packed & 0x00ff_0000) | 0x0000_8080,
            // mode=2: (A,G) を保持し B/R を 0x80 固定
            2 => (packed & 0xff00_0000) | (packed & 0x0000_ff00) | 0x0080_0080,
            // mode=other: (A,B) を保持し G/R を 0x80 固定
            _ => (packed & 0xff00_80ff) | 0x0080_8000,
        };
        let bytes = converted.to_le_bytes();
        px[0] = bytes[0];
        px[1] = bytes[1];
        px[2] = bytes[2];
        px[3] = bytes[3];
    }
}
