--label:${ROOT_CATEGORY}\装飾\@罫線T
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

T_RULED_LINE_STATE = T_RULED_LINE_STATE or {}
T_RULED_LINE_STATE.definition = T_RULED_LINE_STATE.definition or {}
local ruled_line = T_RULED_LINE_STATE.definition
local anchor_count = track_line_count
obj.setanchor("line_anchors", anchor_count)
ruled_line.diagonal_anchor_x_groups = ruled_line.diagonal_anchor_x_groups or {}
ruled_line.diagonal_anchor_y_groups = ruled_line.diagonal_anchor_y_groups or {}
ruled_line.diagonal_colors = ruled_line.diagonal_colors or {}
ruled_line.diagonal_shapes = ruled_line.diagonal_shapes or {}
ruled_line.diagonal_widths = ruled_line.diagonal_widths or {}
ruled_line.diagonal_padding_ratios = ruled_line.diagonal_padding_ratios or {}
local line_index = (#ruled_line.diagonal_anchor_x_groups or 0) + 1
ruled_line.diagonal_colors[line_index] = line_color
ruled_line.diagonal_widths[line_index] = track_line_width
ruled_line.diagonal_padding_ratios[line_index] = (1 - track_length_percent * 0.01) * 0.5
ruled_line.diagonal_shapes[line_index] = math.floor(select_shape)
ruled_line.diagonal_anchor_x_groups[line_index] = {}
ruled_line.diagonal_anchor_y_groups[line_index] = {}
for anchor_index = 1, anchor_count do
    ruled_line.diagonal_anchor_x_groups[line_index][anchor_index] = line_anchors[2 * anchor_index - 1]
    ruled_line.diagonal_anchor_y_groups[line_index][anchor_index] = line_anchors[2 * anchor_index]
end
