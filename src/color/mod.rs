use aviutl2::anyhow;
use std::ptr::NonNull;

pub mod unoptimized;

pub(crate) struct ColorModule;

#[aviutl2::module::functions]
#[allow(clippy::too_many_arguments)]
impl ColorModule {
    fn color_metal(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        flip_upper: u8,
        flip_lower: u8,
        gray_mode: u8,
    ) -> anyhow::Result<()> {
        let gray_mode = match gray_mode {
            0 => crate::color::unoptimized::metal::GrayMode::Average,
            1 => crate::color::unoptimized::metal::GrayMode::Lightness,
            2 => crate::color::unoptimized::metal::GrayMode::Luminance,
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
        crate::color::unoptimized::metal::metal(image_buffer, flip_upper, flip_lower, gray_mode);
        Ok(())
    }

    fn color_pastel(
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
        crate::color::unoptimized::pastel::pastel_bgra(
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

    fn color_grayscale(
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
        crate::color::unoptimized::grayscale::grayscale(
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

    fn color_enh_grayscale(
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
        crate::color::unoptimized::enh_grayscale::enh_grayscale(
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

    fn color_binarization(
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
        crate::color::unoptimized::binarization::binarization(
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

    fn color_binarization_rgb(
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
        crate::color::unoptimized::binarization_rgb::binarization_rgb(
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

    fn color_channel_mixer(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        rr: i32,
        rg: i32,
        rb: i32,
        rc: i32,
        gr: i32,
        gg: i32,
        gb: i32,
        gc: i32,
        br: i32,
        bg: i32,
        bb: i32,
        bc: i32,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };

        crate::color::unoptimized::channel_mixer::channel_mixer(
            image_buffer,
            width,
            height,
            rr,
            rg,
            rb,
            rc,
            gr,
            gg,
            gb,
            gc,
            br,
            bg,
            bb,
            bc,
        )?;
        Ok(())
    }

    fn color_shift_channels(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        alpha_shift: i32,
        red_shift: i32,
        green_shift: i32,
        blue_shift: i32,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };

        crate::color::unoptimized::shift_channels::shift_channels(
            image_buffer,
            width,
            height,
            alpha_shift,
            red_shift,
            green_shift,
            blue_shift,
        )?;
        Ok(())
    }

    fn color_cycle_bit_shift(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        red_shift: i32,
        green_shift: i32,
        blue_shift: i32,
        cycle_24bit: Option<bool>,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };

        crate::color::unoptimized::cycle_bit_shift::cycle_bit_shift(
            image_buffer,
            width,
            height,
            red_shift,
            green_shift,
            blue_shift,
            cycle_24bit.unwrap_or(false),
        )?;
        Ok(())
    }

    fn color_leave_color(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        r: u8,
        g: u8,
        b: u8,
        color_cut_amount: f64,
        color_difference_range: i32,
        edge: i32,
        matching_method: i32,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };

        crate::color::unoptimized::leave_color::leave_color(
            image_buffer,
            width,
            height,
            r,
            g,
            b,
            color_cut_amount,
            color_difference_range,
            edge,
            matching_method,
        )?;
        Ok(())
    }

    fn color_fringe_fix(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        bg_color: u32,
        adjust_method: i32,
        alpha_upper_limit: i32,
        alpha_lower_limit: i32,
        apply_alpha_after: i32,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };

        crate::color::unoptimized::fringe_fix::fringe_fix(
            image_buffer,
            width,
            height,
            bg_color,
            adjust_method,
            alpha_upper_limit,
            alpha_lower_limit,
            apply_alpha_after != 0,
        )?;
        Ok(())
    }

    fn color_bias_deletion(
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
        crate::color::unoptimized::bias_deletion::bias_deletion(
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

    fn color_grainy(
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
        crate::color::unoptimized::grainy::grainy(
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

    fn color_gamma_correction(
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
        crate::color::unoptimized::gamma_correction::gamma_correction(
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

    fn color_color_reduction(
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
        crate::color::unoptimized::color_reduction::color_reduction(image_buffer, shift)?;
        Ok(())
    }

    fn color_tritone_v3(
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
        crate::color::unoptimized::tritone_v3::tritone_v3(
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

    fn color_tritone_v2(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        r1: u8,
        g1: u8,
        b1: u8,
        r2: u8,
        g2: u8,
        b2: u8,
        r3: u8,
        g3: u8,
        b3: u8,
        p1: u8,
        p2: u8,
        p3: u8,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        crate::color::unoptimized::tritone_v2::tritone_v2(
            image_buffer,
            width,
            height,
            r1,
            g1,
            b1,
            r2,
            g2,
            b2,
            r3,
            g3,
            b3,
            p1,
            p2,
            p3,
        )?;
        Ok(())
    }

    fn color_set_tone_curve(
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
        let mut state = unoptimized::TONE_CURVE_STATE
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

    fn color_sim_tone_curve(
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
        let mut state = unoptimized::TONE_CURVE_STATE
            .lock()
            .map_err(|_| anyhow::anyhow!("Failed to acquire tone curve state lock"))?;
        state.sim_tone_curve_impl(image_buffer, copy_red_to_green_blue)?;
        Ok(())
    }

    fn color_image_tone_curve(
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
        let mut state = unoptimized::TONE_CURVE_STATE
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

    fn color_draw_tone_curve(
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
        let state = unoptimized::TONE_CURVE_STATE
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

    fn color_mcut_reduction(
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
        crate::color::unoptimized::reduction::mcut_reduction(
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

    fn color_sample_grid_colors(
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

        let colors = crate::color::unoptimized::reduction::sample_grid_colors(
            image_buffer,
            width,
            height,
            sample_count,
            x_split,
            y_split,
        )?;

        Ok(colors.iter().map(|&c| c as i32).collect())
    }

    fn color_disp_reduction(
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
        crate::color::unoptimized::reduction::disp_reduction(image_buffer, width, height, &colors)?;
        Ok(())
    }

    fn color_extended_contrast(
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
        crate::color::unoptimized::extended_contrast::extended_contrast(
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

    fn color_equalize(
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
        crate::color::unoptimized::equalize::equalize(image_buffer, width, height, calc_method)?;
        Ok(())
    }

    fn color_equalize_rgb(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        crate::color::unoptimized::equalize::equalize_rgb(image_buffer, width, height)?;
        Ok(())
    }

    fn color_create_histogram(
        image_buffer: NonNull<u8>,
        histogram_width: usize,
        histogram_height: usize,
        source_width: usize,
        source_height: usize,
        buffer_width: usize,
        buffer_height: usize,
        vertical_scale: f64,
        show_luminance: bool,
        show_red: bool,
        show_green: bool,
        show_blue: bool,
    ) -> anyhow::Result<()> {
        let buffer_size = buffer_width
            .checked_mul(buffer_height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        crate::color::unoptimized::histogram::create_histogram(
            image_buffer,
            crate::color::unoptimized::histogram::CreateHistogramParams {
                histogram_width,
                histogram_height,
                source_width,
                source_height,
                buffer_width,
                buffer_height,
                vertical_scale,
                show_luminance,
                show_red,
                show_green,
                show_blue,
            },
        )?;
        Ok(())
    }

    fn color_save_g_image(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        let mut state = unoptimized::SHADOW_HIGHLIGHT_STATE
            .lock()
            .map_err(|_| anyhow::anyhow!("Failed to acquire shadow/highlight state lock"))?;
        state.save_g_image(image_buffer, width, height)?;
        Ok(())
    }

    fn color_shadow_highlight(
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
        let mut state = unoptimized::SHADOW_HIGHLIGHT_STATE
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

    fn color_monochromatic(
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
        crate::color::unoptimized::monochromatic::monochromatic(
            image_buffer,
            width,
            height,
            track_r,
            track_g,
            track_b,
        )?;
        Ok(())
    }

    fn color_monochromatic2(
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
        crate::color::unoptimized::monochromatic2::monochromatic2(
            image_buffer,
            width,
            height,
            u,
            v,
            gamma,
        )?;
        Ok(())
    }

    fn color_standard_color(
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
        crate::color::unoptimized::standard_color::standard_color(
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

    fn color_change_to_color(
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
        crate::color::unoptimized::change_to_color::change_to_color(
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

    fn color_tetratone(
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
        crate::color::unoptimized::tetratone::tetratone(
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

    fn color_posterize(
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
        crate::color::unoptimized::posterize::posterize(
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

    fn color_colorama(
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
        crate::color::unoptimized::colorama::colorama(
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

    fn color_minimax_check(
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
        let mut cache = unoptimized::MINIMAX_CACHE
            .lock()
            .map_err(|_| anyhow::anyhow!("Failed to acquire minimax cache lock"))?;
        crate::color::unoptimized::minimax::minimax_check(
            &mut cache,
            image_buffer,
            width,
            height,
            crate::color::unoptimized::minimax::MinimaxCheckParams {
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

    fn color_minimax(
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

        crate::color::unoptimized::minimax::minimax_impl(
            image_buffer,
            width,
            height,
            crate::color::unoptimized::minimax::MinimaxParams {
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

    fn color_minimax_rot(
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

        crate::color::unoptimized::minimax::minimax_rot(
            image_buffer,
            width,
            height,
            crate::color::unoptimized::minimax::MinimaxRotParams {
                original_width,
                original_height,
                angle_rad,
                rotated_90_first: rotated_90_first != 0,
                max_min,
            },
        )?;

        Ok(())
    }

    fn color_minimax_save(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        let mut cache = unoptimized::MINIMAX_CACHE
            .lock()
            .map_err(|_| anyhow::anyhow!("Failed to acquire minimax cache lock"))?;
        crate::color::unoptimized::minimax::minimax_save(&mut cache, image_buffer, width, height)?;
        Ok(())
    }
}
