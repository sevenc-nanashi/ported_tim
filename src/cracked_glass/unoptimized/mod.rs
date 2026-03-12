use aviutl2::anyhow;

use anyhow::{Result, anyhow, bail};
use rand::{RngExt, SeedableRng};
use std::sync::{LazyLock, Mutex};

static GLASS_ORIGINAL: LazyLock<Mutex<Option<Vec<u32>>>> = LazyLock::new(|| Mutex::new(None));

#[inline]
fn pixel_to_u32(pixel: &[u8]) -> u32 {
    (pixel[0] as u32)
        | ((pixel[1] as u32) << 8)
        | ((pixel[2] as u32) << 16)
        | ((pixel[3] as u32) << 24)
}

#[inline]
fn write_u32_pixel(pixel: &mut [u8], value: u32) {
    pixel[0] = (value & 0xff) as u8;
    pixel[1] = ((value >> 8) & 0xff) as u8;
    pixel[2] = ((value >> 16) & 0xff) as u8;
    pixel[3] = ((value >> 24) & 0xff) as u8;
}

pub fn cracked_glass(
    userdata: &mut [u8],
    width: usize,
    height: usize,
    sh: i32,
    pt: i32,
    map_mode: bool,
    background_color: u32,
) -> Result<()> {
    let pixel_count = width
        .checked_mul(height)
        .ok_or_else(|| anyhow!("width * height overflow"))?;
    let expected_len = pixel_count
        .checked_mul(4)
        .ok_or_else(|| anyhow!("buffer size overflow"))?;
    if userdata.len() != expected_len {
        bail!(
            "invalid BGRA buffer length: got {}, expected {}",
            userdata.len(),
            expected_len
        );
    }

    let mut mask = vec![0u8; pixel_count];
    let mut original = vec![0u32; pixel_count];
    let threshold = sh.saturating_mul(3);
    let fill_color = if map_mode {
        0xff00_0000 | (background_color & 0x00ff_ffff)
    } else {
        0
    };

    for (i, px) in userdata.chunks_exact_mut(4).enumerate() {
        let src = pixel_to_u32(px);
        original[i] = src;

        let a = ((src >> 24) & 0xff) as i32;
        let sum = ((src >> 16) & 0xff) as i32 + ((src >> 8) & 0xff) as i32 + (src & 0xff) as i32;
        if a == 0 || sum > threshold {
            mask[i] = 0;
            write_u32_pixel(px, fill_color);
        } else {
            mask[i] = 1;
        }
    }

    let mut queue = vec![0usize; pixel_count];
    let seed = (pt as u64).wrapping_mul(pt as u64).wrapping_mul(0x9fbf1);
    let mut rng = rand::rngs::StdRng::seed_from_u64(seed);

    for idx in 0..pixel_count {
        if mask[idx] == 0 {
            continue;
        }

        let r = rng.random::<u8>() as u32;
        let g = rng.random::<u8>() as u32;
        let b = rng.random::<u8>() as u32;
        let color = (r << 16) | (g << 8) | b | 0xff00_0000;

        let mut top = 1usize;
        queue[0] = idx;
        mask[idx] = 0;
        write_u32_pixel(&mut userdata[idx * 4..idx * 4 + 4], color);

        while top > 0 {
            top -= 1;
            let p = queue[top];

            let x = p % width;
            let y = p / width;

            if x > 0 {
                let n = p - 1;
                if mask[n] == 1 {
                    queue[top] = n;
                    top += 1;
                    mask[n] = 0;
                    write_u32_pixel(&mut userdata[n * 4..n * 4 + 4], color);
                }
            }
            if x + 1 < width {
                let n = p + 1;
                if mask[n] == 1 {
                    queue[top] = n;
                    top += 1;
                    mask[n] = 0;
                    write_u32_pixel(&mut userdata[n * 4..n * 4 + 4], color);
                }
            }
            if y > 0 {
                let n = p - width;
                if mask[n] == 1 {
                    queue[top] = n;
                    top += 1;
                    mask[n] = 0;
                    write_u32_pixel(&mut userdata[n * 4..n * 4 + 4], color);
                }
            }
            if y + 1 < height {
                let n = p + width;
                if mask[n] == 1 {
                    queue[top] = n;
                    top += 1;
                    mask[n] = 0;
                    write_u32_pixel(&mut userdata[n * 4..n * 4 + 4], color);
                }
            }
        }
    }

    let mut state = GLASS_ORIGINAL
        .lock()
        .map_err(|_| anyhow!("Failed to acquire cracked glass state lock"))?;
    if map_mode {
        *state = None;
    } else {
        *state = Some(original);
    }

    Ok(())
}

pub fn add_glass(
    userdata: &mut [u8],
    width: usize,
    height: usize,
    cs: i32,
    edge_mode: i32,
    sh: i32,
) -> Result<()> {
    let pixel_count = width
        .checked_mul(height)
        .ok_or_else(|| anyhow!("width * height overflow"))?;
    let expected_len = pixel_count
        .checked_mul(4)
        .ok_or_else(|| anyhow!("buffer size overflow"))?;
    if userdata.len() != expected_len {
        bail!(
            "invalid BGRA buffer length: got {}, expected {}",
            userdata.len(),
            expected_len
        );
    }

    let mut state = GLASS_ORIGINAL
        .lock()
        .map_err(|_| anyhow!("Failed to acquire cracked glass state lock"))?;
    let original = state
        .as_ref()
        .ok_or_else(|| anyhow!("AddGlass called before CrackedGlass"))?;

    if original.len() != pixel_count {
        *state = None;
        bail!("cached cracked-glass source size mismatch");
    }

    if edge_mode == 0 {
        for (i, px) in userdata.chunks_exact_mut(4).enumerate() {
            let src = original[i];
            let b = px[0] as i32 + ((src & 0xff) as i32 * cs) / 100;
            let g = px[1] as i32 + (((src >> 8) & 0xff) as i32 * cs) / 100;
            let r = px[2] as i32 + (((src >> 16) & 0xff) as i32 * cs) / 100;
            px[0] = b.clamp(0, 255) as u8;
            px[1] = g.clamp(0, 255) as u8;
            px[2] = r.clamp(0, 255) as u8;
        }
    } else {
        let threshold = sh.saturating_mul(3);
        for (i, px) in userdata.chunks_exact_mut(4).enumerate() {
            let src = original[i];
            let a = ((src >> 24) & 0xff) as i32;
            let sum =
                ((src >> 16) & 0xff) as i32 + ((src >> 8) & 0xff) as i32 + (src & 0xff) as i32;
            if a != 0 && sum > threshold {
                px[0] = 0;
                px[1] = 0;
                px[2] = 0;
                px[3] = 0;
            }
        }
    }

    *state = None;
    Ok(())
}
