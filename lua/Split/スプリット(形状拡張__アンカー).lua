--label:tim2\変形\スプリット.anm
--track0:オフセット,0,100,30
--track1:繰り返し,1,50,1,1
--track2:傾斜,-100,100,0
--track3:ｱﾝｶｰ数,2,16,3,1
--check0:滑らかに,1
--dialog:座標,T_POS={-100,0,0,0,100,0};

local An = obj.track3
obj.setanchor("T_POS", An)

local of = obj.track0 * 0.01
local rp = obj.track1
local a = obj.track2 * 0.01

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

if obj.check0 then
    T_line_data_fl = 1
else
    T_line_data_fl = 2
end
