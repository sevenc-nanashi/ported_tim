use aviutl2::anyhow::{self, bail};

fn pixel_count(width: usize, height: usize) -> anyhow::Result<usize> {
    width
        .checked_mul(height)
        .ok_or_else(|| anyhow::anyhow!("pixel count overflow: {width} * {height}"))
}

fn validate_bgra_buffer(buf: &[u8], width: usize, height: usize) -> anyhow::Result<usize> {
    let pixels = pixel_count(width, height)?;
    let expected_len = pixels
        .checked_mul(4)
        .ok_or_else(|| anyhow::anyhow!("buffer size overflow: {pixels} * 4"))?;
    if buf.len() != expected_len {
        bail!(
            "invalid BGRA buffer length: got {}, expected {}",
            buf.len(),
            expected_len
        );
    }
    Ok(pixels)
}

fn clamp_color(value: i32) -> u8 {
    value.clamp(0, 255) as u8
}

pub fn alpha_data_set(
    image_buffer: &mut [u8],
    width: usize,
    height: usize,
    target_method: u8,
) -> anyhow::Result<()> {
    validate_bgra_buffer(image_buffer, width, height)?;

    for pixel in image_buffer.chunks_exact_mut(4) {
        let alpha = match target_method {
            0 => pixel[3],
            1 => pixel[2],
            2 => pixel[1],
            3 => pixel[0],
            4 => ((pixel[0] as u16 + pixel[1] as u16 + pixel[2] as u16) / 3) as u8,
            _ => bail!("invalid target method: {target_method}"),
        };
        pixel[0] = 0;
        pixel[1] = 0;
        pixel[2] = 0;
        pixel[3] = alpha;
    }

    Ok(())
}

#[allow(clippy::too_many_arguments)]
pub fn alpha_fill_color(
    image_buffer: &mut [u8],
    width: usize,
    height: usize,
    red: i32,
    green: i32,
    blue: i32,
    target_position_x: i32,
    target_position_y: i32,
    alpha_threshold: i32,
    improved_calc: bool,
    opacity_scale: f64,
) -> anyhow::Result<()> {
    let pixels = validate_bgra_buffer(image_buffer, width, height)?;
    if pixels == 0 {
        return Ok(());
    }

    let threshold = alpha_threshold.clamp(0, 255) as u32;
    if threshold == 0 {
        return Ok(());
    }

    let fill_r = clamp_color(red);
    let fill_g = clamp_color(green);
    let fill_b = clamp_color(blue);
    let opacity_scale = opacity_scale.clamp(0.0, 1.0);

    let mut alpha_map = vec![0u32; pixels];
    for (i, pixel) in image_buffer.chunks_exact(4).enumerate() {
        alpha_map[i] = pixel[3] as u32;
    }

    if !improved_calc && threshold < 0xff {
        for alpha in &mut alpha_map {
            *alpha = ((*alpha * 0xff) / threshold).min(0xff);
        }
    }

    let center_x = (width as f64 * 0.5).round() as i32 + target_position_x;
    let center_y = (height as f64 * 0.5).round() as i32 + target_position_y;
    if center_x < 0 || center_y < 0 || center_x >= width as i32 || center_y >= height as i32 {
        return Ok(());
    }

    let start_index = center_y as usize * width + center_x as usize;
    if alpha_map[start_index] >= threshold {
        return Ok(());
    }

    let mut visited = vec![false; pixels];
    let mut stack = Vec::with_capacity(pixels.min(4096));
    visited[start_index] = true;
    stack.push(start_index);

    while let Some(index) = stack.pop() {
        let x = index % width;
        let y = index / width;

        if x > 0 {
            let next = index - 1;
            if !visited[next] && alpha_map[next] < threshold {
                visited[next] = true;
                stack.push(next);
            }
        }
        if x + 1 < width {
            let next = index + 1;
            if !visited[next] && alpha_map[next] < threshold {
                visited[next] = true;
                stack.push(next);
            }
        }
        if y > 0 {
            let next = index - width;
            if !visited[next] && alpha_map[next] < threshold {
                visited[next] = true;
                stack.push(next);
            }
        }
        if y + 1 < height {
            let next = index + width;
            if !visited[next] && alpha_map[next] < threshold {
                visited[next] = true;
                stack.push(next);
            }
        }
    }

    if improved_calc {
        let threshold_f = threshold as f64;
        for (index, is_visited) in visited.iter().copied().enumerate() {
            if !is_visited {
                continue;
            }

            let alpha = alpha_map[index] as f64;
            if alpha > threshold_f {
                continue;
            }

            let additional_alpha =
                ((255.0 - alpha) - ((255.0 - threshold_f) * alpha) / threshold_f) * opacity_scale;
            if additional_alpha <= 0.0 {
                continue;
            }

            let new_alpha = alpha + additional_alpha;
            let pixel = &mut image_buffer[index * 4..index * 4 + 4];
            let orig_b = pixel[0] as f64;
            let orig_g = pixel[1] as f64;
            let orig_r = pixel[2] as f64;

            pixel[0] = ((orig_b * alpha + fill_b as f64 * additional_alpha) / new_alpha)
                .round()
                .clamp(0.0, 255.0) as u8;
            pixel[1] = ((orig_g * alpha + fill_g as f64 * additional_alpha) / new_alpha)
                .round()
                .clamp(0.0, 255.0) as u8;
            pixel[2] = ((orig_r * alpha + fill_r as f64 * additional_alpha) / new_alpha)
                .round()
                .clamp(0.0, 255.0) as u8;
            pixel[3] = new_alpha.round().clamp(0.0, 255.0) as u8;
        }
    } else {
        let fill_b = fill_b as u32;
        let fill_g = fill_g as u32;
        let fill_r = fill_r as u32;
        for (index, is_visited) in visited.iter().copied().enumerate() {
            if !is_visited {
                continue;
            }

            let alpha = alpha_map[index].min(0xff);
            let inv_alpha = 0xff - alpha;
            let pixel = &mut image_buffer[index * 4..index * 4 + 4];

            pixel[0] = ((pixel[0] as u32 * alpha + inv_alpha * fill_b) / 0xff) as u8;
            pixel[1] = ((pixel[1] as u32 * alpha + inv_alpha * fill_g) / 0xff) as u8;
            pixel[2] = ((pixel[2] as u32 * alpha + inv_alpha * fill_r) / 0xff) as u8;
            pixel[3] = 0xff;
        }
    }

    Ok(())
}
