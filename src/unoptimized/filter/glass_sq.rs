fn write_rgb_keep_alpha(pixel: &mut [u8], b: u8, g: u8, r: u8) {
    pixel[0] = b;
    pixel[1] = g;
    pixel[2] = r;
}

fn paint_horizontal_pair(
    image_buffer: &mut [u8],
    width: usize,
    height: usize,
    n: usize,
    top_color: (u8, u8, u8),
    bottom_color: (u8, u8, u8),
) {
    if width <= n.saturating_mul(2) {
        return;
    }
    if height < n {
        return;
    }

    let y_top = n - 1;
    let y_bottom = height - n;
    for x in n..(width - n) {
        let top = (y_top * width + x) * 4;
        let bottom = (y_bottom * width + x) * 4;
        write_rgb_keep_alpha(
            &mut image_buffer[top..top + 4],
            top_color.0,
            top_color.1,
            top_color.2,
        );
        write_rgb_keep_alpha(
            &mut image_buffer[bottom..bottom + 4],
            bottom_color.0,
            bottom_color.1,
            bottom_color.2,
        );
    }
}

fn paint_vertical_pair(
    image_buffer: &mut [u8],
    width: usize,
    height: usize,
    n: usize,
    left_color: (u8, u8, u8),
    right_color: (u8, u8, u8),
) {
    if height <= n.saturating_mul(2) {
        return;
    }
    if width < n {
        return;
    }

    let x_left = n - 1;
    let x_right = width - n;
    for y in n..(height - n) {
        let left = (y * width + x_left) * 4;
        let right = (y * width + x_right) * 4;
        write_rgb_keep_alpha(
            &mut image_buffer[left..left + 4],
            left_color.0,
            left_color.1,
            left_color.2,
        );
        write_rgb_keep_alpha(
            &mut image_buffer[right..right + 4],
            right_color.0,
            right_color.1,
            right_color.2,
        );
    }
}

pub fn glass_sq(image_buffer: &mut [u8], width: usize, height: usize) {
    let pixel_count = width.saturating_mul(height);
    let required = pixel_count.saturating_mul(4);
    if image_buffer.len() < required || pixel_count == 0 {
        return;
    }

    // 0x800080 / 0x80ff80
    paint_horizontal_pair(
        image_buffer,
        width,
        height,
        3,
        (0x80, 0x00, 0x80),
        (0x80, 0xff, 0x80),
    );
    paint_horizontal_pair(
        image_buffer,
        width,
        height,
        4,
        (0x80, 0x00, 0x80),
        (0x80, 0xff, 0x80),
    );
    paint_horizontal_pair(
        image_buffer,
        width,
        height,
        5,
        (0x80, 0xff, 0x80),
        (0x80, 0x00, 0x80),
    );
    paint_horizontal_pair(
        image_buffer,
        width,
        height,
        6,
        (0x80, 0xff, 0x80),
        (0x80, 0x00, 0x80),
    );

    // 0x008080 / 0xff8080
    paint_vertical_pair(
        image_buffer,
        width,
        height,
        3,
        (0x80, 0x80, 0x00),
        (0x80, 0x80, 0xff),
    );
    paint_vertical_pair(
        image_buffer,
        width,
        height,
        4,
        (0x80, 0x80, 0x00),
        (0x80, 0x80, 0xff),
    );
    paint_vertical_pair(
        image_buffer,
        width,
        height,
        5,
        (0x80, 0x80, 0xff),
        (0x80, 0x80, 0x00),
    );
    paint_vertical_pair(
        image_buffer,
        width,
        height,
        6,
        (0x80, 0x80, 0xff),
        (0x80, 0x80, 0x00),
    );
}
