--label:${ROOT_CATEGORY}\色調整
---$track:サイズX
---min=50
---max=1000
---step=0.1
local track_size_x = 600

---$track:サイズY
---min=50
---max=1000
---step=0.1
local track_size_y = 200

---$track:表示方式
---min=-1
---max=2
---step=1
local track_display_mode = 0

---$track:赤凹凸
---min=-30
---max=30
---step=0.01
local track_red_bump = 0

---$track:緑凹凸
---min=-30
---max=30
---step=0.01
local track_green_bump = 0

---$track:青凹凸
---min=-30
---max=30
---step=0.01
local track_blue_bump = 0

---$check:Rのみ設定
local check_set_red_only = 0

---$check:Gのみ設定
local check_set_green_only = 0

---$check:Bのみ設定
local check_set_blue_only = 0

---$value:カーブ
local curve_points = { -280, 80, -200, 0, -120, -80, -80, 80, 0, 0, 80, -80, 120, 80, 200, 0, 280, -80 }

---$track:表示精度
---min=1
---max=100
---step=1
local track_display_precision = 20

---$check:カーブ表示
local check_show_curve = true

-- require("T_Color_Module")
local color_module = obj.module("tim2")
local draw_tone_curve = function(
    channel,
    point_index,
    canvas_width,
    canvas_height,
    offset_x,
    offset_y,
    curve_color,
    show_curve,
    bump_amount,
    curve_type
)
    local half_canvas_width = canvas_width * 0.5
    local half_canvas_height = canvas_height * 0.5
    local graph_half_width = canvas_width * 0.4
    local graph_half_height = canvas_height * 0.4
    local graph_width = canvas_width * 0.8
    local graph_height = canvas_height * 0.8
    if show_curve then
        obj.load("figure", "四角形", 0xffffff, 1)
        obj.drawpoly(
            -half_canvas_width + offset_x - 1,
            -half_canvas_height + offset_y,
            0,
            half_canvas_width + offset_x + 1,
            -half_canvas_height + offset_y,
            0,
            half_canvas_width + offset_x + 1,
            half_canvas_height + offset_y,
            0,
            -half_canvas_width + offset_x - 1,
            half_canvas_height + offset_y,
            0
        )
    end
    if curve_type >= 0 then
        local graph_left = offset_x - graph_half_width
        local graph_top = offset_y - graph_half_height
        local x0, y0 =
            (curve_points[point_index] - graph_left) / graph_width,
            (curve_points[point_index + 1] - graph_top) / graph_height
        local x1, y1 =
            (curve_points[point_index + 2] - graph_left) / graph_width,
            (curve_points[point_index + 3] - graph_top) / graph_height
        local x2, y2 =
            (curve_points[point_index + 4] - graph_left) / graph_width,
            (curve_points[point_index + 5] - graph_top) / graph_height
        if x0 > x1 then
            x0, x1 = x1, x0
            y0, y1 = y1, y0
        end
        if x1 > x2 then
            x1, x2 = x2, x1
            y1, y2 = y2, y1
            if x0 > x2 then
                x0, x2 = x2, x0
                y0, y2 = y2, y0
            end
        end
        local curve_parameters
        if curve_type == 0 then
            y0 = y0 + bump_amount * x0 * x0 * x0
            y1 = y1 + bump_amount * x1 * x1 * x1
            y2 = y2 + bump_amount * x2 * x2 * x2
            local first_slope = (y1 - y0) / (x1 - x0)
            local second_slope = (y2 - y0) / (x2 - x0)
            local quadratic_coefficient = (first_slope - second_slope) / (x1 - x2)
            local linear_coefficient = first_slope - quadratic_coefficient * (x1 + x0)
            local constant_coefficient = y0 - quadratic_coefficient * x0 * x0 - linear_coefficient * x0
            curve_parameters = {
                curve_type,
                bump_amount,
                -quadratic_coefficient,
                -linear_coefficient,
                1 - constant_coefficient,
                0,
                0,
                0,
            }
        elseif curve_type == 1 then
            local left_slope = (y1 - y0) / (x1 - x0)
            local left_intercept = y0 - left_slope * x0 - bump_amount / 20
            local right_slope = (y2 - y1) / (x2 - x1)
            local right_intercept = y1 - right_slope * x1 + bump_amount / 20
            curve_parameters =
                { curve_type, -left_slope, 1 - left_intercept, -right_slope, 1 - right_intercept, x1, 0, 0 }
        elseif curve_type == 2 then
            local left_width, full_width, right_width = x1 - x0, x2 - x0, x2 - x1
            local left_slope, center_slope, right_slope =
                (y1 - y0) / left_width, (y2 - y0) / full_width, (y2 - y1) / right_width
            if bump_amount ~= 0 then
                local center_angle = bump_amount / 10 + math.atan2(y2 - y0, full_width)
                center_slope = math.tan(center_angle)
            end
            local left_quadratic = (center_slope - left_slope) / left_width
            local left_linear = center_slope - 2 * x1 * left_quadratic
            local left_constant = y1 - (left_quadratic * x1 + left_linear) * x1
            local right_quadratic = -(center_slope - right_slope) / right_width
            local right_linear = center_slope - 2 * x1 * right_quadratic
            local right_constant = y1 - (right_quadratic * x1 + right_linear) * x1
            curve_parameters = {
                curve_type,
                -left_quadratic,
                -left_linear,
                1 - left_constant,
                -right_quadratic,
                -right_linear,
                1 - right_constant,
                x1,
            }
        end
        color_module.color_set_tone_curve(channel, unpack(curve_parameters))
    end
    if show_curve then
        obj.load("figure", "四角形", curve_color, 1)
        obj.effect("リサイズ", "ドット数でサイズ指定", 1, "X", 256, "Y", 2 * graph_height)
        local pixel_data, width, height = obj.getpixeldata("object", "bgra")
        color_module.color_draw_tone_curve(pixel_data, width, height, channel, curve_color)
        obj.putpixeldata("object", pixel_data, width, height, "bgra")
        obj.effect("リサイズ", "ドット数でサイズ指定", 1, "X", graph_width, "Y", graph_height)
        obj.draw(offset_x, offset_y)
    end
