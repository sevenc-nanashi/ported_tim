--label:${ROOT_CATEGORY}\カメラ制御\@カメラデータコピー
---$track:倍率[%]
---min=0
---max=5000
---step=0.1
local track_scale_percent = 100

---$check:X軸反転
local check_invert_x = 0

---$check:Y軸反転
local check_invert_y = 0

---$check:Z軸反転
local check_invert_z = 0

local scale_ratio = track_scale_percent * 0.01

if check_invert_x == 1 then
    T_AVIUTL_CAMERA_PARAM_COPY.x = -T_AVIUTL_CAMERA_PARAM_COPY.x
end
if check_invert_y == 1 then
    T_AVIUTL_CAMERA_PARAM_COPY.y = -T_AVIUTL_CAMERA_PARAM_COPY.y
end
if check_invert_z == 1 then
    T_AVIUTL_CAMERA_PARAM_COPY.z = -T_AVIUTL_CAMERA_PARAM_COPY.z
end

T_AVIUTL_CAMERA_PARAM_COPY.x = scale_ratio * T_AVIUTL_CAMERA_PARAM_COPY.x
T_AVIUTL_CAMERA_PARAM_COPY.y = scale_ratio * T_AVIUTL_CAMERA_PARAM_COPY.y
T_AVIUTL_CAMERA_PARAM_COPY.z = scale_ratio * T_AVIUTL_CAMERA_PARAM_COPY.z

T_AVIUTL_CAMERA_PARAM_COPY.rz = T_AVIUTL_CAMERA_PARAM_COPY.rz

T_AVIUTL_CAMERA_PARAM_COPY.tx = T_AVIUTL_CAMERA_PARAM_COPY.tx
T_AVIUTL_CAMERA_PARAM_COPY.ty = T_AVIUTL_CAMERA_PARAM_COPY.ty
T_AVIUTL_CAMERA_PARAM_COPY.tz = T_AVIUTL_CAMERA_PARAM_COPY.tz

T_AVIUTL_CAMERA_PARAM_COPY.d = T_AVIUTL_CAMERA_PARAM_COPY.d

obj.setoption("camera_param", T_AVIUTL_CAMERA_PARAM_COPY)
