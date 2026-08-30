--label:${ROOT_CATEGORY}\変形
---$track:基準X
---min=-10000
---max=10000
---step=0.1
local track_base_x = 0

---$track:基準Y
---min=-10000
---max=10000
---step=0.1
local track_base_y = 0

---$track:移動X
---min=-10000
---max=10000
---step=0.1
local track_move_x = 100

---$track:移動Y
---min=-10000
---max=10000
---step=0.1
local track_move_y = 100

---$track:影響範囲
---min=0
---max=10000
---step=1
local track_affect_radius = 200

---$track:被影響範囲
---min=0
---max=10000
---step=1
local track_falloff_radius = 200

---$select:移動座標
---絶対=0
---相対=1
local select_move_coordinates = 1

---$track:分割数
---min=1
---max=300
---step=1
local track_division_count = 30

---$check:境界固定
local check_fix_boundary = false

---$check:パス表示
local check_show_path = false

---$color:移動色
local move_color = 0xff0000

---$color:影響範囲色
local affect_color = 0x00ff00

---$color:被影響範囲色
local falloff_color = 0x0000ff

---$color:文字色
local text_color = 0xff00ff

---$track:表示サイズ
---min=1
---max=500
---step=1
local track_display_size = 50

---$track:線幅
---min=1
---max=100
---step=1
local track_line_width = 3

---$check:中心XY基準
local check_center_xy_base = false

--hide@move_color:check_show_path==0
--hide@affect_color:check_show_path==0
--hide@falloff_color:check_show_path==0
--hide@text_color:check_show_path==0
--hide@track_display_size:check_show_path==0
--hide@track_line_width:check_show_path==0

local is_enabled = function(value)
    return value == true or value == 1
end

obj.setanchor("track_base_x,track_base_y", 1)

local influence_curve = function(normalized_distance)
    if normalized_distance >= 1 then
        return 0
    else
        return (2 * normalized_distance + 1) * (normalized_distance - 1) ^ 2
    end
end

if T_SIMPLE_WARP_POINT_COUNT then
    T_SIMPLE_WARP_POINT_COUNT = T_SIMPLE_WARP_POINT_COUNT + 1
else
    T_SIMPLE_WARP_POINT_COUNT = 1
    T_SIMPLE_WARP_BASE_X = {}
    T_SIMPLE_WARP_BASE_Y = {}
    T_SIMPLE_WARP_TARGET_X = {}
    T_SIMPLE_WARP_TARGET_Y = {}
    T_SIMPLE_WARP_AFFECT_RADIUS = {}
    T_SIMPLE_WARP_FALLOFF_RADIUS = {}
end

T_SIMPLE_WARP_BASE_X[T_SIMPLE_WARP_POINT_COUNT] = track_base_x
T_SIMPLE_WARP_BASE_Y[T_SIMPLE_WARP_POINT_COUNT] = track_base_y
T_SIMPLE_WARP_TARGET_X[T_SIMPLE_WARP_POINT_COUNT] = track_move_x
T_SIMPLE_WARP_TARGET_Y[T_SIMPLE_WARP_POINT_COUNT] = track_move_y
if select_move_coordinates == 1 then
    T_SIMPLE_WARP_TARGET_X[T_SIMPLE_WARP_POINT_COUNT] = T_SIMPLE_WARP_TARGET_X[T_SIMPLE_WARP_POINT_COUNT]
        + T_SIMPLE_WARP_BASE_X[T_SIMPLE_WARP_POINT_COUNT]
    T_SIMPLE_WARP_TARGET_Y[T_SIMPLE_WARP_POINT_COUNT] = T_SIMPLE_WARP_TARGET_Y[T_SIMPLE_WARP_POINT_COUNT]
        + T_SIMPLE_WARP_BASE_Y[T_SIMPLE_WARP_POINT_COUNT]
end
T_SIMPLE_WARP_AFFECT_RADIUS[T_SIMPLE_WARP_POINT_COUNT] = track_affect_radius
T_SIMPLE_WARP_FALLOFF_RADIUS[T_SIMPLE_WARP_POINT_COUNT] = track_falloff_radius

