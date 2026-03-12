use rand::{RngExt, SeedableRng, rngs::StdRng};

const HALF: f64 = 0.5;
const INV_RANDOM_SCALE: f64 = 1.0 / 2048.0;
const RANDOM_CENTER: i32 = 0x7ff;
const FIXED_COLOR_SCALE: i32 = 0x800;
const FIXED_COLOR_MAX: i32 = 0x7f800;
const FIXED_ALPHA_SCALE: u32 = 0x100000;
const FIXED_SPECULAR_SCALE: f64 = 522_240.0;

#[derive(Clone, Copy)]
struct SketchPoint {
    x: f64,
    y: f64,
    base_index: usize,
    color_noise: [i32; 3],
}

pub fn sketch(
    image_buffer: &mut [u8],
    width: usize,
    height: usize,
    size: i32,
    position_offset_percent: f64,
    pitch_percent: f64,
    color_width: i32,
    background_mode: i32,
    background_color: u32,
    enable_3d: bool,
    ambient_percent: f64,
    diffuse_percent: f64,
    specular_percent: f64,
    shininess_percent: f64,
    seed: i32,
    lock_color_reference: bool,
) {
    if width == 0 || height == 0 {
        return;
    }

    let size = size.max(3);
    let position_offset = position_offset_percent / 100.0;
    let pitch_percent = pitch_percent.clamp(0.0, 100.0);
    let pitch = (size as f64 * pitch_percent) / 100.0;
    if !pitch.is_finite() || pitch <= f64::EPSILON {
        return;
    }

    let ambient = ambient_percent.max(0.0) / 100.0;
    let diffuse = diffuse_percent.max(0.0) / 100.0;
    let specular = specular_percent.max(0.0) / 100.0;
    let shininess = shininess_percent.max(0.0);
    let radius = size as f64 * HALF;
    let radius_sq = radius * radius;
    let solid_radius = (radius - 1.0).max(0.0);
    let solid_radius_sq = solid_radius * solid_radius;
    let center_x = width.saturating_sub(1) as f64 * HALF;
    let center_y = height.saturating_sub(1) as f64 * HALF;
    let half_grid_x = (((width as f64) * HALF + pitch) / pitch).ceil() as i32;
    let half_grid_y = (((height as f64) * HALF + pitch) / pitch).ceil() as i32;
    let grid_width = (half_grid_x * 2 + 1) as usize;
    let grid_height = (half_grid_y * 2 + 1) as usize;
    let grid_count = grid_width * grid_height;
    let mut rng = StdRng::seed_from_u64(seed as u64);

    let mut position_noise = Vec::with_capacity(grid_count);
    for _ in 0..grid_count {
        position_noise.push([
            rng.random_range(0..0x1000),
            rng.random_range(0..0x1000),
        ]);
    }
    let mut color_noise = Vec::with_capacity(grid_count);
    for _ in 0..grid_count {
        color_noise.push([
            rng.random_range(0..0x1000),
            rng.random_range(0..0x1000),
            rng.random_range(0..0x1000),
        ]);
    }

    let mut points = Vec::with_capacity(grid_count);
    for grid_y in -half_grid_y..=half_grid_y {
        let base_y = grid_y as f64 * pitch + center_y;
        let base_y_index = clamp_index(round_half_up(base_y), height);
        for grid_x in -half_grid_x..=half_grid_x {
            let point_index =
                ((grid_y + half_grid_y) as usize) * grid_width + (grid_x + half_grid_x) as usize;
            let base_x = grid_x as f64 * pitch + center_x;
            let base_x_index = clamp_index(round_half_up(base_x), width);
            let jitter = position_noise[point_index];
            let x = base_x
                + (jitter[0] - RANDOM_CENTER) as f64 * INV_RANDOM_SCALE * pitch * position_offset;
            let y = base_y
                + (jitter[1] - RANDOM_CENTER) as f64 * INV_RANDOM_SCALE * pitch * position_offset;
            points.push(SketchPoint {
                x,
                y,
                base_index: base_y_index * width + base_x_index,
                color_noise: color_noise[point_index],
            });
        }
    }

    let src = image_buffer.to_vec();
    let (bg_r, bg_g, bg_b) = split_rgb(background_color);

    for y in 0..height {
        let pixel_y = y as f64;
        let estimated_grid_y = trunc_to_i32((pixel_y - center_y) / pitch + half_grid_y as f64);
        let search_y_start = (estimated_grid_y - 3).max(0);
        let search_y_end = (estimated_grid_y + 4).min(grid_height as i32 - 1);
        for x in 0..width {
            let pixel_x = x as f64;
            let pixel_index = y * width + x;
            let src_offset = pixel_index * 4;
            let estimated_grid_x = trunc_to_i32((pixel_x - center_x) / pitch + half_grid_x as f64);
            let search_x_start = (estimated_grid_x - 3).max(0);
            let search_x_end = (estimated_grid_x + 4).min(grid_width as i32 - 1);

            let mut nearest: Option<(usize, f64)> = None;
            let mut second: Option<(usize, f64)> = None;

            for grid_y in search_y_start..=search_y_end {
                for grid_x in search_x_start..=search_x_end {
                    let point_index = grid_y as usize * grid_width + grid_x as usize;
                    let point = points[point_index];
                    let dx = point.x - pixel_x;
                    let dy = point.y - pixel_y;
                    let dist_sq = dx * dx + dy * dy;

                    match nearest {
                        None => nearest = Some((point_index, dist_sq)),
                        Some((_, best_dist_sq)) if dist_sq < best_dist_sq => {
                            second = nearest;
                            nearest = Some((point_index, dist_sq));
                        }
                        _ => match second {
                            None => second = Some((point_index, dist_sq)),
                            Some((_, second_dist_sq)) if dist_sq < second_dist_sq => {
                                second = Some((point_index, dist_sq));
                            }
                            _ => {}
                        },
                    }
                }
            }

            let mut alpha_fixed = 0u32;
            let mut out_rgb = [bg_r, bg_g, bg_b];

            if let Some((nearest_index, nearest_dist_sq)) = nearest
                && nearest_dist_sq <= radius_sq
            {
                let nearest_point = points[nearest_index];
                let mut coverage = coverage_from_distance(nearest_dist_sq, radius, solid_radius_sq);
                let mut fixed_rgb = sample_point_rgb_fixed(
                    &src,
                    width,
                    height,
                    nearest_point,
                    color_width,
                    lock_color_reference,
                );

                if let Some((second_index, second_dist_sq)) = second
                    && second_dist_sq <= radius_sq
                {
                    let second_point = points[second_index];
                    if is_between_points(pixel_x, pixel_y, nearest_point, second_point) {
                        let second_coverage =
                            coverage_from_distance(second_dist_sq, radius, solid_radius_sq);
                        let second_rgb = sample_point_rgb_fixed(
                            &src,
                            width,
                            height,
                            second_point,
                            color_width,
                            lock_color_reference,
                        );
                        fixed_rgb =
                            blend_fixed_rgb(fixed_rgb, second_rgb, coverage, second_coverage);
                        coverage = coverage.max(second_coverage);
                    }
                }

                if enable_3d {
                    fixed_rgb = apply_3d_shading(
                        fixed_rgb,
                        nearest_dist_sq,
                        radius,
                        ambient,
                        diffuse,
                        specular,
                        shininess,
                    );
                }

                alpha_fixed = alpha_to_fixed(coverage);
                out_rgb = [
                    fixed_to_byte(fixed_rgb[0]),
                    fixed_to_byte(fixed_rgb[1]),
                    fixed_to_byte(fixed_rgb[2]),
                ];
            }

            let dst = &mut image_buffer[src_offset..src_offset + 4];
            match background_mode {
                1 => {
                    let inv_alpha = FIXED_ALPHA_SCALE - alpha_fixed;
                    dst[0] = blend_fixed_byte(out_rgb[2], bg_b, alpha_fixed, inv_alpha);
                    dst[1] = blend_fixed_byte(out_rgb[1], bg_g, alpha_fixed, inv_alpha);
                    dst[2] = blend_fixed_byte(out_rgb[0], bg_r, alpha_fixed, inv_alpha);
                    dst[3] = src[src_offset + 3];
                }
                3 => {
                    let inv_alpha = FIXED_ALPHA_SCALE - alpha_fixed;
                    dst[0] = blend_fixed_byte(out_rgb[2], src[src_offset], alpha_fixed, inv_alpha);
                    dst[1] =
                        blend_fixed_byte(out_rgb[1], src[src_offset + 1], alpha_fixed, inv_alpha);
                    dst[2] =
                        blend_fixed_byte(out_rgb[0], src[src_offset + 2], alpha_fixed, inv_alpha);
                    dst[3] = src[src_offset + 3];
                }
                _ => {
                    dst[0] = out_rgb[2];
                    dst[1] = out_rgb[1];
                    dst[2] = out_rgb[0];
                    dst[3] = (((src[src_offset + 3] as u64) * (alpha_fixed as u64)) >> 20) as u8;
                }
            }
        }
    }
}

