--label:${ROOT_CATEGORY}\装飾\@罫線T
---$track:サイズ
---min=0
---max=500
---step=1
local track_cell_size = 100

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

---$track:縦横比[%]
---min=-100
---max=100
---step=0.1
local track_aspect_ratio_percent = -38.2

T_RULED_LINE_STATE = T_RULED_LINE_STATE or {}
T_RULED_LINE_STATE.definition = {}
local ruled_line = T_RULED_LINE_STATE.definition
ruled_line.type = 1
ruled_line.cell_width = track_cell_size
ruled_line.horizontal_count = math.floor(track_horizontal_count)
ruled_line.vertical_count = math.floor(track_vertical_count)
ruled_line.aspect_ratio = track_aspect_ratio_percent * 0.01
ruled_line.vertical_line_x_positions = {}
ruled_line.horizontal_line_y_positions = {}
ruled_line.center_x = 0
ruled_line.center_y = 0
