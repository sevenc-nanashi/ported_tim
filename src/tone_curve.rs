use anyhow::{Result, bail};

const TONE_CURVE_SIZE: usize = 256;

#[derive(Debug, Clone)]
pub struct ToneCurveState {
    /// C の dword_10029C80
    /// channel: 0=R, 1=G, 2=B
    pub r_curve: [u8; TONE_CURVE_SIZE],
    /// C の dword_1002A080
    pub g_curve: [u8; TONE_CURVE_SIZE],
    /// C の dword_1002A480
    pub b_curve: [u8; TONE_CURVE_SIZE],
}

impl Default for ToneCurveState {
    fn default() -> Self {
        let mut ident = [0u8; TONE_CURVE_SIZE];
        for (i, v) in ident.iter_mut().enumerate() {
            *v = i as u8;
        }
        Self {
            r_curve: ident,
            g_curve: ident,
            b_curve: ident,
        }
    }
}

impl ToneCurveState {
    #[inline]
    fn curve_mut(&mut self, channel: usize) -> &mut [u8; TONE_CURVE_SIZE] {
        match channel {
            0 => &mut self.r_curve,
            1 => &mut self.g_curve,
            2 => &mut self.b_curve,
            _ => unreachable!("channel must be 0, 1, or 2"),
        }
    }

    #[inline]
    fn clamp_u8_from_f64(v: f64) -> u8 {
        if v <= 0.0 {
            0
        } else if v >= 255.0 {
            255
        } else {
            v as u8
        }
    }

    #[inline]
    fn clamp_i32(value: i32, lo: i32, hi: i32) -> i32 {
        value.clamp(lo, hi)
    }

    /// Port of `set_tone_curve_impl`.
    ///
    /// Lua order:
    /// 1: channel
    /// 2: mode
    /// 3: unused in the C body
    /// 4..9: coefficients
    pub fn set_tone_curve_impl(
        &mut self,
        channel: usize,
        mode: i32,
        _unused_arg3: f64,
        arg4: f64,
        arg5: f64,
        arg6: f64,
        arg7: f64,
        arg8: f64,
        arg9: f64,
    ) -> Result<()> {
        if channel > 2 {
            bail!("channel out of range: {}", channel);
        }

        match mode {
            0 => {
                // set_tone_curve_mode_0(&v5, &v4, &v3, &<arg3>)
                // C 側の対応:
                // a1 = arg6, a2 = arg5, a3 = arg4, a4 = arg3(未使用引数)
                self.set_tone_curve_mode_0(channel, arg6, arg5, arg4, _unused_arg3);
            }
            1 => {
                // set_tone_curve_mode_1(&v6, &v5, &v4, &<arg3>, &v7, channel)
                // 実質使用されるのは a1, a2, a3, a4, a5 の順。
                // C では:
                //   threshold = *a1 = arg7
                //   hi_mul    = *a3 = arg5
                //   hi_bias   = *a2 = arg6
                //   lo_mul    = *a5 = arg4
                //   lo_bias   = *a4 = arg3
                self.set_tone_curve_mode_1(channel, arg7, arg6, arg5, _unused_arg3, arg4);
            }
            _ => {
                // C は mode!=0 && mode!=1 のとき mode_2 に落ちる。
                self.set_tone_curve_mode_2(
                    channel,
                    arg9,
                    arg8,
                    arg7,
                    arg6,
                    arg5,
                    arg4,
                    _unused_arg3,
                );
            }
        }

        Ok(())
    }

    /// Port of `set_tone_curve_mode_0`.
    ///
    /// dst[i] = clamp(round(i * ((i/255)*(a4*(i/255)+a3)+a2) + a1*255))
    fn set_tone_curve_mode_0(&mut self, channel: usize, a1: f64, a2: f64, a3: f64, a4: f64) {
        let dst = self.curve_mut(channel);
        let v7 = a1 * 255.0;

        for i in 0..256usize {
            let x = i as f64;
            let xn = x / 255.0;
            let y = x * (xn * (a4 * xn + a3) + a2) + 0.5 + v7;
            dst[i] = Self::clamp_u8_from_f64(y);
        }
    }

    /// Port of `set_tone_curve_mode_1`.
    ///
    /// if i/255 >= threshold:
    ///     y = i * hi_mul + hi_bias*255
    /// else
    ///     y = i * lo_mul + lo_bias*255
    fn set_tone_curve_mode_1(
        &mut self,
        channel: usize,
        threshold: f64,
        hi_bias: f64,
        hi_mul: f64,
        lo_bias: f64,
        lo_mul: f64,
    ) {
        let dst = self.curve_mut(channel);

        for i in 0..256usize {
            let x = i as f64;
            let xn = x / 255.0;
            let y = if xn >= threshold {
                x * hi_mul + hi_bias * 255.0 + 0.5
            } else {
                x * lo_mul + lo_bias * 255.0 + 0.5
            };
            dst[i] = Self::clamp_u8_from_f64(y);
        }
    }

