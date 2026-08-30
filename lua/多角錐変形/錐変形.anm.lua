--label:${ROOT_CATEGORY}\変形
---$track:角数
---min=3
---max=100
---step=1
local track_sides = 6

---$track:高さ
---min=0
---max=20000
---step=0.1
local track_height = 200

---$track:上半径
---min=0
---max=10000
---step=0.1
local track_upper_radius = 100

---$track:下半径
---min=0
---max=10000
---step=0.1
local track_lower_radius = 300

---$check:蓋
local check_cap = 0

---$check:中心基準
local check_center_origin = 1

---$check:両面化
local check_double_sided = 0

---$check:星型化
local check_star_shape = 0

---$track:くびれ率
---min=0
---max=100
---step=0.1
local track_constriction_ratio = 50

---$check:角を整数化
local check_integer_sides = 0

--hide@track_constriction_ratio:check_star_shape==0

-- ---$check:アンチエイリアス
-- local ant = 0

local zoom_scale = obj.getvalue("zoom_scale") * 0.01
local side_count = track_sides
local scaled_height = track_height * zoom_scale
local upper_radius = track_upper_radius * zoom_scale
local lower_radius = track_lower_radius * zoom_scale
local texture_height = obj.h
local angle_offset = check_cap and math.pi * 0.5 or 0
-- ant = ant or 1
check_integer_sides = check_integer_sides or 0
check_cap = check_cap or 0
check_center_origin = check_center_origin or 1
check_double_sided = check_double_sided or 0
check_star_shape = check_star_shape or 0
track_constriction_ratio = track_constriction_ratio or 50
local upper_x_positions = {}
local upper_z_positions = {}
local lower_x_positions = {}
local lower_z_positions = {}
-- obj.setoption("antialias", ant)
if check_integer_sides == 1 then
    side_count = math.floor(side_count)
end
if check_star_shape == 0 then
    for i = 0, side_count do
        local angle_radians = 2 * i * math.pi / side_count + angle_offset
        local angle_cosine = math.cos(angle_radians)
        local angle_sine = math.sin(angle_radians)
        upper_x_positions[i] = upper_radius * angle_cosine
        upper_z_positions[i] = upper_radius * angle_sine
        lower_x_positions[i] = lower_radius * angle_cosine
        lower_z_positions[i] = lower_radius * angle_sine
    end
else
    track_constriction_ratio = 1 - track_constriction_ratio * 0.01
    side_count = 2 * side_count
    for i = 0, side_count, 2 do
        local angle_radians = 2 * i * math.pi / side_count + angle_offset
        local angle_cosine = math.cos(angle_radians)
        local angle_sine = math.sin(angle_radians)
        upper_x_positions[i] = upper_radius * angle_cosine
        upper_z_positions[i] = upper_radius * angle_sine
        lower_x_positions[i] = lower_radius * angle_cosine
        lower_z_positions[i] = lower_radius * angle_sine
    end
    upper_radius = upper_radius * track_constriction_ratio
    lower_radius = lower_radius * track_constriction_ratio
    for i = 1, side_count, 2 do
        local angle_radians = 2 * i * math.pi / side_count + angle_offset
        local angle_cosine = math.cos(angle_radians)
        local angle_sine = math.sin(angle_radians)
        upper_x_positions[i] = upper_radius * angle_cosine
        upper_z_positions[i] = upper_radius * angle_sine
        lower_x_positions[i] = lower_radius * angle_cosine
        lower_z_positions[i] = lower_radius * angle_sine
    end
end

local texture_u_positions = {}
for i = 0, side_count do
    texture_u_positions[i] = i / side_count * obj.w
end

local upper_y, lower_y
if check_center_origin == 1 and check_double_sided == 0 then
    upper_y = -scaled_height * 0.5
    lower_y = scaled_height * 0.5
else
    upper_y = -scaled_height
    lower_y = 0
end

for i = 0, side_count - 1 do
    obj.drawpoly(
        upper_x_positions[i],
        upper_y,
        upper_z_positions[i],
        upper_x_positions[i + 1],
        upper_y,
        upper_z_positions[i + 1],
        lower_x_positions[i + 1],
        lower_y,
        lower_z_positions[i + 1],
        lower_x_positions[i],
        lower_y,
        lower_z_positions[i],
        texture_u_positions[i],
        0,
        texture_u_positions[i + 1],
        0,
        texture_u_positions[i + 1],
        texture_height,
        texture_u_positions[i],
        texture_height
    )
end

if check_double_sided == 0 then
    if check_cap == 1 then
        for i = 0, side_count - 1 do
            obj.drawpoly(
                0,
                upper_y,
                0,
                0,
                upper_y,
                0,
                upper_x_positions[i + 1],
                upper_y,
                upper_z_positions[i + 1],
                upper_x_positions[i],
                upper_y,
                upper_z_positions[i],
                texture_u_positions[i],
                0,
                texture_u_positions[i + 1],
                0,
                texture_u_positions[i + 1],
                0,
                texture_u_positions[i],
                0
            )
            obj.drawpoly(
                0,
                lower_y,
                0,
                0,
                lower_y,
                0,
                lower_x_positions[i],
                lower_y,
                lower_z_positions[i],
                lower_x_positions[i + 1],
                lower_y,
                lower_z_positions[i + 1],
                texture_u_positions[i + 1],
                texture_height,
                texture_u_positions[i],
                texture_height,
                texture_u_positions[i],
                texture_height,
                texture_u_positions[i + 1],
                texture_height
            )
        end
    end
else
    for i = 0, side_count - 1 do
        obj.drawpoly(
            upper_x_positions[i + 1],
            -upper_y,
            upper_z_positions[i + 1],
            upper_x_positions[i],
            -upper_y,
            upper_z_positions[i],
            lower_x_positions[i],
            0,
            lower_z_positions[i],
            lower_x_positions[i + 1],
            0,
            lower_z_positions[i + 1],
            texture_u_positions[i + 1],
            0,
            texture_u_positions[i],
            0,
            texture_u_positions[i],
            texture_height,
            texture_u_positions[i + 1],
            texture_height
        )
    end

    if check_cap == 1 then
        for i = 0, side_count - 1 do
            obj.drawpoly(
                0,
                upper_y,
                0,
                0,
                upper_y,
                0,
                upper_x_positions[i + 1],
                upper_y,
                upper_z_positions[i + 1],
                upper_x_positions[i],
                upper_y,
                upper_z_positions[i],
                texture_u_positions[i],
                0,
                texture_u_positions[i + 1],
                0,
                texture_u_positions[i + 1],
                0,
                texture_u_positions[i],
                0
            )
            obj.drawpoly(
                0,
                -upper_y,
                0,
                0,
                -upper_y,
                0,
                upper_x_positions[i],
                -upper_y,
                upper_z_positions[i],
                upper_x_positions[i + 1],
                -upper_y,
                upper_z_positions[i + 1],
                texture_u_positions[i + 1],
                0,
                texture_u_positions[i],
                0,
                texture_u_positions[i],
                0,
                texture_u_positions[i + 1],
                0
            )
        end
    end
end
