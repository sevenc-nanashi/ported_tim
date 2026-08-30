--label:${ROOT_CATEGORY}\カメラ制御
---$track:補正X
---min=-5000
---max=5000
---step=0.1
local track_offset_x = 0

---$track:補正Y
---min=-5000
---max=5000
---step=0.1
local track_offset_y = 0

---$track:補正Z
---min=-5000
---max=5000
---step=0.1
local track_offset_z = 0

---$select:補正方法
---カメラ位置=1
---ターゲット位置=2
---両方=3
local select_adjust_method = 1

local dx = track_offset_x
local dy = track_offset_y
local dz = track_offset_z
local adjust_method = math.floor(select_adjust_method)
local camera = obj.getoption("camera_param")

if adjust_method == 1 or adjust_method == 3 then
    camera.x = camera.x + dx
    camera.y = camera.y + dy
    camera.z = camera.z + dz
end
if adjust_method == 2 or adjust_method == 3 then
    camera.tx = camera.tx + dx
    camera.ty = camera.ty + dy
    camera.tz = camera.tz + dz
end
obj.setoption("camera_param", camera)
