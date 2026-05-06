use anyhow::{Result, anyhow};
use rayon::prelude::*;

const HISTOGRAM_BINS: usize = 256;
const LUMA_R: f64 = 0.299;
const LUMA_G: f64 = 0.587;
const LUMA_B: f64 = 0.114;

pub struct CreateHistogramParams {
    pub histogram_width: usize,
    pub histogram_height: usize,
    pub source_width: usize,
    pub source_height: usize,
    pub buffer_width: usize,
    pub buffer_height: usize,
    pub vertical_scale: f64,
    pub show_luminance: bool,
    pub show_red: bool,
    pub show_green: bool,
    pub show_blue: bool,
}

pub fn create_histogram(buffer: &mut [u8], params: CreateHistogramParams) -> Result<()> {
    validate_buffer(buffer, &params)?;

    clear_histogram_area(
        buffer,
        params.buffer_width,
        params.histogram_width,
        params.histogram_height,
    );

    if params.source_width == 0 || params.source_height == 0 || params.histogram_height == 0 {
        return Ok(());
    }

    let histograms = build_histograms(
        buffer,
        params.buffer_width,
        params.source_width,
        params.source_height,
    );
    let blue_hist = &histograms[0..HISTOGRAM_BINS];
    let green_hist = &histograms[HISTOGRAM_BINS..HISTOGRAM_BINS * 2];
    let red_hist = &histograms[HISTOGRAM_BINS * 2..HISTOGRAM_BINS * 3];
    let luma_hist = &histograms[HISTOGRAM_BINS * 3..HISTOGRAM_BINS * 4];

    if params.show_luminance {
        let scale_base = mean_plus_stddev(luma_hist);
        if scale_base > 0.0 {
            let scale = params.histogram_height as f64 / scale_base * params.vertical_scale / 3.0;
            let bars = scaled_bars(luma_hist, scale, params.histogram_height);
            draw_luminance_histogram(buffer, params.buffer_width, params.histogram_height, &bars);
        }
        return Ok(());
    }

    let scale_base = mean_plus_stddev(blue_hist)
        .max(mean_plus_stddev(green_hist))
        .max(mean_plus_stddev(red_hist));

    if scale_base <= 0.0 {
        return Ok(());
    }

    let scale = params.histogram_height as f64 / scale_base * params.vertical_scale;
    let blue_bars = scaled_bars(blue_hist, scale, params.histogram_height);
    let green_bars = scaled_bars(green_hist, scale, params.histogram_height);
    let red_bars = scaled_bars(red_hist, scale, params.histogram_height);

    draw_rgb_histogram(
        buffer,
        params.buffer_width,
        params.histogram_height,
        RgbHistogramView {
            blue_bars: &blue_bars,
            green_bars: &green_bars,
            red_bars: &red_bars,
            show_blue: params.show_blue,
            show_green: params.show_green,
            show_red: params.show_red,
        },
    );

    Ok(())
}

fn validate_buffer(buffer: &[u8], params: &CreateHistogramParams) -> Result<()> {
    if params.histogram_width < HISTOGRAM_BINS {
        return Err(anyhow!(
            "histogram width must be at least {} pixels, got {}",
            HISTOGRAM_BINS,
            params.histogram_width
        ));
    }

    if params.histogram_width > params.buffer_width
        || params.histogram_height > params.buffer_height
    {
        return Err(anyhow!(
            "histogram area {}x{} exceeds buffer size {}x{}",
            params.histogram_width,
            params.histogram_height,
            params.buffer_width,
            params.buffer_height
        ));
    }

    if params.source_width > params.buffer_width || params.source_height > params.buffer_height {
        return Err(anyhow!(
            "source area {}x{} exceeds buffer size {}x{}",
            params.source_width,
            params.source_height,
            params.buffer_width,
            params.buffer_height
        ));
    }

    let expected_len = params
        .buffer_width
        .checked_mul(params.buffer_height)
        .and_then(|v| v.checked_mul(4))
        .ok_or_else(|| anyhow!("buffer size overflow"))?;

    if buffer.len() != expected_len {
        return Err(anyhow!(
            "buffer length mismatch: got {}, expected {}",
            buffer.len(),
            expected_len
        ));
    }

    Ok(())
}

