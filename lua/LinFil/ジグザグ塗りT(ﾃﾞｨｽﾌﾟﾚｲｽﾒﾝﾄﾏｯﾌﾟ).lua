--label:tim2\ジグザグ塗りT.anm\ジグザグ塗りT(ﾃﾞｨｽﾌﾟﾚｲｽﾒﾝﾄﾏｯﾌﾟ)
---$track:MAPﾚｲﾔ
---min=1
---max=100
---step=1
local rename_me_track0 = 1

---$track:変形X
---min=-500
---max=500
---step=0.1
local rename_me_track1 = 10

---$track:変形Y
---min=-500
---max=500
---step=0.1
local rename_me_track2 = 10

---$track:変形方法
---min=0
---max=2
---step=1
local rename_me_track3 = 0

---$value:ぼかし
local BL = 5

---$value:領域拡張X
local DX = 0

---$value:領域拡張Y
local DY = 0

---$check:MAPサイズ調整
local rename_me_check0 = true

T_LineFill = T_LineFill or {}
T_LineFill.Ly = math.floor(rename_me_track0)
T_LineFill.X = rename_me_track1
T_LineFill.Y = rename_me_track2
T_LineFill.C = rename_me_track3
T_LineFill.BL = BL
T_LineFill.DX = DX
T_LineFill.DY = DY
T_LineFill.RS = rename_me_check0