fn sample_point_rgb_fixed(
    src: &[u8],
    width: usize,
    height: usize,
    point: SketchPoint,
    color_width: i32,
    lock_color_reference: bool,
) -> [i32; 3] {
    let sample_index = if lock_color_reference {
        point.base_index
    } else {
        let x = clamp_index(round_half_up(point.x), width);
        let y = clamp_index(round_half_up(point.y), height);
        y * width + x
    };
    let offset = sample_index * 4;
    let source_b = src[offset] as i32;
    let source_g = src[offset + 1] as i32;
    let source_r = src[offset + 2] as i32;
    [
        clamp_fixed_color(
            source_r * FIXED_COLOR_SCALE + (point.color_noise[0] - RANDOM_CENTER) * color_width,
        ),
        clamp_fixed_color(
            source_g * FIXED_COLOR_SCALE + (point.color_noise[1] - RANDOM_CENTER) * color_width,
        ),
        clamp_fixed_color(
            source_b * FIXED_COLOR_SCALE + (point.color_noise[2] - RANDOM_CENTER) * color_width,
        ),
    ]
}

fn apply_3d_shading(
    fixed_rgb: [i32; 3],
    nearest_dist_sq: f64,
    radius: f64,
    ambient: f64,
    diffuse: f64,
    specular: f64,
    shininess: f64,
) -> [i32; 3] {
    let z = (radius * radius - nearest_dist_sq).max(0.0).sqrt() / radius.max(f64::EPSILON);
    let diffuse_light = z * diffuse + ambient;
    let specular_light = z.powf(shininess) * specular * FIXED_SPECULAR_SCALE;
    [
        clamp_fixed_color(floor_to_i32(
            fixed_rgb[0] as f64 * diffuse_light + specular_light,
        )),
        clamp_fixed_color(floor_to_i32(
            fixed_rgb[1] as f64 * diffuse_light + specular_light,
        )),
        clamp_fixed_color(floor_to_i32(
            fixed_rgb[2] as f64 * diffuse_light + specular_light,
        )),
    ]
}

