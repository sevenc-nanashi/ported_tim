use std::sync::{LazyLock, Mutex};

pub(crate) static FILTER_UNSHARP_STATE: LazyLock<
    Mutex<crate::filter::unoptimized::unsharp::UnsharpState>,
> = LazyLock::new(|| Mutex::new(crate::filter::unoptimized::unsharp::UnsharpState::new()));

pub mod easy_binarization;
pub mod flat_rgb;
pub mod flattening;
pub mod glass_sq;
pub mod gray_color;
pub mod unsharp;
