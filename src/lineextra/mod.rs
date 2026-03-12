use aviutl2::anyhow;
use std::ptr::NonNull;

pub mod unoptimized;

pub(crate) struct LineExtraModule;

#[aviutl2::module::functions]
#[allow(clippy::too_many_arguments)]
impl LineExtraModule {
    fn lineextra_set_public_image(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
    ) -> anyhow::Result<bool> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts(image_buffer.as_ptr(), buffer_size) };
        let mut state = unoptimized::LINE_EXTRA_STATE
            .lock()
            .map_err(|_| anyhow::anyhow!("Failed to acquire line-extra state lock"))?;
        state.set_public_image(image_buffer, width, height)
    }

    #[allow(clippy::too_many_arguments)]

    fn lineextra_line_ext(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        intensity: f64,
        particle_width: f64,
        threshold: f64,
        line_only: bool,
        background_alpha: f64,
        original_alpha: f64,
        line_color: u32,
        bg_color: u32,
        particle_mode: bool,
        particle_loop: bool,
        dir_start_deg: f64,
        dir_end_deg: f64,
        seed: f64,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        let mut state = unoptimized::LINE_EXTRA_STATE
            .lock()
            .map_err(|_| anyhow::anyhow!("Failed to acquire line-extra state lock"))?;
        crate::lineextra::unoptimized::line_ext(
            &mut state,
            image_buffer,
            width,
            height,
            intensity,
            particle_width.round() as i32,
            threshold.round() as i32,
            line_only,
            background_alpha,
            original_alpha,
            line_color,
            bg_color,
            particle_mode,
            particle_loop,
            dir_start_deg.round() as i32,
            dir_end_deg.round() as i32,
            seed.round() as i32,
        )
    }
}
