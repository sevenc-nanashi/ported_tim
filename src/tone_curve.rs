use anyhow::{Result, anyhow, bail};
use std::f64::consts::PI;

#[derive(Debug, Clone)]
pub struct ToneCurveState {
    /// [0] = R, [1] = G, [2] = B
    pub luts: [[u8; 256]; 3],
}

impl Default for ToneCurveState {
    fn default() -> Self {
        let mut luts = [[0u8; 256]; 3];
        for channel_type in 0..3usize {
            for value in 0..256usize {
                luts[channel_type][value] = value as u8;
            }
        }
        Self { luts }
    }
}

#[inline]
fn clamp_i32(value: i32, min_value: i32, max_value: i32) -> i32 {
    value.clamp(min_value, max_value)
}

#[inline]
fn clamp_to_u8(value: f64) -> u8 {
    if value <= 0.0 {
        0
    } else if value >= 255.0 {
        255
    } else {
        value as u8
    }
}

#[inline]
fn normalize_degrees(angle_deg: f64) -> f64 {
    angle_deg - (angle_deg / 360.0).floor() * 360.0
}

#[inline]
fn pixel_offset(buffer_width: usize, x: usize, y: usize) -> usize {
    (y * buffer_width + x) * 4
}

#[inline]
fn validate_bgra_buffer_len(
    pixels: &[u8],
    buffer_width: usize,
    buffer_height: usize,
) -> Result<()> {
    let expected_len = buffer_width
        .checked_mul(buffer_height)
        .and_then(|pixel_count| pixel_count.checked_mul(4))
        .ok_or_else(|| anyhow!("buffer size overflow"))?;

    if pixels.len() != expected_len {
        bail!(
            "invalid buffer length: got {}, expected {}",
            pixels.len(),
            expected_len
        );
    }

    Ok(())
}

#[inline]
fn read_bgra(pixel: &[u8]) -> (u8, u8, u8, u8) {
    let b = pixel[0];
    let g = pixel[1];
    let r = pixel[2];
    let a = pixel[3];
    (b, g, r, a)
}

#[inline]
fn write_bgra(pixel: &mut [u8], b: u8, g: u8, r: u8, a: u8) {
    pixel[0] = b;
    pixel[1] = g;
    pixel[2] = r;
    pixel[3] = a;
}

#[inline]
fn write_bgra_u32_preserve_alpha(pixel: &mut [u8], color_bgra: u32) {
    let alpha = pixel[3];
    pixel[0] = (color_bgra & 0x0000_00FF) as u8;
    pixel[1] = ((color_bgra & 0x0000_FF00) >> 8) as u8;
    pixel[2] = ((color_bgra & 0x00FF_0000) >> 16) as u8;
    pixel[3] = alpha;
}

pub fn set_tone_curve_mode_0(
    state: &mut ToneCurveState,
    channel_type: usize,
    bias: f64,
    quadratic: f64,
    linear: f64,
    scale: f64,
) -> Result<()> {
    if channel_type >= 3 {
        bail!("channel_type out of range: {channel_type}");
    }

    let lut = &mut state.luts[channel_type];
    let bias_255 = bias * 255.0;

    for input_value in 0u16..=255 {
        let x = input_value as f64;
        let xn = x / 255.0;
        let output_value = x * (xn * (quadratic * xn + linear) + scale) + bias_255 + 0.5;
        lut[input_value as usize] = clamp_to_u8(output_value);
    }

    Ok(())
}

pub fn set_tone_curve_mode_1(
    state: &mut ToneCurveState,
    channel_type: usize,
    threshold: f64,
    upper_bias: f64,
    upper_slope: f64,
    lower_bias: f64,
    lower_slope: f64,
) -> Result<()> {
    if channel_type >= 3 {
        bail!("channel_type out of range: {channel_type}");
    }

    let lut = &mut state.luts[channel_type];

    for input_value in 0u16..=255 {
        let x = input_value as f64;
        let xn = x / 255.0;

        let output_value = if xn >= threshold {
            x * upper_slope + upper_bias * 255.0 + 0.5
        } else {
            x * lower_slope + lower_bias * 255.0 + 0.5
        };

        lut[input_value as usize] = clamp_to_u8(output_value);
    }

    Ok(())
}