    /// Port of `set_tone_curve_mode_2`.
    ///
    /// if i/255 >= threshold:
    ///     y = i * ((i/255)*qa + qb) + qc*255
    /// else
    ///     y = i * ((i/255)*pa + pb) + pc*255
    fn set_tone_curve_mode_2(
        &mut self,
        channel: usize,
        threshold: f64,
        qa: f64,
        qb: f64,
        qc: f64,
        pa: f64,
        pb: f64,
        pc: f64,
    ) {
        let dst = self.curve_mut(channel);

        for i in 0..256usize {
            let x = i as f64;
            let xn = x / 255.0;

            let (a, b, c) = if xn >= threshold {
                (qa, qb, qc)
            } else {
                (pa, pb, pc)
            };

            let y = x * (xn * a + b) + 0.5 + c * 255.0;
            dst[i] = Self::clamp_u8_from_f64(y);
        }
    }

    /// Port of `sim_tone_curve_impl`.
    ///
    /// Lua order:
    /// 1: userdata (here: img)
    /// 2: width
    /// 3: height
    /// 4: unify_red_curve_to_all(bool)
    pub fn sim_tone_curve_impl(
        &mut self,
        img: &mut [u8],
        unify_red_curve_to_all: bool,
    ) -> Result<()> {
        if unify_red_curve_to_all {
            for i in 0..256usize {
                let v = self.r_curve[i];
                self.g_curve[i] = v;
                self.b_curve[i] = v;
            }
        }

        for px in img.chunks_exact_mut(4) {
            let b = px[0] as usize;
            let g = px[1] as usize;
            let r = px[2] as usize;
            let a = px[3];

            px[0] = self.b_curve[b];
            px[1] = self.g_curve[g];
            px[2] = self.r_curve[r];
            px[3] = a;
        }

        Ok(())
    }

    /// Port of `draw_tone_curve_impl`.
    ///
    /// Lua order:
    /// 1: userdata (here: img)
    /// 2: width used for drawing, capped at 256
    /// 3: ignored by C
    /// 4: channel
    /// 5: color (0xRRGGBB, no alpha)
    pub fn draw_tone_curve_impl(
        &self,
        img: &mut [u8],
        draw_width: usize,
        height: usize,
        channel: usize,
        color_rgb: u32,
    ) -> Result<()> {
        if channel > 2 {
            bail!("channel out of range: {}", channel);
        }

        let width = draw_width.min(256).min(draw_width);
        if width == 0 {
            return Ok(());
        }

        let fg = 0xFF00_0000u32 | (color_rgb & 0x00FF_FFFF);
        let bg = 0xFF00_0000u32;

        self.draw_tone_curve_column_fill(img, width, height, channel, fg, bg)
    }

    fn draw_tone_curve_column_fill(
        &self,
        img: &mut [u8],
        width: usize,
        height: usize,
        channel: usize,
        fg_argb: u32,
        bg_argb: u32,
    ) -> Result<()> {
        let curve = match channel {
            0 => &self.r_curve,
            1 => &self.g_curve,
            2 => &self.b_curve,
            _ => unreachable!("channel must be 0, 1, or 2"),
        };

        let height_i32 = i32::try_from(height).map_err(|_| anyhow::anyhow!("height too large"))?;
        if height_i32 <= 0 {
            return Ok(());
        }

        for x in 0..width {
            let sample = curve[x] as f64;
            let y_f = sample * (height as f64) / 255.0;
            let y_i = (y_f as i32).clamp(0, height_i32);

            for step in 0..=y_i {
                let yy = height_i32 - 1 - step;
                if yy < 0 {
                    break;
                }
                // let idx = img.pixel_index(x, yy as usize);
                let idx = (yy as usize) * width * 4 + x * 4;
                write_bgra_u32(&mut img[idx..idx + 4], fg_argb);
            }

            if y_i + 1 < height_i32 {
                let start = y_i + 1;
                let remain = height_i32 - start;
                for off in 0..remain {
                    let yy = height_i32 - 1 - (start + off);
                    if yy < 0 {
                        break;
                    }
                    // let idx = img.pixel_index(x, yy as usize);
                    // write_bgra_u32(&mut img.data[idx..idx + 4], bg_argb);
                    let idx = (yy as usize) * width * 4 + x * 4;
                    write_bgra_u32(&mut img[idx..idx + 4], bg_argb);
                }
            }
        }

        Ok(())
    }

