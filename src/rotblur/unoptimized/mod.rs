pub mod dir_hard_blur;
pub mod rad_blur;
pub mod rad_hard_blur;
pub mod rot_blur_l;
pub mod rot_blur_s;
pub mod rot_hard_blur;
pub mod whirlpool;

#[inline]
pub(super) fn lerp(a: f64, b: f64, t: f64) -> f64 {
    a + (b - a) * t
}

pub(super) fn shaped_fraction(frac: f64, roundness: f64) -> f64 {
    let frac = frac.clamp(0.0, 1.0);
    let roundness = roundness.clamp(-1.0, 1.0);
    if roundness == 0.0 {
        return frac;
    }

    let direction = if frac <= 0.5 { -1.0 } else { 1.0 };
    let mirrored = (frac * 2.0 - 1.0).abs();
    let base = 1.0 - roundness.abs();
    let shaped = if base <= mirrored {
        let denom = 1.0 - base * base;
        if denom <= f64::EPSILON {
            1.0
        } else {
            1.0 - (mirrored - 1.0).powi(2) / denom
        }
    } else {
        (mirrored * 2.0) / (base + 1.0)
    };

    let shaped = if roundness <= 0.0 {
        (direction * (mirrored * 2.0 - shaped) + 1.0) * 0.5
    } else {
        (direction * shaped + 1.0) * 0.5
    };
    shaped.clamp(0.0, 1.0)
}

#[derive(Clone, Copy, Default)]
pub(super) struct BilinearContribution {
    pub alpha: f64,
    pub premul: [f64; 3],
    pub raw: [f64; 3],
}

pub(super) fn rotation_blur_iterations(
    width: usize,
    height: usize,
    center_x: f64,
    center_y: f64,
    blur_rad: f64,
    resolution_down: f64,
) -> usize {
    let max_dx = center_x.abs().max((width as f64 - center_x).abs());
    let max_dy = center_y.abs().max((height as f64 - center_y).abs());
    let arc_length = max_dx.hypot(max_dy) * blur_rad.abs();
    if !arc_length.is_finite() || arc_length <= 0.0 {
        return 2;
    }

    let exponent = (arc_length.log2() - resolution_down.abs()).ceil();
    let iterations = 2.0f64.powf(exponent);
    if !iterations.is_finite() || iterations < 2.0 {
        2
    } else {
        iterations as usize
    }
}

pub(super) fn sample_bilinear_transparent(
    src: &[u8],
    width: usize,
    height: usize,
    x: f64,
    y: f64,
) -> [u8; 4] {
    sample_bilinear(src, width, height, x, y, true)
}

pub(super) fn sample_bilinear_clamped(
    src: &[u8],
    width: usize,
    height: usize,
    x: f64,
    y: f64,
) -> [u8; 4] {
    if width == 0 || height == 0 {
        return [0, 0, 0, 0];
    }

    let base_x = x.floor() as isize;
    let base_y = y.floor() as isize;
    let x0 = clamp_index(base_x, width);
    let y0 = clamp_index(base_y, height);
    let x1 = clamp_index(base_x + 1, width);
    let y1 = clamp_index(base_y + 1, height);
    let fx = ((x - base_x as f64) * 256.0).floor().clamp(0.0, 255.0) as i32;
    let fy = ((y - base_y as f64) * 256.0).floor().clamp(0.0, 255.0) as i32;
    let wx1 = ((fx * 256) + 127) / 255;
    let wy1 = ((fy * 256) + 127) / 255;
    let wx0 = 256 - wx1;
    let wy0 = 256 - wy1;
    let idx00 = (y0 * width + x0) * 4;
    let idx10 = (y0 * width + x1) * 4;
    let idx01 = (y1 * width + x0) * 4;
    let idx11 = (y1 * width + x1) * 4;
    let w00 = ((wx0 * wy0) + 127) >> 8;
    let w10 = ((wx1 * wy0) + 127) >> 8;
    let w01 = ((wx0 * wy1) + 127) >> 8;
    let w11 = ((wx1 * wy1) + 127) >> 8;
    let mut out = [0u8; 4];
    for channel in 0..4 {
        let value = src[idx00 + channel] as i32 * w00
            + src[idx10 + channel] as i32 * w10
            + src[idx01 + channel] as i32 * w01
            + src[idx11 + channel] as i32 * w11;
        out[channel] = ((value >> 8).clamp(0, 255)) as u8;
    }
    out
}

