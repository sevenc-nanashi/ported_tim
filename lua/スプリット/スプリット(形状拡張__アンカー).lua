--label:${ROOT_CATEGORY}\変形\@スプリット
---$track:オフセット
---min=0
---max=100
---step=0.1
local track_offset = 30

---$track:繰り返し
---min=1
---max=50
---step=1
local track_repeat = 1

---$track:傾斜
---min=-100
---max=100
---step=0.1
local track_slope = 0

---$track:アンカー数
---min=2
---max=16
---step=1
local track_anchor_count = 3

---$check:滑らかに
local check_smooth = true

---$value:座標
local shape_points = { -100, 0, 0, 0, 100, 0 }

local anchor_count = track_anchor_count
obj.setanchor("shape_points", anchor_count)

local offset_ratio = track_offset * 0.01
local repeat_count = track_repeat
local slope_ratio = track_slope * 0.01

T_SPLIT_LINE_DATA = {}

for i = 1, anchor_count - 1 do
    for j = i + 1, anchor_count do
        if shape_points[2 * i - 1] > shape_points[2 * j - 1] then
            shape_points[2 * i - 1], shape_points[2 * j - 1] = shape_points[2 * j - 1], shape_points[2 * i - 1]
            shape_points[2 * i], shape_points[2 * j] = shape_points[2 * j], shape_points[2 * i]
        end
    end
end
for i = 1, anchor_count do
    T_SPLIT_LINE_DATA[i] = -shape_points[2 * i]
end

local min = math.min(unpack(T_SPLIT_LINE_DATA))
for i = 1, #T_SPLIT_LINE_DATA do
    T_SPLIT_LINE_DATA[i] = T_SPLIT_LINE_DATA[i] - min
end

local n = #T_SPLIT_LINE_DATA
for j = 2, repeat_count do
    for i = 1, n do
        T_SPLIT_LINE_DATA[i + (j - 1) * n] = T_SPLIT_LINE_DATA[i]
    end
end

local center_index = (1 + #T_SPLIT_LINE_DATA) * 0.5
for i = 1, #T_SPLIT_LINE_DATA do
    T_SPLIT_LINE_DATA[i] = T_SPLIT_LINE_DATA[i] * (slope_ratio * (i - center_index) / center_index + 1)
end

local max = math.max(unpack(T_SPLIT_LINE_DATA))
min = math.min(unpack(T_SPLIT_LINE_DATA))
for i = 1, #T_SPLIT_LINE_DATA do
    T_SPLIT_LINE_DATA[i] = (T_SPLIT_LINE_DATA[i] - min) / (max - min) * (1 - offset_ratio) + offset_ratio
end

if check_smooth then
    T_SPLIT_LINE_DATA_MODE = 1
else
    T_SPLIT_LINE_DATA_MODE = 2
end
