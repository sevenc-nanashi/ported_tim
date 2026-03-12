use aviutl2::anyhow;
use std::ptr::NonNull;

pub mod unoptimized;

pub(crate) struct RotBlurModule;

#[aviutl2::module::functions]
#[allow(clippy::too_many_arguments)]
impl RotBlurModule {
    fn rotblur_rot_blur_l(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        blur_amount_deg: f64,
        center_x: f64,
        center_y: f64,
        base_position: f64,
        angle_resolution_down: f64,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        crate::rotblur::unoptimized::rot_blur_l::rot_blur_l(
            image_buffer,
            width,
            height,
            blur_amount_deg,
            center_x,
            center_y,
            base_position,
            angle_resolution_down,
        );
        Ok(())
    }

    fn rotblur_rot_blur_s(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        blur_amount_deg: f64,
        center_x: f64,
        center_y: f64,
        base_position: f64,
        angle_resolution_down: f64,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        crate::rotblur::unoptimized::rot_blur_s::rot_blur_s(
            image_buffer,
            width,
            height,
            blur_amount_deg,
            center_x,
            center_y,
            base_position,
            angle_resolution_down,
        );
        Ok(())
    }

    fn rotblur_rad_blur(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        blur_amount: f64,
        center_x: f64,
        center_y: f64,
        base_position: f64,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        crate::rotblur::unoptimized::rad_blur::rad_blur(
            image_buffer,
            width,
            height,
            blur_amount,
            center_x,
            center_y,
            base_position,
        );
        Ok(())
    }

    fn rotblur_whirlpool(
        image_buffer: NonNull<u8>,
        work_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        swirl_amount_deg: f64,
        radius: f64,
        center_x: f64,
        center_y: f64,
        change: i32,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts(image_buffer.as_ptr(), buffer_size) };
        let work_buffer =
            unsafe { std::slice::from_raw_parts_mut(work_buffer.as_ptr(), buffer_size) };
        crate::rotblur::unoptimized::whirlpool::whirlpool(
            image_buffer,
            work_buffer,
            width,
            height,
            swirl_amount_deg,
            radius,
            center_x,
            center_y,
            change,
        );
        Ok(())
    }

    #[allow(clippy::too_many_arguments)]
    fn rotblur_rot_hard_blur(
        image_buffer: NonNull<u8>,
        work_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        blur_amount_deg: f64,
        radius: f64,
        center_x: f64,
        center_y: f64,
        count: i32,
        amplitude_base: f64,
        roundness: f64,
        base_position: f64,
        seed: i32,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts(image_buffer.as_ptr(), buffer_size) };
        let work_buffer =
            unsafe { std::slice::from_raw_parts_mut(work_buffer.as_ptr(), buffer_size) };
        crate::rotblur::unoptimized::rot_hard_blur::rot_hard_blur(
            image_buffer,
            work_buffer,
            width,
            height,
            blur_amount_deg,
            radius,
            center_x,
            center_y,
            count,
            amplitude_base,
            roundness,
            base_position,
            seed,
        );
        Ok(())
    }

    #[allow(clippy::too_many_arguments)]

    fn rotblur_rad_hard_blur(
        image_buffer: NonNull<u8>,
        work_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        blur_amount: f64,
        center_x: f64,
        center_y: f64,
        count: i32,
        amplitude_base: f64,
        roundness: f64,
        base_position: f64,
        seed: i32,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts(image_buffer.as_ptr(), buffer_size) };
        let work_buffer =
            unsafe { std::slice::from_raw_parts_mut(work_buffer.as_ptr(), buffer_size) };
        crate::rotblur::unoptimized::rad_hard_blur::rad_hard_blur(
            image_buffer,
            work_buffer,
            width,
            height,
            blur_amount,
            center_x,
            center_y,
            count,
            amplitude_base,
            roundness,
            base_position,
            seed,
        );
        Ok(())
    }

    #[allow(clippy::too_many_arguments)]

    fn rotblur_dir_hard_blur(
        image_buffer: NonNull<u8>,
        work_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        blur_amount: f64,
        bump_size: i32,
        angle_rad: f64,
        amplitude_base: f64,
        roundness: f64,
        base_position: f64,
        seed: i32,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts(image_buffer.as_ptr(), buffer_size) };
        let work_buffer =
            unsafe { std::slice::from_raw_parts_mut(work_buffer.as_ptr(), buffer_size) };
        crate::rotblur::unoptimized::dir_hard_blur::dir_hard_blur(
            image_buffer,
            work_buffer,
            width,
            height,
            blur_amount,
            bump_size,
            angle_rad,
            amplitude_base,
            roundness,
            base_position,
            seed,
        );
        Ok(())
    }
}
