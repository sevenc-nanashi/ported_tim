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

    let radius = size.max(0.0).round() as i32;
    if radius <= 0 {
        return Ok(true);
    }
    let threshold = alpha_base.clamp(0, 255) as u8;
    let src = image_buffer.to_vec();
    let mut mask = vec![0u8; width * height];
    for (i, px) in src.chunks_exact(4).enumerate() {
        mask[i] = u8::from(px[3] > threshold);
    }

    let mut dilated = vec![0u8; width * height];
    let mut dist_map = vec![radius as f64; width * height];
    for y in 0..height as i32 {
        for x in 0..width as i32 {
            let idx = (y as usize) * width + x as usize;
            if mask[idx] != 0 {
                dilated[idx] = 255;
                dist_map[idx] = 0.0;
                continue;
            }
            let mut hit = false;
            let mut min_dist2 = i32::MAX;
            for dy in -radius..=radius {
                let ny = y + dy;
                if ny < 0 || ny >= height as i32 {
                    continue;
                }
                let remain = radius * radius - dy * dy;
                let dx_lim = (remain as f64).sqrt() as i32;
                for dx in -dx_lim..=dx_lim {
                    let nx = x + dx;
                    if nx < 0 || nx >= width as i32 {
                        continue;
                    }
                    let nidx = ny as usize * width + nx as usize;
                    if mask[nidx] != 0 {
                        hit = true;
                        let d2 = dx * dx + dy * dy;
                        if d2 < min_dist2 {
                            min_dist2 = d2;
                        }
                    }
                }
            }
            dilated[idx] = u8::from(hit) * 255;
            if hit {
                dist_map[idx] = (min_dist2 as f64).sqrt();
            }
        }
    }

    let mut edge = vec![0u8; width * height];
    for i in 0..edge.len() {
        let src_a = src[i * 4 + 3];
        edge[i] = dilated[i].saturating_sub(src_a);
    }

    let blur_radius = boundary_blur.max(0.0).round() as i32;
    let edge = if blur_radius > 0 {
        box_blur_alpha(&edge, width, height, blur_radius)
    } else {
        edge
    };

    let (r1, g1, b1) = unpack_rgb(color1);
    let (r2, g2, b2) = unpack_rgb(color2);
    for y in 0..height {
        for x in 0..width {
            let idx = y * width + x;
            let a = edge[idx];
            if a == 0 {
                continue;
            }
            let t = if distance_gradient {
                (dist_map[idx] / radius.max(1) as f64).clamp(0.0, 1.0)
            } else {
                0.0
            };
            let rr = lerp(r1 as f64, r2 as f64, t).round().clamp(0.0, 255.0) as u8;
            let gg = lerp(g1 as f64, g2 as f64, t).round().clamp(0.0, 255.0) as u8;
            let bb = lerp(b1 as f64, b2 as f64, t).round().clamp(0.0, 255.0) as u8;

            let p = idx * 4;
            let dst_a = image_buffer[p + 3] as u16;
            let src_a = a as u16;
            if src_a >= dst_a {
                image_buffer[p] = bb;
                image_buffer[p + 1] = gg;
                image_buffer[p + 2] = rr;
                image_buffer[p + 3] = a;
            }
        }
    }
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
    framing(
        image_buffer,
        width,
        height,
        size,
        boundary_blur,
        alpha_base,
        color1,
        color2,
        distance_gradient,
    )
}

fn box_blur_alpha(src: &[u8], width: usize, height: usize, radius: i32) -> Vec<u8> {
    let mut out = vec![0u8; src.len()];
    for y in 0..height as i32 {
        for x in 0..width as i32 {
            let mut sum: u32 = 0;
            let mut cnt: u32 = 0;
            for dy in -radius..=radius {
                let ny = y + dy;
                if ny < 0 || ny >= height as i32 {
                    continue;
                }
                for dx in -radius..=radius {
                    let nx = x + dx;
                    if nx < 0 || nx >= width as i32 {
                        continue;
                    }
                    let nidx = ny as usize * width + nx as usize;
                    sum += src[nidx] as u32;
                    cnt += 1;
                }
            }
            let idx = y as usize * width + x as usize;
            out[idx] = if cnt == 0 { 0 } else { (sum / cnt) as u8 };
        }
    }
    out
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
