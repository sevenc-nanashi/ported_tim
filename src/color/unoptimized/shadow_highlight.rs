use anyhow::{Result, anyhow, bail};

#[derive(Debug, Default, Clone)]
pub struct ShadowHighlightState {
    saved_bgra: Option<Vec<u8>>,
    saved_width: usize,
    saved_height: usize,
}

impl ShadowHighlightState {
    pub fn new() -> Self {
        Self::default()
    }

    /// C の Save_G_Image 相当
    pub fn save_g_image(&mut self, src_bgra: &[u8], width: usize, height: usize) -> Result<()> {
        let expected_len = pixel_buffer_len(width, height)?;
        if src_bgra.len() != expected_len {
            bail!(
                "save_g_image: buffer size mismatch: got {}, expected {}",
                src_bgra.len(),
                expected_len
            );
        }

        if self.saved_bgra.is_some() {
            bail!("save_g_image: image is already saved");
        }

        self.saved_bgra = Some(src_bgra.to_vec());
        self.saved_width = width;
        self.saved_height = height;
        Ok(())
    }

    /// C の shadow_highlight_impl + sub_10015370 相当
    ///
    /// `bgra` は Lua 側の `obj.effect("ぼかし", ...)` 後の画像で、
    /// 処理後の結果でそのまま上書きされる。
    pub fn shadow_highlight_in_place(
        &mut self,
        bgra: &mut [u8],
        width: usize,
        height: usize,
        black_crush_adjust: f64,
        white_clip_adjust: f64,
    ) -> Result<()> {
        let expected_len = pixel_buffer_len(width, height)?;
        if bgra.len() != expected_len {
            bail!(
                "shadow_highlight_in_place: buffer size mismatch: got {}, expected {}",
                bgra.len(),
                expected_len
            );
        }

        let saved = self.saved_bgra.as_ref().ok_or_else(|| {
            anyhow!("shadow_highlight_in_place: no saved image; call save_g_image first")
        })?;

        if self.saved_width != width || self.saved_height != height {
            bail!(
                "shadow_highlight_in_place: saved image size mismatch: saved={}x{}, current={}x{}",
                self.saved_width,
                self.saved_height,
                width,
                height
            );
        }

        let table = build_shadow_highlight_table(black_crush_adjust, white_clip_adjust);
        apply_shadow_highlight_in_place(saved, bgra, &table)?;

        // C と同様、処理後に保存画像を解放
        self.saved_bgra = None;
        self.saved_width = 0;
        self.saved_height = 0;

        Ok(())
    }
}

fn pixel_buffer_len(width: usize, height: usize) -> Result<usize> {
    width
        .checked_mul(height)
        .and_then(|px| px.checked_mul(4))
        .ok_or_else(|| anyhow!("image size overflow: width={}, height={}", width, height))
}

/// テーブルは [orig_channel][luma] -> new_channel
fn build_shadow_highlight_table(black_crush_adjust: f64, white_clip_adjust: f64) -> Vec<u8> {
    let mut table = vec![0u8; 256 * 256];
    let delta = white_clip_adjust - black_crush_adjust;

    for orig in 0u16..=255 {
        let orig_u8 = orig as u8;
        let orig_norm = f64::from(orig_u8) / 255.0;

        for luma_idx in 0u16..=255 {
            let luma_u8 = luma_idx as u8;
            let v7 = f64::from(luma_u8) / 256.0 * delta + black_crush_adjust;

            let out = if v7 < 0.0 {
                let p = (1.0 - orig_norm).powf(1.0 - v7) * 255.0;
                let n = 255_i32 - (p as i32);
                clamp_u8_i32(n)
            } else {
                let p = orig_norm.powf(1.0 + v7) * 255.0;
                clamp_u8_i32(p as i32)
            };

            let idx = (usize::from(orig_u8) << 8) | usize::from(luma_u8);
            table[idx] = out;
        }
    }

    table
}

/// `saved_bgra` を参照し、`bgra` をその場で更新する
fn apply_shadow_highlight_in_place(saved_bgra: &[u8], bgra: &mut [u8], table: &[u8]) -> Result<()> {
    if saved_bgra.len() != bgra.len() {
        bail!(
            "apply_shadow_highlight_in_place: buffer size mismatch: saved={}, current={}",
            saved_bgra.len(),
            bgra.len()
        );
    }
    if table.len() != 256 * 256 {
        bail!(
            "apply_shadow_highlight_in_place: invalid table length {}",
            table.len()
        );
    }
    if !saved_bgra.len().is_multiple_of(4) {
        bail!("apply_shadow_highlight_in_place: buffer length is not multiple of 4");
    }

    for (saved_px, cur_px) in saved_bgra.chunks_exact(4).zip(bgra.chunks_exact_mut(4)) {
        // まず現在のぼかし済み画素から輝度を計算
        let blurred_b = cur_px[0];
        let blurred_g = cur_px[1];
        let blurred_r = cur_px[2];

        let luma_f = f64::from(blurred_r) * 0.298_912
            + f64::from(blurred_g) * 0.586_61
            + f64::from(blurred_b) * 0.114_478;

        let luma = clamp_u8_i32(luma_f as i32);

        // 出力値は保存しておいた元画像の各チャンネル値を使って求める
        let saved_b = saved_px[0];
        let saved_g = saved_px[1];
        let saved_r = saved_px[2];
        let saved_a = saved_px[3];

        cur_px[0] = table_lookup(table, luma, saved_b);
        cur_px[1] = table_lookup(table, luma, saved_g);
        cur_px[2] = table_lookup(table, luma, saved_r);
        cur_px[3] = table_lookup(table, luma, saved_a);
    }

    Ok(())
}

#[inline]
fn table_lookup(table: &[u8], luma: u8, orig: u8) -> u8 {
    let idx = (usize::from(orig) << 8) | usize::from(luma);
    table[idx]
}

#[inline]
fn clamp_u8_i32(v: i32) -> u8 {
    if v <= 0 {
        0
    } else if v >= 255 {
        255
    } else {
        v as u8
    }
}
