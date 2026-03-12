use aviutl2::anyhow;
use std::sync::{LazyLock, Mutex};

pub(crate) static LINE_EXTRA_STATE: LazyLock<Mutex<crate::lineextra::unoptimized::LineExtraState>> =
    LazyLock::new(|| Mutex::new(crate::lineextra::unoptimized::LineExtraState::new()));

pub struct LineExtraState {
    width: usize,
    height: usize,
    original: Option<Vec<u8>>,
}

impl LineExtraState {
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
}

#[derive(Clone, Copy)]
struct LegacyRand {
    holdrand: u32,
}

impl LegacyRand {
    fn seeded(seed: i32) -> Self {
        Self {
            holdrand: seed as u32,
        }
    }

    fn rand15(&mut self) -> i32 {
        self.holdrand = self.holdrand.wrapping_mul(0x343fd).wrapping_add(0x269ec3);
        ((self.holdrand >> 16) & 0x7fff) as i32
    }
}

fn rgb_to_bgr(color: u32) -> (u8, u8, u8) {
    let r = ((color >> 16) & 0xff) as u8;
    let g = ((color >> 8) & 0xff) as u8;
    let b = (color & 0xff) as u8;
    (b, g, r)
}

fn blend_u8(dst: u8, src: u8, alpha01: f64) -> u8 {
    let a = alpha01.clamp(0.0, 1.0);
    ((dst as f64) * (1.0 - a) + (src as f64) * a)
        .round()
        .clamp(0.0, 255.0) as u8
}

fn div255_floor(v: i32) -> i32 {
    v / 0xff
}

