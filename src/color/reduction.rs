use anyhow::{Result, anyhow, ensure};
use rayon::prelude::*;

const HIST_SIZE: usize = 256 * 256 * 256;
const MAX_MC_COLORS: usize = 500;
const MAX_SPECIFIED_COLORS: usize = 10;

#[derive(Clone, Copy, Debug, Default)]
struct Rgb8 {
    r: u8,
    g: u8,
    b: u8,
}

#[derive(Clone, Copy, Debug)]
struct ColorEntry {
    rgb: Rgb8,
    count: u32,
}

#[derive(Clone, Debug)]
struct ColorBox {
    r_min: u8,
    r_max: u8,
    g_min: u8,
    g_max: u8,
    b_min: u8,
    b_max: u8,
    count: u32,
    unique_count: u32,
}

impl ColorBox {
    fn r_range(&self) -> i32 {
        i32::from(self.r_max) - i32::from(self.r_min)
    }

    fn g_range(&self) -> i32 {
        i32::from(self.g_max) - i32::from(self.g_min)
    }

    fn b_range(&self) -> i32 {
        i32::from(self.b_max) - i32::from(self.b_min)
    }

    fn volume_like(&self) -> i32 {
        (self.r_range() + 1) * (self.g_range() + 1) * (self.b_range() + 1)
    }
}

#[derive(Clone, Copy, Debug)]
enum Axis {
    R,
    G,
    B,
}

fn u32_to_rgb(color: u32) -> Rgb8 {
    Rgb8 {
        r: ((color >> 16) & 0xff) as u8,
        g: ((color >> 8) & 0xff) as u8,
        b: (color & 0xff) as u8,
    }
}

fn hist_index(r: u8, g: u8, b: u8) -> usize {
    ((r as usize) << 16) | ((g as usize) << 8) | (b as usize)
}

fn rgb_from_hist_index(idx: usize) -> Rgb8 {
    Rgb8 {
        r: ((idx >> 16) & 0xff) as u8,
        g: ((idx >> 8) & 0xff) as u8,
        b: (idx & 0xff) as u8,
    }
}

fn sq_diff_u8(a: u8, b: u8) -> u32 {
    let d = i32::from(a) - i32::from(b);
    (d * d) as u32
}

fn color_dist2(a: Rgb8, b: Rgb8) -> u32 {
    sq_diff_u8(a.r, b.r) + sq_diff_u8(a.g, b.g) + sq_diff_u8(a.b, b.b)
}

fn pixel_count(width: usize, height: usize) -> Result<usize> {
    width
        .checked_mul(height)
        .ok_or_else(|| anyhow!("image size overflow"))
}

fn validate_bgra_buffer(buf: &[u8], width: usize, height: usize) -> Result<()> {
    let px = pixel_count(width, height)?;
    let expected = px
        .checked_mul(4)
        .ok_or_else(|| anyhow!("buffer size overflow"))?;
    ensure!(
        buf.len() == expected,
        "invalid BGRA buffer length: got {}, expected {}",
        buf.len(),
        expected
    );
    Ok(())
}

fn get_pixel_bgra(buf: &[u8], idx: usize) -> (u8, u8, u8, u8) {
    let base = idx * 4;
    let b = buf[base];
    let g = buf[base + 1];
    let r = buf[base + 2];
    let a = buf[base + 3];
    (b, g, r, a)
}

fn set_pixel_bgra(buf: &mut [u8], idx: usize, b: u8, g: u8, r: u8, a: u8) {
    let base = idx * 4;
    buf[base] = b;
    buf[base + 1] = g;
    buf[base + 2] = r;
    buf[base + 3] = a;
}

/// Lua: T_Color_Module.DispReduction(userdata, w, h, N, T)
pub fn disp_reduction(
    pixels_bgra: &mut [u8],
    width: usize,
    height: usize,
    palette_rgb: &[u32],
) -> Result<()> {
    validate_bgra_buffer(pixels_bgra, width, height)?;

    let palette: Vec<Rgb8> = palette_rgb.iter().copied().map(u32_to_rgb).collect();

    pixels_bgra.par_chunks_exact_mut(4).for_each(|px| {
        let a = px[3];
        let src = Rgb8 {
            r: px[2],
            g: px[1],
            b: px[0],
        };

        let mut best_idx = 0usize;
        let mut best_dist = u32::MAX;
        for (j, &cand) in palette.iter().enumerate() {
            let d = color_dist2(src, cand);
            if d < best_dist {
                best_dist = d;
                best_idx = j;
            }
        }

        let best = palette[best_idx];
        px[0] = best.b;
        px[1] = best.g;
        px[2] = best.r;
        px[3] = a;
    });

    Ok(())
}

