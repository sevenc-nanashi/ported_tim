--label:${ROOT_CATEGORY}\カスタムオブジェクト
local draw_rectangle, core_size
---$track:パターン
---min=0
---max=1000
---step=0.1
local track_pattern = 0

---$track:展開度
---min=0
---max=100
---step=0.01
local track_unfold_amount = 50

---$track:サイズ
---min=1
---max=100
---step=0.1
local track_size = 6

---$track:コア間隔
---min=2
---max=100
---step=0.1
local track_interval = 3

---$value:位置
local core_position = { 0, -150, 0, 150 }

---$color:コア色
local core_color = 0xffffff

--group:発光

---$color:発光色
local glow_color = 0x0000ff

---$track:発光強さ
---min=0
---max=200
---step=0.1
local track_glow_strength = 40

---$track:発光拡散
---min=0
---max=1000
---step=0.1
local track_glow_diffusion = 300

---$track:発光しきい値
---min=0
---max=200
---step=0.1
local track_glow_threshold = 0

---$track:発光拡散速度
---min=0
---max=100
---step=0.1
local track_glow_diffusion_speed = 10

--group:軌道

---$track:軌道フォーク数
---min=0
---max=25
---step=1
local track_fork_count = 8

---$track:軌道直進性
---min=1
---max=100
---step=1
local track_straightness = 8

---$track:軌道設置範囲
---min=0
---max=100
---step=0.1
local track_branch_range = 30

---$track:軌道折れ確率
---min=0
---max=100
---step=0.1
local track_bend_probability = 80

--group:

---$value:領域サイズ
local track_area_size = { -180, -180, 180, 180 }

---$check:枠表示
local check_show_frame = true

local random_seed = math.floor(track_pattern)

local attenuation_rate = 100 - track_unfold_amount
attenuation_rate = (math.exp(0.10 * attenuation_rate) - 1) / 62

local fast_draw_buffer = {}
local function fast_draw(x, y, zoom)
    table.insert(fast_draw_buffer, {
        x - obj.w / 2 * zoom,
        y - obj.h / 2 * zoom,
        0,
        x + obj.w / 2 * zoom,
        y - obj.h / 2 * zoom,
        0,
        x + obj.w / 2 * zoom,
        y + obj.h / 2 * zoom,
        0,
        x - obj.w / 2 * zoom,
        y + obj.h / 2 * zoom,
        0,
        0,
        0,
        obj.w,
        0,
        obj.w,
        obj.h,
        0,
        obj.h,
    })
end
local function flush_fast_draw()
    if #fast_draw_buffer == 0 then
        return
    end
    obj.drawpoly(fast_draw_buffer)
    fast_draw_buffer = {}
end

local function draw_lightning_branch(
    start_x,
    start_y,
    end_x,
    end_y,
    core_interval,
    branch_size,
    straightness,
    remaining_forks,
    branch_range
)
    if core_interval < 0.3 then
        return
    end

    local branch_vector_x, branch_vector_y = end_x - start_x, end_y - start_y
    local branch_length_squared = branch_vector_x * branch_vector_x + branch_vector_y * branch_vector_y
    local branch_length = math.sqrt(branch_length_squared)
    local base_step_x = branch_vector_x * core_interval / branch_length
    local base_step_y = branch_vector_y * core_interval / branch_length

    fast_draw(start_x, start_y, branch_size / core_size)

    local angle_jitter = obj.rand(-75, 75, 0, 10 + random_seed) * 0.01
    local angle_sine = math.sin(angle_jitter)
    local angle_cosine = math.cos(angle_jitter)
    local step_x, step_y =
        angle_cosine * base_step_x + angle_sine * base_step_y, -angle_sine * base_step_x + angle_cosine * base_step_y
    local offset_x = 0
    local offset_y = 0
    local i = 0

    local branch_trigger_offsets = {}

    for j = 1, 3 do
        branch_trigger_offsets[j] = obj.rand(0, branch_vector_y * 0.5, i, j + random_seed)
    end

    while offset_y * offset_y < branch_vector_y * branch_vector_y do
        i = i + 1
        local attenuation = math.exp(-attenuation_rate * offset_y / branch_vector_y)

        if attenuation < 0.005 then
            return
        end

        local retry_count = 0
        repeat
            retry_count = retry_count + 1
            angle_jitter = obj.rand(-75, 75, i, 12 + random_seed + 100 * retry_count) * 0.01
            angle_sine = math.sin(angle_jitter)
            angle_cosine = math.cos(angle_jitter)
            step_x, step_y =
                (angle_cosine * base_step_x + angle_sine * base_step_y) * attenuation,
                (-angle_sine * base_step_x + angle_cosine * base_step_y) * attenuation
        until step_y * base_step_y > 0

        local run_length_factor = math.log(obj.rand(2, 100, i, 11 + random_seed))
            / math.log(track_bend_probability)
            / core_interval

        for k = 0, straightness * run_length_factor do
            fast_draw(
                start_x + offset_x + k * step_x,
                start_y + offset_y + k * step_y,
                branch_size / core_size * attenuation
            )
        end

        offset_x = offset_x + straightness * run_length_factor * step_x
        offset_y = offset_y + straightness * run_length_factor * step_y

        for j = 1, 3 do
            if
                branch_trigger_offsets[j] ~= nil
                and branch_trigger_offsets[j] * branch_trigger_offsets[j] < offset_y * offset_y
                and remaining_forks > 1
            then
                random_seed = random_seed + 1
                remaining_forks = remaining_forks - 1
                local fork_end_offset_x = obj.rand(-branch_range, branch_range, i, 13 + random_seed)
                    * 0.01
                    * branch_vector_y
                draw_lightning_branch(
                    start_x + offset_x,
                    start_y + offset_y,
                    end_x + fork_end_offset_x,
                    end_y,
                    core_interval * 0.8 * attenuation,
                    branch_size * 0.8 * attenuation,
                    straightness,
                    remaining_forks,
                    branch_range
                )
                branch_trigger_offsets[j] = nil
            end
        end
    end