fn sample_bilinear(
    src: &[u8],
    width: usize,
    height: usize,
    x: f64,
    y: f64,
    transparent_outside: bool,
) -> [u8; 4] {
    if width == 0 || height == 0 {
        return [0, 0, 0, 0];
    }
    if transparent_outside
        && (x < 0.0
            || y < 0.0
            || x > width.saturating_sub(1) as f64
            || y > height.saturating_sub(1) as f64)
    {
        return [0, 0, 0, 0];
    }

    let x = x.clamp(0.0, width.saturating_sub(1) as f64);
    let y = y.clamp(0.0, height.saturating_sub(1) as f64);
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
    for channel in 0..4 {
        let value = src[idx00 + channel] as i32 * w00
            + src[idx10 + channel] as i32 * w10
            + src[idx01 + channel] as i32 * w01
            + src[idx11 + channel] as i32 * w11;
        out[channel] = ((value >> 16).clamp(0, 255)) as u8;
    }
    out
}

pub(super) fn sample_bilinear_legacy(
    src: &[u8],
    width: usize,
    height: usize,
    x: f64,
    y: f64,
) -> BilinearContribution {
    if width == 0 || height == 0 {
        return BilinearContribution::default();
    }

    let base_x = x.floor() as isize;
    let base_y = y.floor() as isize;
    let frac_x = x - base_x as f64;
    let frac_y = y - base_y as f64;
    let x0 = clamp_index(base_x, width);
    let x1 = clamp_index(base_x + 1, width);
    let y0 = clamp_index(base_y, height);
    let y1 = clamp_index(base_y + 1, height);
    let pixels = [
        (
            pixel_at(src, width, x0, y0),
            (1.0 - frac_x) * (1.0 - frac_y),
        ),
        (pixel_at(src, width, x1, y0), frac_x * (1.0 - frac_y)),
        (pixel_at(src, width, x1, y1), frac_x * frac_y),
        (pixel_at(src, width, x0, y1), (1.0 - frac_x) * frac_y),
    ];

    let mut contribution = BilinearContribution::default();
    for (pixel, weight) in pixels {
        let alpha = pixel[3] as f64;
        contribution.alpha += alpha * weight;
        contribution.premul[0] += pixel[0] as f64 * alpha * weight;
        contribution.premul[1] += pixel[1] as f64 * alpha * weight;
        contribution.premul[2] += pixel[2] as f64 * alpha * weight;
        contribution.raw[0] += pixel[0] as f64 * weight;
        contribution.raw[1] += pixel[1] as f64 * weight;
        contribution.raw[2] += pixel[2] as f64 * weight;
    }
    contribution
}

#[inline]
fn clamp_index(index: isize, len: usize) -> usize {
    index.clamp(0, len.saturating_sub(1) as isize) as usize
}

#[inline]
fn legacy_nearest_index(value: f64) -> isize {
    (value + 0.5).trunc() as isize
}

#[inline]
fn pixel_at(src: &[u8], width: usize, x: usize, y: usize) -> [u8; 4] {
    let index = (y * width + x) * 4;
    [src[index], src[index + 1], src[index + 2], src[index + 3]]
}

#[inline]
pub(super) fn write_pixel(dst: &mut [u8], width: usize, x: usize, y: usize, pixel: [u8; 4]) {
    let index = (y * width + x) * 4;
    dst[index..index + 4].copy_from_slice(&pixel);
}

