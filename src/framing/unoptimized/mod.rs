use aviutl2::anyhow;
use std::sync::{LazyLock, Mutex};

pub(crate) static FRAMING_STATE: LazyLock<Mutex<crate::framing::unoptimized::FramingState>> =
    LazyLock::new(|| Mutex::new(crate::framing::unoptimized::FramingState::default()));

use anyhow::{Result, ensure};

#[derive(Default)]
pub struct FramingState {
    cached_image: Option<Vec<u8>>,
    cached_width: usize,
    cached_height: usize,
}

pub fn set_image(
    state: &mut FramingState,
    image_buffer: &[u8],
    width: usize,
    height: usize,
) -> Result<bool> {
    ensure!(
        image_buffer.len() == width.saturating_mul(height).saturating_mul(4),
        "Invalid image buffer size"
    );
    if state.cached_image.is_some() {
        return Ok(false);
    }
    state.cached_image = Some(image_buffer.to_vec());
    state.cached_width = width;
    state.cached_height = height;
    Ok(true)
}

pub fn re_alpha(
    state: &mut FramingState,
    image_buffer: &mut [u8],
    width: usize,
    height: usize,
) -> Result<bool> {
    ensure!(
        image_buffer.len() == width.saturating_mul(height).saturating_mul(4),
        "Invalid image buffer size"
    );
    if state.cached_image.is_some() {
        return Ok(false);
    }
    state.cached_image = Some(image_buffer.to_vec());
    state.cached_width = width;
    state.cached_height = height;
    for px in image_buffer.chunks_exact_mut(4) {
        px[3] = 255;
    }
    Ok(true)
}

pub fn set_alpha(
    state: &mut FramingState,
    image_buffer: &mut [u8],
    width: usize,
    height: usize,
) -> Result<bool> {
    ensure!(
        image_buffer.len() == width.saturating_mul(height).saturating_mul(4),
        "Invalid image buffer size"
    );
    let Some(cached) = state.cached_image.take() else {
        return Ok(false);
    };
    if state.cached_width != width
        || state.cached_height != height
        || cached.len() != image_buffer.len()
    {
        state.cached_width = 0;
        state.cached_height = 0;
        return Ok(false);
    }
    for (dst, src) in image_buffer.chunks_exact_mut(4).zip(cached.chunks_exact(4)) {
        dst[3] = src[3];
    }
    state.cached_width = 0;
    state.cached_height = 0;
    Ok(true)
}

pub fn set_color(
    state: &mut FramingState,
    image_buffer: &mut [u8],
    width: usize,
    height: usize,
) -> Result<bool> {
    ensure!(
        image_buffer.len() == width.saturating_mul(height).saturating_mul(4),
        "Invalid image buffer size"
    );
    let Some(cached) = state.cached_image.take() else {
        return Ok(false);
    };
    if state.cached_width != width
        || state.cached_height != height
        || cached.len() != image_buffer.len()
    {
        state.cached_width = 0;
        state.cached_height = 0;
        return Ok(false);
    }
    for (dst, src) in image_buffer.chunks_exact_mut(4).zip(cached.chunks_exact(4)) {
        dst[0] = src[0];
        dst[1] = src[1];
        dst[2] = src[2];
    }
    state.cached_width = 0;
    state.cached_height = 0;
    Ok(true)
}

pub fn framing(
    image_buffer: &mut [u8],
    width: usize,
    height: usize,
    size: f64,
    boundary_blur: f64,
    alpha_base: i32,
    color1: u32,
    color2: u32,
    distance_gradient: bool,
) -> Result<bool> {
    ensure!(
        image_buffer.len() == width.saturating_mul(height).saturating_mul(4),
        "Invalid image buffer size"
    );
    if width == 0 || height == 0 || size <= 0.0 {
        return Ok(true);
    }

    let threshold = alpha_base.clamp(0, 255) as u8;
    let alpha = extract_alpha_mask(image_buffer, width, height, threshold);
    let distance_map = compute_distance_map(&alpha, width, height);
    apply_outline(
        image_buffer,
        width,
        height,
        &distance_map,
        size,
        boundary_blur,
        color1,
        color2,
        distance_gradient,
    );
    Ok(true)
}