fn blend_fixed_rgb(
    first: [i32; 3],
    second: [i32; 3],
    first_weight: f64,
    second_weight: f64,
) -> [i32; 3] {
    let total = first_weight + second_weight;
    if total <= f64::EPSILON {
        return first;
    }
    [
        floor_to_i32((first[0] as f64 * first_weight + second[0] as f64 * second_weight) / total),
        floor_to_i32((first[1] as f64 * first_weight + second[1] as f64 * second_weight) / total),
        floor_to_i32((first[2] as f64 * first_weight + second[2] as f64 * second_weight) / total),
    ]
}

fn coverage_from_distance(distance_sq: f64, radius: f64, solid_radius_sq: f64) -> f64 {
    if distance_sq >= solid_radius_sq {
        (radius - distance_sq.sqrt()).max(0.0)
    } else {
        1.0
    }
}

fn is_between_points(pixel_x: f64, pixel_y: f64, first: SketchPoint, second: SketchPoint) -> bool {
    let dx = second.x - first.x;
    let dy = second.y - first.y;
    let length = dx.hypot(dy);
    if length <= f64::EPSILON {
        return false;
    }
    let first_projection = ((pixel_y - first.y) * dy + (pixel_x - first.x) * dx) / length;
    let second_projection = ((pixel_y - second.y) * dy + (pixel_x - second.x) * dx) / length;
    first_projection * second_projection < 0.0
}

fn split_rgb(color: u32) -> (u8, u8, u8) {
    (
        ((color >> 16) & 0xff) as u8,
        ((color >> 8) & 0xff) as u8,
        (color & 0xff) as u8,
    )
}

fn blend_fixed_byte(foreground: u8, background: u8, alpha: u32, inverse_alpha: u32) -> u8 {
    (((foreground as u64) * (alpha as u64) + (background as u64) * (inverse_alpha as u64)) >> 20)
        as u8
}

fn alpha_to_fixed(alpha: f64) -> u32 {
    floor_to_u32(alpha.clamp(0.0, 1.0) * FIXED_ALPHA_SCALE as f64).min(FIXED_ALPHA_SCALE)
}

fn fixed_to_byte(value: i32) -> u8 {
    (clamp_fixed_color(value) >> 11) as u8
}

fn clamp_fixed_color(value: i32) -> i32 {
    value.clamp(0, FIXED_COLOR_MAX)
}

fn round_half_up(value: f64) -> i32 {
    trunc_to_i32(value + HALF)
}

fn trunc_to_i32(value: f64) -> i32 {
    if !value.is_finite() {
        return 0;
    }
    if value >= 0.0 {
        value.floor() as i32
    } else {
        value.ceil() as i32
    }
}

fn floor_to_i32(value: f64) -> i32 {
    if !value.is_finite() {
        return 0;
    }
    value.floor().clamp(i32::MIN as f64, i32::MAX as f64) as i32
}

fn floor_to_u32(value: f64) -> u32 {
    if !value.is_finite() || value <= 0.0 {
        return 0;
    }
    value.floor().clamp(0.0, u32::MAX as f64) as u32
}

fn clamp_index(index: i32, len: usize) -> usize {
    index.clamp(0, len.saturating_sub(1) as i32) as usize
}