#[inline]
pub(super) fn sample_nearest_legacy(
    src: &[u8],
    width: usize,
    height: usize,
    x: f64,
    y: f64,
) -> [u8; 4] {
    let x = clamp_index(legacy_nearest_index(x), width);
    let y = clamp_index(legacy_nearest_index(y), height);
    pixel_at(src, width, x, y)
}

#[inline]
pub(super) fn sample_nearest_transparent(
    src: &[u8],
    width: usize,
    height: usize,
    x: f64,
    y: f64,
) -> [u8; 4] {
    let x = legacy_nearest_index(x);
    let y = legacy_nearest_index(y);
    if x < 0 || y < 0 || x >= width as isize || y >= height as isize {
        return [0, 0, 0, 0];
    }
    pixel_at(src, width, x as usize, y as usize)
}

#[inline]
pub(super) fn trunc_to_u8(value: f64) -> u8 {
    value.clamp(0.0, 255.0) as u8
}

#[inline]
pub(super) fn rotate_point(cx: f64, cy: f64, dx: f64, dy: f64, angle: f64) -> (f64, f64) {
    let sin_theta = angle.sin();
    let cos_theta = angle.cos();
    (
        cx + dx * cos_theta + dy * sin_theta,
        cy + dy * cos_theta - dx * sin_theta,
    )
}

pub(super) fn copy_to_work(image_buffer: &[u8], work_buffer: &mut [u8]) {
    if work_buffer.len() >= image_buffer.len() {
        work_buffer[..image_buffer.len()].copy_from_slice(image_buffer);
    }
}

fn c_rand(seed: i64) -> i64 {
    seed.wrapping_mul(0x343fd).wrapping_add(0x269ec3)
}

fn wrap_segment(index: i32, period: Option<usize>) -> i32 {
    match period {
        Some(period) if period > 0 => index.rem_euclid(period as i32),
        _ => index,
    }
}

fn segment_random(seed: i32, index: i32, period: Option<usize>) -> f64 {
    let index = wrap_segment(index, period) as i64;
    let seed_base = (seed as i64).wrapping_mul(seed as i64).wrapping_mul(12);
    let cubic = index.wrapping_mul(index).wrapping_mul(index);
    let coeff = if index < 1 { -0x46f_i64 } else { 0x7f1d_i64 };
    let hold = seed_base.wrapping_add(cubic.wrapping_mul(coeff));
    let rand_value = c_rand(hold);
    (((rand_value >> 16) & 0x7fff) % 1000) as f64 / 1000.0
}

pub(super) fn hard_pattern(
    seed: i32,
    phase: f64,
    period: Option<usize>,
    amplitude_base: f64,
    roundness: f64,
    base_position: f64,
) -> f64 {
    let seg0 = phase.floor() as i32;
    let seg1 = seg0 + 1;
    let frac = phase - seg0 as f64;
    let amplitude_base = amplitude_base.clamp(0.0, 1.0);
    let amp0 = amplitude_base + (1.0 - amplitude_base) * segment_random(seed, seg0, period);
    let amp1 = amplitude_base + (1.0 - amplitude_base) * segment_random(seed, seg1, period);
    let neg_amp0 = 1.0 - (1.0 - amplitude_base) * segment_random(seed, seg0, period);
    let neg_amp1 = 1.0 - (1.0 - amplitude_base) * segment_random(seed, seg1, period);
    let neg_scale = 0.5 * (1.0 - base_position.clamp(-1.0, 1.0));
    let pos_scale = 0.5 * (1.0 + base_position.clamp(-1.0, 1.0));
    let (start, end) = if seg0 & 1 == 0 {
        (-neg_amp0 * neg_scale, amp1 * pos_scale)
    } else {
        (amp0 * pos_scale, -neg_amp1 * neg_scale)
    };
    lerp(start, end, shaped_fraction(frac, roundness))
}
