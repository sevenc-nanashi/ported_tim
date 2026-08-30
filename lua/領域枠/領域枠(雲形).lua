--label:${ROOT_CATEGORY}\装飾\@領域枠
---$track:画線幅％
---min=0
---max=100
---step=0.1
local track_stroke_width_percent = 10

---$track:密度
---min=1
---max=200
---step=1
local track_cloud_count = 7

---$track:形状変化
---min=1
---max=5000
---step=0.01
local track_shape_change = 1

---$track:背景濃度
---min=0
---max=100
---step=0.1
local track_background_density = 20

---$color:枠色
local color_border = 0xffffff

---$color:背景色
local color_background = 0xccccff

---$track:追加幅
---min=-5000
---max=5000
---step=0.1
local track_extra_width = 0

---$track:追加高さ
---min=-5000
---max=5000
---step=0.1
local track_extra_height = 0

---$track:平滑度[%]
---min=0
---max=100
---step=0.1
local track_smoothness_percent = 20

---$value:雲横位置[%]
local value_cloud_horizontal_spacing_percent = { 50, 100 }

---$value:雲横重なり[%]
local value_cloud_overlap_percent = { 10, 40 }

---$value:雲高さ[%]
local value_cloud_height_percent = { 70, 90 }

---$track:回転
---min=-360
---max=360
---step=0.1
local track_rotation = 35

---$select:変形
---1=1
---2=2
---3=3
---4=4
---5=5
local select_easing_power = 1

---$track:精度
---min=0.1
---max=10
---step=0.1
local track_precision_scale = 1

---$value:基準
local value_origin_percent = { 0, 0 }

local function create_border_mask(max_dimension, w, h, color_border, stroke_ratio)
    obj.setoption("drawtarget", "tempbuffer", w + 10, h + 10)
    obj.load("figure", "四角形", color_border, max_dimension + 10)
    obj.draw()
    obj.copybuffer("object", "cache:cache-Itiji")
    obj.setoption("blend", "alpha_sub")
    obj.draw(0, 0, 0, 1 - stroke_ratio)
    obj.setoption("blend", 0)
end

local w, h = obj.getpixel()
local stroke_ratio = track_stroke_width_percent * 0.01
local cloud_count = math.floor(track_cloud_count)
local shape_progress = track_shape_change
local current_shape_step = math.floor(shape_progress)
local next_shape_step = current_shape_step + 1
shape_progress = shape_progress - current_shape_step

select_easing_power = math.min(math.max(select_easing_power, 1), 5)

shape_progress = 2 * shape_progress
if shape_progress < 1 then
    shape_progress = shape_progress ^ select_easing_power
else
    shape_progress = 2 - (2 - shape_progress) ^ select_easing_power
end
shape_progress = shape_progress * 0.5

local background_alpha = track_background_density * 0.01

w, h = track_extra_width + w + 2 * stroke_ratio, track_extra_height + h + 2 * stroke_ratio

w = ((w > 0) and w) or 0
h = ((h > 0) and h) or 0
local max_dimension = math.max(w, h)
local half_width = w * 0.5
local half_height = h * 0.5

local scaled_width = track_precision_scale * w
local scaled_height = track_precision_scale * h
local pattern_width = 2 * scaled_width
local pattern_height = 2 * scaled_height
local scaled_max_dimension = math.max(scaled_width, scaled_height)
local base_y = scaled_height * track_smoothness_percent * 0.01
value_origin_percent = value_origin_percent or { 0, 0 }
--オリジナル保存
obj.copybuffer("cache:cache-ori", "object")

--枠作成保存
obj.setoption("drawtarget", "tempbuffer", pattern_width, pattern_height)
obj.load("figure", "四角形", 0xffffff, scaled_max_dimension)
obj.drawpoly(
    -scaled_width,
    -scaled_height,
    0,
    scaled_width,
    -scaled_height,
    0,
    scaled_width,
    base_y,
    0,
    -scaled_width,
    base_y,
    0
)

local current_x_positions = {}
local next_x_positions = {}
current_x_positions[0] = 0
next_x_positions[0] = 0
for i = 1, cloud_count do
    current_x_positions[i] = obj.rand(
        value_cloud_horizontal_spacing_percent[1],
        value_cloud_horizontal_spacing_percent[2],
        i,
        current_shape_step + 1000
    ) + current_x_positions[i - 1]
    next_x_positions[i] = obj.rand(
        value_cloud_horizontal_spacing_percent[1],
        value_cloud_horizontal_spacing_percent[2],
        i,
        next_shape_step + 1000
    ) + next_x_positions[i - 1]
end

for i = 0, cloud_count do
    current_x_positions[i] = current_x_positions[i] / current_x_positions[cloud_count] * pattern_width - scaled_width
    next_x_positions[i] = next_x_positions[i] / next_x_positions[cloud_count] * pattern_width - scaled_width
end

