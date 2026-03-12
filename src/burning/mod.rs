use aviutl2::anyhow;
use std::ptr::NonNull;

pub mod unoptimized;

pub(crate) struct BurningModule;

#[aviutl2::module::functions]
#[allow(clippy::too_many_arguments)]
impl BurningModule {
    fn burning_extended_contrast(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        t: f64,
        ecw: f64,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        crate::burning::unoptimized::extended_contrast::extended_contrast(
            image_buffer,
            width,
            height,
            t,
            ecw,
        )?;
        Ok(())
    }

    fn burning_shift_channels(
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
        crate::burning::unoptimized::shift_channels::shift_channels(image_buffer, width, height)?;
        Ok(())
    }

    fn burning_tritone(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        color1: u32,
        color2: u32,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        crate::burning::unoptimized::tritone::tritone(image_buffer, width, height, color1, color2)?;
        Ok(())
    }
}
