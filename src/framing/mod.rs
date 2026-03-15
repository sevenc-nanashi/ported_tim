mod core;
use std::ptr::NonNull;

pub(crate) struct FramingModule;

#[aviutl2::module::functions]
#[allow(clippy::too_many_arguments)]
impl FramingModule {
    fn framing_create_distance_map(
        image_buffer: NonNull<u8>,
        return_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        alpha_threshold: u8,
        blur: f64,
        distance: f64,
    ) -> anyhow::Result<()> {
        let image_buffer = unsafe {
            std::slice::from_raw_parts_mut(
                image_buffer.as_ptr(),
                width
                    .checked_mul(height)
                    .and_then(|v| v.checked_mul(4))
                    .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?,
            )
        };
        let return_buffer = unsafe {
            std::slice::from_raw_parts_mut(
                return_buffer.as_ptr(),
                width
                    .checked_mul(height)
                    .and_then(|v| v.checked_mul(4))
                    .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?,
            )
        };

        let before = std::time::Instant::now();
        core::create_distance_map(
            image_buffer,
            return_buffer,
            width,
            height,
            alpha_threshold,
            blur,
            distance,
        )?;
        aviutl2::lprintln!("Distance map created in {:.2?}", before.elapsed());
        Ok(())
    }
}
