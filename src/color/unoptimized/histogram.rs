use anyhow::{Result, anyhow};

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

    clear_histogram_area(
        buffer,
        params.buffer_width,
        params.histogram_width,
        params.histogram_height,
    );

    if params.source_width == 0 || params.source_height == 0 || params.histogram_height == 0 {
        return Ok(());
    }

    let mut blue_hist = [0_u32; HISTOGRAM_BINS];
    let mut green_hist = [0_u32; HISTOGRAM_BINS];
    let mut red_hist = [0_u32; HISTOGRAM_BINS];
    let mut luma_hist = [0_u32; HISTOGRAM_BINS];

    for y in 0..params.source_height {
        let row_start = y * params.buffer_width * 4;
        let row = &buffer[row_start..row_start + params.source_width * 4];

        for px in row.chunks_exact(4) {
            let blue = px[0];
            let green = px[1];
            let red = px[2];
            let alpha = px[3];

            if alpha == 0 {
                continue;
            }

            blue_hist[blue as usize] += 1;
            green_hist[green as usize] += 1;
            red_hist[red as usize] += 1;

            let luma = (red as f64 * LUMA_R + green as f64 * LUMA_G + blue as f64 * LUMA_B)
                .round()
                .clamp(0.0, 255.0) as usize;
            luma_hist[luma] += 1;
        }
    }

    if params.show_luminance {
        let scale_base = mean_plus_stddev(&luma_hist);
        if scale_base > 0.0 {
            let scale = params.histogram_height as f64 / scale_base * params.vertical_scale / 3.0;
            draw_histogram(
                buffer,
                params.buffer_width,
                params.histogram_height,
                &luma_hist,
                scale,
                [255, 255, 255],
            );
        }
        return Ok(());
    }

    let scale_base = mean_plus_stddev(&blue_hist)
        .max(mean_plus_stddev(&green_hist))
        .max(mean_plus_stddev(&red_hist));

    if scale_base <= 0.0 {
        return Ok(());
    }

    let scale = params.histogram_height as f64 / scale_base * params.vertical_scale;

    if params.show_blue {
        draw_histogram(
            buffer,
            params.buffer_width,
            params.histogram_height,
            &blue_hist,
            scale,
            [255, 0, 0],
        );
    }
    if params.show_green {
        draw_histogram(
            buffer,
            params.buffer_width,
            params.histogram_height,
            &green_hist,
            scale,
            [0, 255, 0],
        );
    }
    if params.show_red {
        draw_histogram(
            buffer,
            params.buffer_width,
            params.histogram_height,
            &red_hist,
            scale,
            [0, 0, 255],
        );
    }

    Ok(())
}

fn clear_histogram_area(
    buffer: &mut [u8],
    buffer_width: usize,
    histogram_width: usize,
    histogram_height: usize,
) {
    for y in 0..histogram_height {
        let row_start = y * buffer_width * 4;
        let row = &mut buffer[row_start..row_start + histogram_width * 4];
        for px in row.chunks_exact_mut(4) {
            px[0] = 0;
            px[1] = 0;
            px[2] = 0;
            px[3] = 255;
        }
    }
}

fn mean_plus_stddev(histogram: &[u32; HISTOGRAM_BINS]) -> f64 {
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

fn draw_histogram(
    buffer: &mut [u8],
    buffer_width: usize,
    histogram_height: usize,
    histogram: &[u32; HISTOGRAM_BINS],
    scale: f64,
    color_bgra: [u8; 3],
) {
    for (x, &count) in histogram.iter().enumerate() {
        let bar_height = ((count as f64) * scale).round() as usize;
        let bar_height = bar_height.min(histogram_height);

        for y in 0..bar_height {
            let row = histogram_height - 1 - y;
            let pixel_index = (row * buffer_width + x) * 4;
            buffer[pixel_index] |= color_bgra[0];
            buffer[pixel_index + 1] |= color_bgra[1];
            buffer[pixel_index + 2] |= color_bgra[2];
            buffer[pixel_index + 3] = 255;
        }
    }
}
