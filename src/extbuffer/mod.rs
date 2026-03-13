use std::ptr::NonNull;

pub struct ExtbufferModule;

struct Buffer {
    pub data: Vec<u8>,
    pub width: usize,
    pub height: usize,
}
static BUFFERS: std::sync::LazyLock<dashmap::DashMap<i32, Buffer>> =
    std::sync::LazyLock::new(dashmap::DashMap::new);

static HEAP_BUFFERS: std::sync::LazyLock<dashmap::DashMap<usize, Vec<u8>>> =
    std::sync::LazyLock::new(dashmap::DashMap::new);

#[aviutl2::module::functions]
impl ExtbufferModule {
    fn extbuffer_save_buffer(index: i32, data: NonNull<u8>, width: usize, height: usize) {
        let buffer = Buffer {
            data: unsafe { std::slice::from_raw_parts(data.as_ptr(), width * height * 4).to_vec() },
            width,
            height,
        };
        BUFFERS.insert(index, buffer);
    }

    fn extbuffer_load_buffer(index: i32) -> anyhow::Result<(*const u8, usize, usize)> {
        let buffer = BUFFERS
            .get(&index)
            .ok_or_else(|| anyhow::anyhow!("Buffer with index {} not found", index))?;
        let heap_buffer = buffer.data.clone();
        let ptr = heap_buffer.as_ptr();
        HEAP_BUFFERS.insert(ptr as usize, heap_buffer);
        Ok((ptr, buffer.width, buffer.height))
    }

    fn extbuffer_free_buffer(ptr: NonNull<u8>) {
        HEAP_BUFFERS.remove(&(ptr.as_ptr() as usize));
    }

    fn extbuffer_clear_buffer(index: i32) {
        BUFFERS.remove(&index);
    }
}
