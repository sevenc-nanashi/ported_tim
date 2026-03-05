--label:tim2\輪郭追跡.anm\輪郭追跡拡張機能
---$track:破線周期
---min=0
---max=100
---step=0.01
local rename_me_track0 = 5

---$track:破線間隔
---min=0
---max=100
---step=0.01
local rename_me_track1 = 2.5

---$track:滑らかさ
---min=0
---max=1000
---step=1
local rename_me_track2 = 0

---$track:本体透明度
---min=0
---max=100
---step=0.1
local rename_me_track3 = 0

---$value:形状/fig
local fig = "円"

---$value:進行方向/chk
local td = 0

---$value:先端表示/chk
local senp = 0

---$value:先端図形/fig
local senz = "三角形"

---$value:先端サイズ
local sens = 50

Trin_ehn = {}
Trin_ehn.ivf = rename_me_track0 * 0.01
Trin_ehn.ivl = rename_me_track1 * 0.01
Trin_ehn.sm = math.floor(rename_me_track2)
Trin_ehn.halp = 1 - rename_me_track3 * 0.01
Trin_ehn.fig = fig
Trin_ehn.td = td
Trin_ehn.senp = senp
Trin_ehn.senz = senz
Trin_ehn.sens = sens