    /// Port of `image_tone_curve_impl`.
    ///
    /// Lua order:
    /// 1: userdata (here: img)
    /// 2: width  (ignored; img.width を使う)
    /// 3: height (ignored; img.height を使う)
    /// 4: center_x
    /// 5: center_y
    /// 6: degree
    /// 7: line_width
    /// 8: ignored by the C body
    /// 9: hide_line (0/1)
    ///
    /// 動作:
    /// - 画像内の線分上 256 点をサンプリングして B/G/R カーブへ取り込む
    /// - hide_line == false のとき、線を color_rgb で描画する
    ///
    /// 注意:
    /// 元 C の `lua_tonumber(a1, 8)` は値を読むだけで未使用。
    pub fn image_tone_curve_impl(
        &mut self,
        img: &mut [u8],
        width: usize,
        height: usize,
        center_x: f64,
        center_y: f64,
        degree: f64,
        line_width: f64,
        _unused_arg8: f64,
        hide_line: bool,
        color_rgb: u32,
    ) -> Result<()> {
        let theta = degree.rem_euclid(360.0).to_radians();
        let half_width = (line_width * 0.5).max(1.0);

        let dx = theta.cos() * half_width;
        let dy = theta.sin() * half_width;

        let x0 = center_x - dx;
        let y0 = center_y - dy;
        let x1 = center_x + dx;
        let y1 = center_y + dy;

        if dy.abs() >= dx.abs() {
            let slope = if dy == 0.0 { 0.0 } else { dx / dy };
            self.sample_line_y_major(img, width, height, slope, x1, y1, x0, y0)?;
            if !hide_line {
                let span = ((y1 + 0.5).floor() as i32 - (y0 + 0.5).floor() as i32).abs();
                self.draw_line_y_major(
                    img,
                    width,
                    height,
                    slope,
                    span as usize,
                    x1,
                    y1,
                    color_rgb,
                )?;
            }
        } else {
            let slope = if dx == 0.0 { 0.0 } else { dy / dx };
            self.sample_line_x_major(img, width, height, slope, x1, y1, x0, y0)?;
            if !hide_line {
                let span = ((x1 + 0.5).floor() as i32 - (x0 + 0.5).floor() as i32).abs();
                self.draw_line_x_major(
                    img,
                    width,
                    height,
                    slope,
                    span as usize,
                    x1,
                    y1,
                    color_rgb,
                )?;
            }
        }

        Ok(())
    }

    fn sample_line_y_major(
        &mut self,
        img: &mut [u8],
        width: usize,
        height: usize,
        slope: f64,
        _x_hi: f64,
        y_hi: f64,
        x_lo: f64,
        y_lo: f64,
    ) -> Result<()> {
        let h_i32 = i32::try_from(height).map_err(|_| anyhow::anyhow!("height too large"))?;
        let w_i32 = i32::try_from(width).map_err(|_| anyhow::anyhow!("width too large"))?;

        for i in 0..256usize {
            let inv = 255usize - i;
            let y = (inv as f64 * y_lo + i as f64 * y_hi) / 255.0;
            let py = ((height as f64) * 0.5 + y) as i32;
            let px = ((y - y_lo) * slope + x_lo + (width as f64) * 0.5 + 0.5) as i32;

            let px = Self::clamp_i32(px, 0, w_i32 - 1) as usize;
            let py = Self::clamp_i32(py, 0, h_i32 - 1) as usize;

            // let idx = img.pixel_index(px, py);
            // let b = img.data[idx];
            // let g = img.data[idx + 1];
            // let r = img.data[idx + 2];
            let idx = py * width * 4 + px * 4;
            let b = img[idx];
            let g = img[idx + 1];
            let r = img[idx + 2];

            self.r_curve[i] = r;
            self.g_curve[i] = g;
            self.b_curve[i] = b;
        }

        Ok(())
    }

    fn sample_line_x_major(
        &mut self,
        img: &mut [u8],
        width: usize,
        height: usize,
        slope: f64,
        x_hi: f64,
        _y_hi: f64,
        x_lo: f64,
        y_lo: f64,
    ) -> Result<()> {
        let h_i32 = i32::try_from(height).map_err(|_| anyhow::anyhow!("height too large"))?;
        let w_i32 = i32::try_from(width).map_err(|_| anyhow::anyhow!("width too large"))?;

        for i in 0..256usize {
            let inv = 255usize - i;
            let x = (i as f64 * x_hi + inv as f64 * x_lo) / 255.0;
            let px = ((width as f64) * 0.5 + x) as i32;
            let py = ((x - x_lo) * slope + y_lo + (height as f64) * 0.5 + 0.5) as i32;

            let px = Self::clamp_i32(px, 0, w_i32 - 1) as usize;
            let py = Self::clamp_i32(py, 0, h_i32 - 1) as usize;

            // let idx = img.pixel_index(px, py);
            // let b = img.data[idx];
            // let g = img.data[idx + 1];
            // let r = img.data[idx + 2];
            let idx = py * width * 4 + px * 4;
            let b = img[idx];
            let g = img[idx + 1];
            let r = img[idx + 2];

            self.r_curve[i] = r;
            self.g_curve[i] = g;
            self.b_curve[i] = b;
        }

        Ok(())
    }

