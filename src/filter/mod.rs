use aviutl2::anyhow;
use std::ptr::NonNull;

mod graphicpen;
mod preprocessing;
pub mod unoptimized;

pub(crate) struct FilterModule;

#[aviutl2::module::functions]
#[allow(clippy::too_many_arguments)]
impl FilterModule {
    fn filter_flat_rgb(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        mode: i32,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        crate::filter::unoptimized::flat_rgb::flat_rgb(image_buffer, width, height, mode);
        Ok(())
    }

    fn filter_glass_sq(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        crate::filter::unoptimized::glass_sq::glass_sq(image_buffer, width, height);
        Ok(())
    }

    fn filter_flattening(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        divide: f64,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        crate::filter::unoptimized::flattening::flattening(image_buffer, width, height, divide);
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
