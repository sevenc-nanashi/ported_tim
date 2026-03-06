--label:tim2\カメラ制御
---$track:補正X
---min=-5000
---max=5000
---step=0.1
local rename_me_track0 = 0

---$track:補正Y
---min=-5000
---max=5000
---step=0.1
local rename_me_track1 = 0

---$track:補正Z
---min=-5000
---max=5000
---step=0.1
local rename_me_track2 = 0

---$track:補正方法
---min=1
---max=3
---step=1
local rename_me_track3 = 1

local dx = rename_me_track0
local dy = rename_me_track1
local dz = rename_me_track2
local cam = obj.getoption("camera_param")

if AND(rename_me_track3, 1) == 1 then
    cam.x = cam.x + dx
    cam.y = cam.y + dy
    cam.z = cam.z + dz
end
if SHIFT(rename_me_track3, -1) == 1 then
    cam.tx = cam.tx + dx
    cam.ty = cam.ty + dy
    cam.tz = cam.tz + dz
end
obj.setoption("camera_param", cam)