fn compute_average_opaque_color(pixels_bgra: &[u8], width: usize, height: usize) -> Option<Rgb8> {
    let px_count = width * height;

    let mut sum_r: u64 = 0;
    let mut sum_g: u64 = 0;
    let mut sum_b: u64 = 0;
    let mut count: u64 = 0;

    for i in 0..px_count {
        let (b, g, r, a) = get_pixel_bgra(pixels_bgra, i);
        if a != 0 {
            sum_r += u64::from(r);
            sum_g += u64::from(g);
            sum_b += u64::from(b);
            count += 1;
        }
    }

    if count == 0 {
        None
    } else {
        Some(Rgb8 {
            r: (sum_r / count) as u8,
            g: (sum_g / count) as u8,
            b: (sum_b / count) as u8,
        })
    }
}

fn fill_opaque_with_color(pixels_bgra: &mut [u8], width: usize, height: usize, color: Rgb8) {
    pixels_bgra[..width * height * 4]
        .par_chunks_exact_mut(4)
        .for_each(|px| {
            let a = px[3];
            if a != 0 {
                px[0] = color.b;
                px[1] = color.g;
                px[2] = color.r;
                px[3] = 0xff;
            }
        });
}

fn nearest_color_index(src: Rgb8, palette: &[Rgb8], fixed: &[Rgb8]) -> (bool, usize) {
    let mut best_is_fixed = false;
    let mut best_idx = 0usize;
    let mut best_dist = u32::MAX;

    for (i, &c) in palette.iter().enumerate() {
        let d = color_dist2(src, c);
        if d < best_dist {
            best_dist = d;
            best_idx = i;
            best_is_fixed = false;
        }
    }

    for (i, &c) in fixed.iter().enumerate() {
        let d = color_dist2(src, c);
        if d < best_dist {
            best_dist = d;
            best_idx = i;
            best_is_fixed = true;
        }
    }

    (best_is_fixed, best_idx)
}

fn apply_reduction_with_palette_and_fixed(
    pixels_bgra: &mut [u8],
    width: usize,
    height: usize,
    palette: &[Rgb8],
    fixed: &[Rgb8],
) {
    pixels_bgra[..width * height * 4]
        .par_chunks_exact_mut(4)
        .for_each(|px| {
            let b = px[0];
            let g = px[1];
            let r = px[2];
            let a = px[3];
            if a == 0 {
                return;
            }

            let src = Rgb8 { r, g, b };
            let (is_fixed, idx) = nearest_color_index(src, palette, fixed);

            let out = if is_fixed { fixed[idx] } else { palette[idx] };
            px[0] = out.b;
            px[1] = out.g;
            px[2] = out.r;
            px[3] = a;
        });
}

fn draw_palette_grid(
    out_bgra: &mut [u8],
    width: usize,
    height: usize,
    palette: &[Rgb8],
    fixed: &[Rgb8],
) {
    let total = palette.len() + fixed.len();
    if total == 0 || width == 0 || height == 0 {
        return;
    }

    let grid = (total as f64).sqrt().ceil() as usize;
    if grid == 0 {
        unreachable!();
    }

    let cell_h = height / grid;
    let cell_w = width / grid;

    out_bgra.par_chunks_exact_mut(4).for_each(|px| {
        px[0] = 0xff;
        px[1] = 0xff;
        px[2] = 0xff;
        px[3] = 0xff;
    });

    for gy in 0..grid {
        for gx in 0..grid {
            let k = gy * grid + gx;
            let color = if k < palette.len() {
                Some(palette[k])
            } else if k < total {
                Some(fixed[k - palette.len()])
            } else {
                None
            };

            let Some(color) = color else {
                continue;
            };

            let y0 = gy * cell_h;
            let y1 = ((gy + 1) * cell_h).min(height);
            let x0 = gx * cell_w;
            let x1 = ((gx + 1) * cell_w).min(width);

            for y in y0..y1 {
                let row = y * width;
                for x in x0..x1 {
                    set_pixel_bgra(out_bgra, row + x, color.b, color.g, color.r, 0xff);
                }
            }
        }
    }
}

fn color_in_box(color: Rgb8, b: &ColorBox) -> bool {
    color.r >= b.r_min
        && color.r <= b.r_max
        && color.g >= b.g_min
        && color.g <= b.g_max
        && color.b >= b.b_min
        && color.b <= b.b_max
}

