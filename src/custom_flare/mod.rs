use aviutl2::anyhow;

pub(crate) struct CustomFlareModule;

static CUSTOM_FLARE_IMAGES: include_dir::Dir<'_> =
    include_dir::include_dir!("$CARGO_MANIFEST_DIR/src/custom_flare/images");

struct BufferEntry {
    buffer: std::pin::Pin<Vec<u8>>,
    width: usize,
    height: usize,
}

static IMAGE_BUFFERS: std::sync::LazyLock<dashmap::DashMap<String, BufferEntry>> =
    std::sync::LazyLock::new(dashmap::DashMap::new);

#[aviutl2::module::functions]
#[allow(clippy::too_many_arguments)]
impl CustomFlareModule {
    fn custom_flare_load_image(name: String) -> anyhow::Result<(*const u8, usize, usize)> {
        let buffer = IMAGE_BUFFERS.entry(name.clone()).or_try_insert_with(|| {
            let file = CUSTOM_FLARE_IMAGES
                .get_file(format!("{}.webp", name))
                .ok_or_else(|| anyhow::anyhow!("image not found: {}", name))?;
            let img = image::load_from_memory(file.contents())?.to_rgba8();
            let (width, height) = img.dimensions();
            let buffer = img.into_raw();
            let pinned_buffer = std::pin::Pin::new(buffer);
            anyhow::Ok(BufferEntry {
                buffer: pinned_buffer,
                width: width as usize,
                height: height as usize,
            })
        })?;
        Ok((buffer.buffer.as_ptr(), buffer.width, buffer.height))
    }
}
