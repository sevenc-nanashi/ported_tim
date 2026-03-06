--label:tim2\オブジェクト制御\グループ補助.anm
---$track:X
---min=-20000
---max=20000
---step=0.1
local track_x = 0

---$track:Y
---min=-20000
---max=20000
---step=0.1
local track_y = 0

---$track:Z
---min=-20000
---max=20000
---step=0.1
local track_z = 0

---$track:拡大率
---min=0
---max=5000
---step=0.1
local track_scale = 100

obj.ox = obj.ox + track_x
obj.oy = obj.oy + track_y
obj.oz = obj.oz + track_z
obj.zoom = obj.zoom * track_scale * 0.01
