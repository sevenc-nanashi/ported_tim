--label:tim2\カメラ制御
---$track:補正RZ
---min=-5000
---max=5000
---step=0.1
local rename_me_track0 = 0

local dz = rename_me_track0
local cam = obj.getoption("camera_param")

cam.rz = cam.rz + dz

obj.setoption("camera_param", cam)
