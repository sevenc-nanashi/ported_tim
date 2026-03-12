use aviutl2::anyhow;
use std::ptr::NonNull;

pub mod unoptimized;

pub(crate) struct FramingModule;

#[aviutl2::module::functions]
#[allow(clippy::too_many_arguments)]
impl FramingModule {
    fn framing_set_image(
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
        let mut state = unoptimized::FRAMING_STATE
            .lock()
            .map_err(|_| anyhow::anyhow!("Failed to acquire framing state lock"))?;
        crate::framing::unoptimized::set_image(&mut state, image_buffer, width, height)
    }

    fn framing_re_alpha(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
    ) -> anyhow::Result<bool> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        let mut state = unoptimized::FRAMING_STATE
            .lock()
            .map_err(|_| anyhow::anyhow!("Failed to acquire framing state lock"))?;
        crate::framing::unoptimized::re_alpha(&mut state, image_buffer, width, height)
    }

    fn framing_set_alpha(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
    ) -> anyhow::Result<bool> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        let mut state = unoptimized::FRAMING_STATE
            .lock()
            .map_err(|_| anyhow::anyhow!("Failed to acquire framing state lock"))?;
        crate::framing::unoptimized::set_alpha(&mut state, image_buffer, width, height)
    }

    fn framing_set_color(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
    ) -> anyhow::Result<bool> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        let mut state = unoptimized::FRAMING_STATE
            .lock()
            .map_err(|_| anyhow::anyhow!("Failed to acquire framing state lock"))?;
        crate::framing::unoptimized::set_color(&mut state, image_buffer, width, height)
    }

    fn framing_framing(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        size: f64,
        boundary_blur: f64,
        alpha_base: i32,
        color1: u32,
        color2: u32,
        distance_gradient_mode: bool,
    ) -> anyhow::Result<bool> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        crate::framing::unoptimized::framing(
            image_buffer,
            width,
            height,
            size,
            boundary_blur,
            alpha_base,
            color1,
            color2,
            distance_gradient_mode,
        )
    }

    fn framing_framing_hi(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        size: f64,
        boundary_blur: f64,
        alpha_base: i32,
        color1: u32,
        color2: u32,
        distance_gradient_mode: bool,
    ) -> anyhow::Result<bool> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        crate::framing::unoptimized::framing_hi(
            image_buffer,
            width,
            height,
            size,
            boundary_blur,
            alpha_base,
            color1,
            color2,
            distance_gradient_mode,
        )
    }
}
