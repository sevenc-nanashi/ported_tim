use std::sync::{LazyLock, Mutex};

pub(crate) static TONE_CURVE_STATE: LazyLock<
    Mutex<crate::color::unoptimized::tone_curve::ToneCurveState>,
> = LazyLock::new(|| Mutex::new(crate::color::unoptimized::tone_curve::ToneCurveState::default()));
pub mod change_to_color;
pub mod colorama;
pub mod equalize;
pub mod extended_contrast;
pub mod gamma_correction;
pub mod grainy;
pub mod histogram;
pub mod monochromatic;
pub mod monochromatic2;
pub mod reduction;
pub mod standard_color;
pub mod tone_curve;
