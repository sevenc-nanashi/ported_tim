use std::ptr::NonNull;

pub struct ExtbufferModule;

struct Buffer {
    pub data: Vec<u8>,
    pub width: usize,
    pub height: usize,
}
static BUFFERS: std::sync::LazyLock<dashmap::DashMap<i32, Buffer>> =
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

    fn extbuffer_load_buffer_size(index: i32) -> anyhow::Result<(usize, usize)> {
        let buffer = BUFFERS
            .get(&index)
            .ok_or_else(|| anyhow::anyhow!("Buffer with index {} not found", index))?;
        Ok((buffer.width, buffer.height))
    }

    fn extbuffer_load_buffer(index: i32, ptr: NonNull<u8>) -> anyhow::Result<()> {
        let buffer = BUFFERS
            .get(&index)
            .ok_or_else(|| anyhow::anyhow!("Buffer with index {} not found", index))?;
        let size = unsafe {
            std::slice::from_raw_parts_mut(ptr.as_ptr(), buffer.width * buffer.height * 4)
        };
        size.copy_from_slice(&buffer.data);

        Ok(())
    }

    fn extbuffer_clear_buffer(index: i32) {
        BUFFERS.remove(&index);
    }
}
