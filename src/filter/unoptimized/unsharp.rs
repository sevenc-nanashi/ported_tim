pub struct UnsharpState {
    width: usize,
    height: usize,
    original: Option<Vec<u8>>,
}

impl UnsharpState {
    pub const fn new() -> Self {
        Self {
            width: 0,
            height: 0,
            original: None,
        }
    }

    pub fn set_public_image(
        &mut self,
        image_buffer: &[u8],
        width: usize,
        height: usize,
    ) -> anyhow::Result<bool> {
        if self.original.is_some() {
            return Ok(false);
        }
        let required = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        if image_buffer.len() < required {
            anyhow::bail!("Input buffer too small");
        }

        self.width = width;
        self.height = height;
        self.original = Some(image_buffer[..required].to_vec());
        Ok(true)
    }

    pub fn unsharp_mask(
        &mut self,
        image_buffer: &mut [u8],
        width: usize,
        height: usize,
        strength: f64,
    ) -> anyhow::Result<()> {
        let required = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        if image_buffer.len() < required {
            anyhow::bail!("Input buffer too small");
        }

        let original = self
            .original
            .as_ref()
            .ok_or_else(|| anyhow::anyhow!("Public image is not set"))?;
        if self.width != width || self.height != height || original.len() < required {
            anyhow::bail!("Stored image size mismatch");
        }

        let s = strength;
        for i in 0..(width * height) {
            let p = i * 4;
            let ob = original[p] as f64;
            let og = original[p + 1] as f64;
            let or_ = original[p + 2] as f64;
            let oa = original[p + 3];

            let cb = image_buffer[p] as f64;
            let cg = image_buffer[p + 1] as f64;
            let cr = image_buffer[p + 2] as f64;

            image_buffer[p] = (ob + (ob - cb) * s).round().clamp(0.0, 255.0) as u8;
            image_buffer[p + 1] = (og + (og - cg) * s).round().clamp(0.0, 255.0) as u8;
            image_buffer[p + 2] = (or_ + (or_ - cr) * s).round().clamp(0.0, 255.0) as u8;
            image_buffer[p + 3] = oa;
        }

        self.original = None;
        self.width = 0;
        self.height = 0;
        Ok(())
    }
}
