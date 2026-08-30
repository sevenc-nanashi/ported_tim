--label:${ROOT_CATEGORY}\カメラ制御
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

local tim2 = obj.module("tim2")
local loaded_camera_count = tim2.mmdcam_read_data(file_path)

if loaded_camera_count ~= 0 then
    local x, y, z, target_x, target_y, target_z, roll, view_angle, vertical_sign = tim2.mmdcam_get_camera_data(
        obj.frame + track_frame_offset,
        obj.totalframe + track_frame_offset,
        3000 / track_size_correction
    )

    local camera = obj.getoption("camera_param")

    camera.x = x
    camera.y = y
    camera.z = z
    camera.target_x = target_x
    camera.target_y = target_y
    camera.target_z = target_z
    camera.roll = camera.roll + roll

    if vertical_sign < 0 then
        camera.ux = -camera.ux
        camera.uy = -camera.uy
        camera.uz = -camera.uz
    end

    if check_auto_view_angle then
        camera.d = obj.screen_h / math.tan(view_angle * math.pi / 360) / 2
    end

    obj.setoption("camera_param", camera)
end
