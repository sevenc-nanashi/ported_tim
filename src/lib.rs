#![allow(clippy::too_many_arguments)]
use aviutl2::{anyhow, module::ScriptModuleFunctions};
use std::ptr::NonNull;

mod unoptimized;

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

static TONE_CURVE_STATE: std::sync::LazyLock<
    std::sync::Mutex<unoptimized::tone_curve::ToneCurveState>,
> = std::sync::LazyLock::new(|| {
    std::sync::Mutex::new(unoptimized::tone_curve::ToneCurveState::default())
});
static SHADOW_HIGHLIGHT_STATE: std::sync::LazyLock<
    std::sync::Mutex<unoptimized::shadow_highlight::ShadowHighlightState>,
> = std::sync::LazyLock::new(|| {
    std::sync::Mutex::new(unoptimized::shadow_highlight::ShadowHighlightState::new())
});
static MINIMAX_CACHE: std::sync::LazyLock<std::sync::Mutex<unoptimized::minimax::MinimaxCache>> =
    std::sync::LazyLock::new(|| {
        std::sync::Mutex::new(unoptimized::minimax::MinimaxCache::default())
    });

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
            0 => unoptimized::metal::GrayMode::Average,
            1 => unoptimized::metal::GrayMode::Lightness,
            2 => unoptimized::metal::GrayMode::Luminance,
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
        unoptimized::metal::metal(image_buffer, flip_upper, flip_lower, gray_mode);
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
        unoptimized::pastel::pastel_bgra(
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
        unoptimized::grayscale::grayscale(
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
        unoptimized::enh_grayscale::enh_grayscale(
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
        unoptimized::binarization::binarization(
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
        unoptimized::binarization_rgb::binarization_rgb(
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

    fn threshold(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        threshold_1: f64,
        threshold_2: f64,
        detect_method: i32,
        opacity: f64,
        replace_color: u32,
        invert_range: bool,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        unoptimized::threshold::threshold(
            image_buffer,
            width,
            height,
            threshold_1,
            threshold_2,
            detect_method,
            opacity,
            replace_color,
            invert_range,
        )?;
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
        unoptimized::bias_deletion::bias_deletion(
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
        unoptimized::grainy::grainy(
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
        unoptimized::gamma_correction::gamma_correction(
            image_buffer,
            width,
            height,
            exp_r,
            exp_g,
            exp_b,
        )
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
        unoptimized::color_reduction::color_reduction(image_buffer, shift)?;
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
        unoptimized::tritone_v3::tritone_v3(
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
        unoptimized::reduction::mcut_reduction(
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

        let colors = unoptimized::reduction::sample_grid_colors(
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
        unoptimized::reduction::disp_reduction(image_buffer, width, height, &colors)?;
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
        unoptimized::extended_contrast::extended_contrast(
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
        unoptimized::equalize::equalize(image_buffer, width, height, calc_method)?;
        Ok(())
    }

    fn equalize_rgb(image_buffer: NonNull<u8>, width: usize, height: usize) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        unoptimized::equalize::equalize_rgb(image_buffer, width, height)?;
        Ok(())
    }

    fn save_g_image(image_buffer: NonNull<u8>, width: usize, height: usize) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        let mut state = SHADOW_HIGHLIGHT_STATE
            .lock()
            .map_err(|_| anyhow::anyhow!("Failed to acquire shadow/highlight state lock"))?;
        state.save_g_image(image_buffer, width, height)?;
        Ok(())
    }

    fn shadow_highlight(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        black_crush_adjust: f64,
        white_clip_adjust: f64,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        let mut state = SHADOW_HIGHLIGHT_STATE
            .lock()
            .map_err(|_| anyhow::anyhow!("Failed to acquire shadow/highlight state lock"))?;
        state.shadow_highlight_in_place(
            image_buffer,
            width,
            height,
            black_crush_adjust,
            white_clip_adjust,
        )?;
        Ok(())
    }

    fn monochromatic(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        track_r: u8,
        track_g: u8,
        track_b: u8,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        unoptimized::monochromatic::monochromatic(
            image_buffer,
            width,
            height,
            track_r,
            track_g,
            track_b,
        )?;
        Ok(())
    }

    fn monochromatic2(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        u: f64,
        v: f64,
        gamma: f64,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        unoptimized::monochromatic2::monochromatic2(image_buffer, width, height, u, v, gamma)?;
        Ok(())
    }

    fn standard_color(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        col1: u32,
        col2: u32,
        change: f64,
        count: f64,
        scale: f64,
        use_distance_from_specified_color: bool,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        unoptimized::standard_color::standard_color(
            image_buffer,
            width,
            height,
            col1,
            col2,
            change,
            count,
            scale,
            use_distance_from_specified_color,
        )?;
        Ok(())
    }

    fn change_to_color(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        src_color: u32,
        dst_color: u32,
        hue_range: f64,
        saturation_range: f64,
        saturation_adjust: f64,
        luminance_adjust: f64,
        boundary_adjust: f64,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        unoptimized::change_to_color::change_to_color(
            image_buffer,
            width,
            height,
            src_color,
            dst_color,
            hue_range,
            saturation_range,
            saturation_adjust,
            luminance_adjust,
            boundary_adjust,
        )?;
        Ok(())
    }

    fn tetratone(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        col1: u32, // 0xRRGGBB: shadow
        col2: u32, // 0xRRGGBB: midtone 1
        col3: u32, // 0xRRGGBB: midtone 2
        col4: u32, // 0xRRGGBB: highlight
        n1: u8,
        midpoint1: u8,
        midpoint2: u8,
        n2: u8,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        unoptimized::tetratone::tetratone(
            image_buffer,
            width,
            height,
            col1,
            col2,
            col3,
            col4,
            n1,
            midpoint1,
            midpoint2,
            n2,
        )?;
        Ok(())
    }

    fn posterize(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        r_count: usize,
        g_count: usize,
        b_count: usize,
        error_diffusion: bool,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        unoptimized::posterize::posterize(
            image_buffer,
            width,
            height,
            r_count,
            g_count,
            b_count,
            error_diffusion,
        )?;
        Ok(())
    }

    fn colorama(
        image_buffer: NonNull<u8>,
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
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        unoptimized::colorama::colorama(
            image_buffer,
            width,
            height,
            f_shift,
            cycle_count,
            max_colors,
            col1,
            col2,
            col3,
            col4,
            col5,
            col6,
        )?;
        Ok(())
    }

    fn minimax_check(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        max_min: u8,  // 1..=2
        channel: u8,  // 1..=4
        range: usize, // 1..=
        angle_deg: f64,
        horizontal: bool,
        vertical: bool,
        aspect_ratio: f64,
        symmetric: bool,
        save_color: bool,
        fig: u8, // caller comment says [0..4]
        reserved0: f64,
        reserved1: f64,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        let mut cache = MINIMAX_CACHE
            .lock()
            .map_err(|_| anyhow::anyhow!("Failed to acquire minimax cache lock"))?;
        unoptimized::minimax::minimax_check(
            &mut cache,
            image_buffer,
            width,
            height,
            unoptimized::minimax::MinimaxCheckParams {
                max_min,
                channel,
                range,
                angle_deg,
                horizontal,
                vertical,
                aspect_ratio,
                symmetric,
                save_color,
                fig,
                reserved0,
                reserved1,
            },
        )?;
        Ok(())
    }

    fn minimax(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        max_min: u8,
        range: usize,
        channel: u8,
        horizontal: bool,
        vertical: bool,
        symmetric: bool,
        aspect_ratio: f64,
        save_color: bool,
        fig: u8,
        alpha_expand: bool,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };

        unoptimized::minimax::minmax_impl(
            image_buffer,
            width,
            height,
            unoptimized::minimax::MinimaxParams {
                max_min,
                range,
                channel,
                horizontal,
                vertical,
                symmetric,
                aspect_ratio,
                save_color,
                fig,
                alpha_expand,
            },
        )?;

        Ok(())
    }

    fn minimax_rot(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        original_width: usize,
        original_height: usize,
        angle_rad: f64,
        rotated_90_first: i32,
        max_min: u8,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };

        unoptimized::minimax::minimax_rot(
            image_buffer,
            width,
            height,
            unoptimized::minimax::MinimaxRotParams {
                original_width,
                original_height,
                angle_rad,
                rotated_90_first: rotated_90_first != 0,
                max_min,
            },
        )?;

        Ok(())
    }

    fn minimax_save(image_buffer: NonNull<u8>, width: usize, height: usize) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        let mut cache = MINIMAX_CACHE
            .lock()
            .map_err(|_| anyhow::anyhow!("Failed to acquire minimax cache lock"))?;
        unoptimized::minimax::minimax_save(&mut cache, image_buffer, width, height)?;
        Ok(())
    }
}

aviutl2::register_script_module!(PortedTimMod2);