fn extract_colors_and_initial_box(
    pixels_bgra: &[u8],
    width: usize,
    height: usize,
) -> (Vec<ColorEntry>, Option<ColorBox>) {
    let mut hist = vec![0u32; HIST_SIZE];
    let mut used_indices = Vec::new();

    let px_count = width * height;
    let mut unique_count = 0u32;

    let mut r_min = u8::MAX;
    let mut r_max = 0u8;
    let mut g_min = u8::MAX;
    let mut g_max = 0u8;
    let mut b_min = u8::MAX;
    let mut b_max = 0u8;
    let mut count = 0u32;

    for i in 0..px_count {
        let (b, g, r, a) = get_pixel_bgra(pixels_bgra, i);
        if a == 0 {
            continue;
        }

        count += 1;

        r_min = r_min.min(r);
        r_max = r_max.max(r);
        g_min = g_min.min(g);
        g_max = g_max.max(g);
        b_min = b_min.min(b);
        b_max = b_max.max(b);

        let idx = hist_index(r, g, b);
        if hist[idx] == 0 {
            unique_count += 1;
            used_indices.push(idx);
        }
        hist[idx] += 1;
    }

    let initial = if count == 0 {
        None
    } else {
        Some(ColorBox {
            r_min,
            r_max,
            g_min,
            g_max,
            b_min,
            b_max,
            count,
            unique_count,
        })
    };

    let colors = used_indices
        .into_iter()
        .map(|idx| ColorEntry {
            rgb: rgb_from_hist_index(idx),
            count: hist[idx],
        })
        .collect();

    (colors, initial)
}

fn choose_split_axis(b: &ColorBox) -> Option<Axis> {
    let dr = b.r_range();
    let dg = b.g_range();
    let db = b.b_range();

    if dr <= 0 && dg <= 0 && db <= 0 {
        return None;
    }

    let axis = if dr < dg {
        Axis::G
    } else if db > dr {
        if dr > dg { Axis::B } else { Axis::G }
    } else {
        Axis::R
    };

    Some(axis)
}

fn axis_value(color: Rgb8, axis: Axis) -> u8 {
    match axis {
        Axis::R => color.r,
        Axis::G => color.g,
        Axis::B => color.b,
    }
}

fn recompute_box_bounds(colors: &[ColorEntry], b: &mut ColorBox) {
    let mut r_min = u8::MAX;
    let mut r_max = 0u8;
    let mut g_min = u8::MAX;
    let mut g_max = 0u8;
    let mut b_min = u8::MAX;
    let mut b_max = 0u8;
    let mut count = 0u32;
    let mut unique_count = 0u32;

    for entry in colors {
        let color = entry.rgb;
        if !color_in_box(color, b) {
            continue;
        }

        count += entry.count;
        unique_count += 1;
        r_min = r_min.min(color.r);
        r_max = r_max.max(color.r);
        g_min = g_min.min(color.g);
        g_max = g_max.max(color.g);
        b_min = b_min.min(color.b);
        b_max = b_max.max(color.b);
    }

    if count == 0 {
        b.count = 0;
        b.unique_count = 0;
        return;
    }

    b.r_min = r_min;
    b.r_max = r_max;
    b.g_min = g_min;
    b.g_max = g_max;
    b.b_min = b_min;
    b.b_max = b_max;
    b.count = count;
    b.unique_count = unique_count;
}

