use anyhow::{Result, anyhow};

use crate::mmdcam::unoptimized::state::{CameraKeyframe, MmdCamState};

const BEZIER_EPSILON: f64 = 1e-6;
const BEZIER_ITERATIONS: usize = 15;

#[derive(Clone, Copy, Debug, Default)]
pub struct CameraData {
    pub x: f64,
    pub y: f64,
    pub z: f64,
    pub tx: f64,
    pub ty: f64,
    pub tz: f64,
    pub rz: f64,
    pub view_angle: f64,
    pub srvt: f64,
}

pub fn get_camera_data(
    state: &MmdCamState,
    current_frame: i32,
    total_frame: i32,
    size_correction: f64,
) -> Result<CameraData> {
    if state.keyframes.is_empty() {
        return Err(anyhow!("No MMD camera data loaded"));
    }

    let (previous, next) = select_keyframes(&state.keyframes, current_frame, total_frame);
    let current_frame_f64 = f64::from(current_frame);
    let next_frame = i32::try_from(next.frame).unwrap_or(i32::MAX);

    let interpolated = if next_frame == current_frame {
        next
    } else {
        let previous_frame = f64::from(previous.frame);
        let next_frame = f64::from(next.frame);
        let denominator = next_frame - previous_frame;

        if denominator <= 0.0 {
            next
        } else {
            interpolate_keyframe(
                previous,
                next,
                (current_frame_f64 - previous_frame) / denominator,
            )
        }
    };

    Ok(convert_camera(interpolated, size_correction))
}

fn select_keyframes(
    keyframes: &[CameraKeyframe],
    current_frame: i32,
    total_frame: i32,
) -> (CameraKeyframe, CameraKeyframe) {
    let insertion_index = keyframes
        .iter()
        .position(|keyframe| current_frame <= i32::try_from(keyframe.frame).unwrap_or(i32::MAX))
        .unwrap_or(keyframes.len());

    if insertion_index == 0 {
        return (keyframes[0], keyframes[0]);
    }

    if insertion_index == keyframes.len() {
        let previous = keyframes[keyframes.len() - 1];
        let mut next = previous;
        let total_frame = total_frame.max(i32::try_from(previous.frame).unwrap_or(0));
        next.frame = u32::try_from(total_frame).unwrap_or(previous.frame);
        return (previous, next);
    }

    (keyframes[insertion_index - 1], keyframes[insertion_index])
}

fn interpolate_keyframe(
    previous: CameraKeyframe,
    next: CameraKeyframe,
    current_ratio: f64,
) -> CameraKeyframe {
    let curves = next
        .interpolation
        .chunks_exact(4)
        .map(|chunk| {
            solve_bezier(
                f64::from(chunk[0]) / 127.0,
                f64::from(chunk[2]) / 127.0,
                f64::from(chunk[1]) / 127.0,
                f64::from(chunk[3]) / 127.0,
                current_ratio,
            )
        })
        .collect::<Vec<_>>();

    CameraKeyframe {
        frame: next.frame,
        distance: lerp(previous.distance, next.distance, curves[4]),
        target_x: lerp(previous.target_x, next.target_x, curves[0]),
        target_y: lerp(previous.target_y, next.target_y, curves[1]),
        target_z: lerp(previous.target_z, next.target_z, curves[2]),
        rotation_x: lerp(previous.rotation_x, next.rotation_x, curves[3]),
        rotation_y: lerp(previous.rotation_y, next.rotation_y, curves[3]),
        rotation_z: lerp(previous.rotation_z, next.rotation_z, curves[3]),
        interpolation: next.interpolation,
        view_angle: lerp(previous.view_angle, next.view_angle, curves[5]),
        perspective: next.perspective,
    }
}

fn convert_camera(keyframe: CameraKeyframe, size_correction: f64) -> CameraData {
    let tx = f64::from(keyframe.target_x) * size_correction;
    let ty = -f64::from(keyframe.target_y) * size_correction;
    let tz = f64::from(keyframe.target_z) * size_correction;
    let pitch = f64::from(keyframe.rotation_x);
    let yaw = f64::from(keyframe.rotation_y);
    let roll = f64::from(keyframe.rotation_z).to_degrees();
    let distance = (f64::from(keyframe.distance) * size_correction).abs();
    let horizontal_distance = pitch.cos() * distance;

    CameraData {
        x: tx + yaw.sin() * horizontal_distance,
        y: ty + pitch.sin() * distance,
        z: tz - yaw.cos() * horizontal_distance,
        tx,
        ty,
        tz,
        rz: -roll,
        view_angle: f64::from(keyframe.view_angle),
        srvt: pitch.cos(),
    }
}

fn solve_bezier(x1: f64, y1: f64, x2: f64, y2: f64, current_ratio: f64) -> f64 {
    if current_ratio <= 0.0 {
        return 0.0;
    }
    if current_ratio >= 1.0 {
        return 1.0;
    }

    let mut t = 0.5;
    let mut inverse_t = 0.5;

    for iteration in 0..BEZIER_ITERATIONS {
        let x = t * t * t + 3.0 * inverse_t * t * t * x2 + 3.0 * inverse_t * inverse_t * t * x1
            - current_ratio;

        if x.abs() < BEZIER_EPSILON {
            break;
        }

        let step = 1.0 / ((4usize << iteration) as f64);
        if x <= 0.0 {
            t += step;
        } else {
            t -= step;
        }
        inverse_t = 1.0 - t;
    }

    t * t * t + 3.0 * inverse_t * t * t * y2 + 3.0 * inverse_t * inverse_t * t * y1
}

fn lerp(previous: f32, next: f32, amount: f64) -> f32 {
    (f64::from(previous) * (1.0 - amount) + f64::from(next) * amount) as f32
}
