use aviutl2::anyhow;

static CUSTOM_FLARE_IMAGES: include_dir::Dir<'_> =
    include_dir::include_dir!("$CARGO_MANIFEST_DIR/src/custom_flare/unoptimized/images");

static IMAGE_BUFFERS: std::sync::LazyLock<std::sync::Mutex<dashmap::DashMap<usize, Vec<u8>>>> =
    std::sync::LazyLock::new(|| std::sync::Mutex::new(dashmap::DashMap::new()));

pub fn load_image(name: &str) -> anyhow::Result<(*const u8, usize, usize)> {
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

pub fn free_image(ptr: *const u8) {
    let map = IMAGE_BUFFERS.lock().unwrap();
    map.remove(&(ptr as usize));
}
