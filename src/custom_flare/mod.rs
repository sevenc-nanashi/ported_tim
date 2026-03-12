use aviutl2::anyhow;
use std::ptr::NonNull;

pub(crate) struct CustomFlareModule;

static CUSTOM_FLARE_IMAGES: include_dir::Dir<'_> =
    include_dir::include_dir!("$CARGO_MANIFEST_DIR/src/custom_flare/images");

static IMAGE_BUFFERS: std::sync::LazyLock<std::sync::Mutex<dashmap::DashMap<usize, Vec<u8>>>> =
    std::sync::LazyLock::new(|| std::sync::Mutex::new(dashmap::DashMap::new()));

#[aviutl2::module::functions]
#[allow(clippy::too_many_arguments)]
impl CustomFlareModule {
    fn custom_flare_load_image(name: String) -> anyhow::Result<(*const u8, usize, usize)> {
        let file = CUSTOM_FLARE_IMAGES
            .get_file(format!("{}.png", name))
            .ok_or_else(|| anyhow::anyhow!("image not found: {}", name))?;
        let img = image::load_from_memory(file.contents())?.to_rgba8();
        let (width, height) = img.dimensions();
        let buffer = img.into_raw();
        let ptr = buffer.as_ptr();
        let map = IMAGE_BUFFERS.lock().unwrap();
        map.insert(ptr as usize, buffer);
        Ok((ptr, width as usize, height as usize))
    }

    fn custom_flare_free_image(image_ptr: NonNull<u8>) {
        let map = IMAGE_BUFFERS.lock().unwrap();
        map.remove(&(image_ptr.as_ptr() as usize));
    }
}
