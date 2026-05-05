use aviutl2::anyhow;

pub fn calculate_threshold(
    image_buffer: &[u8],
    width: usize,
    height: usize,
) -> anyhow::Result<f64> {
    if width == 0 || height == 0 {
        return Ok(0.0);
    }

    let pixel_count = width
        .checked_mul(height)
        .ok_or_else(|| anyhow::anyhow!("Pixel count overflow"))?;
    let required = pixel_count
        .checked_mul(4)
        .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
    if image_buffer.len() < required {
        return Err(anyhow::anyhow!("Image buffer is too small"));
    }

    let sum: u64 = image_buffer
        .chunks_exact(4)
        .take(pixel_count)
        .map(|px| px[0] as u64)
        .sum();
    Ok(((sum as f64 / pixel_count as f64) as f32) as f64)
}
