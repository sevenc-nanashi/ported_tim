use aviutl2::anyhow;

pub mod unoptimized;

pub(crate) struct MmdCamModule;

#[aviutl2::module::functions]
impl MmdCamModule {
    fn mmdcam_read_data(file_path: String) -> anyhow::Result<usize> {
        let mut state = unoptimized::MMD_CAM_STATE
            .lock()
            .map_err(|_| anyhow::anyhow!("Failed to acquire MMDCam state lock"))?;
        crate::mmdcam::unoptimized::read_data::read_data(&mut state, &file_path)
    }

    fn mmdcam_get_camera_data(
        current_frame: i32,
        total_frame: i32,
        size_correction: f64,
    ) -> anyhow::Result<(f64, f64, f64, f64, f64, f64, f64, f64, f64)> {
        let state = unoptimized::MMD_CAM_STATE
            .lock()
            .map_err(|_| anyhow::anyhow!("Failed to acquire MMDCam state lock"))?;
        let camera = crate::mmdcam::unoptimized::get_camera_data::get_camera_data(
            &state,
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
