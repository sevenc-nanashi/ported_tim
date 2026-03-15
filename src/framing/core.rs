struct QueueEntry {
    x: usize,
    y: usize,
    nearest_x: usize,
    nearest_y: usize,
    dist2: u64,
}

impl std::cmp::PartialEq for QueueEntry {
    fn eq(&self, other: &Self) -> bool {
        self.x == other.x && self.y == other.y
    }
}
impl std::cmp::PartialOrd for QueueEntry {
    fn partial_cmp(&self, other: &Self) -> Option<std::cmp::Ordering> {
        let res = other.dist2.cmp(&self.dist2);
        if res.is_eq() {
            let base_key = (self.x, self.y);
            let other_key = (other.x, other.y);
            let res = base_key.cmp(&other_key);
            if res.is_eq() {
                let self_nearest_key = (self.nearest_x, self.nearest_y);
                let other_nearest_key = (other.nearest_x, other.nearest_y);
                Some(self_nearest_key.cmp(&other_nearest_key))
            } else {
                Some(res)
            }
        } else {
            Some(res)
        }
    }
}
impl std::cmp::Eq for QueueEntry {}
impl std::cmp::Ord for QueueEntry {
    fn cmp(&self, other: &Self) -> std::cmp::Ordering {
        self.partial_cmp(other).unwrap()
    }
}

#[inline]
fn smoothstep(edge0: f64, edge1: f64, x: f64) -> f64 {
    let t = ((x - edge0) / (edge1 - edge0)).clamp(0.0, 1.0);
    t * t * (3.0 - 2.0 * t)
}

#[inline]
fn unlerp_clamped(edge0: f64, edge1: f64, x: f64) -> f64 {
    ((x - edge0) / (edge1 - edge0)).clamp(0.0, 1.0)
}

// NOTE:
// - R = グラデーション（0 = col2、255 = col1）
// - G = アルファ（0 = 透明、255 = 不透明）
// - B = 0
// - A = 255
//
// 範囲外はAが0になるが、範囲外は(0, 0, 0, 255)が(0, 0, 0, 0)になるだけなので、特に問題ないはず。
pub fn create_distance_map(
    original: &[u8],
    dest: &mut [u8],
    width: usize,
    height: usize,
    alpha_threshold: u8,
    blur: f64,
    distance: f64,
) -> anyhow::Result<()> {
    let mut queue = std::collections::binary_heap::BinaryHeap::new();
    let pixel_count = width
        .checked_mul(height)
        .ok_or_else(|| anyhow::anyhow!("Image size overflow"))?;
    let mut best_dist2 = vec![u64::MAX; pixel_count];
    for y in 0..height {
        for x in 0..width {
            let idx = (y * width + x) * 4;
            let alpha = original[idx + 3];
            if alpha > alpha_threshold {
                best_dist2[y * width + x] = 0;
                queue.push(QueueEntry {
                    x,
                    y,
                    nearest_x: x,
                    nearest_y: y,
                    dist2: 0,
                });
            }
        }
    }
    let max_distance_squared = (distance * distance).ceil() as u64;
    while let Some(QueueEntry {
        x,
        y,
        nearest_x,
        nearest_y,
        dist2,
    }) = queue.pop()
    {
        let pixel_idx = y * width + x;
        if dist2 != best_dist2[pixel_idx] {
            continue;
        }
        let idx = pixel_idx * 4;
        if dest[idx + 3] == 255 {
            continue;
        }
        let dist = (dist2 as f64).sqrt();
        let alpha = smoothstep(0.0, 1.0, unlerp_clamped(distance, distance - blur, dist));
        let color_level = 1.0 - dist / distance;
        dest[idx] = (color_level * 255.0).round() as u8;
        dest[idx + 1] = (alpha * 255.0).round() as u8;
        dest[idx + 3] = 255;

        for (nx, ny) in [
            (x.wrapping_sub(1), y),
            (x + 1, y),
            (x, y.wrapping_sub(1)),
            (x, y + 1),
        ] {
            if nx < width && ny < height {
                let next_pixel_idx = ny * width + nx;
                if dest[next_pixel_idx * 4 + 3] != 0 {
                    continue;
                }
                let next_dist2 = ((nearest_x as i64 - nx as i64).pow(2)
                    + (nearest_y as i64 - ny as i64).pow(2))
                    as u64;
                if next_dist2 > max_distance_squared || next_dist2 >= best_dist2[next_pixel_idx] {
                    continue;
                }
                best_dist2[next_pixel_idx] = next_dist2;
                queue.push(QueueEntry {
                    x: nx,
                    y: ny,
                    nearest_x,
                    nearest_y,
                    dist2: next_dist2,
                });
            }
        }
    }
    Ok(())
}
