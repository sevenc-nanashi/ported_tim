use std::sync::{LazyLock, Mutex};

pub(crate) static FAMILIAR_STATE: LazyLock<Mutex<crate::familiar::unoptimized::FamiliarState>> =
    LazyLock::new(|| Mutex::new(crate::familiar::unoptimized::FamiliarState::default()));

use anyhow::{Result, ensure};

#[derive(Debug, Clone, Copy, Default)]
pub struct FamiliarState {
    target_r: u8,
    target_g: u8,
    target_b: u8,
}

impl FamiliarState {
    pub fn get_color(&self) -> (u8, u8, u8) {
        (self.target_r, self.target_g, self.target_b)
    }
}

#[derive(Debug, Clone, Copy)]
struct Region {
    left: usize,
    top: usize,
    right: usize,
    bottom: usize,
}

impl Region {
    fn is_empty(self) -> bool {
        self.left >= self.right || self.top >= self.bottom
    }
}

pub fn set_color(
    state: &mut FamiliarState,
    image_buffer: &mut [u8],
    width: usize,
    height: usize,
    center_x: f64,
    center_y: f64,
    range_width: f64,
    range_height: f64,
    show_range: bool,
    frame_color: u32,
    line_width: i32,
) -> Result<()> {
    ensure!(
        image_buffer.len() == width.saturating_mul(height).saturating_mul(4),
        "Invalid image buffer size"
    );

    let region = resolve_region(width, height, center_x, center_y, range_width, range_height);
    if !region.is_empty() {
        let mut sum_r: u64 = 0;
        let mut sum_g: u64 = 0;
        let mut sum_b: u64 = 0;
        let mut count: u64 = 0;

        for y in region.top..region.bottom {
            let row_start = y * width * 4;
            for x in region.left..region.right {
                let idx = row_start + x * 4;
                sum_b += image_buffer[idx] as u64;
                sum_g += image_buffer[idx + 1] as u64;
                sum_r += image_buffer[idx + 2] as u64;
                count += 1;
            }
        }

        if count > 0 {
            state.target_r = (sum_r / count) as u8;
            state.target_g = (sum_g / count) as u8;
            state.target_b = (sum_b / count) as u8;
        }
    }

    if show_range && line_width > 0 && !region.is_empty() {
        draw_region_frame(
            image_buffer,
            width,
            height,
            region,
            frame_color,
            line_width as usize,
        );
    }

    Ok(())
}

pub fn familiar(
    state: &FamiliarState,
    image_buffer: &mut [u8],
    width: usize,
    height: usize,
    adapt_rate: f64,
    lightness_adjust: f64,
    correct_saturation: bool,
    correct_value: bool,
) -> Result<()> {
    ensure!(
        image_buffer.len() == width.saturating_mul(height).saturating_mul(4),
        "Invalid image buffer size"
    );

    let p = adapt_rate.clamp(0.0, 1.0);
    let l = lightness_adjust.max(0.0);
    let current_avg = average_rgb_of_nonzero_alpha(image_buffer)?;
    let Some((avg_r, avg_g, avg_b)) = current_avg else {
        return Ok(());
    };
    let (target_h, target_s, target_v) = rgb_to_hsv(state.target_r, state.target_g, state.target_b);
    let (current_h, current_s, current_v) = rgb_to_hsv(avg_r, avg_g, avg_b);
    let hue_delta = target_h - current_h;
    let mut saturation_ratio = safe_div(target_s, current_s);
    let mut value_ratio = safe_div(target_v, current_v);
    if !correct_saturation {
        saturation_ratio = 1.0;
    }
    if !correct_value {
        value_ratio = 1.0;
    }

    for px in image_buffer.chunks_exact_mut(4) {
        let b = px[0];
        let g = px[1];
        let r = px[2];
        let a = px[3];
        if a == 0 {
            continue;
        }

        let (src_h, src_s, src_v) = rgb_to_hsv(r, g, b);
        let adj_h = (src_h + hue_delta).rem_euclid(360.0);
        let adj_s = (src_s * saturation_ratio).clamp(0.0, 1.0);
        let adj_v = (src_v * value_ratio).clamp(0.0, 1.0);
        let (adj_r, adj_g, adj_b) = hsv_to_rgb(adj_h, adj_s, adj_v);

        let out_r = ((r as f64 * (1.0 - p) + adj_r as f64 * p) * l).clamp(0.0, 255.0);
        let out_g = ((g as f64 * (1.0 - p) + adj_g as f64 * p) * l).clamp(0.0, 255.0);
        let out_b = ((b as f64 * (1.0 - p) + adj_b as f64 * p) * l).clamp(0.0, 255.0);
        px[0] = out_b.round() as u8;
        px[1] = out_g.round() as u8;
        px[2] = out_r.round() as u8;
    }

    Ok(())
}

fn resolve_region(
    width: usize,
    height: usize,
    center_x: f64,
    center_y: f64,
    range_width: f64,
    range_height: f64,
) -> Region {
    let w = width as i32;
    let h = height as i32;
    let cx = center_x.trunc() as i32;
    let cy = center_y.trunc() as i32;
    let rw = range_width.trunc() as i32;
    let rh = range_height.trunc() as i32;

    let left = (((w - rw) / 2) + cx).max(0) as usize;
    let top = (((h - rh) / 2) + cy).max(0) as usize;
    let right = ((((w + rw) / 2) + cx).min(w).max(0)) as usize;
    let bottom = ((((h + rh) / 2) + cy).min(h).max(0)) as usize;

    Region {
        left,
        top,
        right,
        bottom,
    }
}

