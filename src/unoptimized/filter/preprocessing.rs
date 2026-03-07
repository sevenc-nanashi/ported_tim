fn clamp_i32_to_u8(v: i32) -> u8 {
    v.clamp(0, 255) as u8
}

#[inline]
fn cvt_f64_to_i32_like_dll(v: f64) -> i32 {
    // FUN_10008a90 相当: 実質は int キャスト互換（0方向切り捨て）。
    v as i32
}

pub fn preprocessing(
    image_buffer: &mut [u8],
    width: usize,
    height: usize,
    charcoal_apply: f64,
    chalk_apply: f64,
    pen_pressure: f64,
    threshold: i32,
    auto_threshold: bool,
) {
    let pixel_count = width.saturating_mul(height);
    let required = pixel_count.saturating_mul(4);
    if image_buffer.len() < required || pixel_count == 0 {
        return;
    }

    // DLL同様に単チャンネル値（B）を作業対象にする。
    let mut src_gray = vec![0u8; pixel_count];
    for i in 0..pixel_count {
        src_gray[i] = image_buffer[i * 4];
    }

    let mut th = threshold.clamp(0, 255);
    if auto_threshold {
        let sum: u64 = src_gray.iter().map(|&v| v as u64).sum();
        th = (sum / pixel_count as u64) as i32;
    }

    // LUT #1
    let mut lut_threshold = [0u8; 256];
    if th > 0 {
        for i in 0..th {
            lut_threshold[i as usize] =
                clamp_i32_to_u8(cvt_f64_to_i32_like_dll((i as f64) * 128.0 / (th as f64)));
        }
    }
    if th < 256 {
        let denom = (255 - th).max(1) as f64;
        for i in th..=255 {
            let v = 128.0 + ((i - th) as f64) * 127.5 / denom;
            lut_threshold[i as usize] = clamp_i32_to_u8(cvt_f64_to_i32_like_dll(v));
        }
    }

    // LUT #2/#3
    let pressure = pen_pressure + 0.5;
    let charcoal_gain = charcoal_apply + 1.0;
    let chalk_gain = chalk_apply + 1.0;

    let mut lut_charcoal = [0u8; 256];
    let mut lut_chalk = [0u8; 256];
    for i in 0..=255usize {
        let x = i as f64 / 255.0;

        // DLL側は pow 結果を一度 float に落としてから後続演算している。
        let base_charcoal = (x.powf(pressure) as f32) as f64;
        let v_charcoal = cvt_f64_to_i32_like_dll(
            ((base_charcoal * 255.0 - 127.5) * charcoal_gain + 127.5).clamp(0.0, 255.0),
        );
        lut_charcoal[i] = clamp_i32_to_u8(v_charcoal);

        // C側(0x100085d0)は base=(1 - (1-x)^pressure) を使う。
        let base_chalk = 1.0 - (((1.0 - x).powf(pressure) as f32) as f64);
        let v_chalk = cvt_f64_to_i32_like_dll(
            ((base_chalk * 255.0 - 127.5) * chalk_gain + 127.5).clamp(0.0, 255.0),
        );
        lut_chalk[i] = clamp_i32_to_u8(v_chalk);
    }

    // threshold==0: tmp経由, それ以外: src経由
    let use_original_for_index = threshold != 0;
    for i in 0..pixel_count {
        let p = i * 4;
        let a = image_buffer[p + 3];
        let idx0 = if use_original_for_index {
            src_gray[i] as usize
        } else {
            image_buffer[p] as usize
        };
        let idx1 = lut_threshold[idx0] as usize;
        let idx2 = lut_charcoal[idx1] as usize;
        let out = lut_chalk[idx2];

        image_buffer[p] = out;
        image_buffer[p + 1] = out;
        image_buffer[p + 2] = out;
        image_buffer[p + 3] = a;
    }
}
