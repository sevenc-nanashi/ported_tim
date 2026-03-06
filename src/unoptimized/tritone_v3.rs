use anyhow::Result;

/// Lua 側の TritoneV3(userdata, w, h, color1, color2, color3, p1, p2, p3, mode)
/// と同じ引数順を想定した単一スレッド版。
///
/// - `userdata`: BGRA バッファ
/// - `w`, `h`: 画像サイズ
/// - `color1`, `color2`, `color3`: 0xRRGGBB
/// - `p1`, `p2`, `p3`: しきい値（0..255想定）
/// - `mode`: 1 のとき中間色を `(color1 + color3) / 2` に差し替える
///
/// 入出力とも BGRA。
pub fn tritone_v3(
    userdata: &mut [u8],
    w: usize,
    h: usize,
    color1: u32,
    color2: u32,
    color3: u32,
    p1: u8,
    p2: u8,
    p3: u8,
    mode: i32,
) -> Result<()> {
    let (r1, g1, b1) = split_rgb(color1);
    let (mut r2, mut g2, mut b2) = split_rgb(color2);
    let (r3, g3, b3) = split_rgb(color3);

    if mode == 1 {
        r2 = avg_u8(r3, r1);
        g2 = avg_u8(g3, g1);
        b2 = avg_u8(b3, b1);
    } else if mode != 0 {
        // 元コードは mode==1 以外をすべて「そのまま color2 を使う」扱い。
        // 到達不能ではないので unreachable! にはしない。
    }

    let lut = build_tritone_lut([r1, g1, b1], [r2, g2, b2], [r3, g3, b3], p1, p2, p3);

    apply_lut_bgra(userdata, w, h, &lut);

    Ok(())
}

fn split_rgb(rgb: u32) -> (u8, u8, u8) {
    let r = ((rgb >> 16) & 0xff) as u8;
    let g = ((rgb >> 8) & 0xff) as u8;
    let b = (rgb & 0xff) as u8;
    (r, g, b)
}

fn avg_u8(a: u8, b: u8) -> u8 {
    ((a as u16 + b as u16) / 2) as u8
}

/// 2048 段階の LUT を作る。
/// 各要素は [R, G, B]。
fn build_tritone_lut(
    color1: [u8; 3],
    color2: [u8; 3],
    color3: [u8; 3],
    p1: u8,
    p2: u8,
    p3: u8,
) -> [[u8; 3]; 2048] {
    let mut lut = [[0u8; 3]; 2048];

    for i in 0..2048 {
        let x = (i as f64) * 255.0;

        let c = if x <= (2047 * (p1 as u32)) as f64 {
            if x <= (2047 * (p2 as u32)) as f64 {
                if x <= (2047 * (p3 as u32)) as f64 {
                    color3
                } else {
                    // color3 -> color2
                    let denom = (p2 as isize - p3 as isize) as f64;
                    if denom == 0.0 {
                        unreachable!("p2 == p3 なのに補間区間へ入った");
                    }
                    let t = (x - (2047 * (p3 as u32)) as f64) / denom;
                    lerp_rgb(color3, color2, t)
                }
            } else {
                // color2 -> color1
                let denom = (p1 as isize - p2 as isize) as f64;
                if denom == 0.0 {
                    unreachable!("p1 == p2 なのに補間区間へ入った");
                }
                let t = (x - (2047 * (p2 as u32)) as f64) / denom;
                lerp_rgb(color2, color1, t)
            }
        } else {
            color1
        };

        lut[i] = c;
    }

    lut
}

fn lerp_rgb(from: [u8; 3], to: [u8; 3], t: f64) -> [u8; 3] {
    let r = ((from[0] as f64) * (2047.0 - t) + (to[0] as f64) * t) as i32 >> 11;
    let g = ((from[1] as f64) * (2047.0 - t) + (to[1] as f64) * t) as i32 >> 11;
    let b = ((from[2] as f64) * (2047.0 - t) + (to[2] as f64) * t) as i32 >> 11;

    [r as u8, g as u8, b as u8]
}

/// BGRA 入力を輝度化し、LUT で BGRA に書き戻す。
fn apply_lut_bgra(userdata: &mut [u8], w: usize, h: usize, lut: &[[u8; 3]; 2048]) {
    let pixel_count = w * h;

    for i in 0..pixel_count {
        let base = i * 4;

        let b = userdata[base] as f64;
        let g = userdata[base + 1] as f64;
        let r = userdata[base + 2] as f64;
        let a = userdata[base + 3];

        let lum = ((r * 0.298_912 + g * 0.586_61 + b * 0.114_478) * 2047.0 / 255.0) as usize;
        let [rr, gg, bb] = lut[lum];

        userdata[base] = bb;
        userdata[base + 1] = gg;
        userdata[base + 2] = rr;
        userdata[base + 3] = a;
    }
}
