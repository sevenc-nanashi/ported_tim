--label:tim2\装飾\罫線T.anm
---$track:斜線数
---min=1
---max=16
---step=1
local track_line_count = 1

---$track:線幅
---min=1
---max=500
---step=1
local track_line_width = 6

---$track:長さ%
---min=0
---max=200
---step=0.1
local track_length_percent = 100

---$track:形状
---min=0
---max=2
---step=1
local track_shape = 0

---$color:線色
local Scl = 0xffffff

---$value:アンカー
local posSL = { 0, 0 }

RuledlineT = RuledlineT or {}
local apnum = track_line_count
obj.setanchor("posSL", apnum)
RuledlineT.SLX = RuledlineT.SLX or {}
RuledlineT.SLY = RuledlineT.SLY or {}
RuledlineT.Scl = RuledlineT.Scl or {}
RuledlineT.SLC = RuledlineT.SLC or {}
RuledlineT.Sdw = RuledlineT.Sdw or {}
RuledlineT.Pdw = RuledlineT.Pdw or {}
local num = (#RuledlineT.SLX or 0) + 1
RuledlineT.Scl[num] = Scl
RuledlineT.Sdw[num] = track_line_width
RuledlineT.Pdw[num] = (1 - track_length_percent * 0.01) * 0.5
RuledlineT.SLC[num] = math.floor(track_shape)
RuledlineT.SLX[num] = {}
RuledlineT.SLY[num] = {}
for k = 1, apnum do
    RuledlineT.SLX[num][k] = posSL[2 * k - 1]
    RuledlineT.SLY[num][k] = posSL[2 * k]
end
