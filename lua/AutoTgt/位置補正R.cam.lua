--label:tim2\カメラ制御
---$track:補正RZ
---min=-5000
---max=5000
---step=0.1
local track_rotation_z_offset = 0

local rotation_z_offset = track_rotation_z_offset
local cam = obj.getoption("camera_param")

cam.rz = cam.rz + rotation_z_offset

obj.setoption("camera_param", cam)
