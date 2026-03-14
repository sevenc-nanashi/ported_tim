use aviutl2::anyhow::{self, Context};

mod get_camera_data;
mod read_data;
mod state;

pub(crate) struct MmdCamModule;

static MMD_CAM_STATE: std::sync::Mutex<Option<crate::mmdcam::state::MmdCamState>> =
    std::sync::Mutex::new(None);

#[aviutl2::module::functions]
impl MmdCamModule {
    fn mmdcam_read_data(file_path: String) -> anyhow::Result<usize> {
        let mut state = MMD_CAM_STATE
            .lock()
            .map_err(|_| anyhow::anyhow!("Failed to acquire MMDCam state lock"))?;
        let keyframes = crate::mmdcam::read_data::read_data(&file_path)?;
        let length = keyframes.len();
        *state = Some(crate::mmdcam::state::MmdCamState { keyframes });
        Ok(length)
    }

    #[expect(clippy::type_complexity)]
    fn mmdcam_get_camera_data(
        current_frame: i32,
        total_frame: i32,
        size_correction: f64,
    ) -> anyhow::Result<(f64, f64, f64, f64, f64, f64, f64, f64, f64)> {
        let state = MMD_CAM_STATE
            .lock()
            .map_err(|_| anyhow::anyhow!("Failed to acquire MMDCam state lock"))?;
        let state = state.as_ref().context("MMD camera data not loaded")?;
        let camera = crate::mmdcam::get_camera_data::get_camera_data(
            state,
            current_frame,
            total_frame,
            size_correction,
        )?;
        Ok((
            camera.x,
            camera.y,
            camera.z,
            camera.tx,
            camera.ty,
            camera.tz,
            camera.rz,
            camera.view_angle,
            camera.srvt,
        ))
    }
}
