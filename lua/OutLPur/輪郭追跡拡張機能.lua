--label:tim2\輪郭追跡.anm
---$track:破線周期
---min=0
---max=100
---step=0.01
local track_line_period = 5

---$track:破線間隔
---min=0
---max=100
---step=0.01
local track_line_spacing = 2.5

---$track:滑らかさ
---min=0
---max=1000
---step=1
local track_smoothness = 0

---$track:本体透明度
---min=0
---max=100
---step=0.1
local track_opacity = 0

---$figure:形状
local fig = "円"

---$check:進行方向
local td = 0

---$check:先端表示
local senp = 0

---$figure:先端図形
local senz = "三角形"

---$value:先端サイズ
local sens = 50

Trin_ehn = {}
Trin_ehn.ivf = track_line_period * 0.01
Trin_ehn.ivl = track_line_spacing * 0.01
Trin_ehn.sm = math.floor(track_smoothness)
Trin_ehn.halp = 1 - track_opacity * 0.01
Trin_ehn.fig = fig
Trin_ehn.td = td
Trin_ehn.senp = senp
Trin_ehn.senz = senz
Trin_ehn.sens = sens
