#![allow(clippy::too_many_arguments)]
use aviutl2::{anyhow, module::ScriptModuleFunctions};
use std::ptr::NonNull;

mod binarization;
mod binarization_rgb;
mod enh_grayscale;
mod grayscale;
mod metal;
mod pastel;

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
}

aviutl2::register_script_module!(PortedTimMod2);