fn clear_histogram_area(
    buffer: &mut [u8],
    buffer_width: usize,
    histogram_width: usize,
    histogram_height: usize,
) {
    buffer
        .par_chunks_exact_mut(buffer_width * 4)
        .take(histogram_height)
        .for_each(|row| {
            for px in row[..histogram_width * 4].chunks_exact_mut(4) {
                px[0] = 0;
                px[1] = 0;
                px[2] = 0;
                px[3] = 255;
            }
        });
}

fn build_histograms(
    buffer: &[u8],
    buffer_width: usize,
    source_width: usize,
    source_height: usize,
) -> Vec<u32> {
    buffer
        .par_chunks_exact(buffer_width * 4)
        .take(source_height)
        .map(|row| {
            let mut histograms = vec![0_u32; HISTOGRAM_BINS * 4];
            for px in row[..source_width * 4].chunks_exact(4) {
                let blue = px[0];
                let green = px[1];
                let red = px[2];
                let alpha = px[3];

                if alpha == 0 {
                    continue;
                }

                histograms[blue as usize] += 1;
                histograms[HISTOGRAM_BINS + green as usize] += 1;
                histograms[HISTOGRAM_BINS * 2 + red as usize] += 1;

                let luma = (red as f64 * LUMA_R + green as f64 * LUMA_G + blue as f64 * LUMA_B)
                    .round()
                    .clamp(0.0, 255.0) as usize;
                histograms[HISTOGRAM_BINS * 3 + luma] += 1;
            }
            histograms
        })
        .reduce(
            || vec![0_u32; HISTOGRAM_BINS * 4],
            |mut total, row_histograms| {
                total
                    .iter_mut()
                    .zip(row_histograms)
                    .for_each(|(total, count)| *total += count);
                total
            },
        )
}

fn mean_plus_stddev(histogram: &[u32]) -> f64 {
    let mean = histogram.iter().map(|&count| count as f64).sum::<f64>() / HISTOGRAM_BINS as f64;

    let variance = histogram
        .iter()
        .map(|&count| {
            let diff = count as f64 - mean;
            diff * diff
        })
        .sum::<f64>()
        / HISTOGRAM_BINS as f64;

    mean + variance.sqrt()
}

fn scaled_bars(histogram: &[u32], scale: f64, histogram_height: usize) -> Vec<usize> {
    histogram
        .iter()
        .map(|&count| ((count as f64) * scale).round() as usize)
        .map(|bar_height| bar_height.min(histogram_height))
        .collect()
}

fn draw_luminance_histogram(
    buffer: &mut [u8],
    buffer_width: usize,
    histogram_height: usize,
    bars: &[usize],
) {
    buffer
        .par_chunks_exact_mut(buffer_width * 4)
        .take(histogram_height)
        .enumerate()
        .for_each(|(row_index, row)| {
            let y_from_bottom = histogram_height - 1 - row_index;
            for (x, &bar_height) in bars.iter().enumerate() {
                if y_from_bottom < bar_height {
                    let pixel_index = x * 4;
                    row[pixel_index] = 255;
                    row[pixel_index + 1] = 255;
                    row[pixel_index + 2] = 255;
                    row[pixel_index + 3] = 255;
                }
            }
        });
}

struct RgbHistogramView<'a> {
    blue_bars: &'a [usize],
    green_bars: &'a [usize],
    red_bars: &'a [usize],
    show_blue: bool,
    show_green: bool,
    show_red: bool,
}

fn draw_rgb_histogram(
    buffer: &mut [u8],
    buffer_width: usize,
    histogram_height: usize,
    view: RgbHistogramView<'_>,
) {
    buffer
        .par_chunks_exact_mut(buffer_width * 4)
        .take(histogram_height)
        .enumerate()
        .for_each(|(row_index, row)| {
            let y_from_bottom = histogram_height - 1 - row_index;
            for x in 0..HISTOGRAM_BINS {
                let pixel_index = x * 4;
                if view.show_blue && y_from_bottom < view.blue_bars[x] {
                    row[pixel_index] |= 255;
                }
                if view.show_green && y_from_bottom < view.green_bars[x] {
                    row[pixel_index + 1] |= 255;
                }
                if view.show_red && y_from_bottom < view.red_bars[x] {
                    row[pixel_index + 2] |= 255;
                }
                row[pixel_index + 3] = 255;
            }
        });
}
