use std::f64::consts::TAU;

use super::{copy_to_work, hard_pattern, sample_bilinear_transparent, write_pixel};

#[allow(clippy::too_many_arguments)]
pub fn rad_hard_blur(
    image_buffer: &[u8],
    work_buffer: &mut [u8],
    width: usize,
    height: usize,
    blur_amount: f64,
    center_x: f64,
    center_y: f64,
    count: i32,
    amplitude_base: f64,
    roundness: f64,
    base_position: f64,
    seed: i32,
) {
    if width == 0 || height == 0 || work_buffer.len() < image_buffer.len() {
        return;
    }
    if blur_amount.abs() <= f64::EPSILON {
        copy_to_work(image_buffer, work_buffer);
        return;
    }

    let src = image_buffer.to_vec();
    let cx = width as f64 * 0.5 + center_x;
    let cy = height as f64 * 0.5 + center_y;
    let count = count.max(1) as usize;

    for y in 0..height {
        let dy = y as f64 - cy;
        for x in 0..width {
            let dx = x as f64 - cx;
            let angle_phase = dy.atan2(dx).rem_euclid(TAU) * count as f64 / TAU;
            let scale = 1.0
                + blur_amount
                    * hard_pattern(
                        seed,
                        angle_phase,
                        Some(count),
                        amplitude_base,
                        roundness,
                        base_position,
                    );
            let sample_x = cx + dx * scale;
            let sample_y = cy + dy * scale;
            let pixel = sample_bilinear_transparent(&src, width, height, sample_x, sample_y);
            write_pixel(work_buffer, width, x, y, pixel);
        }
    }
}
