--label:${ROOT_CATEGORY}\アニメーション効果
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

local current_time = obj.time
local animation_duration = track_time_ms * 0.001
local max_size = track_size_percent * 0.01
local size_error = track_size_error
local horizontal_offset = track_horizontal_offset * 0.01
local center_offset = track_center_offset or 70
local random_seed = math.floor(track_random_seed or 0)

local object_count = obj.num - 1
local object_index = obj.index - 1

local appearance_start_time = (object_count - object_index) / object_count * animation_duration / 4
local appearance_end_time = appearance_start_time + animation_duration / 4
local settling_start_time = object_index / object_count * animation_duration / 4 + animation_duration / 2
local settling_end_time = object_index / object_count * animation_duration / 2 + animation_duration / 2

local initial_size_variation = obj.rand(-size_error, size_error, object_index, random_seed) * 0.01
local settled_size_variation = obj.rand(-size_error / 2, size_error / 2, object_index, 1000 + random_seed) * 0.01
local size_transition = 1

if current_time < appearance_start_time then
    obj.alpha = 0
elseif current_time < appearance_end_time then
    local appearance_progress = (current_time - appearance_start_time) / (appearance_end_time - appearance_start_time)
    size_transition = appearance_progress + initial_size_variation
    obj.alpha = math.min(2 * appearance_progress, 1)
elseif current_time < settling_start_time then
    obj.alpha = 1
    size_transition = (current_time - appearance_end_time) / (settling_start_time - appearance_end_time)
    size_transition = (1 - size_transition) * (1 + initial_size_variation)
        + size_transition * (1 + settled_size_variation)
elseif current_time < settling_end_time then
    obj.alpha = 1
    size_transition = (current_time - settling_start_time) / (settling_end_time - settling_start_time)
    size_transition = (1 - size_transition) * (1 + settled_size_variation) + size_transition
else
    obj.alpha = 1
end

obj.zoom = obj.zoom * (1 + (max_size - 1) * (1 - size_transition))
obj.ox = obj.ox + horizontal_offset * (obj.ox - center_offset) * (1 - size_transition)
