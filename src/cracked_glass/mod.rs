use aviutl2::anyhow;
use std::ptr::NonNull;

pub mod unoptimized;

pub(crate) struct CrackedGlassModule;

#[aviutl2::module::functions]
#[allow(clippy::too_many_arguments)]
impl CrackedGlassModule {
    fn cracked_glass_cracked_glass(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        sh: i32,
        pt: i32,
        map_mode: bool,
        background_color: u32,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };

        crate::cracked_glass::unoptimized::cracked_glass(
            image_buffer,
            width,
            height,
            sh,
            pt,
            map_mode,
            background_color,
        )?;
        Ok(())
    }

    fn cracked_glass_add_glass(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        cs: i32,
        edge_mode: i32,
        sh: i32,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };

        crate::cracked_glass::unoptimized::add_glass(
            image_buffer,
            width,
            height,
            cs,
            edge_mode,
            sh,
        )?;
        Ok(())
    }
}
