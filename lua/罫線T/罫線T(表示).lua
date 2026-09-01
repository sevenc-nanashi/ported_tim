--label:${ROOT_CATEGORY}\装飾\@罫線T
---$track:線幅
---min=1
---max=500
---step=1
local track_line_width = 6

---$track:1行目高さ比[%]
---min=0
---max=500
---step=0.1
local track_first_row_height_percent = 100

---$track:1列目幅比[%]
---min=0
---max=500
---step=0.1
local track_first_column_width_percent = 100

---$track:背景透明度
---min=0
---max=100
---step=0.1
local track_opacity = 0

---$color:線色
local line_color = 0xffffff

---$check:座標保存
local check_save_coordinates = true

---$check:エッジ調整
local check_edge_adjust = false

local is_enabled = function(value)
    return value == true or value == 1
end

local ruled_line_state = T_RULED_LINE_STATE
local definition = ruled_line_state.definition
local line_width = track_line_width
local background_alpha = 1 - track_opacity * 0.01
local line_color_value = line_color or 0xffffff
local edge_adjust_factor = is_enabled(check_edge_adjust) and 1 or 0
local vertical_line_x_positions = definition.vertical_line_x_positions
local horizontal_line_y_positions = definition.horizontal_line_y_positions
local deletion_anchor_x_groups = definition.deletion_anchor_x_groups or {}
local deletion_anchor_y_groups = definition.deletion_anchor_y_groups or {}
local diagonal_anchor_x_groups = definition.diagonal_anchor_x_groups or {}
local diagonal_anchor_y_groups = definition.diagonal_anchor_y_groups or {}
local cx_value = definition.center_x
local cy_value = definition.center_y
local half_line_width = line_width * 0.5
local draw_diagonal = function(x0, y0, x1, y1, line_width, padding_ratio)
    local remaining_ratio = 1 - padding_ratio
    local normal_x, normal_y = y1 - y0, x0 - x1
    local segment_length = math.sqrt(normal_x * normal_x + normal_y * normal_y)
    normal_x, normal_y = line_width * 0.5 * normal_x / segment_length, line_width * 0.5 * normal_y / segment_length
    local u0, v0, u1, v1, u2, v2, u3, v3 =
        x0 + normal_x,
        y0 + normal_y,
        x1 + normal_x,
        y1 + normal_y,
        x1 - normal_x,
        y1 - normal_y,
        x0 - normal_x,
        y0 - normal_y
    u0, u1 = padding_ratio * u0 + remaining_ratio * u1, remaining_ratio * u0 + padding_ratio * u1
    v0, v1 = padding_ratio * v0 + remaining_ratio * v1, remaining_ratio * v0 + padding_ratio * v1
    u2, u3 = padding_ratio * u2 + remaining_ratio * u3, remaining_ratio * u2 + padding_ratio * u3
    v2, v3 = padding_ratio * v2 + remaining_ratio * v3, remaining_ratio * v2 + padding_ratio * v3
    obj.drawpoly(u0, v0, 0, u1, v1, 0, u2, v2, 0, u3, v3, 0)
end
if definition.type == 1 then
    local first_row_height = track_first_row_height_percent
    local first_column_width = track_first_column_width_percent
    local cell_width = definition.cell_width
    local cell_height = cell_width
    local horizontal_count = definition.horizontal_count
    local vertical_count = definition.vertical_count
    local aspect_ratio = definition.aspect_ratio
    if aspect_ratio > 0 then
        cell_width = cell_width * (1 - aspect_ratio)
    else
        cell_height = cell_height * (1 + aspect_ratio)
    end
    first_column_width = (definition.first_column_width or first_column_width or 100) * 0.01 * cell_width
    first_row_height = (definition.first_row_height or first_row_height or 100) * 0.01 * cell_height
    cell_height, first_row_height, first_column_width =
        math.floor(cell_height), math.floor(first_row_height), math.floor(first_column_width)
    definition.total_width = first_column_width + (horizontal_count - 1) * cell_width
    definition.total_height = first_row_height + (vertical_count - 1) * cell_height
    definition.vertical_line_x_positions[1] = -definition.total_width * 0.5
    for i = 2, horizontal_count + 1 do
        vertical_line_x_positions[i] = first_column_width + (i - 2) * cell_width - definition.total_width * 0.5
    end
    definition.horizontal_line_y_positions[1] = -definition.total_height * 0.5
    for i = 2, vertical_count + 1 do
        horizontal_line_y_positions[i] = first_row_height + (i - 2) * cell_height - definition.total_height * 0.5
    end
