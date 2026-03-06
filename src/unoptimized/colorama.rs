use anyhow::{Result, bail};

const GRADIENT_SIZE: usize = 1021; // 0..=1020

#[inline]
fn split_rgb(color: u32) -> [u8; 3] {
    [
        ((color >> 16) & 0xff) as u8, // R
        ((color >> 8) & 0xff) as u8,  // G
        (color & 0xff) as u8,         // B
    ]
}

#[inline]
fn lerp_u8(a: u8, b: u8, t: f64) -> u8 {
    ((a as f64) * (1.0 - t) + (b as f64) * t) as u8
}

/// Port of T_Color_Module.Colorama
///
/// Lua side:
/// Colorama(userdata, w, h, f_shift, cycle_count, max_colors, col1, col2, col3, col4, col5, col6)
///
/// - `pixels`: BGRA buffer
/// - `width`, `height`: image size
/// - `f_shift`: Lua wrapper already divides by 100 before calling this function
/// - `cycle_count`: number of palette cycles
/// - `max_colors`: number of active colors, expected in 1..=6
/// - `col1..col6`: 0xRRGGBB
pub fn colorama(
    pixels: &mut [u8],
    width: usize,
    height: usize,
    f_shift: f64,
    cycle_count: f64,
    max_colors: usize,
    col1: u32,
    col2: u32,
    col3: u32,
    col4: u32,
    col5: u32,
    col6: u32,
) -> Result<()> {
    let pixel_count = width
        .checked_mul(height)
        .ok_or_else(|| anyhow::anyhow!("image size overflow: width={width}, height={height}"))?;

    let expected_len = pixel_count
        .checked_mul(4)
        .ok_or_else(|| anyhow::anyhow!("buffer size overflow"))?;

    if pixels.len() != expected_len {
        bail!(
            "invalid buffer length: got {}, expected {} ({}x{}x4)",
            pixels.len(),
            expected_len,
            width,
            height
        );
    }

    let colors = [
        split_rgb(col1),
        split_rgb(col2),
        split_rgb(col3),
        split_rgb(col4),
        split_rgb(col5),
        split_rgb(col6),
    ];

    let active_count = match max_colors {
        1..=6 => max_colors,
        _ => unreachable!("validation macro should guarantee max_colors in 1..=6"),
    };

    // C code appends the first color after the last active color so interpolation
    // can wrap around cleanly.
    let mut palette = [[0u8; 3]; 7];
    palette[..6].copy_from_slice(&colors);
    palette[active_count] = palette[0];

    // Equivalent to sub_10014900: build 1021-color gradient table.
    let mut gradient = [[0u8; 3]; GRADIENT_SIZE];
    let scale = active_count as f64 * cycle_count;

    for i in 0..GRADIENT_SIZE {
        let x = ((i as f64 / 1020.0) + f_shift) * scale;
        let base = x.floor();
        let frac = x - base;

        // C does: palette[(floor(x) % max_colors)]
        let src_idx = (base as usize) % active_count;
        let c0 = palette[src_idx];
        let c1 = palette[src_idx + 1];

        gradient[i][0] = lerp_u8(c0[0], c1[0], frac); // R
        gradient[i][1] = lerp_u8(c0[1], c1[1], frac); // G
        gradient[i][2] = lerp_u8(c0[2], c1[2], frac); // B
    }

    // Equivalent to sub_100149F0: recolor pixels by luminance.
    for px in pixels.chunks_exact_mut(4) {
        let b = px[0];
        let g = px[1];
        let r = px[2];
        let a = px[3];

        let idx = ((r as f64) * 0.298_912 + (g as f64) * 0.586_61 + (b as f64) * 0.114_478) * 4.0;

        let idx = idx as usize;
        debug_assert!(idx < GRADIENT_SIZE);

        let mapped = gradient[idx];

        // Output stays BGRA
        px[0] = mapped[2]; // B
        px[1] = mapped[1]; // G
        px[2] = mapped[0]; // R
        px[3] = a; // preserve alpha
    }

    Ok(())
}