pub fn set_tone_curve_mode_2(
    state: &mut ToneCurveState,
    channel_type: usize,
    threshold: f64,
    upper_bias: f64,
    upper_linear: f64,
    upper_quadratic: f64,
    lower_bias: f64,
    lower_linear: f64,
    lower_quadratic: f64,
) -> Result<()> {
    if channel_type >= 3 {
        bail!("channel_type out of range: {channel_type}");
    }

    let lut = &mut state.luts[channel_type];

    for input_value in 0u16..=255 {
        let x = input_value as f64;
        let xn = x / 255.0;

        let output_value = if xn >= threshold {
            x * (xn * upper_quadratic + upper_linear) + upper_bias * 255.0 + 0.5
        } else {
            x * (xn * lower_quadratic + lower_linear) + lower_bias * 255.0 + 0.5
        };

        lut[input_value as usize] = clamp_to_u8(output_value);
    }

    Ok(())
}

pub fn sim_tone_curve(
    state: &ToneCurveState,
    pixels: &mut [u8],
    buffer_width: usize,
    buffer_height: usize,
    copy_red_to_green_blue: bool,
) -> Result<()> {
    validate_bgra_buffer_len(pixels, buffer_width, buffer_height)?;

    let red_lut = state.luts[0];
    let mut green_lut = state.luts[1];
    let mut blue_lut = state.luts[2];

    if copy_red_to_green_blue {
        green_lut = red_lut;
        blue_lut = red_lut;
    }

    for pixel in pixels.chunks_exact_mut(4) {
        let b = pixel[0];
        let g = pixel[1];
        let r = pixel[2];
        let a = pixel[3];

        pixel[0] = blue_lut[b as usize];
        pixel[1] = green_lut[g as usize];
        pixel[2] = red_lut[r as usize];
        pixel[3] = a;
    }

    Ok(())
}

#[inline]
fn trunc_to_i32(value: f64) -> i32 {
    value as i32
}

#[inline]
fn round_half_up_to_i32_c(value: f64) -> i32 {
    (value + 0.5) as i32
}

fn sample_tone_curve_steep(
    pixels: &[u8],
    image_width: usize,
    image_height: usize,
    line_slope: f64,
    line_start_x: f64,
    line_start_y: f64,
    line_end_y: f64,
) -> ([u8; 256], [u8; 256], [u8; 256]) {
    let mut red_lut = [0u8; 256];
    let mut green_lut = [0u8; 256];
    let mut blue_lut = [0u8; 256];

    for sample_index in 0usize..256 {
        let reverse_index = 255usize - sample_index;
        let interpolated_y =
            ((reverse_index as f64) * line_start_y + (sample_index as f64) * line_end_y) / 255.0;

        let pixel_y = clamp_i32(
            trunc_to_i32(image_height as f64 * 0.5 + interpolated_y),
            0,
            image_height as i32 - 1,
        ) as usize;

        let pixel_x = clamp_i32(
            round_half_up_to_i32_c(
                (interpolated_y - line_start_y) * line_slope
                    + line_start_x
                    + image_width as f64 * 0.5,
            ),
            0,
            image_width as i32 - 1,
        ) as usize;

        let offset = pixel_offset(image_width, pixel_x, pixel_y);
        let (b, g, r, _) = read_bgra(&pixels[offset..offset + 4]);

        red_lut[sample_index] = r;
        green_lut[sample_index] = g;
        blue_lut[sample_index] = b;
    }

    (red_lut, green_lut, blue_lut)
}

