#![allow(clippy::too_many_arguments)]
use aviutl2::{anyhow, module::ScriptModuleFunctions};
use std::ptr::NonNull;

mod bias_deletion;
mod binarization;
mod binarization_rgb;
mod color_reduction;
mod enh_grayscale;
mod equalize;
mod extended_contrast;
mod gamma_correction;
mod grainy;
mod grayscale;
mod metal;
mod pastel;
mod reduction;
mod tone_curve;
mod tritone_v3;

#[aviutl2::plugin(ScriptModule)]
struct PortedTimMod2 {}

impl aviutl2::module::ScriptModule for PortedTimMod2 {
    fn new(_info: aviutl2::AviUtl2Info) -> aviutl2::AnyResult<Self> {
        Ok(Self {})
    }

    fn plugin_info(&self) -> aviutl2::module::ScriptModuleTable {
        aviutl2::module::ScriptModuleTable {
            information: "ported_tim.mod2".into(),
            functions: Self::functions(),
        }
    }
}

static TONE_CURVE_STATE: std::sync::LazyLock<std::sync::Mutex<tone_curve::ToneCurveState>> =
    std::sync::LazyLock::new(|| std::sync::Mutex::new(tone_curve::ToneCurveState::default()));

#[aviutl2::module::functions]
#[allow(clippy::too_many_arguments)]
impl PortedTimMod2 {
    fn metal(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        flip_upper: u8,
        flip_lower: u8,
        gray_mode: u8,
    ) -> anyhow::Result<()> {
        let gray_mode = match gray_mode {
            0 => metal::GrayMode::Average,
            1 => metal::GrayMode::Lightness,
            2 => metal::GrayMode::Luminance,
            _ => {
                anyhow::bail!("Invalid gray mode: {}", gray_mode);
            }
        };
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        metal::metal(image_buffer, flip_upper, flip_lower, gray_mode);
        Ok(())
    }

    fn pastel(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        saturation_pct: f64,
        brightness_pct: f64,
        threshold_pct: f64,
        shw: f64,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        pastel::pastel_bgra(
            image_buffer,
            width,
            height,
            saturation_pct,
            brightness_pct,
            threshold_pct,
            shw,
        );
        Ok(())
    }

    fn grayscale(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        gray_mode: u8,
        bright_color: u32,
        dark_color: u32,
        gamma_scale: f64,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        grayscale::grayscale(
            image_buffer,
            width,
            height,
            gray_mode as i32,
            bright_color,
            dark_color,
            gamma_scale,
        );
        Ok(())
    }

    fn enh_grayscale(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        red: f64,
        green: f64,
        blue: f64,
        cyan: f64,
        magenta: f64,
        yellow: f64,
        white: f64,
        gamma_exp: f64,
        col: Option<u32>,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        enh_grayscale::enh_grayscale(
            image_buffer,
            width,
            height,
            red,
            green,
            blue,
            cyan,
            magenta,
            yellow,
            white,
            gamma_exp,
            col,
        )
        .map_err(|e| anyhow::anyhow!(e))?;
        Ok(())
    }

    fn binarization(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        threshold: u8,
        gray_mode: u8,
        auto_detect_method: u8,
        colorize: bool,
        color1: u32,
        color2: u32,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        binarization::binarization(
            image_buffer,
            width,
            height,
            threshold,
            gray_mode,
            auto_detect_method,
            colorize,
            color1,
            color2,
        )?;

        Ok(())
    }

    fn binarization_rgb(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        r_threshold: u8,
        g_threshold: u8,
        b_threshold: u8,
        auto_detect_method: u8,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        binarization_rgb::binarization_rgb(
            image_buffer,
            width,
            height,
            r_threshold,
            g_threshold,
            b_threshold,
            auto_detect_method,
        );

        Ok(())
    }
    fn bias_deletion(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        range: i32,
        adjust_amount: f64,
        offset: f64,
        threshold: f64,
        variance_correction: bool,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        bias_deletion::bias_deletion(
            image_buffer,
            width,
            height,
            range,
            adjust_amount,
            offset,
            threshold,
            variance_correction,
        )
        .map_err(|e| anyhow::anyhow!(e))?;
        Ok(())
    }

    fn grainy(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        amount: f64,
        contrast: f64,
        processing_method: u8,
        seed: i32,
        color1: u32,
        color2: u32,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        grainy::grainy(
            image_buffer,
            width,
            height,
            amount,
            contrast,
            processing_method as i32,
            seed,
            color1,
            color2,
        )?;
        Ok(())
    }

    fn gamma_correction(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        exp_r: f64,
        exp_g: f64,
        exp_b: f64,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        gamma_correction::gamma_correction(image_buffer, width, height, exp_r, exp_g, exp_b)
            .map_err(|e| anyhow::anyhow!(e))?;
        Ok(())
    }

