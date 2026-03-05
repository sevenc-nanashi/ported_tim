--label:tim2\ジグザグ塗りT.anm
---$track:MAPﾚｲﾔ
---min=1
---max=100
---step=1
local track_map = 1

---$track:変形X
---min=-500
---max=500
---step=0.1
local track_deform_x = 10

---$track:変形Y
---min=-500
---max=500
---step=0.1
local track_deform_y = 10

---$track:変形方法
---min=0
---max=2
---step=1
local track_deform_method = 0

---$value:ぼかし
local BL = 5

---$value:領域拡張X
local DX = 0

---$value:領域拡張Y
local DY = 0

---$check:MAPサイズ調整
local check0 = true

T_LineFill = T_LineFill or {}
T_LineFill.Ly = math.floor(track_map)
T_LineFill.X = track_deform_x
T_LineFill.Y = track_deform_y
T_LineFill.C = track_deform_method
T_LineFill.BL = BL
T_LineFill.DX = DX
T_LineFill.DY = DY
T_LineFill.RS = check0
