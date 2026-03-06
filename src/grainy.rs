use anyhow::{Result, anyhow};
use rand::rngs::StdRng;
use rand::{RngExt, SeedableRng};

#[inline]
fn clamp_u8(v: f64) -> u8 {
    if v <= 0.0 {
        0
    } else if v >= 255.0 {
        255
    } else {
        v as u8
    }
}

pub fn grainy(
    userdata: &mut [u8],
    w: usize,
    h: usize,
    amount: f64,
    contrast: f64,
    processing_method: i32,
    seed: i32,
    col1: u32,
    col2: u32,
) -> Result<()> {
    let pixels = w
        .checked_mul(h)
        .ok_or_else(|| anyhow!("dimension overflow"))?;

    let required = pixels
        .checked_mul(4)
        .ok_or_else(|| anyhow!("buffer overflow"))?;

    if userdata.len() < required {
        return Err(anyhow!("buffer too small"));
    }

    // C: srand(654321 * seed^3)
    let rng_seed = if seed != 0 {
        let s = seed as i64;
        (654321i64.wrapping_mul(s.wrapping_mul(s).wrapping_mul(s))) as u64
    } else {
        1
    };

    let mut rng = StdRng::seed_from_u64(rng_seed);

    let contrast_scale = contrast * 0.01;

    match processing_method {
        // ------------------------------------------------------------
        // method 1
        // ------------------------------------------------------------
        1 => {
            let threshold_shift = (amount - 50.0) * 5.1205;

            for i in 0..pixels {
                let p = i * 4;

                let b = userdata[p] as f64;
                let g = userdata[p + 1] as f64;
                let r = userdata[p + 2] as f64;
                let a = userdata[p + 3];

                let mut luminance =
                    contrast_scale * (g * 0.58661 + r * 0.298912 + b * 0.114478 - 128.0) + 128.0;

                luminance = luminance.clamp(0.0, 255.0);

                let noise = (rng.random_range(0..10000) as f64) * 0.0256 + threshold_shift;

                let chosen = if noise <= luminance { col1 } else { col2 };

                let c = chosen & 0x00ffffff;

                userdata[p] = (c & 0xff) as u8;
                userdata[p + 1] = ((c >> 8) & 0xff) as u8;
                userdata[p + 2] = ((c >> 16) & 0xff) as u8;
                userdata[p + 3] = a;
            }
        }

        // ------------------------------------------------------------
        // method 2
        // ------------------------------------------------------------
        2 => {
            let noise_scale = amount * 5.12;

            for i in 0..pixels {
                let p = i * 4;

                let b = userdata[p] as f64;
                let g = userdata[p + 1] as f64;
                let r = userdata[p + 2] as f64;
                let a = userdata[p + 3];

                let r0 = (r - 128.0) * contrast_scale + 128.0;
                let g0 = (g - 128.0) * contrast_scale + 128.0;
                let b0 = (b - 128.0) * contrast_scale + 128.0;

                let noise = |rng: &mut StdRng| {
                    ((rng.random_range(0..10000) as f64) * 0.0002 - 1.0) * noise_scale
                };

                let r1 = clamp_u8(r0 + noise(&mut rng));
                let g1 = clamp_u8(g0 + noise(&mut rng));
                let b1 = clamp_u8(b0 + noise(&mut rng));

                userdata[p] = b1;
                userdata[p + 1] = g1;
                userdata[p + 2] = r1;
                userdata[p + 3] = a;
            }
        }

        // ------------------------------------------------------------
        // method 3
        // ------------------------------------------------------------
        3 => {
            let c = col1 & 0x00ffffff;

            let col_b = (c & 0xff) as f64;
            let col_g = ((c >> 8) & 0xff) as f64;
            let col_r = ((c >> 16) & 0xff) as f64;

            for i in 0..pixels {
                let p = i * 4;

                let b = userdata[p] as f64;
                let g = userdata[p + 1] as f64;
                let r = userdata[p + 2] as f64;
                let a = userdata[p + 3];

                let prob = (rng.random_range(0..10000) as f64) * 0.01;

                let (sr, sg, sb) = if prob < amount {
                    (col_r, col_g, col_b)
                } else {
                    (r, g, b)
                };

                let r2 = clamp_u8((sr - 128.0) * contrast_scale + 128.0);
                let g2 = clamp_u8((sg - 128.0) * contrast_scale + 128.0);
                let b2 = clamp_u8((sb - 128.0) * contrast_scale + 128.0);

                userdata[p] = b2;
                userdata[p + 1] = g2;
                userdata[p + 2] = r2;
                userdata[p + 3] = a;
            }
        }

        _ => unreachable!("processing_method must be 1..=3"),
    }

    Ok(())
}
