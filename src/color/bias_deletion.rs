use anyhow::{Result, anyhow};
use rayon::prelude::*;

struct ChannelIntegral {
    sum: Vec<f64>,
    sum2: Option<Vec<f64>>,
    global_var: f64,
}

#[inline]
fn clamp_u8(x: f64) -> u8 {
    if x <= 0.0 {
        0
    } else if x >= 255.0 {
        255
    } else {
        x as u8
    }
}

#[inline]
fn rect_sum(integral: &[f64], iw: usize, xa: usize, xb: usize, ya: usize, yb: usize) -> f64 {
    let a = integral[ya * iw + xa];
    let b = integral[ya * iw + xb];
    let c = integral[yb * iw + xa];
    let d = integral[yb * iw + xb];
    d - b - c + a
}

fn build_channel_integral(
    image_buffer: &[u8],
    width: usize,
    height: usize,
    channel: usize,
    variance_correction: bool,
) -> ChannelIntegral {
    let iw = width + 1;
    let ih = height + 1;
    let mut sum = vec![0.0f64; iw * ih];
    let mut sum2 = variance_correction.then(|| vec![0.0f64; iw * ih]);

    for y in 0..height {
        let mut row_sum = 0.0f64;
        let mut row_sum2 = 0.0f64;

        for x in 0..width {
            let idx = (y * width + x) * 4 + channel;
            let value = image_buffer[idx] as f64;

            row_sum += value;
            sum[(y + 1) * iw + (x + 1)] = sum[y * iw + (x + 1)] + row_sum;

            if let Some(ref mut sum2) = sum2 {
                row_sum2 += value * value;
                sum2[(y + 1) * iw + (x + 1)] = sum2[y * iw + (x + 1)] + row_sum2;
            }
        }
    }

    let global_var = if let Some(ref sum2) = sum2 {
        let n_all = (width as f64) * (height as f64);
        let sum_all = sum[height * iw + width];
        let mean_all = sum_all / n_all;
        let var = (sum2[height * iw + width] / n_all) - (mean_all * mean_all);
        if var.is_finite() && var > 0.0 {
            var
        } else {
            0.0
        }
    } else {
        0.0
    };

    ChannelIntegral {
        sum,
        sum2,
        global_var,
    }
}

pub fn bias_deletion(
    image_buffer: &mut [u8],
    width: usize,
    height: usize,
    range: i32,
    adjust_amount: f64,
    offset: f64,
    threshold: f64,
    variance_correction: bool,
) -> Result<()> {
    let expected = width
        .checked_mul(height)
        .and_then(|p| p.checked_mul(4))
        .ok_or_else(|| anyhow!("w*h*4 overflow"))?;
    if image_buffer.len() != expected {
        return Err(anyhow!(
            "image buffer length mismatch: got {}, expected {}",
            image_buffer.len(),
            expected
        ));
    }

    let integrals = (0..3)
        .map(|channel| {
            build_channel_integral(image_buffer, width, height, channel, variance_correction)
        })
        .collect::<Vec<_>>();

    let range = range.max(0) as usize;
    let adjust = adjust_amount / 100.0;
    let out_bias = 128.0 + offset;
    let threshold2 = threshold * threshold;
    let iw = width + 1;

    image_buffer
        .par_chunks_mut(4)
        .enumerate()
        .for_each(|(pixel_index, pixel)| {
            let x = pixel_index % width;
            let y = pixel_index / width;
            let x0 = x.saturating_sub(range);
            let y0 = y.saturating_sub(range);
            let x1 = (x + range).min(width - 1);
            let y1 = (y + range).min(height - 1);
            let xa = x0;
            let xb = x1 + 1;
            let ya = y0;
            let yb = y1 + 1;
            let area = ((x1 - x0 + 1) as f64) * ((y1 - y0 + 1) as f64);

            for channel in 0..3 {
                let integral = &integrals[channel];
                let mean = rect_sum(&integral.sum, iw, xa, xb, ya, yb) / area;
                let dev = pixel[channel] as f64 - mean;

                let corrected = if variance_correction {
                    let sum2 = integral
                        .sum2
                        .as_ref()
                        .expect("sum2 must exist when variance_correction is true");
                    let local_var = (rect_sum(sum2, iw, xa, xb, ya, yb) / area) - (mean * mean);
                    let local_var = if local_var.is_finite() && local_var > 0.0 {
                        local_var
                    } else {
                        0.0
                    };
                    let denom = local_var.max(threshold2);
                    if denom <= 0.0 || integral.global_var <= 0.0 {
                        0.0
                    } else {
                        (integral.global_var / denom).sqrt() * dev
                    }
                } else {
                    dev
                };

                pixel[channel] = clamp_u8(corrected * adjust + out_bias);
            }
        });

    Ok(())
}