fn draw_region_frame(
    image_buffer: &mut [u8],
    width: usize,
    height: usize,
    region: Region,
    frame_color: u32,
    line_width: usize,
) {
    if line_width == 0 || region.is_empty() {
        return;
    }
    let r = ((frame_color >> 16) & 0xFF) as u8;
    let g = ((frame_color >> 8) & 0xFF) as u8;
    let b = (frame_color & 0xFF) as u8;

    let x0 = region.left as i32;
    let y0 = region.top as i32;
    let x1 = region.right as i32;
    let y1 = region.bottom as i32;
    let lw = line_width as i32;
    let ox0 = (x0 - lw).max(0) as usize;
    let oy0 = (y0 - lw).max(0) as usize;
    let ox1 = (x1 + lw).min(width as i32).max(0) as usize;
    let oy1 = (y1 + lw).min(height as i32).max(0) as usize;
    let ix0 = (x0 + lw).clamp(0, width as i32) as usize;
    let iy0 = (y0 + lw).clamp(0, height as i32) as usize;
    let ix1 = (x1 - lw).clamp(0, width as i32) as usize;
    let iy1 = (y1 - lw).clamp(0, height as i32) as usize;

    for y in oy0..oy1 {
        for x in ox0..ox1 {
            let inside_inner = x >= ix0 && x < ix1 && y >= iy0 && y < iy1;
            if !inside_inner {
                set_pixel_bgra(image_buffer, width, x, y, b, g, r);
            }
        }
    }
}

fn average_rgb_of_nonzero_alpha(image_buffer: &[u8]) -> Result<Option<(u8, u8, u8)>> {
    ensure!(
        image_buffer.len().is_multiple_of(4),
        "Invalid image buffer size"
    );
    let mut sum_r: u64 = 0;
    let mut sum_g: u64 = 0;
    let mut sum_b: u64 = 0;
    let mut count: u64 = 0;
    for px in image_buffer.chunks_exact(4) {
        if px[3] != 0 {
            sum_b += px[0] as u64;
            sum_g += px[1] as u64;
            sum_r += px[2] as u64;
            count += 1;
        }
    }
    if count == 0 {
        Ok(None)
    } else {
        Ok(Some((
            (sum_r / count) as u8,
            (sum_g / count) as u8,
            (sum_b / count) as u8,
        )))
    }
}

fn safe_div(numerator: f64, denominator: f64) -> f64 {
    if denominator.abs() <= f64::EPSILON {
        1.0
    } else {
        numerator / denominator
    }
}

fn rgb_to_hsv(r: u8, g: u8, b: u8) -> (f64, f64, f64) {
    let rf = r as f64 / 255.0;
    let gf = g as f64 / 255.0;
    let bf = b as f64 / 255.0;

    let max = rf.max(gf).max(bf);
    let min = rf.min(gf).min(bf);
    let delta = max - min;

    let hue = if delta == 0.0 {
        0.0
    } else if max == rf {
        60.0 * ((gf - bf) / delta).rem_euclid(6.0)
    } else if max == gf {
        60.0 * (((bf - rf) / delta) + 2.0)
    } else {
        60.0 * (((rf - gf) / delta) + 4.0)
    };

    let saturation = if max == 0.0 { 0.0 } else { delta / max };
    (hue, saturation, max)
}

fn hsv_to_rgb(h: f64, s: f64, v: f64) -> (u8, u8, u8) {
    if s <= 0.0 {
        let gray = (v * 255.0).round().clamp(0.0, 255.0) as u8;
        return (gray, gray, gray);
    }

    let hh = h.rem_euclid(360.0) / 60.0;
    let i = hh.floor() as i32;
    let f = hh - i as f64;
    let p = v * (1.0 - s);
    let q = v * (1.0 - s * f);
    let t = v * (1.0 - s * (1.0 - f));

    let (r, g, b) = match i {
        0 => (v, t, p),
        1 => (q, v, p),
        2 => (p, v, t),
        3 => (p, q, v),
        4 => (t, p, v),
        _ => (v, p, q),
    };

    (
        (r * 255.0).round().clamp(0.0, 255.0) as u8,
        (g * 255.0).round().clamp(0.0, 255.0) as u8,
        (b * 255.0).round().clamp(0.0, 255.0) as u8,
    )
}

fn set_pixel_bgra(image_buffer: &mut [u8], width: usize, x: usize, y: usize, b: u8, g: u8, r: u8) {
    let idx = (y * width + x) * 4;
    if idx + 3 >= image_buffer.len() {
        return;
    }
    image_buffer[idx] = b;
    image_buffer[idx + 1] = g;
    image_buffer[idx + 2] = r;
}

#[cfg(test)]
mod tests {
    use super::*;

    #[test]
    fn set_color_uses_full_frame_when_range_matches_dimensions() {
        let mut state = FamiliarState::default();
        let mut image = vec![
            0, 0, 0, 255, 255, 0, 0, 255, //
            0, 255, 0, 255, 0, 0, 255, 255,
        ];
        set_color(
            &mut state, &mut image, 2, 2, 0.0, 0.0, 2.0, 2.0, false, 0, 0,
        )
        .unwrap();
        let (r, g, b) = state.get_color();
        assert_eq!((r, g, b), (63, 63, 63));
    }

    #[test]
    fn familiar_full_adapt_reaches_target_hsv_when_enabled() {
        let mut state = FamiliarState::default();
        state.target_r = 0;
        state.target_g = 255;
        state.target_b = 0;

        let mut image = vec![0, 0, 255, 255];
        familiar(&state, &mut image, 1, 1, 1.0, 1.0, true, true).unwrap();
        assert_eq!(image, vec![0, 255, 0, 255]);
    }
}
