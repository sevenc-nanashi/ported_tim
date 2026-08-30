--label:${ROOT_CATEGORY}\カスタムオブジェクト\@けいおんグッズ
---$track:サイズ
---min=0
---max=5000
---step=0.1
local track_cup_size = 200

---$track:水面高さ
---min=0
---max=100
---step=0.1
local track_tea_level_percent = 80

---$track:透明度
---min=0
---max=100
---step=0.1
local track_opacity = 20

---$track:カップソーサー間
---min=-1000
---max=1000
---step=0.1
local track_cup_saucer_gap = 13

---$value:分割数
local segment_count = 40

---$color:カップ(色)
local color_cup = 0xffffff

---$color:ソーサー(色)
local color_saucer = 0x02d2d2

---$color:ティー(色)
local color_tea = 0xa14250

-- ---$value:ティー境界補正
---$track:ティー境界補正
---min=-1000
---max=1000
---step=0.1
local tea_boundary_adjust = 5

-- ---$value:取っ手幅
---$track:取っ手幅
---min=0
---max=1000
---step=0.01
local handle_width_ratio = 0.03

-- ---$value:取っ手位置補正
---$track:取っ手位置補正
---min=-1000
---max=1000
---step=0.1
local handle_position_adjust = 1

-- ---$value:ｱﾝﾁｴｲﾘｱｽ[0/1/2]
-- local ANT = 0

local function calculate_cup_profile(x)
    if x <= 0.9 then
        return 1.191156183 * x ^ 4
    else
        local quadratic_coefficient = -12.88588146
        local linear_coefficient = 26.66799905
        return quadratic_coefficient * x * x + linear_coefficient * x + 1 - quadratic_coefficient - linear_coefficient
    end
end

local function polar_to_cartesian(radius, angle)
    return radius * math.cos(angle), radius * math.sin(angle)
end

local vertices_buffer = {}
local function push_poly(x0, y0, z0, x1, y1, z1, x2, y2, z2, x3, y3, z3)
    table.insert(
        vertices_buffer,
        { x0, y0, z0, x1, y1, z1, x2, y2, z2, x3, y3, z3, 0, 0, obj.w, 0, obj.w, obj.h, obj.h, 0 }
    )
end
local function flush_polys()
    obj.drawpoly(vertices_buffer)
    vertices_buffer = {}
end

local cup_radius = track_cup_size / 2
local cup_saucer_gap_ratio = track_cup_saucer_gap / 1000
-- ANT = math.floor(ANT)
local pi = math.pi

--ティーカップ本体作成
obj.load("figure", "四角形", color_cup, cup_radius)

-- if ANT < 2 then
--     obj.setoption("antialias", ANT)
-- end

local y1 = -cup_radius * calculate_cup_profile(0) - cup_radius * cup_saucer_gap_ratio
local previous_radius = 0
for i = 0, segment_count - 1 do
    -- if ANT >= 2 then
    --     if i == segment_count - 1 then
    --         obj.setoption("antialias", 1)
    --     else
    --         obj.setoption("antialias", 0)
    --     end
    -- end
    local profile_ratio = (i + 1) / segment_count
    local y0 = -cup_radius * calculate_cup_profile(profile_ratio) - cup_radius * cup_saucer_gap_ratio
    local current_radius = cup_radius * profile_ratio
    local x0, z0 = polar_to_cartesian(current_radius, 0)
    local x3, z3 = polar_to_cartesian(previous_radius, 0)
    for j = 0, segment_count - 1 do
        -- local start_angle = j * 2 * pi / segment_count
        local end_angle = (j + 1) * 2 * pi / segment_count
        local x1, z1 = polar_to_cartesian(current_radius, end_angle)
        local x2, z2 = polar_to_cartesian(previous_radius, end_angle)
        push_poly(x0, y0, z0, x1, y0, z1, x2, y1, z2, x3, y1, z3)
        x0, z0 = x1, z1
        x3, z3 = x2, z2
    end
    y1 = y0
    previous_radius = current_radius
end
flush_polys()

