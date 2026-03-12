use aviutl2::anyhow;
use std::ptr::NonNull;

pub mod unoptimized;

pub(crate) struct RandomBlurModule;

#[aviutl2::module::functions]
#[allow(clippy::too_many_arguments)]
impl RandomBlurModule {
    fn rndblur_pal_rand_blur(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        max_offset: f64,
        angle_deg: f64,
        seed: i32,
        base_position: f64,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        let mut state = unoptimized::RANDOM_BLUR_STATE
            .lock()
            .map_err(|_| anyhow::anyhow!("Failed to acquire random blur state lock"))?;
        crate::rndblur::unoptimized::pal_rand_blur::pal_rand_blur(
            &mut state,
            image_buffer,
            width,
            height,
            max_offset,
            angle_deg,
            seed,
            base_position,
        );
        Ok(())
    }

    fn rndblur_rot_rand_blur(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        max_offset: f64,
        radius: f64,
        center_x: f64,
        center_y: f64,
        seed: i32,
        base_position: f64,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        let mut state = unoptimized::RANDOM_BLUR_STATE
            .lock()
            .map_err(|_| anyhow::anyhow!("Failed to acquire random blur state lock"))?;
        crate::rndblur::unoptimized::rot_rand_blur::rot_rand_blur(
            &mut state,
            image_buffer,
            width,
            height,
            max_offset,
            radius,
            center_x,
            center_y,
            seed,
            base_position,
        );
        Ok(())
    }

    fn rndblur_rad_rand_blur(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        max_offset: f64,
        radius: f64,
        center_x: f64,
        center_y: f64,
        seed: i32,
        base_position: f64,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        let mut state = unoptimized::RANDOM_BLUR_STATE
            .lock()
            .map_err(|_| anyhow::anyhow!("Failed to acquire random blur state lock"))?;
        crate::rndblur::unoptimized::rad_rand_blur::rad_rand_blur(
            &mut state,
            image_buffer,
            width,
            height,
            max_offset,
            radius,
            center_x,
            center_y,
            seed,
            base_position,
        );
        Ok(())
    }
}
