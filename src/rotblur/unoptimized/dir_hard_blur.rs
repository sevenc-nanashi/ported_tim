use super::{copy_to_work, hard_pattern, sample_bilinear_transparent, write_pixel};

#[allow(clippy::too_many_arguments)]
pub fn dir_hard_blur(
    image_buffer: &[u8],
    work_buffer: &mut [u8],
    width: usize,
    height: usize,
    blur_amount: f64,
    bump_size: i32,
    angle_rad: f64,
    amplitude_base: f64,
    roundness: f64,
    base_position: f64,
    seed: i32,
) {
    if width == 0 || height == 0 || work_buffer.len() < image_buffer.len() {
        return;
    }
    if blur_amount.abs() <= f64::EPSILON || bump_size == 0 {
        copy_to_work(image_buffer, work_buffer);
        return;
    }

    let src = image_buffer.to_vec();
    let cos_theta = angle_rad.cos();
    let sin_theta = angle_rad.sin();
    let half_width = width as f64 * 0.5;
    let half_height = height as f64 * 0.5;
    let bump_size = bump_size.abs().max(1) as f64;

    for y in 0..height {
        let y_from_center = y as f64 - half_height;
        for x in 0..width {
            let x_from_center = x as f64 - half_width;
            let phase = (x_from_center * sin_theta - y_from_center * cos_theta) / bump_size;
            let offset = blur_amount
                * hard_pattern(seed, phase, None, amplitude_base, roundness, base_position);
            let sample_x = x as f64 + cos_theta * offset;
            let sample_y = y as f64 + sin_theta * offset;
            let pixel = sample_bilinear_transparent(&src, width, height, sample_x, sample_y);
            write_pixel(work_buffer, width, x, y, pixel);
        }
    }
}