end
local canvas_width, canvas_height = definition.total_width + line_width, definition.total_height + line_width
obj.copybuffer("cache:bk", "object")
obj.setoption("drawtarget", "tempbuffer", canvas_width, canvas_height)
if #diagonal_anchor_x_groups > 0 then
    for group_index = 1, #diagonal_anchor_x_groups do
        obj.load("figure", "四角形", definition.diagonal_colors[group_index], 1)
        local diagonal_width = definition.diagonal_widths[group_index]
        local diagonal_padding_ratio = definition.diagonal_padding_ratios[group_index]
        local diagonal_shape = definition.diagonal_shapes[group_index]
        for anchor_index = 1, #diagonal_anchor_x_groups[group_index] do
            local x0 = diagonal_anchor_x_groups[group_index][anchor_index] - cx_value
            local y0 = diagonal_anchor_y_groups[group_index][anchor_index] - cy_value
            local column_index = -1
            local row_index = -1
            for position_index = 1, #vertical_line_x_positions - 1 do
                if
                    vertical_line_x_positions[position_index] <= x0
                    and x0 < vertical_line_x_positions[position_index + 1]
                then
                    column_index = position_index
                    break
                end
            end
            for position_index = 1, #horizontal_line_y_positions - 1 do
                if
                    horizontal_line_y_positions[position_index] <= y0
                    and y0 < horizontal_line_y_positions[position_index + 1]
                then
                    row_index = position_index
                    break
                end
            end
            if column_index > 0 and row_index > 0 then
                x0 = vertical_line_x_positions[column_index] + half_line_width
                y0 = horizontal_line_y_positions[row_index + 1] - half_line_width
                x1 = vertical_line_x_positions[column_index + 1] - half_line_width
                y1 = horizontal_line_y_positions[row_index] + half_line_width
                if diagonal_shape == 0 or diagonal_shape == 2 then
                    draw_diagonal(x0, y0, x1, y1, diagonal_width, diagonal_padding_ratio)
                end
                if diagonal_shape == 1 or diagonal_shape == 2 then
                    draw_diagonal(x0, y1, x1, y0, diagonal_width, diagonal_padding_ratio)
                end
            end
        end
    end
end
obj.load("figure", "四角形", line_color_value, 1)
local deleted_horizontal_segments = {}
local deleted_vertical_segments = {}
for i = 0, #vertical_line_x_positions do
    deleted_horizontal_segments[i] = {}
    deleted_vertical_segments[i] = {}
