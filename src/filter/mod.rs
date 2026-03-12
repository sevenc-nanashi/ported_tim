use aviutl2::anyhow;
use std::ptr::NonNull;

pub mod unoptimized;

pub(crate) struct FilterModule;

#[aviutl2::module::functions]
#[allow(clippy::too_many_arguments)]
impl FilterModule {
    fn filter_sharp(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        strength: f64,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        crate::filter::unoptimized::sharp::sharp(image_buffer, width, height, strength);
        Ok(())
    }

    fn filter_emboss(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        strength: f64,
        direction: i32,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        crate::filter::unoptimized::emboss::emboss(
            image_buffer,
            width,
            height,
            strength,
            direction,
        );
        Ok(())
    }

    fn filter_flat_rgb(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        mode: i32,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        crate::filter::unoptimized::flat_rgb::flat_rgb(image_buffer, width, height, mode);
        Ok(())
    }

    fn filter_glass_sq(
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
        crate::filter::unoptimized::glass_sq::glass_sq(image_buffer, width, height);
        Ok(())
    }

    fn filter_flattening(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        divide: f64,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        crate::filter::unoptimized::flattening::flattening(image_buffer, width, height, divide);
        Ok(())
    }

    fn filter_set_public_image(
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
        let mut state = unoptimized::FILTER_UNSHARP_STATE
            .lock()
            .map_err(|_| anyhow::anyhow!("Failed to acquire unsharp state lock"))?;
        state.set_public_image(image_buffer, width, height)
    }

    fn filter_unsharp_mask(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        strength: f64,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        let mut state = unoptimized::FILTER_UNSHARP_STATE
            .lock()
            .map_err(|_| anyhow::anyhow!("Failed to acquire unsharp state lock"))?;
        state.unsharp_mask(image_buffer, width, height, strength)?;
        Ok(())
    }

    fn filter_graphicpen(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        line_length: i32,
        threshold: i32,
        white_line_amount: f64,
        black_line_amount: f64,
        direction: i32,
        seed: i32,
        auto_threshold: bool,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        crate::filter::unoptimized::graphicpen::graphicpen(
            image_buffer,
            width,
            height,
            line_length,
            threshold,
            white_line_amount,
            black_line_amount,
            direction,
            seed,
            auto_threshold,
        );
        Ok(())
    }

    fn filter_blaster(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        direction: i32,
        edge: f64,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        crate::filter::unoptimized::blaster::blaster(image_buffer, width, height, direction, edge);
        Ok(())
    }

    fn filter_gray_color(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        r1: i32,
        g1: i32,
        b1: i32,
        r2: i32,
        g2: i32,
        b2: i32,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        crate::filter::unoptimized::gray_color::gray_color(
            image_buffer,
            width,
            height,
            r1,
            g1,
            b1,
            r2,
            g2,
            b2,
        );
        Ok(())
    }

    fn filter_easy_binarization(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        threshold: i32,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        crate::filter::unoptimized::easy_binarization::easy_binarization(
            image_buffer,
            width,
            height,
            threshold,
        );
        Ok(())
    }

    fn filter_preprocessing(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        charcoal_apply: f64,
        chalk_apply: f64,
        pen_pressure: f64,
        threshold: i32,
        auto_threshold: bool,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        crate::filter::unoptimized::preprocessing::preprocessing(
            image_buffer,
            width,
            height,
            charcoal_apply,
            chalk_apply,
            pen_pressure,
            threshold,
            auto_threshold,
        );
        Ok(())
    }

    fn filter_chalk_charcoal(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        length: i32,
        r1: i32,
        g1: i32,
        b1: i32,
        r2: i32,
        g2: i32,
        b2: i32,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        crate::filter::unoptimized::chalk_charcoal::chalk_charcoal(
            image_buffer,
            width,
            height,
            length,
            r1,
            g1,
            b1,
            r2,
            g2,
            b2,
        );
        Ok(())
    }
}
