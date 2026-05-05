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