end

function draw_rectangle(x1, y1, x2, y2)
    obj.drawpoly(x1, y1, 0, x2, y1, 0, x2, y2, 0, x1, y2, 0, 0, 0, obj.w, 0, obj.w, obj.h, 0, obj.h)
end

core_size = track_size
local remaining_forks = math.floor(track_fork_count or 0)
local straightness = math.floor(track_straightness or 1)
local branch_range = track_branch_range or 30
local glow_strength = track_glow_strength or 40
local glow_diffusion = track_glow_diffusion or 300
local glow_threshold = track_glow_threshold or 0
local glow_diffusion_speed = track_glow_diffusion_speed or 10

local core_interval = track_interval

obj.setanchor("core_position", 2, "line")
local start_x, start_y, end_x, end_y = unpack(core_position)
obj.setanchor("track_area_size", 2)
local area_min_x, area_min_y, area_max_x, area_max_y = unpack(track_area_size)
local area_center_x, area_center_y = (area_max_x + area_min_x) / 2, (area_max_y + area_min_y) / 2

if remaining_forks > 25 then
    remaining_forks = 25
end

straightness = math.floor(straightness)
if straightness < 1 then
    straightness = 1
end

obj.setoption("drawtarget", "tempbuffer", math.abs(area_max_x - area_min_x), math.abs(area_max_y - area_min_y))

obj.load("figure", "円", core_color, core_size)

draw_lightning_branch(
    start_x - area_center_x,
    start_y - area_center_y,
    end_x - area_center_x,
    end_y - area_center_y,
    core_interval,
    core_size,
    straightness,
    remaining_forks,
    branch_range
)
flush_fast_draw()

if obj.getoption("gui") == true and obj.getinfo("saving") == false and check_show_frame then
    obj.load("figure", "四角形", 0xffffff, 100)
    area_min_x = area_min_x - area_center_x
    area_max_x = area_max_x - area_center_x
    area_min_y = area_min_y - area_center_y
    area_max_y = area_max_y - area_center_y
    draw_rectangle(area_min_x, area_min_y - 0.5, area_max_x, area_min_y + 0.5)
    draw_rectangle(area_min_x, area_max_y - 0.5, area_max_x, area_max_y + 0.5)
    draw_rectangle(area_min_x - 0.5, area_min_y, area_min_x + 0.5, area_max_y)
    draw_rectangle(area_max_x - 0.5, area_min_y, area_max_x + 0.5, area_max_y)
end

obj.load("tempbuffer")

obj.cx, obj.cy = obj.cx - area_center_x, obj.cy - area_center_y

obj.effect("色調補正", "明るさ", 200)
obj.effect(
    "発光",
    "強さ",
    glow_strength,
    "拡散",
    glow_diffusion,
    "しきい値",
    glow_threshold,
    "拡散速度",
    glow_diffusion_speed,
    "color",
    core_color,
    "no_color",
    0,
    "サイズ固定",
    1
)
obj.effect(
    "発光",
    "強さ",
    glow_strength,
    "拡散",
    glow_diffusion,
    "しきい値",
    glow_threshold,
    "拡散速度",
    glow_diffusion_speed,
    "color",
    glow_color,
    "no_color",
    0,
    "サイズ固定",
    1
)
