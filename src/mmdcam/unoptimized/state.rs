#[derive(Clone, Copy, Debug, Default)]
pub struct CameraKeyframe {
    pub frame: u32,
    pub distance: f32,
    pub target_x: f32,
    pub target_y: f32,
    pub target_z: f32,
    pub rotation_x: f32,
    pub rotation_y: f32,
    pub rotation_z: f32,
    pub interpolation: [u8; 24],
    pub view_angle: f32,
    pub perspective: u8,
}

#[derive(Debug, Default)]
pub struct MmdCamState {
    pub keyframes: Vec<CameraKeyframe>,
}

impl MmdCamState {
    pub fn clear(&mut self) {
        self.keyframes.clear();
    }
}
