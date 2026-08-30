--label:${ROOT_CATEGORY}\装飾\@罫線T
---$track:制御点数
---min=1
---max=16
---step=1
local track_control_point_count = 4

---$track:スナップX
---min=1
---max=500
---step=1
local track_snap_x = 30

---$track:スナップY
---min=1
---max=500
---step=1
local track_snap_y = 30

---$value:制御点座標
local control_points = { -30, -80, 80, -80, -140, 74, -130, 0 }

T_RULED_LINE_STATE = T_RULED_LINE_STATE or {}
T_RULED_LINE_STATE.definition = {}
local ruled_line = T_RULED_LINE_STATE.definition
ruled_line.type = 2
local control_point_count = math.floor(track_control_point_count)
local snap_x = track_snap_x
local snap_y = track_snap_y
obj.setanchor("control_points", control_point_count)
local snapped_x_positions = {}
local snapped_y_positions = {}
for i = 1, control_point_count do
    snapped_x_positions[i] = (math.floor(control_points[2 * i - 1] / snap_x - 0.5) + 1) * snap_x
    snapped_y_positions[i] = (math.floor(control_points[2 * i] / snap_y - 0.5) + 1) * snap_y
end
local max_x = math.max(unpack(snapped_x_positions))
local min_x = math.min(unpack(snapped_x_positions))
local max_y = math.max(unpack(snapped_y_positions))
local min_y = math.min(unpack(snapped_y_positions))
ruled_line.center_x = (max_x + min_x) * 0.5
ruled_line.center_y = (max_y + min_y) * 0.5
ruled_line.total_width = max_x - min_x
ruled_line.total_height = max_y - min_y
for i = 1, control_point_count do
    snapped_x_positions[i] = snapped_x_positions[i] - ruled_line.center_x
    snapped_y_positions[i] = snapped_y_positions[i] - ruled_line.center_y
end
ruled_line.vertical_line_x_positions = {}
ruled_line.horizontal_line_y_positions = {}
ruled_line.vertical_line_x_positions[1] = -ruled_line.total_width * 0.5
ruled_line.horizontal_line_y_positions[1] = -ruled_line.total_height * 0.5
local diagonal_slope = ruled_line.total_height / ruled_line.total_width
for i = 1, control_point_count do
    if diagonal_slope * snapped_x_positions[i] > snapped_y_positions[i] then
        ruled_line.vertical_line_x_positions[#ruled_line.vertical_line_x_positions + 1] = snapped_x_positions[i]
    else
        ruled_line.horizontal_line_y_positions[#ruled_line.horizontal_line_y_positions + 1] = snapped_y_positions[i]
    end
end
table.sort(ruled_line.vertical_line_x_positions)
table.sort(ruled_line.horizontal_line_y_positions)
