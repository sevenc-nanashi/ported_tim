use std::f64::consts::PI;

use super::{RandomBlurState, copy_clamped_pixel, random_offset};

pub fn pal_rand_blur(
    state: &mut RandomBlurState,
    image_buffer: &mut [u8],
    width: usize,
    height: usize,
    max_offset: f64,
    angle_deg: f64,
    seed: i32,
    base_position: f64,
) {
    if width == 0 || height == 0 || max_offset.abs() <= f64::EPSILON {
        return;
    }

    let src = image_buffer.to_vec();
    let radians = angle_deg * PI / 180.0;
    let cos_angle = radians.cos();
    let sin_angle = radians.sin();

    state.with_rng(seed, |rng| {
        for y in 0..height {
            for x in 0..width {
                let delta = random_offset(rng, base_position) * max_offset;
                let sample_x = (x as f64 + cos_angle * delta).round() as i32;
                let sample_y = (y as f64 + sin_angle * delta).round() as i32;
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
