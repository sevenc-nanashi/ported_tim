--label:tim2\アニメーション効果
---$track:速度
---min=0
---max=10000
---step=0.1
local track_speed = 30

---$track:放射度
---min=0
---max=100
---step=0.1
local track_radial_amount = 100

---$track:初期半径
---min=0
---max=10000
---step=0.1
local track_radius = 100

---$track:個数
---min=1
---max=10000
---step=1
local track_count = 30

---$track:速度誤差
---min=0
---max=10
---step=0.01
local track_speed_error = 1.5

---$check:均等動径配置
local check_even_radius_distribution = 0

---$check:均等角配置
local check_even_angle_distribution = 0

---$track:初期回転角誤差
---min=0
---max=360
---step=0.1
local track_initial_rotation_error = 360

---$track:最大回転速度
---min=0
---max=1000
---step=0.1
local track_max_rotation_speed = 45

---$track:消滅時間
---min=0
---max=10
---step=0.01
local track_fade_duration = 0.3

---$track:消滅速度
---min=0
---max=100
---step=0.1
local track_fade_speed = 10

---$track:中心X
---min=-2000
---max=2000
---step=0.1
local track_center_x = 0

---$track:中心Y
---min=-2000
---max=2000
---step=0.1
local track_center_y = 0

---$track:乱数シード
---min=0
---max=1000000
---step=1
local track_random_seed = 200

local speed = track_speed
local radial_amount = track_radial_amount * 0.01
local initial_radius = track_radius
local particle_count = math.floor(track_count)
local speed_error = math.max(track_speed_error or 0, 0)
local is_even_radius_distribution = check_even_radius_distribution == true or check_even_radius_distribution == 1
local is_even_angle_distribution = check_even_angle_distribution == true or check_even_angle_distribution == 1
local initial_rotation_error = math.max(track_initial_rotation_error or 360, 0) * 10
local max_rotation_speed = track_max_rotation_speed or 45
local fade_duration = math.max(track_fade_duration or 0, 0)
local fade_speed = math.max(track_fade_speed or 0, 0)
local center_x = track_center_x or 0
local center_y = track_center_y or 0
local random_seed = math.floor(track_random_seed or 200)
local sector_count = math.min(particle_count, 8)
local radius_distribution_min = is_even_radius_distribution and 1000 or 0

local T = obj.time
local total_time = obj.totaltime
obj.setoption("drawtarget", "tempbuffer", obj.screen_w, obj.screen_h)
for i = 1, particle_count do
    local q = obj.rand(radius_distribution_min, 1000, i, 1000 + random_seed) * 0.001
    local r = initial_radius * math.sqrt(q)
        + speed * (1 + speed_error * obj.rand(0, 1000, i, 2000 + random_seed) * 0.001) * T
    local sector_index = i % sector_count
    local d1
    if is_even_angle_distribution then
        d1 = 2 * math.pi * (i - 1) / particle_count
    else
        d1 = 2
            * math.pi
            * obj.rand(
                sector_index / sector_count * 1000,
                (sector_index + 1) / sector_count * 1000,
                i,
                3000 + random_seed
            )
            * 0.001
    end
    r = r * radial_amount
    local x = r * math.cos(d1)
    local y = r * math.sin(d1)
    local rot = obj.rand(0, initial_rotation_error, i, 4000 + random_seed) * 0.1
        + max_rotation_speed * obj.rand(-1000, 1000, i, 5000 + random_seed) * 0.001 * T
    local alp = 1
    local fade_start_time = total_time - i / particle_count * fade_duration
    if T > fade_start_time then
        alp = math.max(0, 1 - fade_speed * (T - fade_start_time))
    end
    obj.draw(x + center_x, y + center_y, 0, radial_amount, alp, 0, 0, rot)
end

obj.copybuffer("obj", "tmp")
