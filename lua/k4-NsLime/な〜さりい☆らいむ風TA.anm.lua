--label:tim2\アニメーション効果
---$track:時間mS
---min=1
---max=10000
---step=0.1
local track_time_ms = 1000

---$track:サイズ％
---min=5
---max=5000
---step=0.1
local track_size_percent = 450

---$track:サイズ誤差
---min=0
---max=500
---step=0.1
local track_size_error = 30

---$track:横ズレ量
---min=0
---max=1000
---step=0.1
local track_horizontal_offset = 450

---$track:中心ズレ
---min=-2000
---max=2000
---step=0.1
local track_center_offset = 70

---$track:乱数シード
---min=0
---max=1000000
---step=1
local track_random_seed = 0

local T = obj.time
local animation_duration = track_time_ms * 0.001
local max_size = track_size_percent * 0.01
local size_error = track_size_error
local horizontal_offset = track_horizontal_offset * 0.01
local center_offset = track_center_offset or 70
local random_seed = math.floor(track_random_seed or 0)

local object_count = obj.num - 1
local object_index = obj.index - 1

local T1 = (object_count - object_index) / object_count * animation_duration / 4
local T2 = T1 + animation_duration / 4
local T3 = object_index / object_count * animation_duration / 4 + animation_duration / 2
local T4 = object_index / object_count * animation_duration / 2 + animation_duration / 2

local z1 = obj.rand(-size_error, size_error, object_index, random_seed) * 0.01
local z2 = obj.rand(-size_error / 2, size_error / 2, object_index, 1000 + random_seed) * 0.01
local x = 1

if T < T1 then
    obj.alpha = 0
elseif T < T2 then
    local al = (T - T1) / (T2 - T1)
    x = al + z1
    obj.alpha = math.min(2 * al, 1)
elseif T < T3 then
    obj.alpha = 1
    x = (T - T2) / (T3 - T2)
    x = (1 - x) * (1 + z1) + x * (1 + z2)
elseif T < T4 then
    obj.alpha = 1
    x = (T - T3) / (T4 - T3)
    x = (1 - x) * (1 + z2) + x
else
    obj.alpha = 1
end

obj.zoom = obj.zoom * (1 + (max_size - 1) * (1 - x))
obj.ox = obj.ox + horizontal_offset * (obj.ox - center_offset) * (1 - x)
