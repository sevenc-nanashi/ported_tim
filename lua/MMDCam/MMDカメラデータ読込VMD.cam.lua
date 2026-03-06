--label:tim2\未分類
---$track:ｻｲｽﾞ補正
---min=0
---max=10000
---step=0.01
local rename_me_track0 = 100

---$track:ﾌﾚｰﾑｵﾌｾｯﾄ
---min=0
---max=10000
---step=1
local rename_me_track1 = 0

---$track:自動視野角
---min=0
---max=1
---step=1
local rename_me_track2 = 1

---$file:ファイル
local rename_me_file = ""
file = rename_me_file

require("MMD2AviUtl")

local mmd_h = MMD2AviUtl.ReadData(file)

if mmd_h.count ~= 0 then
    local cam_t = MMD2AviUtl.GetCameraData(
        obj.frame + rename_me_track1,
        obj.totalframe + rename_me_track1,
        3000 / rename_me_track0
    )

    local cam = obj.getoption("camera_param")

    cam.x = cam_t.x
    cam.y = cam_t.y
    cam.z = cam_t.z
    cam.tx = cam_t.tx
    cam.ty = cam_t.ty
    cam.tz = cam_t.tz
    cam.rz = cam.rz + cam_t.rz

    if cam_t.srvt < 0 then
        cam.ux = -cam.ux
        cam.uy = -cam.uy
        cam.uz = -cam.uz
    end

    if rename_me_track2 == 1 then
        cam.d = obj.screen_h / math.tan(cam_t.viewAngle * math.pi / 360) / 2
    end

    obj.setoption("camera_param", cam)
end
