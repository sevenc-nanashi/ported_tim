use super::{RandomBlurState, copy_clamped_pixel, random_offset};

pub fn rad_rand_blur(
    state: &mut RandomBlurState,
    image_buffer: &mut [u8],
    width: usize,
    height: usize,
    max_offset: f64,
    radius: f64,
    center_x: f64,
    center_y: f64,
    seed: i32,
    base_position: f64,
) {
    if width == 0 || height == 0 || max_offset.abs() <= f64::EPSILON || radius.abs() <= f64::EPSILON
    {
        return;
    }

    let src = image_buffer.to_vec();
    let origin_x = width as f64 * 0.5 + center_x;
    let origin_y = height as f64 * 0.5 + center_y;
    let max_scale = max_offset / radius;

    state.with_rng(seed, |rng| {
        for y in 0..height {
            let dy = y as f64 - origin_y;
            for x in 0..width {
                let dx = x as f64 - origin_x;
                let scale = random_offset(rng, base_position) * max_scale;
                let sample_x = (x as f64 + dx * scale + 0.5).round() as i32;
                let sample_y = (y as f64 + dy * scale + 0.5).round() as i32;
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