end
if #deletion_anchor_x_groups > 0 then
    for group_index = 1, #deletion_anchor_x_groups do
        for anchor_index = 1, #deletion_anchor_x_groups[group_index] do
            deletion_anchor_x_groups[group_index][anchor_index] = deletion_anchor_x_groups[group_index][anchor_index]
                - cx_value
            deletion_anchor_y_groups[group_index][anchor_index] = deletion_anchor_y_groups[group_index][anchor_index]
                - cy_value
        end
    end
    for group_index = 1, #deletion_anchor_x_groups do
        for anchor_index = 1, #definition.deletion_anchor_x_groups[group_index] - 1 do
            local start_column, end_column, start_row, end_row = 0, 0, 0, 0
            local x0 = deletion_anchor_x_groups[group_index][anchor_index]
            local x1 = deletion_anchor_x_groups[group_index][anchor_index + 1]
            local y0 = deletion_anchor_y_groups[group_index][anchor_index]
            local y1 = deletion_anchor_y_groups[group_index][anchor_index + 1]
            for position_index = 1, #vertical_line_x_positions - 1 do
                if
                    vertical_line_x_positions[position_index] <= x0
                    and x0 < vertical_line_x_positions[position_index + 1]
                then
                    start_column = position_index
                    break
                end
            end
            for position_index = 1, #vertical_line_x_positions - 1 do
                if
                    vertical_line_x_positions[position_index] <= x1
                    and x1 < vertical_line_x_positions[position_index + 1]
                then
                    end_column = position_index
                    break
                end
            end
            for position_index = 1, #horizontal_line_y_positions - 1 do
                if
                    horizontal_line_y_positions[position_index] <= y0
                    and y0 < horizontal_line_y_positions[position_index + 1]
                then
                    start_row = position_index
                    break
                end
            end
            for position_index = 1, #horizontal_line_y_positions - 1 do
                if
                    horizontal_line_y_positions[position_index] <= y1
                    and y1 < horizontal_line_y_positions[position_index + 1]
                then
                    end_row = position_index
                    break
                end
            end
            if vertical_line_x_positions[#vertical_line_x_positions] <= x0 then
                start_column = #vertical_line_x_positions
            end
            if vertical_line_x_positions[#vertical_line_x_positions] <= x1 then
                end_column = #vertical_line_x_positions
            end
            if horizontal_line_y_positions[#horizontal_line_y_positions] <= y0 then
                start_row = #horizontal_line_y_positions
            end
            if horizontal_line_y_positions[#horizontal_line_y_positions] <= y1 then
                end_row = #horizontal_line_y_positions
            end
            if start_column > end_column then
                start_column, end_column = end_column, start_column
            end
            if start_row > end_row then
                start_row, end_row = end_row, start_row
            end
            for i = start_column, end_column do
                for j = start_row, end_row - 1 do
                    if end_row > start_row then
                        deleted_horizontal_segments[i][j + 1] = 1
                    end
                end
            end
            for j = start_row, end_row do
                for i = start_column, end_column - 1 do
                    if end_column > start_column then
                        deleted_vertical_segments[i + 1][j] = 1
                    end
                end
            end
        end
    end
end
for j = 1, #horizontal_line_y_positions do
    local y0 = horizontal_line_y_positions[j] - half_line_width
    local y1 = horizontal_line_y_positions[j] + half_line_width
    for i = 1, #vertical_line_x_positions - 1 do
        local x0 = vertical_line_x_positions[i] - half_line_width
        local x1 = vertical_line_x_positions[i + 1] + half_line_width
        if deleted_horizontal_segments[i][j] == nil then
            obj.drawpoly(x0, y0, 0, x1, y0, 0, x1, y1, 0, x0, y1, 0)
        end
    end
end
for i = 1, #vertical_line_x_positions do
    local x0 = vertical_line_x_positions[i] - half_line_width
    local x1 = vertical_line_x_positions[i] + half_line_width
    for j = 1, #horizontal_line_y_positions - 1 do
        local y0 = horizontal_line_y_positions[j] - half_line_width
        local y1 = horizontal_line_y_positions[j + 1] + half_line_width
        if deleted_vertical_segments[i][j] == nil then
            obj.drawpoly(x0, y0, 0, x1, y0, 0, x1, y1, 0, x0, y1, 0)
        end
    end
end
obj.copybuffer("cache:img", "tempbuffer")
obj.copybuffer("object", "cache:bk")
obj.setoption("drawtarget", "tempbuffer", canvas_width, canvas_height)
obj.draw(-cx_value, -cy_value, 0, 1, background_alpha)
obj.copybuffer("object", "cache:img")
obj.draw()
obj.load("tempbuffer")
if definition.type == 1 then
    cx_value = 0.5 * ((canvas_width - obj.screen_w) % 2) * edge_adjust_factor
    cy_value = 0.5 * ((canvas_height - obj.screen_h) % 2) * edge_adjust_factor
else
    cx_value = -cx_value + 0.5 * ((line_width - obj.screen_w) % 2) * edge_adjust_factor
    cy_value = -cy_value + 0.5 * ((line_width - obj.screen_h) % 2) * edge_adjust_factor
end
obj.cx, obj.cy = cx_value, cy_value
if is_enabled(check_save_coordinates) then
    ruled_line_state.coordinates = {}
    ruled_line_state.coordinates.x_positions = vertical_line_x_positions
    ruled_line_state.coordinates.y_positions = horizontal_line_y_positions
    ruled_line_state.coordinates.center_x = -cx_value
    ruled_line_state.coordinates.center_y = -cy_value
end
ruled_line_state.definition = nil
ruled_line_state.auto_placement_index = nil
