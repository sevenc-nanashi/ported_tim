use std::f64::consts::PI;

use super::{RandomBlurState, copy_clamped_pixel, random_offset};

pub fn rot_rand_blur(
    state: &mut RandomBlurState,
    image_buffer: &mut [u8],
    width: usize,
    height: usize,
    max_offset: f64,
    _radius: f64,
    center_x: f64,
    center_y: f64,
    seed: i32,
    base_position: f64,
) {
    if width == 0 || height == 0 || max_offset.abs() <= f64::EPSILON {
        return;
    }

    let src = image_buffer.to_vec();
    let origin_x = width as f64 * 0.5 + center_x;
    let origin_y = height as f64 * 0.5 + center_y;
    let max_angle = max_offset * PI / 180.0;

    state.with_rng(seed, |rng| {
        for y in 0..height {
            let dy = y as f64 - origin_y;
            for x in 0..width {
                let dx = x as f64 - origin_x;
                let theta = random_offset(rng, base_position) * max_angle;
                let sin_theta = theta.sin();
                let cos_theta = theta.cos();
                let sample_x = (origin_x + dx * cos_theta + dy * sin_theta + 0.5).round() as i32;
                let sample_y = (origin_y + dy * cos_theta - dx * sin_theta + 0.5).round() as i32;
                copy_clamped_pixel(
                    &src,
                    image_buffer,
                    width,
                    height,
                    y * width + x,
                    sample_x,
                    sample_y,
                );
            }
        }
    });
}
