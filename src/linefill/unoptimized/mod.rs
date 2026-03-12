use rand::rngs::StdRng;
use rand::{RngExt, SeedableRng};

/// Ghidra 解析ベースの `T_LineFill_Module.LineFill(...)` 互換実装。
/// 対応元: FUN_10001000 + FUN_1000a180/a1f0/a2e0/a370/a400
pub fn line_fill(
    image_buffer: &[u8],
    width: usize,
    height: usize,
    spacing: i32,
    radians: f64,
    alpha_threshold: i32,
    random_x: f64,
    random_y: f64,
    seed: i32,
) -> (usize, usize, usize, Vec<f64>) {
    if width == 0 || height == 0 {
        return (0, 0, 0, Vec::new());
    }
    let pixel_count = width.saturating_mul(height);
    let required = pixel_count.saturating_mul(4);
    if image_buffer.len() < required {
        return (width, height, 0, Vec::new());
    }

    let threshold = alpha_threshold.clamp(0, 255) as u8;
    let mut mask = vec![0u8; pixel_count];
    for i in 0..pixel_count {
        let a = image_buffer[i * 4 + 3];
        mask[i] = u8::from(a > threshold);
    }

    let Some(first_idx) = mask.iter().position(|&v| v != 0) else {
        return (width, height, 0, Vec::new());
    };
    let Some(last_idx) = mask.iter().rposition(|&v| v != 0) else {
        return (width, height, 0, Vec::new());
    };
    let first_row = first_idx / width;
    let last_row = last_idx / width;

    let step_rows = spacing.max(1) as usize;
    let mut segments = (last_row.saturating_sub(first_row)) / step_rows;
    if segments < 2 {
        segments = 1;
    }
    let n = segments + 1;

    // [x0, y0, x1, y1, ...]。ここでは画像座標系(左上原点)。
    let mut pts = vec![0.0_f64; n * 2];
    for i in 0..=segments {
        let y = first_row + (last_row - first_row) * i / segments;
        let row = &mask[y * width..(y + 1) * width];
        let x = if i % 2 == 0 {
            row.iter().position(|&v| v != 0).map(|v| v as i32)
        } else {
            row.iter().rposition(|&v| v != 0).map(|v| v as i32)
        }
        .unwrap_or(-100);
        pts[i * 2] = x as f64;
        pts[i * 2 + 1] = y as f64;
    }

    // 欠損補間（偶数系列・奇数系列を独立補間）
    let mut even_last = pts[0];
    if segments > 1 {
        let second_even = pts[4];
        if second_even < 0.0 {
            pts[4] = even_last;
        }
        even_last = pts[4];
    }
    for i in (4..pts.len()).step_by(4) {
        if pts[i] >= 0.0 {
            even_last = pts[i];
        } else {
            pts[i] = even_last;
        }
    }
    let mut odd_last = pts[0];
    for i in (2..pts.len()).step_by(4) {
        if pts[i] >= 0.0 {
            odd_last = pts[i];
        } else {
            pts[i] = odd_last;
        }
    }

    if random_x > 0.0 || random_y > 0.0 {
        let s = seed as i64;
        let rng_seed = s.wrapping_mul(s).wrapping_mul(s).wrapping_mul(0x9fbf1) as u64;
        let mut rng = StdRng::seed_from_u64(rng_seed);
        for i in 0..n {
            let rx = ((rng.random_range(0..10_000) as f64) * 0.0001 - 0.5) * random_x * 2.0;
            let ry = ((rng.random_range(0..10_000) as f64) * 0.0001 - 0.5) * random_y * 2.0;
            pts[i * 2] += rx;
            pts[i * 2 + 1] += ry;
        }
    }

    // 中心原点 + 回転
    let cos_r = radians.cos();
    let sin_r = radians.sin();
    let half_w = width as f64 * 0.5;
    let half_h = height as f64 * 0.5;
    let mut max_abs_x = 0.0_f64;
    let mut max_abs_y = 0.0_f64;
    for i in 0..n {
        let dx = pts[i * 2] - half_w;
        let dy = pts[i * 2 + 1] - half_h;
        let x = cos_r * dx + sin_r * dy;
        let y = cos_r * dy - sin_r * dx;
        pts[i * 2] = x;
        pts[i * 2 + 1] = y;
        max_abs_x = max_abs_x.max(x.abs());
        max_abs_y = max_abs_y.max(y.abs());
    }

    let ws = (max_abs_x.ceil() as usize).saturating_mul(2);
    let hs = (max_abs_y.ceil() as usize).saturating_mul(2);
    (ws, hs, n, pts)
}