    fn color_reduction(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        shift: u8,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        color_reduction::color_reduction(image_buffer, shift)?;
        Ok(())
    }

    fn tritone_v3(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        color1: u32,
        color2: u32,
        color3: u32,
        p1: u8,
        p2: u8,
        p3: u8,
        mode: i32,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        tritone_v3::tritone_v3(
            image_buffer,
            width,
            height,
            color1,
            color2,
            color3,
            p1,
            p2,
            p3,
            mode,
        )?;
        Ok(())
    }

    fn set_tone_curve(
        channel: usize,
        mode: i32,
        unused_arg3: f64,
        arg4: f64,
        arg5: f64,
        arg6: f64,
        arg7: f64,
        arg8: f64,
        arg9: f64,
    ) -> anyhow::Result<()> {
        let mut state = TONE_CURVE_STATE
            .lock()
            .map_err(|_| anyhow::anyhow!("Failed to acquire tone curve state lock"))?;
        state.set_tone_curve_impl(
            channel,
            mode,
            unused_arg3,
            arg4,
            arg5,
            arg6,
            arg7,
            arg8,
            arg9,
        )
    }

    fn sim_tone_curve(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        copy_red_to_green_blue: bool,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        let mut state = TONE_CURVE_STATE
            .lock()
            .map_err(|_| anyhow::anyhow!("Failed to acquire tone curve state lock"))?;
        state.sim_tone_curve_impl(image_buffer, copy_red_to_green_blue)?;
        Ok(())
    }

    fn image_tone_curve(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        center_x: f64,
        center_y: f64,
        degree: f64,
        line_width: f64,
        unused_arg8: f64,
        hide_line: bool,
        color_rgb: u32,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        let mut state = TONE_CURVE_STATE
            .lock()
            .map_err(|_| anyhow::anyhow!("Failed to acquire tone curve state lock"))?;
        state.image_tone_curve_impl(
            image_buffer,
            width,
            height,
            center_x,
            center_y,
            degree,
            line_width,
            unused_arg8,
            hide_line,
            color_rgb,
        )?;
        Ok(())
    }

    fn draw_tone_curve(
        image_buffer: NonNull<u8>,
        image_width: usize,
        image_height: usize,
        channel_type: usize,
        curve_color_rgba: u32,
    ) -> anyhow::Result<()> {
        let buffer_size = image_width
            .checked_mul(image_height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        let state = TONE_CURVE_STATE
            .lock()
            .map_err(|_| anyhow::anyhow!("Failed to acquire tone curve state lock"))?;
        state.draw_tone_curve_impl(
            image_buffer,
            image_width,
            image_height,
            channel_type,
            curve_color_rgba,
        )?;
        Ok(())
    }

    fn mcut_reduction(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        mc_color_count: usize,
        cl_color_count: usize,
        cap: bool,
        specified_colors_rgb: Vec<i32>,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        let specified_colors_rgb = specified_colors_rgb
            .into_iter()
            .map(|c| c as u32)
            .collect::<Vec<u32>>();
        reduction::mcut_reduction(
            image_buffer,
            width,
            height,
            mc_color_count,
            cl_color_count,
            cap,
            &specified_colors_rgb,
        )?;
        Ok(())
    }

    fn sample_grid_colors(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        sample_count: usize,
        x_split: usize,
        y_split: usize,
    ) -> anyhow::Result<Vec<i32>> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };

        let colors = reduction::sample_grid_colors(
            image_buffer,
            width,
            height,
            sample_count,
            x_split,
            y_split,
        )?;

        Ok(colors.iter().map(|&c| c as i32).collect())
    }

    fn disp_reduction(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        colors: Vec<i32>,
    ) -> anyhow::Result<()> {
        let colors = colors.into_iter().map(|c| c as u32).collect::<Vec<u32>>();
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        reduction::disp_reduction(image_buffer, width, height, &colors)?;
        Ok(())
    }

    fn extended_contrast(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        center: f64,
        intensity: f64,
        brightness: f64,
        smooth: f64,
        show_curve: bool,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        extended_contrast::extended_contrast(
            image_buffer,
            width,
            height,
            center,
            intensity,
            brightness,
            smooth,
            show_curve,
        )?;
        Ok(())
    }

    fn equalize(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        calc_method: u8,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        equalize::equalize(image_buffer, width, height, calc_method)?;
        Ok(())
    }

    fn equalize_rgb(image_buffer: NonNull<u8>, width: usize, height: usize) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        equalize::equalize_rgb(image_buffer, width, height)?;
        Ok(())
    }
}

aviutl2::register_script_module!(PortedTimMod2);