    fn draw_line_y_major(
        &self,
        img: &mut [u8],
        width: usize,
        height: usize,
        slope: f64,
        span: usize,
        x_hi: f64,
        y_hi: f64,
        color_rgb: u32,
    ) -> Result<()> {
        if span == 0 {
            return Ok(());
        }

        let h_i32 = i32::try_from(height).map_err(|_| anyhow::anyhow!("height too large"))?;
        let w_i32 = i32::try_from(width).map_err(|_| anyhow::anyhow!("width too large"))?;
        let color = 0xFF00_0000u32 | (color_rgb & 0x00FF_FFFF);

        for i in 0..=span {
            let inv = span - i;
            let y = (inv as f64 * y_hi + i as f64 * (y_hi - (span as f64))) / (span as f64);
            let py = ((height as f64) * 0.5 + y) as i32;
            let px = ((y - y_hi) * slope + x_hi + (width as f64) * 0.5 + 0.5) as i32;

            let px = Self::clamp_i32(px, 0, w_i32 - 1) as usize;
            let py = Self::clamp_i32(py, 0, h_i32 - 1) as usize;

            // let idx = img.pixel_index(px, py);
            // let alpha = img.data[idx + 3];
            // write_bgra_keep_alpha(&mut img.data[idx..idx + 4], color, alpha);
            let idx = py * width * 4 + px * 4;
            let alpha = img[idx + 3];
            write_bgra_keep_alpha(&mut img[idx..idx + 4], color, alpha);
        }

        Ok(())
    }

    fn draw_line_x_major(
        &self,
        img: &mut [u8],
        width: usize,
        height: usize,
        slope: f64,
        span: usize,
        x_hi: f64,
        y_hi: f64,
        color_rgb: u32,
    ) -> Result<()> {
        if span == 0 {
            return Ok(());
        }

        let h_i32 = i32::try_from(height).map_err(|_| anyhow::anyhow!("height too large"))?;
        let w_i32 = i32::try_from(width).map_err(|_| anyhow::anyhow!("width too large"))?;
        let color = 0xFF00_0000u32 | (color_rgb & 0x00FF_FFFF);

        for i in 0..=span {
            let inv = span - i;
            let x = (i as f64 * x_hi + inv as f64 * (x_hi - (span as f64))) / (span as f64);
            let px = ((width as f64) * 0.5 + x) as i32;
            let py = ((x - x_hi) * slope + y_hi + (height as f64) * 0.5 + 0.5) as i32;

            let px = Self::clamp_i32(px, 0, w_i32 - 1) as usize;
            let py = Self::clamp_i32(py, 0, h_i32 - 1) as usize;

            // let idx = img.pixel_index(px, py);
            // let alpha = img.data[idx + 3];
            // write_bgra_keep_alpha(&mut img.data[idx..idx + 4], color, alpha);
            let idx = py * width * 4 + px * 4;
            let alpha = img[idx + 3];
            write_bgra_keep_alpha(&mut img[idx..idx + 4], color, alpha);
        }

        Ok(())
    }
}

#[inline]
fn write_bgra_u32(dst: &mut [u8], argb: u32) {
    debug_assert!(dst.len() >= 4);
    let a = ((argb >> 24) & 0xFF) as u8;
    let r = ((argb >> 16) & 0xFF) as u8;
    let g = ((argb >> 8) & 0xFF) as u8;
    let b = (argb & 0xFF) as u8;

    dst[0] = b;
    dst[1] = g;
    dst[2] = r;
    dst[3] = a;
}

#[inline]
fn write_bgra_keep_alpha(dst: &mut [u8], argb_no_alpha_replace: u32, alpha: u8) {
    debug_assert!(dst.len() >= 4);
    let r = ((argb_no_alpha_replace >> 16) & 0xFF) as u8;
    let g = ((argb_no_alpha_replace >> 8) & 0xFF) as u8;
    let b = (argb_no_alpha_replace & 0xFF) as u8;

    dst[0] = b;
    dst[1] = g;
    dst[2] = r;
    dst[3] = alpha;
}
