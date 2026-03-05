--label:tim2\ジグザグ塗りT.anm
---$track:角度
---min=-3600
---max=3600
---step=0.1
local track_angle = 20

---$track:本体α
---min=0
---max=100
---step=0.1
local track_alpha = 100

---$track:ラインα
---min=0
---max=100
---step=0.1
local track_alpha_2 = 100

---$track:ぼかし
---min=0
---max=500
---step=1
local track_blur = 0

T_LineFill = T_LineFill or {}
T_LineFill.K = track_angle
T_LineFill.OgA = track_alpha
T_LineFill.LnA = track_alpha_2
T_LineFill.B = track_blur
