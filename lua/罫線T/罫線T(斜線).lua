--label:tim2\装飾\@罫線T
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

---$track:長さ[%]
---min=0
---max=200
---step=0.1
local track_length_percent = 100

---$select:形状
---右上がり=0
---右下がり=1
---交差=2
local select_shape = 0

---$color:線色
local line_color = 0xffffff

---$value:斜線アンカー
local line_anchors = { 0, 0 }

RuledlineT = RuledlineT or {}
local anchor_count = track_line_count
obj.setanchor("line_anchors", anchor_count)
RuledlineT.SLX = RuledlineT.SLX or {}
RuledlineT.SLY = RuledlineT.SLY or {}
RuledlineT.Scl = RuledlineT.Scl or {}
RuledlineT.SLC = RuledlineT.SLC or {}
RuledlineT.Sdw = RuledlineT.Sdw or {}
RuledlineT.Pdw = RuledlineT.Pdw or {}
local line_index = (#RuledlineT.SLX or 0) + 1
RuledlineT.Scl[line_index] = line_color
RuledlineT.Sdw[line_index] = track_line_width
RuledlineT.Pdw[line_index] = (1 - track_length_percent * 0.01) * 0.5
RuledlineT.SLC[line_index] = math.floor(select_shape)
RuledlineT.SLX[line_index] = {}
RuledlineT.SLY[line_index] = {}
for k = 1, anchor_count do
    RuledlineT.SLX[line_index][k] = line_anchors[2 * k - 1]
    RuledlineT.SLY[line_index][k] = line_anchors[2 * k]
end
