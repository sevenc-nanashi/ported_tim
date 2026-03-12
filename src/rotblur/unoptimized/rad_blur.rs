use std::mem;

use super::{sample_nearest_legacy, trunc_to_u8, write_pixel};

pub fn rad_blur(
    image_buffer: &mut [u8],
    width: usize,
    height: usize,
    blur_amount: f64,
    center_x: f64,
    center_y: f64,
    base_position: f64,
) {
    if width == 0 || height == 0 || blur_amount.abs() <= f64::EPSILON {
        return;
    }

    let blur_scale = blur_amount / 200.0;
    let inner = 1.0 - (base_position + 1.0) * blur_scale;
    let outer = 1.0 + (1.0 - base_position) * blur_scale;
    let (sign, mut inner_abs) = if inner < 0.0 {
        (-1.0, -inner)
    } else {
        (1.0, inner)
    };
    let mut outer_scale = outer;
    let cx = width as f64 * 0.5 + center_x;
    let cy = height as f64 * 0.5 + center_y;
    let max_dx = cx.abs().max((width as f64 - cx).abs());
    let max_dy = cy.abs().max((height as f64 - cy).abs());
    let displacement = max_dx.hypot(max_dy) * (outer_scale - sign * inner_abs).abs();
    let mut iterations = next_power_of_two(displacement).max(2);
    let mut src = image_buffer.to_vec();
    let mut dst = vec![0; image_buffer.len()];

    while iterations > 1 {
        inner_abs = inner_abs.sqrt();
        outer_scale = outer_scale.sqrt();
        let scale_sum = inner_abs + outer_scale;
        apply_rad_blur_pass(
            &src,
            &mut dst,
            width,
            height,
            cx,
            cy,
            sign,
            inner_abs,
            outer_scale,
            scale_sum,
        );
        iterations >>= 1;
        mem::swap(&mut src, &mut dst);
    }

    image_buffer.copy_from_slice(&src);
}

#[allow(clippy::too_many_arguments)]
fn apply_rad_blur_pass(
    src: &[u8],
    dst: &mut [u8],
    width: usize,
    height: usize,
    center_x: f64,
    center_y: f64,
    sign: f64,
    inner_scale: f64,
    outer_scale: f64,
    scale_sum: f64,
) {
    for y in 0..height {
        let dy = y as f64 - center_y;
        for x in 0..width {
            let dx = x as f64 - center_x;
            let inner_pixel = sample_nearest_legacy(
                src,
                width,
                height,
                dx * inner_scale * sign + center_x,
                dy * inner_scale * sign + center_y,
            );
            let outer_pixel = sample_nearest_legacy(
                src,
                width,
                height,
                dx * outer_scale + center_x,
                dy * outer_scale + center_y,
            );
            let weighted_alpha =
                inner_pixel[3] as f64 * inner_scale + outer_pixel[3] as f64 * outer_scale;
            let out = if weighted_alpha > 0.0 {
                [
                    trunc_to_u8(
                        (inner_pixel[0] as f64 * inner_pixel[3] as f64 * inner_scale
                            + outer_pixel[0] as f64 * outer_pixel[3] as f64 * outer_scale)
                            / weighted_alpha,
                    ),
                    trunc_to_u8(
                        (inner_pixel[1] as f64 * inner_pixel[3] as f64 * inner_scale
                            + outer_pixel[1] as f64 * outer_pixel[3] as f64 * outer_scale)
                            / weighted_alpha,
                    ),
                    trunc_to_u8(
                        (inner_pixel[2] as f64 * inner_pixel[3] as f64 * inner_scale
                            + outer_pixel[2] as f64 * outer_pixel[3] as f64 * outer_scale)
                            / weighted_alpha,
                    ),
                    trunc_to_u8(weighted_alpha / scale_sum),
                ]
            } else {
                [
                    trunc_to_u8(
                        (inner_pixel[0] as f64 * inner_scale + outer_pixel[0] as f64 * outer_scale)
                            / scale_sum,
                    ),
                    trunc_to_u8(
                        (inner_pixel[1] as f64 * inner_scale + outer_pixel[1] as f64 * outer_scale)
                            / scale_sum,
                    ),
                    trunc_to_u8(
                        (inner_pixel[2] as f64 * inner_scale + outer_pixel[2] as f64 * outer_scale)
                            / scale_sum,
                    ),
                    0,
                ]
            };
            write_pixel(dst, width, x, y, out);
        }
    }
}

fn next_power_of_two(value: f64) -> i32 {
    if !value.is_finite() || value <= 0.0 {
        return 1;
    }
    2.0f64.powf(value.log2().ceil()) as i32
}
