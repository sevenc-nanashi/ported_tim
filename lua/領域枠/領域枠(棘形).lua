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
local track_spike_count = 10

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

---$track:棘幅ランダム性[%]
---min=0
---max=200
---step=0.1
local track_spike_width_randomness_percent = 50

---$value:棘高さ[%]
local value_spike_height_percent = { 20, 30 }

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

---$value:基準
local value_origin_percent = { 0, 0 }

local w, h = obj.getpixel()
local stroke_ratio = track_stroke_width_percent * 0.01
local spike_count = math.floor(track_spike_count)
local shape_progress = track_shape_change
local current_shape_step = math.floor(shape_progress)
local next_shape_step = current_shape_step + 1
shape_progress = shape_progress - current_shape_step
track_spike_width_randomness_percent = track_spike_width_randomness_percent * 0.5
track_rotation = math.rad(track_rotation)
value_origin_percent = value_origin_percent or { 0, 0 }
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
local half_width = w * 0.5
local half_height = h * 0.5
local max_dimension = math.max(w, h)

--オリジナル保存
obj.copybuffer("cache:cache-ori", "object")

--座標計算
local current_angles = {}
local next_angles = {}
current_angles[0] = 0
next_angles[0] = 0
for i = 1, spike_count do
    current_angles[i] = obj.rand(
        100 - track_spike_width_randomness_percent,
        100 + track_spike_width_randomness_percent,
        i,
        current_shape_step + 1000
    ) + current_angles[i - 1]
    next_angles[i] = obj.rand(
        100 - track_spike_width_randomness_percent,
        100 + track_spike_width_randomness_percent,
        i,
        next_shape_step + 1000
    ) + next_angles[i - 1]
end

for i = 0, spike_count do
    current_angles[i] = current_angles[i] / current_angles[spike_count] * 2 * math.pi - track_rotation
    next_angles[i] = next_angles[i] / next_angles[spike_count] * 2 * math.pi - track_rotation
end

local outer_x_positions = {}
local inner_x_positions = {}
local outer_y_positions = {}
local inner_y_positions = {}

for i = 0, spike_count do
    outer_x_positions[i], outer_y_positions[i] =
        half_width * math.cos(current_angles[i]), half_height * math.sin(current_angles[i])
    inner_x_positions[i], inner_y_positions[i] =
        half_width * math.cos(next_angles[i]), half_height * math.sin(next_angles[i])
end

for i = 0, spike_count do
    outer_x_positions[i] = (1 - shape_progress) * outer_x_positions[i] + shape_progress * inner_x_positions[i]
    outer_y_positions[i] = (1 - shape_progress) * outer_y_positions[i] + shape_progress * inner_y_positions[i]
end

local spike_canvas_extension = 2
    * max_dimension
    * math.max(value_spike_height_percent[1], value_spike_height_percent[2])
    * 0.01
w = w + spike_canvas_extension
h = h + spike_canvas_extension
local canvas_max_dimension = math.max(w, h)
local spike_offset_x = {}
local spike_offset_y = {}
local outer_spike_x = {}
local outer_spike_y = {}
local inner_spike_x = {}
local inner_spike_y = {}
for i = 0, spike_count - 1 do
    local x = outer_x_positions[i + 1] - outer_x_positions[i]
    local y = outer_y_positions[i + 1] - outer_y_positions[i]
    local edge_length = math.sqrt(x * x + y * y)
    local spike_height = (
        (1 - shape_progress)
            * obj.rand(value_spike_height_percent[1], value_spike_height_percent[2], i, current_shape_step + 3000)
        + shape_progress
            * obj.rand(value_spike_height_percent[1], value_spike_height_percent[2], i, next_shape_step + 3000)
    )
        * 0.01
        * max_dimension
    spike_offset_x[i] = spike_height * y / edge_length
    spike_offset_y[i] = -spike_height * x / edge_length
    outer_spike_x[i] = (outer_x_positions[i + 1] + outer_x_positions[i]) * 0.5 + spike_offset_x[i]
    outer_spike_y[i] = (outer_y_positions[i + 1] + outer_y_positions[i]) * 0.5 + spike_offset_y[i]
    inner_spike_x[i] = (outer_x_positions[i + 1] + outer_x_positions[i]) * 0.5 + spike_offset_x[i] * (1 - stroke_ratio)
    inner_spike_y[i] = (outer_y_positions[i + 1] + outer_y_positions[i]) * 0.5 + spike_offset_y[i] * (1 - stroke_ratio)
end

for i = 1, spike_count - 1 do
    inner_x_positions[i] = outer_x_positions[i] - (spike_offset_x[i - 1] + spike_offset_x[i]) * 0.5 * stroke_ratio
    inner_y_positions[i] = outer_y_positions[i] - (spike_offset_y[i - 1] + spike_offset_y[i]) * 0.5 * stroke_ratio
end
inner_x_positions[0] = outer_x_positions[0] - (spike_offset_x[spike_count - 1] + spike_offset_x[0]) * 0.5 * stroke_ratio
inner_y_positions[0] = outer_y_positions[0] - (spike_offset_y[spike_count - 1] + spike_offset_y[0]) * 0.5 * stroke_ratio
inner_x_positions[spike_count] = outer_x_positions[spike_count]
    - (spike_offset_x[spike_count - 1] + spike_offset_x[0]) * 0.5 * stroke_ratio
inner_y_positions[spike_count] = outer_y_positions[spike_count]
    - (spike_offset_y[spike_count - 1] + spike_offset_y[0]) * 0.5 * stroke_ratio

--描画
obj.setoption("drawtarget", "tempbuffer", w, h)

obj.load("figure", "四角形", color_background, max_dimension)
obj.setoption("blend", "alpha_add")
for i = 0, spike_count - 1 do
    obj.drawpoly(
        0,
        0,
        0,
        inner_x_positions[i],
        inner_y_positions[i],
        0,
        inner_spike_x[i],
        inner_spike_y[i],
        0,
        inner_x_positions[i + 1],
        inner_y_positions[i + 1],
        0
    )
end

obj.load("figure", "四角形", 0xffffff, canvas_max_dimension)
obj.setoption("blend", "alpha_sub")
obj.draw(0, 0, 0, 1, 1 - background_alpha)

obj.copybuffer("object", "cache:cache-ori")
obj.setoption("blend", 0)
obj.draw()

obj.load("figure", "四角形", color_border, max_dimension)
obj.setoption("blend", "alpha_add")
for i = 0, spike_count - 1 do
    obj.drawpoly(
        outer_x_positions[i],
        outer_y_positions[i],
        0,
        outer_spike_x[i],
        outer_spike_y[i],
        0,
        inner_spike_x[i],
        inner_spike_y[i],
        0,
        inner_x_positions[i],
        inner_y_positions[i],
        0
    )
    obj.drawpoly(
        inner_x_positions[i + 1],
        inner_y_positions[i + 1],
        0,
        inner_spike_x[i],
        inner_spike_y[i],
        0,
        outer_spike_x[i],
        outer_spike_y[i],
        0,
        outer_x_positions[i + 1],
        outer_y_positions[i + 1],
        0
    )
end

obj.load("tempbuffer")
obj.setoption("blend", 0)
obj.cx = obj.cx + w * value_origin_percent[1] * 0.01
obj.cy = obj.cy + h * value_origin_percent[2] * 0.01
