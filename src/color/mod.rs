use aviutl2::anyhow;
use std::ptr::NonNull;

mod bias_deletion;
mod binarization;
mod binarization_rgb;
mod equalize;
mod minimax;
mod posterize;
mod reduction;
mod tone_curve;
pub mod unoptimized;

use std::sync::{LazyLock, Mutex};

pub(crate) static MINIMAX_CACHE: LazyLock<Mutex<minimax::MinimaxCache>> =
    LazyLock::new(|| Mutex::new(minimax::MinimaxCache::default()));
pub(crate) static TONE_CURVE_STATE: LazyLock<Mutex<tone_curve::ToneCurveState>> =
    LazyLock::new(|| Mutex::new(tone_curve::ToneCurveState::default()));

pub(crate) struct ColorModule;

#[aviutl2::module::functions]
#[allow(clippy::too_many_arguments)]
impl ColorModule {
    fn color_binarization_threshold(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        threshold: u8,
        gray_mode: u8,
        auto_detect_method: u8,
    ) -> anyhow::Result<f64> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts(image_buffer.as_ptr() as *const u8, buffer_size) };
        crate::color::binarization::calculate_threshold(
            image_buffer,
            width,
            height,
            threshold,
            gray_mode,
            auto_detect_method,
        )
    }

    fn color_binarization_rgb_thresholds(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        r_threshold: u8,
        g_threshold: u8,
        b_threshold: u8,
        auto_detect_method: u8,
    ) -> anyhow::Result<Vec<i32>> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts(image_buffer.as_ptr() as *const u8, buffer_size) };
        let thresholds = crate::color::binarization_rgb::calculate_thresholds(
            image_buffer,
            width,
            height,
            r_threshold,
            g_threshold,
            b_threshold,
            auto_detect_method,
        )?;
        Ok(thresholds.into_iter().map(i32::from).collect())
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
        crate::color::bias_deletion::bias_deletion(
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
        let mut state = TONE_CURVE_STATE
            .lock()
            .map_err(|_| anyhow::anyhow!("Failed to acquire tone curve state lock"))?;
        state.sim_tone_curve_impl(image_buffer, copy_red_to_green_blue)?;
        Ok(())
    }

    fn color_prepare_tone_curve_lut(
        lut_buffer: NonNull<u8>,
        lut_width: usize,
        lut_height: usize,
        copy_red_to_green_blue: bool,
    ) -> anyhow::Result<()> {
        let buffer_size = lut_width
            .checked_mul(lut_height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let lut_buffer =
            unsafe { std::slice::from_raw_parts_mut(lut_buffer.as_ptr(), buffer_size) };
        let mut state = TONE_CURVE_STATE
            .lock()
            .map_err(|_| anyhow::anyhow!("Failed to acquire tone curve state lock"))?;
        state.prepare_tone_curve_lut_impl(
            lut_buffer,
            lut_width,
            lut_height,
            copy_red_to_green_blue,
        )?;
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
        crate::color::reduction::mcut_reduction(
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

        let colors = crate::color::reduction::sample_grid_colors(
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
        crate::color::reduction::disp_reduction(image_buffer, width, height, &colors)?;
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

    fn color_prepare_equalize_lut(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        lut_buffer: NonNull<u8>,
        lut_width: usize,
        lut_height: usize,
        calc_method: u8,
    ) -> anyhow::Result<Vec<f64>> {
        let image_buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Image buffer size overflow"))?;
        let lut_buffer_size = lut_width
            .checked_mul(lut_height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("LUT buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts(image_buffer.as_ptr(), image_buffer_size) };
        let lut_buffer =
            unsafe { std::slice::from_raw_parts_mut(lut_buffer.as_ptr(), lut_buffer_size) };
        crate::color::equalize::prepare_equalize_lut(
            image_buffer,
            width,
            height,
            lut_buffer,
            lut_width,
            lut_height,
            calc_method,
        )
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

    fn color_posterize_error_diffusion(
        image_buffer: NonNull<u8>,
        width: usize,
        height: usize,
        r_count: usize,
        g_count: usize,
        b_count: usize,
    ) -> anyhow::Result<()> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        crate::color::posterize::posterize_error_diffusion(
            image_buffer,
            width,
            height,
            r_count,
            g_count,
            b_count,
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
    ) -> anyhow::Result<f64> {
        let buffer_size = width
            .checked_mul(height)
            .and_then(|v| v.checked_mul(4))
            .ok_or_else(|| anyhow::anyhow!("Buffer size overflow"))?;
        let image_buffer =
            unsafe { std::slice::from_raw_parts_mut(image_buffer.as_ptr(), buffer_size) };
        let mut cache = MINIMAX_CACHE
            .lock()
            .map_err(|_| anyhow::anyhow!("Failed to acquire minimax cache lock"))?;
        let restored = crate::color::minimax::minimax_check(
            &mut cache,
            image_buffer,
            width,
            height,
            crate::color::minimax::MinimaxCheckParams {
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
            },
        )?;
        Ok(if restored { 1.0 } else { 0.0 })
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

        crate::color::minimax::minimax_impl(
            image_buffer,
            width,
            height,
            crate::color::minimax::MinimaxParams {
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

        crate::color::minimax::minimax_rot(
            image_buffer,
            width,
            height,
            crate::color::minimax::MinimaxRotParams {
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
        let mut cache = MINIMAX_CACHE
            .lock()
            .map_err(|_| anyhow::anyhow!("Failed to acquire minimax cache lock"))?;
        crate::color::minimax::minimax_save(&mut cache, image_buffer, width, height)?;
        Ok(())
    }
}
