--label:${ROOT_CATEGORY}\アニメーション効果
---$track:振幅
---min=0
---max=1000
---step=0.1
local track_amplitude_percent = 100

---$track:波数
---min=0
---max=5000
---step=0.1
local track_horizontal_wave_count = 100

---$track:位相ズレX
---min=-5000
---max=5000
---step=0.1
local track_offset_x = -100

---$track:位相ズレY
---min=-5000
---max=5000
---step=0.1
local track_offset_y = 0

---$track:分割数
---min=2
---max=300
---step=1
local track_division_count = 30

--group:モード,false
---$check:左端を基準
local check_anchor_left = true

---$check:上端を基準
local check_anchor_top = false

---$check:右端を基準
local check_anchor_right = false

---$check:下端を基準
local check_anchor_bottom = false

--group:縦波数
---$check:縦波数を別指定
local check_use_separate_vertical_wave_count = false

---$track:縦波数::縦波数
---min=0
---max=5000
---step=0.1
local track_vertical_wave_count = 100

--hide@track_vertical_wave_count:check_use_separate_vertical_wave_count==0

track_division_count = math.max(2, math.floor(track_division_count or 30))
local w, h = obj.w, obj.h
local half_width, half_height = w / 2, h / 2
local cell_width, cell_height = w / track_division_count, h / track_division_count
local amplitude = w / 30 * track_amplitude_percent / 100
local horizontal_angular_frequency = track_horizontal_wave_count
track_vertical_wave_count = (check_use_separate_vertical_wave_count and (track_vertical_wave_count or 100))
    or horizontal_angular_frequency
horizontal_angular_frequency = 2 * math.pi / w * horizontal_angular_frequency / 100
track_vertical_wave_count = 2 * math.pi / w * track_vertical_wave_count / 100
local phase_offset_x = 2 * math.pi * track_offset_x / 100
local phase_offset_y = 2 * math.pi * track_offset_y / 100
local y_sin = {}
for j = 0, track_division_count do
    local v = j * cell_height
    y_sin[j] = math.sin((v - half_height) * track_vertical_wave_count + phase_offset_y)
end
local vertices = {}
for i = 0, track_division_count - 1 do
    local u1 = i * cell_width
    local u2 = (i + 1) * cell_width
    local x1 = u1 - half_width
    local x2 = u2 - half_width
    local left_wave = math.sin(x1 * horizontal_angular_frequency + phase_offset_x)
    local right_wave = math.sin(x2 * horizontal_angular_frequency + phase_offset_x)
    local left_anchor_ratio = i / track_division_count
    local right_anchor_ratio = (i + 1) / track_division_count
    for j = 0, track_division_count - 1 do
        local v1 = j * cell_height
        local v2 = (j + 1) * cell_height
        local y1 = v1 - half_height
        local y2 = v2 - half_height
        local z1 = amplitude * (left_wave + y_sin[j])
        local z2 = amplitude * (right_wave + y_sin[j])
        local z3 = amplitude * (right_wave + y_sin[j + 1])
        local z4 = amplitude * (left_wave + y_sin[j + 1])
        local top_anchor_ratio = j / track_division_count
        local bottom_anchor_ratio = (j + 1) / track_division_count
        if check_anchor_left then
            z1, z2, z3, z4 =
                z1 * left_anchor_ratio, z2 * right_anchor_ratio, z3 * right_anchor_ratio, z4 * left_anchor_ratio
        end
        if check_anchor_top then
            z1, z2, z3, z4 =
                z1 * top_anchor_ratio, z2 * top_anchor_ratio, z3 * bottom_anchor_ratio, z4 * bottom_anchor_ratio
        end
        if check_anchor_right then
            z1, z2, z3, z4 =
                z1 * (1 - left_anchor_ratio),
                z2 * (1 - right_anchor_ratio),
                z3 * (1 - right_anchor_ratio),
                z4 * (1 - left_anchor_ratio)
        end
        if check_anchor_bottom then
            z1, z2, z3, z4 =
                z1 * (1 - top_anchor_ratio),
                z2 * (1 - top_anchor_ratio),
                z3 * (1 - bottom_anchor_ratio),
                z4 * (1 - bottom_anchor_ratio)
        end
        vertices[#vertices + 1] = { x1, y1, z1, x2, y1, z2, x2, y2, z3, x1, y2, z4, u1, v1, u2, v1, u2, v2, u1, v2 }
    end
end
if #vertices > 0 then
    obj.drawpoly(vertices)
end
