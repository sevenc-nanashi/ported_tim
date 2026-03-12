use std::sync::{LazyLock, Mutex};

pub(crate) static FILTER_UNSHARP_STATE: LazyLock<
    Mutex<crate::filter::unoptimized::unsharp::UnsharpState>,
> = LazyLock::new(|| Mutex::new(crate::filter::unoptimized::unsharp::UnsharpState::new()));

pub mod blaster;
pub mod chalk_charcoal;
pub mod easy_binarization;
pub mod emboss;
pub mod flat_rgb;
pub mod flattening;
pub mod glass_sq;
pub mod graphicpen;
pub mod gray_color;
pub mod preprocessing;
pub mod sharp;
pub mod unsharp;
