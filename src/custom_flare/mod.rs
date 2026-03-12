use aviutl2::anyhow;
use std::ptr::NonNull;

pub mod unoptimized;

pub(crate) struct CustomFlareModule;

#[aviutl2::module::functions]
#[allow(clippy::too_many_arguments)]
impl CustomFlareModule {
    fn custom_flare_load_image(name: String) -> anyhow::Result<(*const u8, usize, usize)> {
        let image_data = crate::custom_flare::unoptimized::load_image(&name)?;
        Ok(image_data)
    }

    fn custom_flare_free_image(image_ptr: NonNull<u8>) {
        crate::custom_flare::unoptimized::free_image(image_ptr.as_ptr());
    }
}
