--label:tim2\罫線T.anm
---$track:サイズ
---min=0
---max=500
---step=1
local rename_me_track0 = 100

---$track:横数
---min=1
---max=100
---step=1
local rename_me_track1 = 4

---$track:縦数
---min=1
---max=100
---step=1
local rename_me_track2 = 4

---$track:縦横比%
---min=-100
---max=100
---step=0.1
local rename_me_track3 = -38.2

RuledlineT = RuledlineT or {}
RuledlineT.typ = 1
RuledlineT.dw = rename_me_track0
RuledlineT.nx = math.floor(rename_me_track1)
RuledlineT.ny = math.floor(rename_me_track2)
RuledlineT.asp = rename_me_track3 * 0.01
RuledlineT.LPX = {}
RuledlineT.LPY = {}
RuledlineT.cx = 0
RuledlineT.cy = 0
