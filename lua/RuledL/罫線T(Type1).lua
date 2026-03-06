--label:tim2\未分類\罫線T.anm
---$track:サイズ
---min=0
---max=500
---step=1
local track_size = 100

---$track:横数
---min=1
---max=100
---step=1
local track_horizontal_count = 4

---$track:縦数
---min=1
---max=100
---step=1
local track_vertical_count = 4

---$track:縦横比%
---min=-100
---max=100
---step=0.1
local track_aspect_ratio_percent = -38.2

RuledlineT = RuledlineT or {}
RuledlineT.typ = 1
RuledlineT.dw = track_size
RuledlineT.nx = math.floor(track_horizontal_count)
RuledlineT.ny = math.floor(track_vertical_count)
RuledlineT.asp = track_aspect_ratio_percent * 0.01
RuledlineT.LPX = {}
RuledlineT.LPY = {}
RuledlineT.cx = 0
RuledlineT.cy = 0
