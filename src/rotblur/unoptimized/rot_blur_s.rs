use std::mem;

use super::{rotation_blur_iterations, sample_bilinear_legacy, trunc_to_u8, write_pixel};

pub fn rot_blur_s(
    image_buffer: &mut [u8],
    width: usize,
    height: usize,
    blur_amount_deg: f64,
    center_x: f64,
    center_y: f64,
    base_position: f64,
    angle_resolution_down: f64,
) {
    if width == 0 || height == 0 || blur_amount_deg.abs() <= f64::EPSILON {
        return;
    }

    let cx = width as f64 * 0.5 + center_x;
    let cy = height as f64 * 0.5 + center_y;
    let blur_rad = blur_amount_deg.to_radians();
    let iterations =
        rotation_blur_iterations(width, height, cx, cy, blur_rad, angle_resolution_down);
    let step = blur_rad / (iterations - 1) as f64;
    let mut current = iterations / 2;
    let mut src = image_buffer.to_vec();
    let mut dst = vec![0; image_buffer.len()];

    loop {
        let half = current / 2;
        let center_component = half as f64 * step * base_position;
        let span = (blur_rad / current as f64) * 0.25;
        let angle_pos = center_component + span;
        let angle_neg = center_component - span;
        apply_rot_blur_s_pass(
            &src,
            &mut dst,
            width,
            height,
            cx,
            cy,
            angle_pos.sin(),
            angle_pos.cos(),
            angle_neg.sin(),
            angle_neg.cos(),
        );
        if current < 2 {
            break;
        }
        current = half;
        mem::swap(&mut src, &mut dst);
    }

    image_buffer.copy_from_slice(&dst);
}

#[allow(clippy::too_many_arguments)]
fn apply_rot_blur_s_pass(
    src: &[u8],
    dst: &mut [u8],
    width: usize,
    height: usize,
    center_x: f64,
    center_y: f64,
    sin_pos: f64,
    cos_pos: f64,
    sin_neg: f64,
    cos_neg: f64,
) {
    for y in 0..height {
        let dy = y as f64 - center_y;
        for x in 0..width {
            let dx = x as f64 - center_x;
            let pos = sample_bilinear_legacy(
                src,
                width,
                height,
                dx * cos_pos + dy * sin_pos + center_x,
                dy * cos_pos - dx * sin_pos + center_y,
            );
            let neg = sample_bilinear_legacy(
                src,
                width,
                height,
                dx * cos_neg + dy * sin_neg + center_x,
                dy * cos_neg - dx * sin_neg + center_y,
            );
            let alpha_sum = pos.alpha + neg.alpha;
            let out = if alpha_sum == 0.0 {
                [
                    trunc_to_u8((pos.raw[0] + neg.raw[0]) * 0.5),
                    trunc_to_u8((pos.raw[1] + neg.raw[1]) * 0.5),
                    trunc_to_u8((pos.raw[2] + neg.raw[2]) * 0.5),
                    0,
                ]
            } else {
                [
                    trunc_to_u8((pos.premul[0] + neg.premul[0]) / alpha_sum),
                    trunc_to_u8((pos.premul[1] + neg.premul[1]) / alpha_sum),
                    trunc_to_u8((pos.premul[2] + neg.premul[2]) / alpha_sum),
                    trunc_to_u8(alpha_sum * 0.5),
                ]
            };
            write_pixel(dst, width, x, y, out);
        }
    }
}
