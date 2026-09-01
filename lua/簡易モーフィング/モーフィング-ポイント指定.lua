--label:${ROOT_CATEGORY}\変形\@モーフィング
local x, y
---$track:ポイント数
---min=1
---max=14
---step=1
local track_point_count = 3

---$select:画像種別
---変化前=1
---変化後=2
local track_image_index = 1

---$check:ポイント表示
local check_show_points = false

---$track:ポイントサイズ
---min=0
---max=500
---step=1
local track_point_size = 30

---$track:フォントサイズ
---min=0
---max=500
---step=1
local track_font_size = 30

---$color:ポイント色
local point_color = 0xffffff

---$color:文字色
local label_color = 0x0

---$value:座標
local point_positions = { -100, 0, 0, 0, 100, 0 }

--hide@track_point_size:check_show_points==0
--hide@track_font_size:check_show_points==0
--hide@point_color:check_show_points==0
--hide@label_color:check_show_points==0

T_MORPHING_DRAW_ANCHOR = function()
    if T_MORPHING_SHOW_GUIDE then
        local morph_object = T_MORPHING_OBJECTS[T_MORPHING_POINT_COUNT]
        local morph_points = morph_object.pos
        local point_count = #morph_points
        obj.setoption("drawtarget", "tempbuffer", morph_object.w, morph_object.h)
        obj.draw()
        obj.load("figure", "円", T_MORPHING_POINT_DISPLAY.point_color, T_MORPHING_POINT_DISPLAY.point_size)
        for i = 1, point_count do
            obj.draw(morph_points[i].x, morph_points[i].y)
        end
        obj.setfont("", T_MORPHING_POINT_DISPLAY.font_size, 0, T_MORPHING_POINT_DISPLAY.label_color)
        for i = 1, point_count do
            obj.load("text", i)
            obj.draw(morph_points[i].x, morph_points[i].y)
        end
        obj.load("tempbuffer")
    end
    T_MORPHING_POINT_DISPLAY = nil
    T_MORPHING_SHOW_GUIDE = nil
    T_MORPHING_POINT_COUNT = nil
end

local anchor_count = track_point_count
T_MORPHING_POINT_COUNT = track_image_index
T_MORPHING_SHOW_GUIDE = check_show_points

if T_MORPHING_OBJECTS == nil then
    T_MORPHING_OBJECTS = {}
end

T_MORPHING_POINT_DISPLAY = {}
T_MORPHING_POINT_DISPLAY.point_color = point_color
T_MORPHING_POINT_DISPLAY.point_size = track_point_size
T_MORPHING_POINT_DISPLAY.label_color = label_color
T_MORPHING_POINT_DISPLAY.font_size = track_font_size

local image_width, image_height = obj.getpixel()
local half_width, half_height = image_width * 0.5, image_height * 0.5
T_MORPHING_OBJECTS[T_MORPHING_POINT_COUNT] = {}
local morph_object = T_MORPHING_OBJECTS[T_MORPHING_POINT_COUNT]
morph_object.layer = obj.layer
morph_object.w = image_width
morph_object.h = image_height
morph_object.pos = {}
local morph_points = morph_object.pos
morph_points[1] = { x = -half_width, y = -half_height }
morph_points[2] = { x = half_width, y = -half_height }
morph_points[3] = { x = half_width, y = half_height }
morph_points[4] = { x = -half_width, y = half_height }

obj.setanchor("point_positions", anchor_count)

local existing_point_count = #morph_points
for i = 1, anchor_count do
    morph_points[existing_point_count + i] = {}
    morph_points[existing_point_count + i].x = point_positions[2 * i - 1]
    morph_points[existing_point_count + i].y = point_positions[2 * i]
end

if
    obj.getoption("script_name", 1, true)
    ~= "モーフィング-ポイント追加@モーフィング@モーフィング@tim.anm2"
then
    T_MORPHING_DRAW_ANCHOR()
    T_MORPHING_DRAW_ANCHOR = nil
end