pub fn framing_hi(
    image_buffer: &mut [u8],
    width: usize,
    height: usize,
    size: f64,
    boundary_blur: f64,
    alpha_base: i32,
    color1: u32,
    color2: u32,
    distance_gradient: bool,
) -> Result<bool> {
    ensure!(
        image_buffer.len() == width.saturating_mul(height).saturating_mul(4),
        "Invalid image buffer size"
    );
    if width == 0 || height == 0 || size <= 0.0 {
        return Ok(true);
    }

    let hi_width = width.saturating_mul(3);
    let hi_height = height.saturating_mul(3);
    let threshold = alpha_base.clamp(0, 255) as u8;
    let mut hi_alpha = upsample_alpha_mask_3x(image_buffer, width, height, threshold);
    smooth_alpha_mask_3x(&mut hi_alpha, hi_width, hi_height);

    let distance_map = compute_distance_map(&hi_alpha, hi_width, hi_height);
    let mut hi_image = vec![0u8; hi_width * hi_height * 4];
    apply_outline(
        &mut hi_image,
        hi_width,
        hi_height,
        &distance_map,
        size,
        boundary_blur,
        color1,
        color2,
        distance_gradient,
    );
    downsample_3x_rgba(&hi_image, image_buffer, width, height);
    Ok(true)
}

fn extract_alpha_mask(image_buffer: &[u8], width: usize, height: usize, threshold: u8) -> Vec<u8> {
    let mut alpha = vec![0u8; width * height];
    for (idx, px) in image_buffer.chunks_exact(4).enumerate() {
        alpha[idx] = u8::from(px[3] > threshold);
    }
    alpha
}

fn upsample_alpha_mask_3x(
    image_buffer: &[u8],
    width: usize,
    height: usize,
    threshold: u8,
) -> Vec<u8> {
    let hi_width = width * 3;
    let hi_height = height * 3;
    let mut hi_alpha = vec![0u8; hi_width * hi_height];
    for y in 0..height {
        for x in 0..width {
            let src_idx = (y * width + x) * 4 + 3;
            let value = u8::from(image_buffer[src_idx] > threshold);
            let base_y = y * 3;
            let base_x = x * 3;
            for dy in 0..3 {
                for dx in 0..3 {
                    hi_alpha[(base_y + dy) * hi_width + base_x + dx] = value;
                }
            }
        }
    }
    hi_alpha
}

fn smooth_alpha_mask_3x(alpha: &mut [u8], width: usize, height: usize) {
    if width < 3 || height < 3 {
        return;
    }

    for y in 0..height {
        let row = y * width;
        let mut x = 2usize;
        while x + 1 < width {
            let idx = row + x;
            let left = alpha[idx];
            let center = alpha[idx + 1];
            alpha[idx] = ((left * 2 + center) / 3).min(1);
            alpha[idx + 1] = ((left + center * 2) / 3).min(1);
            x += 3;
        }
    }

    let mut y = 2usize;
    while y + 1 < height {
        for x in 0..width {
            let top_idx = y * width + x;
            let bottom_idx = top_idx + width;
            let top = alpha[top_idx];
            let bottom = alpha[bottom_idx];
            alpha[top_idx] = ((top * 2 + bottom) / 3).min(1);
            alpha[bottom_idx] = ((top + bottom * 2) / 3).min(1);
        }
        y += 3;
    }
}

fn compute_distance_map(mask: &[u8], width: usize, height: usize) -> Vec<f64> {
    let mut points = Vec::new();
    for y in 0..height {
        for x in 0..width {
            if mask[y * width + x] != 0 {
                points.push((x as isize, y as isize));
            }
        }
    }

    if points.is_empty() {
        return vec![f64::INFINITY; width * height];
    }

    let mut distance_map = vec![f64::INFINITY; width * height];
    for y in 0..height {
        for x in 0..width {
            let idx = y * width + x;
            if mask[idx] != 0 {
                distance_map[idx] = 0.0;
                continue;
            }
            let mut best = f64::INFINITY;
            for &(px, py) in &points {
                let dx = px - x as isize;
                let dy = py - y as isize;
                let dist = ((dx * dx + dy * dy) as f64).sqrt();
                if dist < best {
                    best = dist;
                }
            }
            distance_map[idx] = best;
        }
    }
    distance_map
}

