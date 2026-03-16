use std::sync::{LazyLock, Mutex};

pub(crate) static TONE_CURVE_STATE: LazyLock<
    Mutex<crate::color::unoptimized::tone_curve::ToneCurveState>,
> = LazyLock::new(|| Mutex::new(crate::color::unoptimized::tone_curve::ToneCurveState::default()));
pub(crate) static SHADOW_HIGHLIGHT_STATE: LazyLock<
    Mutex<crate::color::unoptimized::shadow_highlight::ShadowHighlightState>,
> = LazyLock::new(|| {
    Mutex::new(crate::color::unoptimized::shadow_highlight::ShadowHighlightState::new())
});
pub(crate) static MINIMAX_CACHE: LazyLock<Mutex<crate::color::unoptimized::minimax::MinimaxCache>> =
    LazyLock::new(|| Mutex::new(crate::color::unoptimized::minimax::MinimaxCache::default()));

pub mod bias_deletion;
pub mod change_to_color;
pub mod color_reduction;
pub mod colorama;
pub mod cycle_bit_shift;
pub mod enh_grayscale;
pub mod equalize;
pub mod extended_contrast;
pub mod fringe_fix;
pub mod gamma_correction;
pub mod grainy;
pub mod grayscale;
pub mod histogram;
pub mod leave_color;
pub mod metal;
pub mod minimax;
pub mod monochromatic;
pub mod monochromatic2;
pub mod pastel;
pub mod posterize;
pub mod reduction;
pub mod shadow_highlight;
pub mod shift_channels;
pub mod standard_color;
pub mod tetratone;
pub mod tone_curve;
pub mod tritone_v2;
pub mod tritone_v3;
