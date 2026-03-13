--label:tim2\カメラ制御
---$track:サイズ補正
---min=1
---max=10000
---step=0.01
local track_size_correction = 100

---$track:フレームオフセット
---min=0
---max=10000
---step=1
local track_frame_offset = 0

---$check:自動視野角
local check_auto_view_angle = true

---$file:ファイル
local file_path = ""

local function is_enabled(value)
    return value == true or value == 1
end

local tim2 = obj.module("tim2")
local loaded_camera_count = tim2.mmdcam_read_data(file_path)

if loaded_camera_count ~= 0 then
    local x, y, z, tx, ty, tz, rz, view_angle, srvt = tim2.mmdcam_get_camera_data(
        obj.frame + track_frame_offset,
        obj.totalframe + track_frame_offset,
        3000 / track_size_correction
    )

    local cam = obj.getoption("camera_param")

    cam.x = x
    cam.y = y
    cam.z = z
    cam.tx = tx
    cam.ty = ty
    cam.tz = tz
    cam.rz = cam.rz + rz

    if srvt < 0 then
        cam.ux = -cam.ux
        cam.uy = -cam.uy
        cam.uz = -cam.uz
    end

    if is_enabled(check_auto_view_angle) then
        cam.d = obj.screen_h / math.tan(view_angle * math.pi / 360) / 2
    end

    obj.setoption("camera_param", cam)
end
