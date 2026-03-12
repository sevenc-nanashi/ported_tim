use aviutl2::anyhow;
use std::ptr::NonNull;

pub mod unoptimized;

pub(crate) struct RbwGraModule;

#[aviutl2::module::functions]
#[allow(clippy::too_many_arguments)]
impl RbwGraModule {
    fn rbwgra_r_gradation_line(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        mix_strength: f64,
        shrink_rate: f64,
        rotation_rad: f64,
        reverse: bool,
        circular: bool,
        shift: f64,
        repeat: bool,
        boundary_correction: f64,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        crate::rbwgra::unoptimized::r_gradation_line(
            image_buffer,
            width,
            height,
            mix_strength,
            shrink_rate,
            rotation_rad,
            reverse,
            circular,
            shift,
            repeat,
            boundary_correction,
        );
        Ok(())
    }
}