if obj.getoption("script_name") ~= obj.getoption("script_name", 1) then
    local width, height = obj.getpixel()
    local original_origin_x = obj.ox
    local original_origin_y = obj.oy
    local original_origin_z = obj.oz
    local original_center_x = obj.cx
    local original_center_y = obj.cy
    local original_center_z = obj.cz

    local half_width = width / 2
    local half_height = height / 2

    if is_enabled(check_center_xy_base) then
        for k = 1, T_SIMPLE_WARP_POINT_COUNT do
            T_SIMPLE_WARP_BASE_X[k] = T_SIMPLE_WARP_BASE_X[k] + original_center_x
            T_SIMPLE_WARP_BASE_Y[k] = T_SIMPLE_WARP_BASE_Y[k] + original_center_y
            T_SIMPLE_WARP_TARGET_X[k] = T_SIMPLE_WARP_TARGET_X[k] + original_center_x
            T_SIMPLE_WARP_TARGET_Y[k] = T_SIMPLE_WARP_TARGET_Y[k] + original_center_y
        end
    end

    obj.setoption("drawtarget", "tempbuffer", width, height)
    obj.setoption("blend", "alpha_add")

    local cell_width = width / track_division_count
    local cell_height = height / track_division_count

    local displacement_x = {}
    local displacement_y = {}
    for i = 0, track_division_count do
        displacement_x[i] = {}
        displacement_y[i] = {}
        for j = 0, track_division_count do
            displacement_x[i][j] = 0
            displacement_y[i][j] = 0
        end
    end

    -- ズレ量を計算
    for i = 0, track_division_count do
        local grid_x = i * cell_width - half_width
        for j = 0, track_division_count do
            local accumulated_x = 0
            local accumulated_y = 0

            local grid_y = j * cell_height - half_height
            for control_point_index = 1, T_SIMPLE_WARP_POINT_COUNT do
                local distance = (
                    (grid_x - T_SIMPLE_WARP_BASE_X[control_point_index]) ^ 2
                    + (grid_y - T_SIMPLE_WARP_BASE_Y[control_point_index]) ^ 2
                ) ^ 0.5

                local influence = influence_curve(distance / T_SIMPLE_WARP_AFFECT_RADIUS[control_point_index])
                if is_enabled(check_fix_boundary) then -- 境界補正
                    if grid_x < T_SIMPLE_WARP_BASE_X[control_point_index] then
                        influence = influence
                            * influence_curve(
                                (T_SIMPLE_WARP_BASE_X[control_point_index] - grid_x)
                                    / (T_SIMPLE_WARP_BASE_X[control_point_index] + half_width)
                            )
                    else
                        influence = influence
                            * influence_curve(
                                (T_SIMPLE_WARP_BASE_X[control_point_index] - grid_x)
                                    / (T_SIMPLE_WARP_BASE_X[control_point_index] - half_width)
                            )
                    end
                    if grid_y < T_SIMPLE_WARP_BASE_Y[control_point_index] then
                        influence = influence
                            * influence_curve(
                                (T_SIMPLE_WARP_BASE_Y[control_point_index] - grid_y)
                                    / (T_SIMPLE_WARP_BASE_Y[control_point_index] + half_height)
                            )
                    else
                        influence = influence
                            * influence_curve(
                                (T_SIMPLE_WARP_BASE_Y[control_point_index] - grid_y)
                                    / (T_SIMPLE_WARP_BASE_Y[control_point_index] - half_height)
                            )
                    end
                end

                local isolation_weight = 1
                for k = 1, T_SIMPLE_WARP_POINT_COUNT do
                    if k ~= control_point_index then
                        local other_distance = (
                            (grid_x - T_SIMPLE_WARP_BASE_X[k]) ^ 2 + (grid_y - T_SIMPLE_WARP_BASE_Y[k]) ^ 2
                        ) ^ 0.5
                        isolation_weight = isolation_weight
                            * (1 - influence_curve(other_distance / T_SIMPLE_WARP_FALLOFF_RADIUS[k]))
                    end
                end

                if distance > 0 then
                    accumulated_x = accumulated_x
                        + influence
                            * (T_SIMPLE_WARP_TARGET_X[control_point_index] - T_SIMPLE_WARP_BASE_X[control_point_index])
                            * isolation_weight
                    accumulated_y = accumulated_y
                        + influence
                            * (T_SIMPLE_WARP_TARGET_Y[control_point_index] - T_SIMPLE_WARP_BASE_Y[control_point_index])
                            * isolation_weight
                else
                    accumulated_x = T_SIMPLE_WARP_TARGET_X[control_point_index]
                        - T_SIMPLE_WARP_BASE_X[control_point_index]
                    accumulated_y = T_SIMPLE_WARP_TARGET_Y[control_point_index]
                        - T_SIMPLE_WARP_BASE_Y[control_point_index]
                end
                if distance == 0 then
                    break
                end
            end --s
            displacement_x[i][j] = accumulated_x
            displacement_y[i][j] = accumulated_y
        end
    end

    -- 表示
    local polygons = {}
    for i = 0, track_division_count - 1 do
        local u0 = i * cell_width
        local u1 = (i + 1) * cell_width
        for j = 0, track_division_count - 1 do
            local v0 = j * cell_height
            local v1 = (j + 1) * cell_height

            local px0 = u0 + displacement_x[i][j] - half_width
            local px1 = u1 + displacement_x[i + 1][j] - half_width
            local px2 = u1 + displacement_x[i + 1][j + 1] - half_width
            local px3 = u0 + displacement_x[i][j + 1] - half_width

            local py0 = v0 + displacement_y[i][j] - half_height
            local py1 = v0 + displacement_y[i + 1][j] - half_height
            local py2 = v1 + displacement_y[i + 1][j + 1] - half_height
            local py3 = v1 + displacement_y[i][j + 1] - half_height

            table.insert(
                polygons,
                { px0, py0, 0, px1, py1, 0, px2, py2, 0, px3, py3, 0, u0, v0, u1, v0, u1, v1, u0, v1 }
            )
        end
    end
    obj.drawpoly(polygons)

    -- 枠表示
    if is_enabled(check_show_path) and obj.getinfo("saving") == false then
        for i = 1, T_SIMPLE_WARP_POINT_COUNT do
            obj.load("figure", "円", move_color, track_display_size)
            obj.draw(T_SIMPLE_WARP_TARGET_X[i], T_SIMPLE_WARP_TARGET_Y[i], 0)

            local path_length = (
                (T_SIMPLE_WARP_BASE_X[i] - T_SIMPLE_WARP_TARGET_X[i]) ^ 2
                + (T_SIMPLE_WARP_BASE_Y[i] - T_SIMPLE_WARP_TARGET_Y[i]) ^ 2
            ) ^ 0.5
            local u1 = track_display_size / 2 * (T_SIMPLE_WARP_BASE_Y[i] - T_SIMPLE_WARP_TARGET_Y[i]) / path_length
                + T_SIMPLE_WARP_BASE_X[i]
            local v1 = track_display_size / 2 * (T_SIMPLE_WARP_TARGET_X[i] - T_SIMPLE_WARP_BASE_X[i]) / path_length
                + T_SIMPLE_WARP_BASE_Y[i]
            local u2 = -track_display_size / 2 * (T_SIMPLE_WARP_BASE_Y[i] - T_SIMPLE_WARP_TARGET_Y[i]) / path_length
                + T_SIMPLE_WARP_BASE_X[i]
            local v2 = -track_display_size / 2 * (T_SIMPLE_WARP_TARGET_X[i] - T_SIMPLE_WARP_BASE_X[i]) / path_length
                + T_SIMPLE_WARP_BASE_Y[i]

            obj.load("figure", "四角形", move_color, 100)
            obj.drawpoly(
                u1,
                v1,
                0,
                T_SIMPLE_WARP_TARGET_X[i],
                T_SIMPLE_WARP_TARGET_Y[i],
                0,
                T_SIMPLE_WARP_TARGET_X[i],
                T_SIMPLE_WARP_TARGET_Y[i],
                0,
                u2,
                v2,
                0,
                0,
                0,
                width,
                0,
                width,
                height,
                0,
                height
            )

            obj.setfont("", track_display_size * 2, 1, text_color, 0x0)
            obj.load("text", i)
            obj.draw(T_SIMPLE_WARP_BASE_X[i], T_SIMPLE_WARP_BASE_Y[i], 0)

            obj.load("figure", "円", affect_color, 2 * T_SIMPLE_WARP_AFFECT_RADIUS[i], track_line_width)
            obj.draw(T_SIMPLE_WARP_BASE_X[i], T_SIMPLE_WARP_BASE_Y[i], 0)

            obj.load("figure", "円", falloff_color, 2 * T_SIMPLE_WARP_FALLOFF_RADIUS[i], track_line_width)
            obj.draw(T_SIMPLE_WARP_BASE_X[i], T_SIMPLE_WARP_BASE_Y[i], 0)
        end
    end

    T_SIMPLE_WARP_POINT_COUNT = 0
    obj.load("tempbuffer")
    obj.ox = original_origin_x
    obj.oy = original_origin_y
    obj.oz = original_origin_z
    obj.cx = original_center_x
    obj.cy = original_center_y
    obj.cz = original_center_z
end