end
local canvas_width, canvas_height = track_size_x, track_size_y
local red_bump = track_red_bump
local green_bump = track_green_bump or 0
local blue_bump = track_blue_bump or 0
local curve_type = track_display_mode
check_set_red_only = check_set_red_only or 0
check_set_green_only = check_set_green_only or 0
check_set_blue_only = check_set_blue_only or 0
if check_set_red_only == 1 or check_set_green_only == 1 or check_set_blue_only == 1 then
    if check_show_curve then
        obj.setanchor("curve_points", 3)
    end
    obj.setoption("drawtarget", "tempbuffer", canvas_width / 3, canvas_height)
    if check_set_red_only == 1 then
        draw_tone_curve(0, 1, canvas_width / 3, canvas_height, 0, 0, 0xff0000, check_show_curve, red_bump, curve_type)
        T_TONE_CURVE_R = 1
    elseif check_set_green_only == 1 then
        draw_tone_curve(1, 1, canvas_width / 3, canvas_height, 0, 0, 0x00ff00, check_show_curve, red_bump, curve_type)
        T_TONE_CURVE_G = 1
    else
        draw_tone_curve(2, 1, canvas_width / 3, canvas_height, 0, 0, 0x0000ff, check_show_curve, red_bump, curve_type)
        T_TONE_CURVE_B = 1
    end
else
    T_TONE_CURVE_R = 1
    T_TONE_CURVE_G = 1
    T_TONE_CURVE_B = 1
    if check_show_curve then
        obj.setanchor("curve_points", 9)
    end
    obj.setoption("drawtarget", "tempbuffer", canvas_width, canvas_height)
    draw_tone_curve(
        0,
        1,
        canvas_width / 3,
        canvas_height,
        -canvas_width / 3,
        0,
        0xff0000,
        check_show_curve,
        red_bump,
        curve_type
    )
    draw_tone_curve(1, 7, canvas_width / 3, canvas_height, 0, 0, 0x00ff00, check_show_curve, green_bump, curve_type)
    draw_tone_curve(
        2,
        13,
        canvas_width / 3,
        canvas_height,
        canvas_width / 3,
        0,
        0x0000ff,
        check_show_curve,
        blue_bump,
        curve_type
    )
end
obj.load("tempbuffer")
