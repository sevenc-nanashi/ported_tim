pub mod pal_rand_blur;
pub mod rad_rand_blur;
pub mod rot_rand_blur;

use rand::{RngExt, SeedableRng, rngs::StdRng};

pub struct RandomBlurState {
    rng: StdRng,
}

impl RandomBlurState {
    pub fn new() -> Self {
        Self {
            rng: StdRng::seed_from_u64(1),
        }
    }

    pub(super) fn with_rng<T>(&mut self, seed: i32, callback: impl FnOnce(&mut StdRng) -> T) -> T {
        if seed != 0 {
            let s = seed as i64;
            let mut rng = StdRng::seed_from_u64(
                s.wrapping_mul(s).wrapping_mul(s).wrapping_mul(0x9fbf1) as u64,
            );
            callback(&mut rng)
        } else {
            callback(&mut self.rng)
        }
    }
}

pub(super) fn random_offset<R: RngExt + ?Sized>(rng: &mut R, base_position: f64) -> f64 {
    let unit = rng.random_range(0..1000) as f64 / 1000.0;
    0.5 - unit - base_position * 0.5
}

pub(super) fn copy_clamped_pixel(
    src: &[u8],
    dst: &mut [u8],
    width: usize,
    height: usize,
    dst_pixel_index: usize,
    sample_x: i32,
    sample_y: i32,
) {
    let sx = sample_x.clamp(0, width.saturating_sub(1) as i32) as usize;
    let sy = sample_y.clamp(0, height.saturating_sub(1) as i32) as usize;
    let src_offset = (sy * width + sx) * 4;
    let dst_offset = dst_pixel_index * 4;
    dst[dst_offset..dst_offset + 4].copy_from_slice(&src[src_offset..src_offset + 4]);
}