fn sample_tone_curve_shallow(
    pixels: &[u8],
    image_width: usize,
    image_height: usize,
    line_slope: f64,
    line_start_x: f64,
    line_end_x: f64,
    line_start_y: f64,
) -> ([u8; 256], [u8; 256], [u8; 256]) {
    let mut red_lut = [0u8; 256];
    let mut green_lut = [0u8; 256];
    let mut blue_lut = [0u8; 256];

    for sample_index in 0usize..256 {
        let reverse_index = 255usize - sample_index;
        let interpolated_x =
            ((sample_index as f64) * line_end_x + (reverse_index as f64) * line_start_x) / 255.0;

        let pixel_x = clamp_i32(
            trunc_to_i32(image_width as f64 * 0.5 + interpolated_x),
            0,
            image_width as i32 - 1,
        ) as usize;

        let pixel_y = clamp_i32(
            round_half_up_to_i32_c(
                (interpolated_x - line_start_x) * line_slope
                    + line_start_y
                    + image_height as f64 * 0.5,
            ),
            0,
            image_height as i32 - 1,
        ) as usize;

        let offset = pixel_offset(image_width, pixel_x, pixel_y);
        let (b, g, r, _) = read_bgra(&pixels[offset..offset + 4]);

        red_lut[sample_index] = r;
        green_lut[sample_index] = g;
        blue_lut[sample_index] = b;
    }

    (red_lut, green_lut, blue_lut)
}

fn draw_sample_line_steep(
    pixels: &mut [u8],
    image_width: usize,
    image_height: usize,
    line_slope: f64,
    step_count: usize,
    line_start_x: f64,
    line_start_y: f64,
    line_end_y: f64,
    line_color_bgra: u32,
) {
    let denominator = step_count as f64;

    for step_index in 0usize..=step_count {
        let interpolated_y = if step_count == 0 {
            line_start_y
        } else {
            let reverse_index = step_count - step_index;
            ((reverse_index as f64) * line_start_y + (step_index as f64) * line_end_y) / denominator
        };

        let pixel_y = clamp_i32(
            trunc_to_i32(image_height as f64 * 0.5 + interpolated_y),
            0,
            image_height as i32 - 1,
        ) as usize;

        let pixel_x = clamp_i32(
            round_half_up_to_i32_c(
                (interpolated_y - line_start_y) * line_slope
                    + line_start_x
                    + image_width as f64 * 0.5,
            ),
            0,
            image_width as i32 - 1,
        ) as usize;

        let offset = pixel_offset(image_width, pixel_x, pixel_y);
        write_bgra_u32_preserve_alpha(&mut pixels[offset..offset + 4], line_color_bgra);
    }
}

fn draw_sample_line_shallow(
    pixels: &mut [u8],
    image_width: usize,
    image_height: usize,
    line_slope: f64,
    step_count: usize,
    line_start_x: f64,
    line_end_x: f64,
    line_start_y: f64,
    line_color_bgra: u32,
) {
    let denominator = step_count as f64;

    for step_index in 0usize..=step_count {
        let interpolated_x = if step_count == 0 {
            line_start_x
        } else {
            let reverse_index = step_count - step_index;
            ((step_index as f64) * line_end_x + (reverse_index as f64) * line_start_x) / denominator
        };

        let pixel_x = clamp_i32(
            trunc_to_i32(image_width as f64 * 0.5 + interpolated_x),
            0,
            image_width as i32 - 1,
        ) as usize;

        let pixel_y = clamp_i32(
            round_half_up_to_i32_c(
                (interpolated_x - line_start_x) * line_slope
                    + line_start_y
                    + image_height as f64 * 0.5,
            ),
            0,
            image_height as i32 - 1,
        ) as usize;

        let offset = pixel_offset(image_width, pixel_x, pixel_y);
        write_bgra_u32_preserve_alpha(&mut pixels[offset..offset + 4], line_color_bgra);
    }
}

