use aviutl2::anyhow::{Result, bail};

pub(crate) fn calculate_threshold(image_buffer: &[u8], width: usize, height: usize) -> Result<f64> {
    if width == 0 || height == 0 {
        bail!("width/height must be > 0");
    }

    let pixel_count = width
        .checked_mul(height)
        .ok_or_else(|| aviutl2::anyhow::anyhow!("width*height overflow"))?;
    let buffer_size = pixel_count
        .checked_mul(4)
        .ok_or_else(|| aviutl2::anyhow::anyhow!("pixel byte size overflow"))?;
    if image_buffer.len() != buffer_size {
        bail!(
            "image_buffer length mismatch: expected {} bytes, got {}",
            buffer_size,
            image_buffer.len()
        );
    }

    let sum: u64 = image_buffer
        .chunks_exact(4)
        .map(|pixel| u64::from(pixel[0]))
        .sum();
    Ok(sum as f64 / pixel_count as f64)
}

pub(crate) fn graphicpen(
    image_buffer: &mut [u8],
    width: usize,
    height: usize,
    length: i32,
    threshold: i32,
    white_line_amount: f64,
    black_line_amount: f64,
    direction: i32,
    seed: i32,
    auto_threshold: bool,
) {
    if width == 0 || height == 0 {
        return;
    }
    let pixel_count = width.saturating_mul(height);
    let required = pixel_count.saturating_mul(4);
    if image_buffer.len() < required {
        return;
    }

    let mut gray = vec![0u8; pixel_count];
    for i in 0..pixel_count {
        gray[i] = image_buffer[i * 4];
    }

    let mut th = threshold.clamp(0, 255) as f64;
    if auto_threshold {
        let sum: u64 = gray.iter().map(|&v| v as u64).sum();
        th = sum as f64 / pixel_count as f64;
    }
    let th_u8 = th.round().clamp(0.0, 255.0) as u8;

    let mut lut = [0.0f64; 256];
    let low_den = th + 1.0;
    for (i, value) in lut.iter_mut().enumerate().take(th_u8 as usize) {
        *value = 1.0 - ((i + 1) as f64 / low_den);
    }
    let high_den = (255.0 - th) + 1.0;
    for (i, value) in lut.iter_mut().enumerate().skip(th_u8 as usize) {
        *value = (i as f64 - th) / high_den;
    }

    let (sign, dir_flag, mut len_eff) = match direction {
        0 => (1isize, 1isize, ((length as f64) * 0.7).round() as i32),
        1 => (1isize, 0isize, length),
        2 => (-1isize, 1isize, ((length as f64) * 0.7).round() as i32),
        _ => (0isize, 1isize, length),
    };
    len_eff = len_eff.max(0);
    let threshold_mode = th_u8;
    let step = sign * width as isize + dir_flag;
    let len = len_eff as usize;
    if width <= len * 2 || height <= len * 2 {
        for (i, &v) in gray.iter().enumerate() {
            let p = i * 4;
            image_buffer[p] = v;
            image_buffer[p + 1] = v;
            image_buffer[p + 2] = v;
        }
        return;
    }

    let white_adj = 1.0 - white_line_amount * 2.0;
    let black_adj = 1.0 - black_line_amount * 2.0;

    let s = seed as i64;
    let rng_seed = 654_321i64.wrapping_mul(s.wrapping_mul(s).wrapping_mul(s)) as u64;
    let mut rng = fastrand::Rng::with_seed(rng_seed as _ );

    let mut out = gray.clone();
    for y in len..(height - len) {
        for x in len..(width - len) {
            let idx = y * width + x;
            let px = out[idx];
            let r0 = rng.f64_inclusive();
            let r1 = rng.f64_inclusive();

            if px <= threshold_mode {
                out[idx] = 0;
                if lut[px as usize] + white_adj < r0 {
                    draw_line(&mut out, idx, step, len, r1, 255);
                }
            } else {
                out[idx] = 255;
                if lut[px as usize] + black_adj < r0 {
                    draw_line(&mut out, idx, step, len, r1, 0);
                }
            }
        }
    }

    for (i, &v) in out.iter().enumerate() {
        let p = i * 4;
        image_buffer[p] = v;
        image_buffer[p + 1] = v;
        image_buffer[p + 2] = v;
    }
}

fn draw_line(out: &mut [u8], idx: usize, step: isize, len: usize, random: f64, value: u8) {
    let d = len as f64 * random + 1.0;
    let start = (d * -0.5).round() as isize;
    let end = (d * 0.5).round() as isize;
    if end <= start {
        return;
    }

    let pixel_count = out.len() as isize;
    for t in start..end {
        let n = idx as isize + t * step;
        if (0..pixel_count).contains(&n) {
            out[n as usize] = value;
        }
    }
}