fn split_box(colors: &[ColorEntry], boxes: &mut Vec<ColorBox>, idx: usize) -> bool {
    let src = boxes[idx].clone();
    let Some(axis) = choose_split_axis(&src) else {
        return false;
    };

    let start = match axis {
        Axis::R => src.r_min,
        Axis::G => src.g_min,
        Axis::B => src.b_min,
    };
    let end = match axis {
        Axis::R => src.r_max,
        Axis::G => src.g_max,
        Axis::B => src.b_max,
    };

    let mut best_cut = None::<u8>;
    let mut best_half = 0u32;
    let mut prev_half = 0u32;
    let mut axis_counts = [0u32; 256];

    for entry in colors {
        let color = entry.rgb;
        if color_in_box(color, &src) {
            axis_counts[usize::from(axis_value(color, axis))] += 1;
        }
    }

    let mut half = 0u32;
    for t in start..=end {
        half += axis_counts[usize::from(t)];
        if half.saturating_mul(2) >= src.unique_count {
            best_cut = Some(t);
            best_half = half;
            break;
        }
        prev_half = half;
    }

    let Some(cut) = best_cut else {
        return false;
    };

    let mut a = src.clone();
    let mut c = src.clone();

    match axis {
        Axis::R => {
            if cut == src.r_max {
                a.r_max = cut.saturating_sub(1);
                c.r_min = cut;
                a.unique_count = prev_half;
                c.unique_count = src.unique_count.saturating_sub(prev_half);
            } else {
                a.r_max = cut;
                c.r_min = cut.saturating_add(1);
                a.unique_count = best_half;
                c.unique_count = src.unique_count.saturating_sub(best_half);
            }
        }
        Axis::G => {
            if cut == src.g_max {
                a.g_max = cut.saturating_sub(1);
                c.g_min = cut;
                a.unique_count = prev_half;
                c.unique_count = src.unique_count.saturating_sub(prev_half);
            } else {
                a.g_max = cut;
                c.g_min = cut.saturating_add(1);
                a.unique_count = best_half;
                c.unique_count = src.unique_count.saturating_sub(best_half);
            }
        }
        Axis::B => {
            if cut == src.b_max {
                a.b_max = cut.saturating_sub(1);
                c.b_min = cut;
                a.unique_count = prev_half;
                c.unique_count = src.unique_count.saturating_sub(prev_half);
            } else {
                a.b_max = cut;
                c.b_min = cut.saturating_add(1);
                a.unique_count = best_half;
                c.unique_count = src.unique_count.saturating_sub(best_half);
            }
        }
    }

    recompute_box_bounds(colors, &mut a);
    recompute_box_bounds(colors, &mut c);

    if a.count == 0 || c.count == 0 {
        return false;
    }

    boxes[idx] = a;
    boxes.push(c);
    true
}

fn box_average_color(colors: &[ColorEntry], b: &ColorBox) -> Option<(Rgb8, u32)> {
    if b.count == 0 {
        return None;
    }

    let mut sum_r: u64 = 0;
    let mut sum_g: u64 = 0;
    let mut sum_b: u64 = 0;
    let mut count: u64 = 0;

    for entry in colors {
        let color = entry.rgb;
        if !color_in_box(color, b) {
            continue;
        }

        let v = entry.count as u64;
        count += v;
        sum_r += u64::from(color.r) * v;
        sum_g += u64::from(color.g) * v;
        sum_b += u64::from(color.b) * v;
    }

    if count == 0 {
        None
    } else {
        Some((
            Rgb8 {
                r: (sum_r / count) as u8,
                g: (sum_g / count) as u8,
                b: (sum_b / count) as u8,
            },
            count as u32,
        ))
    }
}

fn merge_palette(colors: &mut Vec<(Rgb8, u32)>, target_len: usize) {
    if target_len == 0 {
        colors.clear();
        return;
    }

    while colors.len() > target_len {
        let mut best_i = 0usize;
        let mut best_j = 1usize;
        let mut best_d = u32::MAX;

        for i in 0..colors.len() - 1 {
            for j in (i + 1)..colors.len() {
                let d = color_dist2(colors[i].0, colors[j].0);
                if d < best_d {
                    best_d = d;
                    best_i = i;
                    best_j = j;
                }
            }
        }

        let (ci, wi) = colors[best_i];
        let (cj, wj) = colors[best_j];

        let total = wi as u64 + wj as u64;
        let merged = Rgb8 {
            r: (((ci.r as u64) * (wi as u64) + (cj.r as u64) * (wj as u64)) / total) as u8,
            g: (((ci.g as u64) * (wi as u64) + (cj.g as u64) * (wj as u64)) / total) as u8,
            b: (((ci.b as u64) * (wi as u64) + (cj.b as u64) * (wj as u64)) / total) as u8,
        };

        colors[best_i] = (merged, wi + wj);
        colors.swap_remove(best_j);
    }
}

