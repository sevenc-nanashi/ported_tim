use aviutl2::anyhow;
use std::ptr::NonNull;

mod core;

pub(crate) struct AlphaModule;

#[aviutl2::module::functions]
#[allow(clippy::too_many_arguments)]
impl AlphaModule {
    fn alpha_data_set(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        target_method: u8,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        crate::alpha::core::alpha_data_set(image_buffer, width, height, target_method)
    }

    fn alpha_fill_color(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        red: i32,
        green: i32,
        blue: i32,
        target_position_x: i32,
        target_position_y: i32,
        alpha_threshold: i32,
        improved_calc: bool,
        opacity_scale: f64,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        crate::alpha::core::alpha_fill_color(
            image_buffer,
            width,
            height,
            red,
            green,
            blue,
            target_position_x,
            target_position_y,
            alpha_threshold,
            improved_calc,
            opacity_scale,
        )
    }
}
