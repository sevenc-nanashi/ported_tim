--label:${ROOT_CATEGORY}\装飾\@罫線T
---$track:開始位置
---min=1
---max=1000
---step=1
local track_start_position = 1

---$track:終了位置(0で単独)
---min=0
---max=1000
---step=1
local track_end_position = 0

---$track:サイズ補正[%]
---min=0
---max=1000
---step=0.1
local track_size_adjust_percent = 100

---$check:行列反転
local check_reverse_rows_columns = false

---$check:サイズ自動調整
local check_auto_size_adjust = false

--group:自動配置
---$check:自動配置::自動配置
local check_auto_place = false

---$select:配置順
---左上=0
---右上=1
---左下=2
---右下=3
local select_order = 0

---$check:最終オブジェクト
local check_last_object = false
--group:

--hide@track_start_position:check_auto_place==1
--hide@track_end_position:check_auto_place==1
--hide@select_order:check_auto_place==0
--hide@check_last_object:check_auto_place==0

local is_enabled = function(value)
    return value == true or value == 1
end

local calculate_grid_position = function(object_index, horizontal_count, vertical_count, is_reverse_order)
    local i, j
    if is_reverse_order then
        j = object_index % vertical_count
        i = (object_index - j) / vertical_count
    else
        i = object_index % horizontal_count
        j = (object_index - i) / horizontal_count
    end
    return i + 1, j + 1
end
local ruled_line_state = T_RULED_LINE_STATE
local coordinates = ruled_line_state.coordinates
local horizontal_count = #coordinates.x_positions - 1
local vertical_count = #coordinates.y_positions - 1
local is_reverse_order = is_enabled(check_reverse_rows_columns)
local start_object_index = math.floor(track_start_position - 1)
local end_object_index = math.floor(track_end_position - 1)
local start_column, start_row, end_column, end_row
if not is_enabled(check_auto_place) then
    start_object_index = start_object_index % (horizontal_count * vertical_count)
    end_object_index = end_object_index % (horizontal_count * vertical_count)
    start_column, start_row =
        calculate_grid_position(start_object_index, horizontal_count, vertical_count, is_reverse_order)
    if track_end_position > 0 then
        end_column, end_row =
            calculate_grid_position(end_object_index, horizontal_count, vertical_count, is_reverse_order)
        start_column, end_column = math.min(start_column, end_column), math.max(start_column, end_column)
        start_row, end_row = math.min(start_row, end_row), math.max(start_row, end_row)
    else
        end_column, end_row = start_column, start_row
    end
else
    local order_index = (select_order or 0) % 4
    ruled_line_state.auto_placement_index = (ruled_line_state.auto_placement_index or -1) + 1
    start_object_index = ruled_line_state.auto_placement_index % (horizontal_count * vertical_count)
    start_column, start_row =
        calculate_grid_position(start_object_index, horizontal_count, vertical_count, is_reverse_order)
    if order_index == 1 or order_index == 3 then
        start_column = horizontal_count - start_column + 1
    end
    if order_index == 2 or order_index == 3 then
        start_row = vertical_count - start_row + 1
    end
    end_column, end_row = start_column, start_row
    if is_enabled(check_last_object) then
        ruled_line_state.auto_placement_index = nil
    end
end
local placement_x = (coordinates.x_positions[start_column] + coordinates.x_positions[end_column + 1]) * 0.5
local placement_y = (coordinates.y_positions[start_row] + coordinates.y_positions[end_row + 1]) * 0.5
local scale_ratio = track_size_adjust_percent * 0.01
if is_enabled(check_auto_size_adjust) then
    local w, h = obj.getpixel()
    local target_width = coordinates.x_positions[end_column + 1] - coordinates.x_positions[start_column]
    local target_height = coordinates.y_positions[end_row + 1] - coordinates.y_positions[start_row]
    scale_ratio = scale_ratio * math.min(target_width / w, target_height / h, 1)
end
obj.draw(placement_x + coordinates.center_x, placement_y + coordinates.center_y, 0, scale_ratio)