pub fn image_tone_curve(
    state: &mut ToneCurveState,
    pixels: &mut [u8],
    image_width: usize,
    image_height: usize,
    center_x: f64,
    center_y: f64,
    angle_deg: f64,
    line_length: f64,
    line_color_bgra: u32,
    hide_line: bool,
) -> Result<()> {
    validate_bgra_buffer_len(pixels, image_width, image_height)?;

    let angle_rad = normalize_degrees(angle_deg) * PI / 180.0;

    let mut half_length = line_length * 0.5;
    if half_length < 1.0 {
        half_length = 1.0;
    }

    let delta_x = angle_rad.cos() * half_length;
    let delta_y = angle_rad.sin() * half_length;

    let line_start_x = center_x - delta_x;
    let line_start_y = center_y - delta_y;
    let line_end_x = center_x + delta_x;
    let line_end_y = center_y + delta_y;

    if delta_y.abs() >= delta_x.abs() {
        if delta_y == 0.0 {
            unreachable!("delta_y.abs() >= delta_x.abs() && delta_y == 0.0");
        }

        let line_slope = delta_x / delta_y;
        let (red_lut, green_lut, blue_lut) = sample_tone_curve_steep(
            pixels,
            image_width,
            image_height,
            line_slope,
            line_start_x,
            line_start_y,
            line_end_y,
        );

        state.luts[0] = red_lut;
        state.luts[1] = green_lut;
        state.luts[2] = blue_lut;

        if !hide_line {
            let step_count = ((round_half_up_to_i32_c(line_end_y))
                - (round_half_up_to_i32_c(line_start_y)))
            .unsigned_abs() as usize;

            draw_sample_line_steep(
                pixels,
                image_width,
                image_height,
                line_slope,
                step_count,
                line_start_x,
                line_start_y,
                line_end_y,
                line_color_bgra,
            );
        }
    } else {
        if delta_x == 0.0 {
            unreachable!("delta_y.abs() < delta_x.abs() && delta_x == 0.0");
        }

        let line_slope = delta_y / delta_x;
        let (red_lut, green_lut, blue_lut) = sample_tone_curve_shallow(
            pixels,
            image_width,
            image_height,
            line_slope,
            line_start_x,
            line_end_x,
            line_start_y,
        );

        state.luts[0] = red_lut;
        state.luts[1] = green_lut;
        state.luts[2] = blue_lut;

        if !hide_line {
            let step_count = ((round_half_up_to_i32_c(line_end_x))
                - (round_half_up_to_i32_c(line_start_x)))
            .unsigned_abs() as usize;

            draw_sample_line_shallow(
                pixels,
                image_width,
                image_height,
                line_slope,
                step_count,
                line_start_x,
                line_end_x,
                line_start_y,
                line_color_bgra,
            );
        }
    }

    Ok(())
}

pub fn draw_tone_curve(
    state: &ToneCurveState,
    pixels: &mut [u8],
    buffer_width: usize,
    buffer_height: usize,
    channel_type: usize,
    curve_color_bgra: u32,
) -> Result<()> {
    validate_bgra_buffer_len(pixels, buffer_width, buffer_height)?;

    if channel_type >= 3 {
        bail!("channel_type out of range: {channel_type}");
    }

    let graph_width = buffer_width.min(256);
    if graph_width == 0 || buffer_height == 0 {
        return Ok(());
    }

    let background_color_bgra: u32 = 0xFF00_0000;
    let graph_height = buffer_height as f64;

    for x in 0usize..graph_width {
        let lut_value = state.luts[channel_type][x] as f64;
        let filled_height = (lut_value * graph_height / 255.0).floor() as i32;
        let filled_height = filled_height.clamp(0, buffer_height as i32);

        for y_offset in 0..filled_height {
            let y = buffer_height - 1 - y_offset as usize;
            let offset = pixel_offset(buffer_width, x, y);
            let alpha = pixels[offset + 3];
            let b = (curve_color_bgra & 0x0000_00FF) as u8;
            let g = ((curve_color_bgra & 0x0000_FF00) >> 8) as u8;
            let r = ((curve_color_bgra & 0x00FF_0000) >> 16) as u8;
            write_bgra(&mut pixels[offset..offset + 4], b, g, r, alpha);
        }

        for y_offset in filled_height as usize..buffer_height {
            let y = buffer_height - 1 - y_offset;
            let offset = pixel_offset(buffer_width, x, y);
            let alpha = pixels[offset + 3];
            let b = (background_color_bgra & 0x0000_00FF) as u8;
            let g = ((background_color_bgra & 0x0000_FF00) >> 8) as u8;
            let r = ((background_color_bgra & 0x00FF_0000) >> 16) as u8;
            write_bgra(&mut pixels[offset..offset + 4], b, g, r, alpha);
        }
    }

    Ok(())
}
