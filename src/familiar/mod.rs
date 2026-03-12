use aviutl2::anyhow;
use std::ptr::NonNull;

pub mod unoptimized;

pub(crate) struct FamiliarModule;

#[aviutl2::module::functions]
#[allow(clippy::too_many_arguments)]
impl FamiliarModule {
    fn famili_set_color(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        center_x: f64,
        center_y: f64,
        range_width: f64,
        range_height: f64,
        show_range: bool,
        frame_color: u32,
        line_width: i32,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        let mut state = unoptimized::FAMILIAR_STATE
            .lock()
            .map_err(|_| anyhow::anyhow!("Failed to acquire familiar state lock"))?;
        crate::familiar::unoptimized::set_color(
            &mut state,
            image_buffer,
            width,
            height,
            center_x,
            center_y,
            range_width,
            range_height,
            show_range,
            frame_color,
            line_width,
        )?;
        Ok(())
    }

    fn famili_get_color() -> anyhow::Result<(u8, u8, u8)> {
        let state = unoptimized::FAMILIAR_STATE
            .lock()
            .map_err(|_| anyhow::anyhow!("Failed to acquire familiar state lock"))?;
        Ok(state.get_color())
    }

    fn famili_familiar(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        adapt_rate: f64,
        lightness_adjust: f64,
        correct_saturation: bool,
        correct_value: bool,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        let state = unoptimized::FAMILIAR_STATE
            .lock()
            .map_err(|_| anyhow::anyhow!("Failed to acquire familiar state lock"))?;
        crate::familiar::unoptimized::familiar(
            &state,
            image_buffer,
            width,
            height,
            adapt_rate,
            lightness_adjust,
            correct_saturation,
            correct_value,
        )?;
        Ok(())
    }
}