--皿作成
obj.load("figure", "四角形", color_saucer, cup_radius)
-- if ANT < 2 then
--     obj.setoption("antialias", ANT)
-- end
local v1 = 0
y1 = 0
previous_radius = 0
for i = 0, segment_count - 1 do
    -- if ANT >= 2 then
    --     if i == segment_count - 1 then
    --         obj.setoption("antialias", 1)
    --     else
    --         obj.setoption("antialias", 0)
    --     end
    -- end
    local profile_ratio = (i + 1) / segment_count
    local y0 = -0.26 * cup_radius * profile_ratio ^ 2.4
    local current_radius = 1.5 * cup_radius * profile_ratio
    for j = 0, segment_count - 1 do
        local start_angle = j * 2 * pi / segment_count
        local end_angle = (j + 1) * 2 * pi / segment_count
        local x0, z0 = polar_to_cartesian(current_radius, start_angle)
        local x1, z1 = polar_to_cartesian(current_radius, end_angle)
        local x2, z2 = polar_to_cartesian(previous_radius, end_angle)
        local x3, z3 = polar_to_cartesian(previous_radius, start_angle)
        push_poly(x0, y0, z0, x1, y0, z1, x2, y1, z2, x3, y1, z3)
    end
    -- local v1 = profile_ratio
    y1 = y0
    previous_radius = current_radius
end
flush_polys()

--取っ手作成
obj.load("figure", "四角形", color_cup, cup_radius * 0.6)
-- if ANT > 1 then
--     ANT = 1
-- end
--obj.setoption("antialias", ANT)
local handle_offset_y = cup_radius * calculate_cup_profile(0.85) + cup_radius * cup_saucer_gap_ratio
local handle_offset_x = (0.85 + 0.315) * cup_radius + handle_position_adjust
local handle_half_depth = cup_radius * handle_width_ratio
for j = 0, segment_count - 1 do
    local start_angle = j * 2 * pi / segment_count
    local end_angle = (j + 1) * 2 * pi / segment_count
    local start_height_scale = 1 + 0.5 * ((1 + math.cos(start_angle)) / 2) ^ 12
    local end_height_scale = 1 + 0.5 * ((1 + math.cos(end_angle)) / 2) ^ 12
    local x0, y0 = polar_to_cartesian(cup_radius * 0.30 * start_height_scale, start_angle + 0.7 * pi)
    local x1, y1 = polar_to_cartesian(cup_radius * 0.30 * end_height_scale, end_angle + 0.7 * pi)
    local x2, y2 = polar_to_cartesian(cup_radius * 0.24 * end_height_scale, end_angle + 0.7 * pi)
    local x3, y3 = polar_to_cartesian(cup_radius * 0.24 * start_height_scale, start_angle + 0.7 * pi)
    push_poly(
        x0 + handle_offset_x,
        y0 - handle_offset_y,
        handle_half_depth,
        x1 + handle_offset_x,
        y1 - handle_offset_y,
        handle_half_depth,
        x2 + handle_offset_x,
        y2 - handle_offset_y,
        handle_half_depth,
        x3 + handle_offset_x,
        y3 - handle_offset_y,
        handle_half_depth
    )
    push_poly(
        x0 + handle_offset_x,
        y0 - handle_offset_y,
        -handle_half_depth,
        x1 + handle_offset_x,
        y1 - handle_offset_y,
        -handle_half_depth,
        x2 + handle_offset_x,
        y2 - handle_offset_y,
        -handle_half_depth,
        x3 + handle_offset_x,
        y3 - handle_offset_y,
        -handle_half_depth
    )
    push_poly(
        x0 + handle_offset_x,
        y0 - handle_offset_y,
        handle_half_depth,
        x1 + handle_offset_x,
        y1 - handle_offset_y,
        handle_half_depth,
        x1 + handle_offset_x,
        y1 - handle_offset_y,
        -handle_half_depth,
        x0 + handle_offset_x,
        y0 - handle_offset_y,
        -handle_half_depth
    )
    push_poly(
        x2 + handle_offset_x,
        y2 - handle_offset_y,
        handle_half_depth,
        x3 + handle_offset_x,
        y3 - handle_offset_y,
        handle_half_depth,
        x3 + handle_offset_x,
        y3 - handle_offset_y,
        -handle_half_depth,
        x2 + handle_offset_x,
        y2 - handle_offset_y,
        -handle_half_depth
    )
end

flush_polys()

--紅茶作成
previous_radius = track_tea_level_percent / 100
y1 = -cup_radius * calculate_cup_profile(previous_radius) - cup_radius * cup_saucer_gap_ratio
previous_radius = cup_radius * previous_radius - tea_boundary_adjust
obj.load("figure", "円", color_tea, 2 * previous_radius)
-- if ANT > 1 then
--     ANT = 1
-- end
-- obj.setoption("antialias", ANT)
obj.alpha = 1 - track_opacity / 100
obj.drawpoly(
    -previous_radius,
    y1,
    -previous_radius,
    previous_radius,
    y1,
    -previous_radius,
    previous_radius,
    y1,
    previous_radius,
    -previous_radius,
    y1,
    previous_radius
)
