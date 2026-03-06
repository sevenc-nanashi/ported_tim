--label:tim2\未分類\グループ補助.anm
---$track:透過率
---min=0
---max=100
---step=0.1
local track_transparency = 0

---$track:X回転
---min=-3600
---max=3600
---step=0.1
local track_x_rotation = 0

---$track:Y回転
---min=-3600
---max=3600
---step=0.1
local track_y_rotation = 0

---$track:Z回転
---min=-3600
---max=3600
---step=0.1
local track_z_rotation = 0

obj.alpha = obj.alpha * (1 - track_transparency * 0.01)
obj.rx = obj.rx + track_x_rotation
obj.ry = obj.ry + track_y_rotation
obj.rz = obj.rz + track_z_rotation