/// Lua: T_Color_Module.MCutReduction(userdata, w, h, mN, cN, Cap, colN, col)
pub fn mcut_reduction(
    pixels_bgra: &mut [u8],
    width: usize,
    height: usize,
    mc_color_count: usize,
    cl_color_count: usize,
    cap: bool,
    specified_colors_rgb: &[u32],
) -> Result<()> {
    validate_bgra_buffer(pixels_bgra, width, height)?;
    ensure!(
        mc_color_count <= MAX_MC_COLORS,
        "mc_color_count must be <= {}",
        MAX_MC_COLORS
    );
    ensure!(
        specified_colors_rgb.len() <= MAX_SPECIFIED_COLORS,
        "specified_colors_rgb length must be <= {}",
        MAX_SPECIFIED_COLORS
    );

    let mut m = mc_color_count.min(MAX_MC_COLORS);
    let mut c = cl_color_count.min(m);
    let fixed: Vec<Rgb8> = specified_colors_rgb
        .iter()
        .copied()
        .map(u32_to_rgb)
        .collect();

    if m == 0 && fixed.is_empty() {
        m = 1;
        c = 0;
    }

    if m <= 1 {
        let avg = compute_average_opaque_color(pixels_bgra, width, height).unwrap_or_default();
        let palette = if m == 1 { vec![avg] } else { Vec::new() };

        if m == 1 && fixed.is_empty() && !cap {
            fill_opaque_with_color(pixels_bgra, width, height, avg);
            return Ok(());
        }

        if cap {
            draw_palette_grid(pixels_bgra, width, height, &palette, &fixed);
        } else {
            apply_reduction_with_palette_and_fixed(pixels_bgra, width, height, &palette, &fixed);
        }

        return Ok(());
    }

    let (colors, initial_box) = extract_colors_and_initial_box(pixels_bgra, width, height);
    let Some(initial_box) = initial_box else {
        return Ok(());
    };

    let mut boxes = vec![initial_box];

    while boxes.len() < m {
        let mut best_idx = None::<usize>;
        let mut best_volume = -1i32;

        for (i, b) in boxes.iter().enumerate() {
            let vol = b.volume_like();
            if vol > best_volume {
                best_volume = vol;
                best_idx = Some(i);
            }
        }

        let Some(idx) = best_idx else {
            unreachable!();
        };

        if !split_box(&colors, &mut boxes, idx) {
            break;
        }
    }

    let mut palette_with_weights: Vec<(Rgb8, u32)> = boxes
        .iter()
        .filter_map(|b| box_average_color(&colors, b))
        .collect();

    if c > 0 && palette_with_weights.len() > c {
        merge_palette(&mut palette_with_weights, c);
    }

    let palette: Vec<Rgb8> = palette_with_weights.iter().map(|&(rgb, _)| rgb).collect();

    if cap {
        draw_palette_grid(pixels_bgra, width, height, &palette, &fixed);
    } else {
        apply_reduction_with_palette_and_fixed(pixels_bgra, width, height, &palette, &fixed);
    }

    Ok(())
}

/// 任意: 2本目の Lua スクリプト相当の補助関数。
/// 画像を nx * ny に分割し、各セル中心の色を最大 sample_count 個まで取得する。
pub fn sample_grid_colors(
    pixels_bgra: &[u8],
    width: usize,
    height: usize,
    sample_count: usize,
    x_split: usize,
    y_split: usize,
) -> Result<Vec<u32>> {
    validate_bgra_buffer(pixels_bgra, width, height)?;
    ensure!(x_split >= 1, "x_split must be >= 1");
    ensure!(y_split >= 1, "y_split must be >= 1");

    let mut out = Vec::new();
    let dx = width as f64 / x_split as f64;
    let dy = height as f64 / y_split as f64;

    for j in 0..y_split {
        for i in 0..x_split {
            if out.len() >= sample_count {
                return Ok(out);
            }

            let xf = ((i as f64 + 0.5) * dx).floor();
            let yf = ((j as f64 + 0.5) * dy).floor();

            let x = xf.clamp(0.0, (width.saturating_sub(1)) as f64) as usize;
            let y = yf.clamp(0.0, (height.saturating_sub(1)) as f64) as usize;

            let idx = y * width + x;
            let (b, g, r, _) = get_pixel_bgra(pixels_bgra, idx);
            out.push(((r as u32) << 16) | ((g as u32) << 8) | b as u32);
        }
    }

    Ok(out)
}

#[cfg(test)]
mod tests {
    use super::*;

    fn push_pixel(buf: &mut Vec<u8>, r: u8, g: u8, b: u8) {
        buf.extend_from_slice(&[b, g, r, 0xff]);
    }

    #[test]
    fn mcut_split_uses_unique_color_median_not_pixel_weight_median() {
        let mut pixels = Vec::new();
        for _ in 0..100 {
            push_pixel(&mut pixels, 0, 0, 0);
        }
        push_pixel(&mut pixels, 10, 0, 0);
        push_pixel(&mut pixels, 20, 0, 0);

        mcut_reduction(&mut pixels, 102, 1, 2, 0, false, &[]).unwrap();

        assert_eq!(pixels[100 * 4 + 2], 0);
        assert_eq!(pixels[101 * 4 + 2], 20);
    }
}