obj.load("figure", "円", 0xffffff, math.min(scaled_width, scaled_height))
for i = 1, cloud_count - 1 do
    local current_left_x = current_x_positions[i - 1]
    local next_left_x = next_x_positions[i - 1]
    local current_right_x = current_x_positions[i]
        + (current_x_positions[i + 1] - current_x_positions[i])
            * obj.rand(value_cloud_overlap_percent[1], value_cloud_overlap_percent[2], i, current_shape_step + 2000)
            * 0.01
    local next_right_x = next_x_positions[i]
        + (next_x_positions[i + 1] - next_x_positions[i])
            * obj.rand(value_cloud_overlap_percent[1], value_cloud_overlap_percent[2], i, next_shape_step + 2000)
            * 0.01
    local current_cloud_height = (scaled_height - base_y)
        * obj.rand(value_cloud_height_percent[1], value_cloud_height_percent[2], i, current_shape_step + 3000)
        * 0.01
    local next_cloud_height = (scaled_height - base_y)
        * obj.rand(value_cloud_height_percent[1], value_cloud_height_percent[2], i, next_shape_step + 3000)
        * 0.01
    local interpolated_left_x = (1 - shape_progress) * current_left_x + shape_progress * next_left_x
    local interpolated_right_x = (1 - shape_progress) * current_right_x + shape_progress * next_right_x
    local interpolated_cloud_height = (1 - shape_progress) * current_cloud_height + shape_progress * next_cloud_height
    obj.drawpoly(
        interpolated_left_x,
        -interpolated_cloud_height + base_y,
        0,
        interpolated_right_x,
        -interpolated_cloud_height + base_y,
        0,
        interpolated_right_x,
        interpolated_cloud_height + base_y,
        0,
        interpolated_left_x,
        interpolated_cloud_height + base_y,
        0
    )
end
local current_left_x = current_x_positions[cloud_count - 1]
local next_left_x = next_x_positions[cloud_count - 1]
local current_right_x = current_x_positions[cloud_count]
    + (current_x_positions[1] - current_x_positions[0])
        * obj.rand(
            value_cloud_overlap_percent[1],
            value_cloud_overlap_percent[2],
            cloud_count,
            current_shape_step + 2000
        )
        * 0.01
local next_right_x = next_x_positions[cloud_count]
    + (next_x_positions[1] - next_x_positions[0])
        * obj.rand(value_cloud_overlap_percent[1], value_cloud_overlap_percent[2], cloud_count, next_shape_step + 2000)
        * 0.01
local current_cloud_height = (scaled_height - base_y)
    * obj.rand(value_cloud_height_percent[1], value_cloud_height_percent[2], cloud_count, current_shape_step + 3000)
    * 0.01
local next_cloud_height = (scaled_height - base_y)
    * obj.rand(value_cloud_height_percent[1], value_cloud_height_percent[2], cloud_count, next_shape_step + 3000)
    * 0.01

local interpolated_left_x = (1 - shape_progress) * current_left_x + shape_progress * next_left_x
local interpolated_right_x = (1 - shape_progress) * current_right_x + shape_progress * next_right_x
local interpolated_cloud_height = (1 - shape_progress) * current_cloud_height + shape_progress * next_cloud_height
obj.drawpoly(
    interpolated_left_x,
    -interpolated_cloud_height + base_y,
    0,
    interpolated_right_x,
    -interpolated_cloud_height + base_y,
    0,
    interpolated_right_x,
    interpolated_cloud_height + base_y,
    0,
    interpolated_left_x,
    interpolated_cloud_height + base_y,
    0
)
obj.drawpoly(
    interpolated_left_x - pattern_width,
    -interpolated_cloud_height + base_y,
    0,
    interpolated_right_x - pattern_width,
    -interpolated_cloud_height + base_y,
    0,
    interpolated_right_x - pattern_width,
    interpolated_cloud_height + base_y,
    0,
    interpolated_left_x - pattern_width,
    interpolated_cloud_height + base_y,
    0
)

obj.copybuffer("object", "tempbuffer")
obj.effect("極座標変換", "回転", track_rotation)
obj.setoption("drawtarget", "tempbuffer", w, h)
obj.drawpoly(
    -half_width,
    -half_height,
    0,
    half_width,
    -half_height,
    0,
    half_width,
    half_height,
    0,
    -half_width,
    half_height,
    0
)
obj.copybuffer("cache:cache-Itiji", "tempbuffer")

--枠作成保存
create_border_mask(max_dimension, w, h, color_border, stroke_ratio)
obj.copybuffer("cache:cache-waku", "tempbuffer")

--削除領域作成保存
create_border_mask(max_dimension, w, h, color_border, 0)
obj.copybuffer("cache:cache-del", "tempbuffer")

--描画
obj.setoption("drawtarget", "tempbuffer", w, h)
obj.load("figure", "四角形", color_background, max_dimension)
obj.draw(0, 0, 0, 1, background_alpha)

obj.copybuffer("object", "cache:cache-ori")
obj.draw()

obj.copybuffer("object", "cache:cache-waku")
obj.draw()

obj.copybuffer("object", "cache:cache-del")
obj.setoption("blend", "alpha_sub")
obj.draw()

obj.load("tempbuffer")
obj.setoption("blend", 0)
obj.cx = obj.cx + w * value_origin_percent[1] * 0.01
obj.cy = obj.cy + h * value_origin_percent[2] * 0.01
