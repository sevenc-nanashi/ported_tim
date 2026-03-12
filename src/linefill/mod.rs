use aviutl2::anyhow;
use std::ptr::NonNull;

pub mod unoptimized;

pub(crate) struct LineFillModule;

#[aviutl2::module::functions]
#[allow(clippy::too_many_arguments)]
impl LineFillModule {
    fn linefill_line_fill(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        spacing: i32,
        radians: f64,
        alpha_threshold: i32,
        random_x: f64,
        random_y: f64,
        seed: i32,
    ) -> anyhow::Result<(usize, usize, usize, Vec<f64>)> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts(image_buffer.as_ptr(), buffer_size) };
        Ok(crate::linefill::unoptimized::line_fill(
            image_buffer,
            width,
            height,
            spacing,
            radians,
            alpha_threshold,
            random_x,
            random_y,
            seed,
        ))
    }
}
