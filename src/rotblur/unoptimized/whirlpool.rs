use std::f64::consts::PI;

use super::{copy_to_work, sample_nearest_legacy, write_pixel};

pub fn whirlpool(
    image_buffer: &[u8],
    work_buffer: &mut [u8],
    width: usize,
    height: usize,
    swirl_amount_deg: f64,
    radius: f64,
    center_x: f64,
    center_y: f64,
    change: i32,
) {
    if width == 0 || height == 0 || work_buffer.len() < image_buffer.len() {
        return;
    }
    if swirl_amount_deg.abs() <= f64::EPSILON || radius.abs() <= f64::EPSILON {
        copy_to_work(image_buffer, work_buffer);
        return;
    }

    let src = image_buffer.to_vec();
    let cx = width as f64 * 0.5 + center_x;
    let cy = height as f64 * 0.5 + center_y;
    let swirl_rad = swirl_amount_deg * PI / 180.0;
    let radius_recip = 1.0 / radius.abs().max(1.0);

    for y in 0..height {
        let dy = y as f64 - cy;
        for x in 0..width {
            let dx = x as f64 - cx;
            let distance_ratio = (dx * dx + dy * dy).sqrt() * radius_recip;
            let angle = if change == 0 {
                distance_ratio * distance_ratio * swirl_rad
            } else {
                (-4.0 * distance_ratio).exp() * swirl_rad
            };
            let sin_theta = angle.sin();
            let cos_theta = angle.cos();
            let pixel = sample_nearest_legacy(
                &src,
                width,
                height,
                dx * cos_theta + dy * sin_theta + cx,
                dy * cos_theta - dx * sin_theta + cy,
            );
            write_pixel(work_buffer, width, x, y, pixel);
        }
    }
}
