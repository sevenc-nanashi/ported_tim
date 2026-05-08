use aviutl2::anyhow;
use std::ptr::NonNull;

mod graphicpen;
mod preprocessing;

pub(crate) struct FilterModule;

#[aviutl2::module::functions]
#[allow(clippy::too_many_arguments)]
impl FilterModule {
    fn filter_graphicpen(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        line_length: i32,
        threshold: i32,
        white_line_amount: f64,
        black_line_amount: f64,
        direction: i32,
        seed: i32,
        auto_threshold: bool,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        crate::filter::graphicpen::graphicpen(
            image_buffer,
            width,
            height,
            line_length,
            threshold,
            white_line_amount,
            black_line_amount,
            direction,
            seed,
            auto_threshold,
        );
        Ok(())
    }

    fn filter_graphicpen_threshold(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
    ) -> anyhow::Result<f64> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts(image_buffer.as_ptr() as *const u8, buffer_size) };
        crate::filter::graphicpen::calculate_threshold(image_buffer, width, height)
    }

    fn filter_preprocessing_threshold(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
    ) -> anyhow::Result<f64> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts(image_buffer.as_ptr() as *const u8, buffer_size) };
        crate::filter::preprocessing::calculate_threshold(image_buffer, width, height)
    }
}
