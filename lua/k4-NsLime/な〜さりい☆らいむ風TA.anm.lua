--label:tim2\未分類
---$track:時間mS
---min=1
---max=10000
---step=0.1
local track_time_ms = 1000

---$track:ｻｲｽﾞ％
---min=5
---max=5000
---step=0.1
local track_size_percent = 450

---$track:ｻｲｽﾞ誤差
---min=0
---max=500
---step=0.1
local track_size_error = 30

---$track:横ズレ量
---min=0
---max=1000
---step=0.1
local track_horizontal_offset = 450

---$value:中心ズレ
local cx = 70

---$value:乱数シード
local seed = 0

local T = obj.time
local Mtime = track_time_ms * 0.001
local maxsize = track_size_percent * 0.01
local dsize = track_size_error
local yz = track_horizontal_offset * 0.01

local N = obj.num - 1
local id = obj.index - 1

local T1 = (N - id) / N * Mtime / 4
local T2 = T1 + Mtime / 4
local T3 = id / N * Mtime / 4 + Mtime / 2
local T4 = id / N * Mtime / 2 + Mtime / 2

local z1 = obj.rand(-dsize, dsize, id, seed) * 0.01
local z2 = obj.rand(-dsize / 2, dsize / 2, id, 1000 + seed) * 0.01
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

obj.zoom = obj.zoom * (1 + (maxsize - 1) * (1 - x))
obj.ox = obj.ox + yz * (obj.ox - cx) * (1 - x)
