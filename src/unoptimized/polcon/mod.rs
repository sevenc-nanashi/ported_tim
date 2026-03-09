fn sample_bilinear(src: &[u8], width: usize, height: usize, x: f64, y: f64) -> [u8; 4] {
    let x = x.clamp(0.0, (width.saturating_sub(1)) as f64);
    let y = y.clamp(0.0, (height.saturating_sub(1)) as f64);

    let x0 = x.floor() as usize;
    let y0 = y.floor() as usize;
    let x1 = (x0 + 1).min(width.saturating_sub(1));
    let y1 = (y0 + 1).min(height.saturating_sub(1));

    let fx = ((x - x0 as f64) * 256.0).floor().clamp(0.0, 255.0) as i32;
    let fy = ((y - y0 as f64) * 256.0).floor().clamp(0.0, 255.0) as i32;
    let wx0 = 256 - fx;
    let wy0 = 256 - fy;

    let idx00 = (y0 * width + x0) * 4;
    let idx10 = (y0 * width + x1) * 4;
    let idx01 = (y1 * width + x0) * 4;
    let idx11 = (y1 * width + x1) * 4;

    let w00 = wx0 * wy0;
    let w10 = fx * wy0;
    let w01 = wx0 * fy;
    let w11 = fx * fy;

    let mut out = [0u8; 4];
    for c in 0..4 {
        let p00 = src[idx00 + c] as i32;
        let p10 = src[idx10 + c] as i32;
        let p01 = src[idx01 + c] as i32;
        let p11 = src[idx11 + c] as i32;
        let v = p00 * w00 + p10 * w10 + p01 * w01 + p11 * w11;
        out[c] = ((v >> 16).clamp(0, 255)) as u8;
    }
    out
}

fn write_pixel(dst: &mut [u8], width: usize, x: usize, y: usize, px: [u8; 4]) {
    let idx = (y * width + x) * 4;
    dst[idx..idx + 4].copy_from_slice(&px);
}

pub fn polar_conversion(
    image_buffer: &mut [u8],
    work_buffer: &mut [u8],
    width: usize,
    height: usize,
    range: f64,
    apply_amount: f64,
) {
    if width == 0 || height == 0 {
        return;
    }
    let len = match width.checked_mul(height).and_then(|v| v.checked_mul(4)) {
        Some(v) => v,
        None => return,
    };
    if image_buffer.len() < len || work_buffer.len() < len {
        return;
    }

    let range = range.clamp(0.0, 1.0);

    let src = image_buffer[..len].to_vec();
    let dst = &mut work_buffer[..len];
    let cx = width as f64 * 0.5;
    let cy = height as f64 * 0.5;
    let half_w = width as f64 * 0.5;
    let half_h = height as f64 * 0.5;
    let diag_half = ((width * width + height * height) as f64).sqrt() * 0.5;
    let radius_x = half_w * range + diag_half * (1.0 - range);
    let radius_y = half_h * range + diag_half * (1.0 - range);
    if radius_x <= 0.0 || radius_y <= 0.0 {
        return;
    }
    let x_div = (width.saturating_sub(1)).max(1) as f64;
    let y_div = (height.saturating_sub(1)).max(1) as f64;
    let a = apply_amount.clamp(0.0, 1.0);
    let b = 1.0 - a;

    for y in 0..height {
        for x in 0..width {
            let nx = (x as f64 - cx) / radius_x;
            let ny = (y as f64 - cy) / radius_y;
            let theta = nx.atan2(ny);
            let r = (nx * nx + ny * ny).sqrt();
            let sx = ((theta / std::f64::consts::PI) + 1.0) * x_div * 0.5;
            let sy = r * y_div;
            let bx = b * x as f64 + a * sx;
            let by = b * y as f64 + a * sy;
            if bx < 0.0 || bx > x_div || by < 0.0 || by > y_div {
                write_pixel(dst, width, x, y, [0, 0, 0, 0]);
            } else {
                let px = sample_bilinear(&src, width, height, bx, by);
                write_pixel(dst, width, x, y, px);
            }
        }
    }

    image_buffer[..len].copy_from_slice(dst);
}

pub fn polar_inversion(
    image_buffer: &mut [u8],
    work_buffer: &mut [u8],
    width: usize,
    height: usize,
    range: f64,
    apply_amount: f64,
) {
    if width == 0 || height == 0 {
        return;
    }
    let len = match width.checked_mul(height).and_then(|v| v.checked_mul(4)) {
        Some(v) => v,
        None => return,
    };
    if image_buffer.len() < len || work_buffer.len() < len {
        return;
    }

    let range = range.clamp(0.0, 1.0);

    let src = image_buffer[..len].to_vec();
    let dst = &mut work_buffer[..len];
    let cx = width as f64 * 0.5;
    let cy = height as f64 * 0.5;
    let half_w = width as f64 * 0.5;
    let half_h = height as f64 * 0.5;
    let diag_half = ((width * width + height * height) as f64).sqrt() * 0.5;
    let radius_x = half_w * range + diag_half * (1.0 - range);
    let radius_y = half_h * range + diag_half * (1.0 - range);
    if radius_x <= 0.0 || radius_y <= 0.0 {
        return;
    }
    let tau = std::f64::consts::PI * 2.0;
    let x_scale = (width.saturating_sub(1)).max(1) as f64;
    let y_scale = (height.saturating_sub(1)).max(1) as f64;
    let a = apply_amount.clamp(0.0, 1.0);
    let b = 1.0 - a;

    for y in 0..height {
        for x in 0..width {
            let mut theta = (2.0 * x as f64 / x_scale - 1.0) * std::f64::consts::PI;
            if theta < -std::f64::consts::PI {
                theta += tau;
            }
            let t = y as f64 / y_scale;
            let sx = cx + theta.sin() * (radius_x * t);
            let sy = cy + theta.cos() * (radius_y * t);
            let bx = b * x as f64 + a * sx;
            let by = b * y as f64 + a * sy;
            if bx < 0.0 || bx > x_scale || by < 0.0 || by > y_scale {
                write_pixel(dst, width, x, y, [0, 0, 0, 0]);
            } else {
                let mapped = sample_bilinear(&src, width, height, bx, by);
                write_pixel(dst, width, x, y, mapped);
            }
        }
    }

    image_buffer[..len].copy_from_slice(dst);
}
