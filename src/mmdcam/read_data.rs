use std::{
    fs::File,
    io::{Read, Seek, SeekFrom},
};

use anyhow::Result;

use super::state::{CameraKeyframe, MmdCamState};

const VMD_HEADER_PREFIX: &[u8] = b"Vocaloid Motion Data 0002";
const MAX_CAMERA_KEYFRAMES: usize = 499;
const BONE_KEYFRAME_SIZE: u64 = 0x6f;
const MORPH_KEYFRAME_SIZE: u64 = 0x17;

pub fn read_data(file_path: &str) -> Result<Vec<CameraKeyframe>> {
    let mut file = File::open(file_path)?;

    let header = read_array::<30>(&mut file)?;
    if !header.starts_with(VMD_HEADER_PREFIX) {
        return Err(anyhow::anyhow!("Invalid VMD file header"));
    }

    let _model_name = read_array::<20>(&mut file)?;

    let bone_count = read_u32(&mut file)? as u64;
    file.seek(SeekFrom::Current(i64::try_from(
        bone_count.saturating_mul(BONE_KEYFRAME_SIZE),
    )?))?;

    let morph_count = read_u32(&mut file)? as u64;
    file.seek(SeekFrom::Current(i64::try_from(
        morph_count.saturating_mul(MORPH_KEYFRAME_SIZE),
    )?))?;

    let camera_count = read_u32(&mut file)? as usize;
    let load_count = camera_count.min(MAX_CAMERA_KEYFRAMES);

    let mut keyframes = (0..load_count)
        .map(|_| read_camera_keyframe(&mut file))
        .collect::<Result<Vec<_>>>()?;
    keyframes.sort_by_key(|keyframe| keyframe.frame);
    Ok(keyframes)
}

fn read_camera_keyframe(reader: &mut impl Read) -> Result<CameraKeyframe> {
    Ok(CameraKeyframe {
        frame: read_u32(reader)?,
        distance: read_f32(reader)?,
        target_x: read_f32(reader)?,
        target_y: read_f32(reader)?,
        target_z: read_f32(reader)?,
        rotation_x: read_f32(reader)?,
        rotation_y: read_f32(reader)?,
        rotation_z: read_f32(reader)?,
        interpolation: read_array::<24>(reader)?,
        view_angle: read_u32(reader)? as f32,
        perspective: read_array::<1>(reader)?[0],
    })
}

fn read_u32(reader: &mut impl Read) -> Result<u32> {
    Ok(u32::from_le_bytes(read_array::<4>(reader)?))
}

fn read_f32(reader: &mut impl Read) -> Result<f32> {
    Ok(f32::from_le_bytes(read_array::<4>(reader)?))
}

fn read_array<const N: usize>(reader: &mut impl Read) -> Result<[u8; N]> {
    let mut buf = [0u8; N];
    reader.read_exact(&mut buf)?;
    Ok(buf)
}
