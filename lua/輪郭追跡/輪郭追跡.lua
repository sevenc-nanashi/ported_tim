--label:${ROOT_CATEGORY}\装飾
---$track:描画度
---min=0
---max=100
---step=0.1
local track_draw_amount = 100

---$track:線幅
---min=0
---max=1000
---step=0.1
local track_line_width = 10

---$track:開始点
---min=0
---max=100
---step=0.1
local track_start_point = 0

---$track:閾値
---min=0
---max=255
---step=1
local track_threshold = 128

---$color:色
local line_color = 0xffffff

---$check:逆回転
local check_reverse = 0

---$check:輪郭のみ
local check_contour_only = 0

---$check:輪郭を下に
local check_draw_contour_below = 0

---$check:中心補正
local check_restore_center = 1

---$track:スキャン粗さ
---min=1
---max=100
---step=1
local track_scan_step = 1

--group:拡張機能,false

---$check:拡張機能を使用
local check_use_extension = 0

---$track:破線周期
---min=0
---max=100
---step=0.01
local track_line_period = 5

---$track:破線間隔
---min=0
---max=100
---step=0.01
local track_line_spacing = 2.5

---$track:滑らかさ
---min=0
---max=1000
---step=1
local track_smoothness = 0

---$track:本体透明度
---min=0
---max=100
---step=0.1
local track_opacity = 0

---$figure:形状
local extension_figure = "円"

---$check:進行方向
local check_follow_direction = 0

---$check:先端表示
local check_show_tip = 0

---$figure:先端図形
local extension_tip_figure = "三角形"

---$track:先端サイズ
---min=0
---max=1000
---step=1
local extension_tip_size = 50

--group:

--hide@track_line_period:check_use_extension==0
--hide@track_line_spacing:check_use_extension==0
--hide@track_smoothness:check_use_extension==0
--hide@track_opacity:check_use_extension==0
--hide@extension_figure:check_use_extension==0
--hide@check_follow_direction:check_use_extension==0
--hide@check_show_tip:check_use_extension==0
--hide@extension_tip_figure:check_use_extension==0
--hide@extension_tip_figure:check_show_tip==0
--hide@extension_tip_size:check_use_extension==0
--hide@extension_tip_size:check_show_tip==0

local original_center_x = obj.cx
local original_center_y = obj.cy
check_restore_center = check_restore_center or 0

local line_figure, line_period, line_spacing, follow_direction, smoothness, body_opacity, show_tip, tip_figure, tip_size

if check_use_extension == 1 then
    line_figure = extension_figure
    line_period = track_line_period * 0.01
    line_spacing = track_line_spacing * 0.01
    follow_direction = check_follow_direction
    smoothness = math.floor(track_smoothness)
    body_opacity = 1 - track_opacity * 0.01
    show_tip = check_show_tip
    tip_figure = extension_tip_figure
    tip_size = extension_tip_size
elseif T_CONTOUR_TRACE_EXTENSION == nil then
    line_figure = "円"
    line_period = 1
    line_spacing = 0
    follow_direction = 0
    smoothness = 0
    body_opacity = 1
    show_tip = 0
    tip_figure = nil
    tip_size = nil
else
    line_figure = T_CONTOUR_TRACE_EXTENSION.line_figure
    line_period = T_CONTOUR_TRACE_EXTENSION.line_period
    line_spacing = T_CONTOUR_TRACE_EXTENSION.line_spacing
    follow_direction = T_CONTOUR_TRACE_EXTENSION.follow_direction
    smoothness = T_CONTOUR_TRACE_EXTENSION.smoothness
    body_opacity = T_CONTOUR_TRACE_EXTENSION.body_opacity
    show_tip = T_CONTOUR_TRACE_EXTENSION.show_tip
    tip_figure = T_CONTOUR_TRACE_EXTENSION.tip_figure
    tip_size = T_CONTOUR_TRACE_EXTENSION.tip_size
end

local draw_ratio = track_draw_amount * 0.01
local line_width = track_line_width
local start_ratio = track_start_point * 0.01
local threshold = track_threshold
track_scan_step = math.floor(track_scan_step or 1)
track_scan_step = (track_scan_step < 1 and 1) or track_scan_step

local contour_module = obj.module("tim2")
local pixel_data, width, height = obj.getpixeldata("object", "bgra")
local point_count, total_length, points =
    contour_module.rgline_trace_contour(pixel_data, width, height, threshold, track_scan_step, smoothness)
local point_index = math.floor(point_count * start_ratio)

obj.setoption("drawtarget", "tempbuffer", width + line_width, height + line_width)

if check_contour_only == 0 and check_draw_contour_below ~= 1 then
    obj.draw(0, 0, 0, 1, body_opacity)
else
    obj.copybuffer("cache:IMG", "object")
end

obj.load("figure", line_figure, line_color, line_width)

local target_length = total_length * draw_ratio
local drawn_length = 0
local traversed_point_count = 0
local point_rotation
local point_x
local point_y

if target_length > 0 and total_length > 0 and point_count > 0 then
    repeat
        traversed_point_count = traversed_point_count + 1
        point_index = (traversed_point_count + math.floor(point_count * start_ratio)) % point_count
        if check_reverse == 0 then
            point_index = point_count - point_index - 1
        end
        point_index = point_index + 1
        local base = (point_index - 1) * 4
        point_x = points[base + 1]
        point_y = points[base + 2]
        drawn_length = drawn_length + points[base + 3]

        local progress_ratio = drawn_length / total_length
        local segment_index = math.floor(progress_ratio / line_period)

        if
            segment_index * line_period < progress_ratio
            and progress_ratio <= (segment_index + 1) * line_period - line_spacing
        then
            if follow_direction == 1 then
                point_rotation = points[base + 4]
            else
                point_rotation = 0
            end
            obj.draw(point_x - width / 2, point_y - height / 2, 0, 1, 1, 0, 0, point_rotation)
        end
    until drawn_length >= target_length

    if show_tip == 1 then
        obj.load("figure", tip_figure, line_color, tip_size)
        obj.draw(point_x - width / 2, point_y - height / 2, 0, 1, 1, 0, 0, (point_rotation or 0) - 90)
    end
end

if check_contour_only == 0 and check_draw_contour_below == 1 then
    obj.copybuffer("object", "cache:IMG")
    obj.draw(0, 0, 0, 1, body_opacity)
end

obj.load("tempbuffer")

if check_restore_center == 1 then
    obj.cx = original_center_x
    obj.cy = original_center_y
end
