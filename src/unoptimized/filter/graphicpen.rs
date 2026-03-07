struct LcgRand {
    state: u32,
}

impl LcgRand {
    fn new(seed: u32) -> Self {
        Self { state: seed }
    }

    fn next_u32(&mut self) -> u32 {
        self.state = self.state.wrapping_mul(214013).wrapping_add(2531011);
        (self.state >> 16) & 0x7fff
    }

    fn next_f64(&mut self) -> f64 {
        (self.next_u32() % 10_000) as f64 / 10_000.0
    }
}

pub fn graphicpen(
    image_buffer: &mut [u8],
    width: usize,
    height: usize,
    length: i32,
    threshold: i32,
    white_line_amount: f64,
    black_line_amount: f64,
    direction: i32,
    seed: i32,
    auto_threshold: bool,
) {
    if width == 0 || height == 0 {
        return;
    }
    let pixel_count = width.saturating_mul(height);
    let required = pixel_count.saturating_mul(4);
    if image_buffer.len() < required {
        return;
    }

    let mut gray = vec![0u8; pixel_count];
    for i in 0..pixel_count {
        gray[i] = image_buffer[i * 4];
    }

    let mut th = threshold.clamp(0, 255) as f64;
    if auto_threshold {
        let sum: u64 = gray.iter().map(|&v| v as u64).sum();
        th = sum as f64 / pixel_count as f64;
    }
    let th_u8 = th.round().clamp(0.0, 255.0) as u8;

    let mut lut = [0.0f64; 256];
    let low_den = th + 1.0;
    for i in 0..(th_u8 as usize) {
        lut[i] = 1.0 - ((i + 1) as f64 / low_den);
    }
    let high_den = (255.0 - th) + 1.0;
    for i in th_u8 as usize..256 {
        lut[i] = (i as f64 - th) / high_den;
    }

    let (sign, dir_flag, mut len_eff) = match direction {
        0 => (1isize, 1isize, ((length as f64) * 0.7).round() as i32),
        1 => (1isize, 0isize, length),
        2 => (-1isize, 1isize, ((length as f64) * 0.7).round() as i32),
        _ => (0isize, 1isize, length),
    };
    len_eff = len_eff.max(0);
    let threshold_mode = th_u8;
    let step = sign * width as isize + dir_flag;
    let len = len_eff as usize;
    if width <= len * 2 || height <= len * 2 {
        for i in 0..pixel_count {
            let v = gray[i];
            let p = i * 4;
            image_buffer[p] = v;
            image_buffer[p + 1] = v;
            image_buffer[p + 2] = v;
        }
        return;
    }

    let white_adj = 1.0 - white_line_amount * 2.0;
    let black_adj = 1.0 - black_line_amount * 2.0;

    let mut rng = LcgRand::new((seed as i64 * seed as i64 * seed as i64 * 654_321) as u32);
    let mut random_table = vec![0.0f64; 100_000];
    for v in &mut random_table {
        *v = rng.next_f64();
    }

    let mut out = gray.clone();
    for y in len..(height - len) {
        for x in len..(width - len) {
            let idx = y * width + x;
            let px = out[idx];
            let r0 = random_table[idx % random_table.len()];
            let r1 = random_table[(idx + 50_000) % random_table.len()];

            if px <= threshold_mode {
                out[idx] = 0;
                if lut[px as usize] + white_adj < r0 {
                    let d = len as f64 * r1 + 1.0;
                    let start = (d * -0.5).round() as isize;
                    let end = (d * 0.5).round() as isize;
                    if end > start {
                        for t in start..end {
                            let n = idx as isize + t * step;
                            if (0..pixel_count as isize).contains(&n) {
                                out[n as usize] = 255;
                            }
                        }
                    }
                }
            } else {
                out[idx] = 255;
                if lut[px as usize] + black_adj < r0 {
                    let d = len as f64 * r1 + 1.0;
                    let start = (d * -0.5).round() as isize;
                    let end = (d * 0.5).round() as isize;
                    if end > start {
                        for t in start..end {
                            let n = idx as isize + t * step;
                            if (0..pixel_count as isize).contains(&n) {
                                out[n as usize] = 0;
                            }
                        }
                    }
                }
            }
        }
    }

    for i in 0..pixel_count {
        let v = out[i];
        let p = i * 4;
        image_buffer[p] = v;
        image_buffer[p + 1] = v;
        image_buffer[p + 2] = v;
    }
}
