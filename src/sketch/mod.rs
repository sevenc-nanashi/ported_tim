use aviutl2::anyhow;
use std::ptr::NonNull;

pub mod unoptimized;

pub(crate) struct SketchModule;

#[aviutl2::module::functions]
#[allow(clippy::too_many_arguments)]
impl SketchModule {
    fn sketch_sketch(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        size: f64,
        position_offset_percent: f64,
        pitch_percent: f64,
        color_width: f64,
        background_mode: f64,
        background_color: u32,
        enable_3d: f64,
        ambient_percent: f64,
        diffuse_percent: f64,
        specular_percent: f64,
        shininess_percent: f64,
        seed: f64,
        lock_color_reference: bool,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        crate::sketch::unoptimized::sketch(
            image_buffer,
            width,
            height,
            size as i32,
            position_offset_percent,
            pitch_percent,
            color_width as i32,
            background_mode as i32,
            background_color,
            enable_3d as i32 != 0,
            ambient_percent,
            diffuse_percent,
            specular_percent,
            shininess_percent,
            seed as i32,
            lock_color_reference,
        );
        Ok(())
    }
}
