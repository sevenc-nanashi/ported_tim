--label:tim2\変形\@スプリット.anm
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
local T_POS = { -100, 0, 0, 0, 100, 0 }

local An = track_anchor_count
obj.setanchor("T_POS", An)

local of = track_offset * 0.01
local rp = track_repeat
local a = track_slope * 0.01

T_line_data = {}

for i = 1, An - 1 do
    for j = i + 1, An do
        if T_POS[2 * i - 1] > T_POS[2 * j - 1] then
            T_POS[2 * i - 1], T_POS[2 * j - 1] = T_POS[2 * j - 1], T_POS[2 * i - 1]
            T_POS[2 * i], T_POS[2 * j] = T_POS[2 * j], T_POS[2 * i]
        end
    end
end
for i = 1, An do
    T_line_data[i] = -T_POS[2 * i]
end

local Min = math.min(unpack(T_line_data))
for i = 1, #T_line_data do
    T_line_data[i] = T_line_data[i] - Min
end

local N = #T_line_data
for j = 2, rp do
    for i = 1, N do
        T_line_data[i + (j - 1) * N] = T_line_data[i]
    end
end

local sfi = (1 + #T_line_data) * 0.5
for i = 1, #T_line_data do
    T_line_data[i] = T_line_data[i] * (a * (i - sfi) / sfi + 1)
end

local Max = math.max(unpack(T_line_data))
Min = math.min(unpack(T_line_data))
for i = 1, #T_line_data do
    T_line_data[i] = (T_line_data[i] - Min) / (Max - Min) * (1 - of) + of
end

if check_smooth then
    T_line_data_fl = 1
else
    T_line_data_fl = 2
end
