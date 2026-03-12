use aviutl2::anyhow;
use std::ptr::NonNull;

pub mod unoptimized;

pub(crate) struct RgLineModule;

#[aviutl2::module::functions]
#[allow(clippy::too_many_arguments)]
impl RgLineModule {
    fn rgline_set_public_image(
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
        let mut state = unoptimized::RG_LINE_STATE
            .lock()
            .map_err(|_| anyhow::anyhow!("Failed to acquire rgline state lock"))?;
        state.set_public_image(image_buffer, width, height)
    }

    fn rgline_set_map_image(
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
        let mut state = unoptimized::RG_LINE_STATE
            .lock()
            .map_err(|_| anyhow::anyhow!("Failed to acquire rgline state lock"))?;
        state.set_map_image(image_buffer, width, height)
    }

    #[allow(clippy::too_many_arguments)]

    fn rgline_line_ext(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        length: f64,
        intensity_upper: f64,
        intensity_lower: f64,
        threshold: f64,
        edge_strength: f64,
        edge_threshold: f64,
        line_only: bool,
        original_alpha: f64,
        background_alpha: f64,
        line_color: u32,
        bg_color: u32,
        screen_blend: bool,
        line_gamma: f64,
        direction_mask_seed: f64,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        let mut state = unoptimized::RG_LINE_STATE
            .lock()
            .map_err(|_| anyhow::anyhow!("Failed to acquire rgline state lock"))?;
        crate::rgline::unoptimized::line_ext(
            &mut state,
            image_buffer,
            width,
            height,
            length.round() as i32,
            intensity_upper.round() as i32,
            intensity_lower.round() as i32,
            threshold.round() as i32,
            edge_strength.round() as i32,
            edge_threshold.round() as i32,
            line_only,
            original_alpha.round() as i32,
            background_alpha.round() as i32,
            line_color,
            bg_color,
            screen_blend,
            line_gamma,
            direction_mask_seed.round() as i32,
        )
    }
}
