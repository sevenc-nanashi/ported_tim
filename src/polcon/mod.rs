use aviutl2::anyhow;
use std::ptr::NonNull;

pub mod optimized;

pub(crate) struct PolConModule;

#[aviutl2::module::functions]
#[allow(clippy::too_many_arguments)]
impl PolConModule {
    fn polcon_polar_conversion(
        image_buffer: NonNull<u8>,
        work_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        range: f64,
        apply_amount: f64,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        let work_buffer =
            unsafe { std::slice::from_raw_parts_mut(work_buffer.as_ptr(), buffer_size) };
        crate::polcon::optimized::polar_conversion(
            image_buffer,
            work_buffer,
            width,
            height,
            range,
            apply_amount,
        );
        Ok(())
    }

    fn polcon_polar_inversion(
        image_buffer: NonNull<u8>,
        work_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        range: f64,
        apply_amount: f64,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        let work_buffer =
            unsafe { std::slice::from_raw_parts_mut(work_buffer.as_ptr(), buffer_size) };
        crate::polcon::optimized::polar_inversion(
            image_buffer,
            work_buffer,
            width,
            height,
            range,
            apply_amount,
        );
        Ok(())
    }
}
