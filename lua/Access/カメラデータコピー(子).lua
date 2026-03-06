--label:tim2\カメラ制御\カメラデータコピー.cam
---$track:倍率[%]
---min=0
---max=5000
---step=0.1
local rename_me_track0 = 100

---$check:X軸反転
local mx = 0

---$check:Y軸反転
local my = 0

---$check:Z軸反転
local mz = 0

local bai = rename_me_track0 * 0.01

if mx == 1 then
    aviutl_camera_param_copy.x = -aviutl_camera_param_copy.x
end
if my == 1 then
    aviutl_camera_param_copy.y = -aviutl_camera_param_copy.y
end
if mz == 1 then
    aviutl_camera_param_copy.z = -aviutl_camera_param_copy.z
end

aviutl_camera_param_copy.x = bai * aviutl_camera_param_copy.x
aviutl_camera_param_copy.y = bai * aviutl_camera_param_copy.y
aviutl_camera_param_copy.z = bai * aviutl_camera_param_copy.z

aviutl_camera_param_copy.rz = aviutl_camera_param_copy.rz

aviutl_camera_param_copy.tx = aviutl_camera_param_copy.tx
aviutl_camera_param_copy.ty = aviutl_camera_param_copy.ty
aviutl_camera_param_copy.tz = aviutl_camera_param_copy.tz

aviutl_camera_param_copy.d = aviutl_camera_param_copy.d

obj.setoption("camera_param", aviutl_camera_param_copy)
