use std::mem;

use super::{rotation_blur_iterations, sample_nearest_legacy, write_pixel};

pub fn rot_blur_l(
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
    let step = blur_rad / iterations as f64;
    let mut current = iterations / 2;
    let mut src = image_buffer.to_vec();
    let mut dst = vec![0; image_buffer.len()];

    loop {
        let half = current / 2;
        let delta = half as f64 * step;
        let base_offset = base_position * delta;
        let angle_pos = base_offset + delta;
        let angle_neg = base_offset - delta;
        apply_rot_blur_l_pass(
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
fn apply_rot_blur_l_pass(
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
            let pos = sample_nearest_legacy(
                src,
                width,
                height,
                dx * cos_pos + dy * sin_pos + center_x,
                dy * cos_pos - dx * sin_pos + center_y,
            );
            let neg = sample_nearest_legacy(
                src,
                width,
                height,
                dx * cos_neg + dy * sin_neg + center_x,
                dy * cos_neg - dx * sin_neg + center_y,
            );
            let alpha_pos = pos[3] as u32;
            let alpha_neg = neg[3] as u32;
            let alpha_sum = alpha_pos + alpha_neg;
            let out = if alpha_neg == 0 {
                [
                    ((pos[0] as u32 + neg[0] as u32) / 2) as u8,
                    ((pos[1] as u32 + neg[1] as u32) / 2) as u8,
                    ((pos[2] as u32 + neg[2] as u32) / 2) as u8,
                    alpha_sum.min(255) as u8,
                ]
            } else {
                [
                    ((pos[0] as u32 * alpha_pos + neg[0] as u32 * alpha_neg) / alpha_sum) as u8,
                    ((pos[1] as u32 * alpha_pos + neg[1] as u32 * alpha_neg) / alpha_sum) as u8,
                    ((pos[2] as u32 * alpha_pos + neg[2] as u32 * alpha_neg) / alpha_sum) as u8,
                    (alpha_sum / 2).min(255) as u8,
                ]
            };
            write_pixel(dst, width, x, y, out);
        }
    }
}
