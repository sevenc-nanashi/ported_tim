use std::sync::{LazyLock, Mutex};

pub(crate) static MMD_CAM_STATE: LazyLock<Mutex<crate::mmdcam::unoptimized::state::MmdCamState>> =
    LazyLock::new(|| Mutex::new(crate::mmdcam::unoptimized::state::MmdCamState::default()));

pub mod get_camera_data;
pub mod read_data;
pub mod state;