#[allow(clippy::too_many_arguments)]
pub fn line_ext(
    state: &mut LineExtraState,
    image_buffer: &mut [u8],
    width: usize,
    height: usize,
    intensity: f64,
    particle_width: i32,
    threshold: i32,
    line_only: bool,
    background_alpha: f64,
    original_alpha: f64,
    line_color: u32,
    bg_color: u32,
    particle_mode: bool,
    particle_loop: bool,
    dir_start_deg: i32,
    dir_end_deg: i32,
    seed: i32,
) -> anyhow::Result<()> {
    let required = width
        .checked_mul(height)
        .and_then(|v| v.checked_mul(4))
        .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
    if image_buffer.len() < required {
        anyhow::bail!("Input buffer too small");
    }

    let original = match state.original.as_ref() {
        Some(v) if state.width == width && state.height == height && v.len() >= required => v,
        _ => return Ok(()),
    };

    let threshold_luma = threshold.clamp(0, 255);
    let intensity_scale = (intensity / 100.0).max(0.0);
    let bg_u = (((100.0 - background_alpha.clamp(0.0, 100.0)) * 255.0) / 100.0)
        .round()
        .clamp(0.0, 255.0) as i32;
    let orig_alpha_scale = (original_alpha.clamp(0.0, 100.0) / 100.0).clamp(0.0, 1.0);
    let (line_b, line_g, line_r) = rgb_to_bgr(line_color);
    let (bg_b, bg_g, bg_r) = rgb_to_bgr(bg_color);
    let threshold_cmp = (0xff - threshold_luma) * 0x100;
    let lut = if (intensity_scale - 1.0).abs() > f64::EPSILON {
        let mut t = [0i32; 1024];
        for (i, v) in t.iter_mut().enumerate() {
            let x = (i as f64) / 1024.0;
            *v = (x.powf(intensity_scale) * 65280.0).clamp(0.0, 65280.0) as i32;
        }
        Some(t)
    } else {
        None
    };

    let mut out = vec![0u8; required];
    for i in 0..(width * height) {
        let p = i * 4;
        let ob = original[p];
        let og = original[p + 1];
        let or_ = original[p + 2];
        let oa = original[p + 3];

        let cb = image_buffer[p];
        let cg = image_buffer[p + 1];
        let cr = image_buffer[p + 2];

        let cur_l = (cg as i32) * 0x96 + (cb as i32) * 0x1d + (cr as i32) * 0x4d;
        let mut i_var1 = if cur_l <= 0 {
            0xff00
        } else {
            let orig_l_scaled = (ob as i32) * 0x1d00 + (og as i32) * 0x9600 + (or_ as i32) * 0x4d00;
            let mut v = (orig_l_scaled / cur_l) * 0xff;
            if v > 0xff00 {
                v = 0xff00;
            }
            v
        };
        if i_var1 > threshold_cmp {
            i_var1 = 0xff00;
        }
        if let Some(t) = &lut {
            i_var1 = t[((i_var1 >> 6) as usize).min(1023)];
        }
        let i_var5 = ((0xff00 - i_var1) >> 8).clamp(0, 0xff);

        if line_only {
            let alpha = div255_floor(i_var5 * oa as i32).clamp(0, 255) as u8;
            out[p] = line_b;
            out[p + 1] = line_g;
            out[p + 2] = line_r;
            out[p + 3] = alpha;
        } else {
            let den = 0xfe01 - (0xff - bg_u) * (0xff - i_var5);
            if den < 1 {
                out[p] = 0;
                out[p + 1] = 0;
                out[p + 2] = 0;
                out[p + 3] = 0;
            } else {
                let i_var2 = (0xff - i_var5) * bg_u;
                out[p] = ((i_var2 * bg_b as i32 + i_var5 * line_b as i32 * 0xff) / den)
                    .clamp(0, 255) as u8;
                out[p + 1] = ((i_var2 * bg_g as i32 + i_var5 * line_g as i32 * 0xff) / den)
                    .clamp(0, 255) as u8;
                out[p + 2] = ((i_var2 * bg_r as i32 + i_var5 * line_r as i32 * 0xff) / den)
                    .clamp(0, 255) as u8;
                let a1 = div255_floor(den * oa as i32);
                out[p + 3] = div255_floor(a1).clamp(0, 255) as u8;
            }
            out[p + 3] = (((out[p + 3] as f64) * orig_alpha_scale)
                .round()
                .clamp(0.0, 255.0)) as u8;
        }
    }

    if particle_width > 0 {
        let mut rng = LegacyRand::seeded(seed);
        let mut moved = vec![0u8; required];
        let dir0 = (dir_start_deg as f64).to_radians();
        let dir1 = (dir_end_deg as f64).to_radians();
        let dir_span = dir1 - dir0;
        let w = particle_width;

        for y in 0..height {
            for x in 0..width {
                let i = y * width + x;
                let p = i * 4;
                if out[p + 3] == 0 {
                    continue;
                }

                let r = rng.rand15() as f64 / 32767.0;
                let ang = dir0 + dir_span * r;
                let dist = (rng.rand15() % (w + 1)) as f64;
                let dx = (ang.cos() * dist).round() as isize;
                let dy = (ang.sin() * dist).round() as isize;

                let mut nx = x as isize + dx;
                let mut ny = y as isize + dy;
                if particle_loop {
                    nx = ((nx % width as isize) + width as isize) % width as isize;
                    ny = ((ny % height as isize) + height as isize) % height as isize;
                } else if nx < 0 || ny < 0 || nx >= width as isize || ny >= height as isize {
                    continue;
                }

                let np = (ny as usize * width + nx as usize) * 4;
                if particle_mode {
                    let sa = out[p + 3] as f64 / 255.0;
                    moved[np] = blend_u8(moved[np], out[p], sa);
                    moved[np + 1] = blend_u8(moved[np + 1], out[p + 1], sa);
                    moved[np + 2] = blend_u8(moved[np + 2], out[p + 2], sa);
                    moved[np + 3] = moved[np + 3].saturating_add(out[p + 3] / 2);
                } else {
                    moved[np] = out[p];
                    moved[np + 1] = out[p + 1];
                    moved[np + 2] = out[p + 2];
                    moved[np + 3] = out[p + 3];
                }
            }
        }
        out = moved;
    }

    image_buffer[..required].copy_from_slice(&out);
    state.original = None;
    state.width = 0;
    state.height = 0;
    Ok(())
}