fn apply_outline(
    image_buffer: &mut [u8],
    width: usize,
    height: usize,
    distance_map: &[f64],
    size: f64,
    boundary_blur: f64,
    color1: u32,
    color2: u32,
    distance_gradient: bool,
) {
    let outline_limit = size + 0.5;
    let blur = boundary_blur.max(0.0);
    let (r1, g1, b1) = unpack_rgb(color1);
    let (r2, g2, b2) = unpack_rgb(color2);

    for y in 0..height {
        for x in 0..width {
            let idx = y * width + x;
            let dist = distance_map[idx];
            let (r, g, b, a) = render_outline_pixel(
                dist,
                outline_limit,
                blur,
                (r1, g1, b1),
                (r2, g2, b2),
                distance_gradient,
            );
            let p = idx * 4;
            image_buffer[p] = b;
            image_buffer[p + 1] = g;
            image_buffer[p + 2] = r;
            image_buffer[p + 3] = a;
        }
    }
}

fn render_outline_pixel(
    dist: f64,
    outline_limit: f64,
    blur: f64,
    outer_color: (u8, u8, u8),
    inner_color: (u8, u8, u8),
    distance_gradient: bool,
) -> (u8, u8, u8, u8) {
    let (r, g, b) = if distance_gradient {
        let t = if outline_limit <= 0.0 {
            1.0
        } else {
            (dist / outline_limit).clamp(0.0, 1.0)
        };
        (
            lerp(inner_color.0 as f64, outer_color.0 as f64, t)
                .round()
                .clamp(0.0, 255.0) as u8,
            lerp(inner_color.1 as f64, outer_color.1 as f64, t)
                .round()
                .clamp(0.0, 255.0) as u8,
            lerp(inner_color.2 as f64, outer_color.2 as f64, t)
                .round()
                .clamp(0.0, 255.0) as u8,
        )
    } else {
        outer_color
    };

    if !dist.is_finite() || dist > outline_limit {
        return (r, g, b, 0);
    }

    if blur <= 0.0 || dist <= outline_limit - blur {
        return (r, g, b, 255);
    }

    let t = ((outline_limit - dist) / blur).clamp(0.0, 1.0);
    let a = smoothstep(t).round().clamp(0.0, 255.0) as u8;
    (r, g, b, a)
}

fn downsample_3x_rgba(src: &[u8], dst: &mut [u8], width: usize, height: usize) {
    let hi_width = width * 3;
    for y in 0..height {
        for x in 0..width {
            let mut sum = [0u32; 4];
            for dy in 0..3 {
                for dx in 0..3 {
                    let src_idx = ((y * 3 + dy) * hi_width + (x * 3 + dx)) * 4;
                    sum[0] += src[src_idx] as u32;
                    sum[1] += src[src_idx + 1] as u32;
                    sum[2] += src[src_idx + 2] as u32;
                    sum[3] += src[src_idx + 3] as u32;
                }
            }
            let dst_idx = (y * width + x) * 4;
            dst[dst_idx] = (sum[0] / 9) as u8;
            dst[dst_idx + 1] = (sum[1] / 9) as u8;
            dst[dst_idx + 2] = (sum[2] / 9) as u8;
            dst[dst_idx + 3] = (sum[3] / 9) as u8;
        }
    }
}

fn smoothstep(t: f64) -> f64 {
    (3.0 - 2.0 * t) * t * t * 255.0
}

fn unpack_rgb(rgb: u32) -> (u8, u8, u8) {
    (
        ((rgb >> 16) & 0xFF) as u8,
        ((rgb >> 8) & 0xFF) as u8,
        (rgb & 0xFF) as u8,
    )
}

fn lerp(a: f64, b: f64, t: f64) -> f64 {
    a + (b - a) * t
}
