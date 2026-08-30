--label:${ROOT_CATEGORY}\アニメーション効果
---$track:出力頻度
---min=1
---max=5000
---step=0.1
local track_output_frequency = 30

---$track:出力速度
---min=0
---max=5000
---step=0.1
local track_speed = 30

---$track:初期半径
---min=0
---max=10000
---step=0.1
local track_radius = 50

---$track:生存時間
---min=0
---max=10000
---step=0.1
local track_lifetime = 300

---$color:色1
local start_color = 0xffff00

---$color:色2
local end_color = 0xffffff

---$track:最終拡大率[%]
---min=0
---max=1000
---step=0.1
local track_final_zoom_percent = 50

---$track:最終透過度[%]
---min=0
---max=1000
---step=0.1
local track_final_alpha_percent = 20

---$track:拡散角度開始
---min=-180
---max=180
---step=0.1
local track_scatter_angle_start = -180

---$track:拡散角度終了
---min=-180
---max=180
---step=0.1
local track_scatter_angle_end = 180

local current_time = obj.time
local output_frequency = track_output_frequency
local speed = track_speed
local initial_radius = track_radius
local lifetime = track_lifetime * 0.01
local spawn_interval = 1 / output_frequency
local first_index = math.max(math.floor(1 + (current_time - lifetime) * output_frequency), 0)
local last_index = math.floor(current_time * output_frequency)
local final_zoom = track_final_zoom_percent * 0.01
local final_alpha = track_final_alpha_percent * 0.01
local scatter_angle_start = math.min(track_scatter_angle_start or -180, track_scatter_angle_end or 180)
local scatter_angle_end = math.max(track_scatter_angle_start or -180, track_scatter_angle_end or 180)

for i = first_index, last_index do
    local spawn_time = i * spawn_interval
    local particle_age = current_time - spawn_time

    if particle_age < lifetime then
        local life_progress = particle_age / lifetime
        local inverse_life_progress = 1 - life_progress
        local start_red, start_green, start_blue = RGB(start_color)
        local end_red, end_green, end_blue = RGB(end_color)

        obj.effect(
            "単色化",
            "color",
            RGB(
                start_red * inverse_life_progress + end_red * life_progress,
                start_green * inverse_life_progress + end_green * life_progress,
                start_blue * inverse_life_progress + end_blue * life_progress
            ),
            "輝度を保持する",
            0
        )

        local spawn_x = obj.getvalue("particle_x", spawn_time, 0)
        local spawn_y = obj.getvalue("particle_y", spawn_time, 0)

        local source_velocity_x = spawn_x - obj.getvalue("particle_x", spawn_time - 1 / obj.framerate, 0)
        local source_velocity_y = spawn_y - obj.getvalue("particle_y", spawn_time - 1 / obj.framerate, 0)

        local trajectory_angle = math.atan2(source_velocity_x, source_velocity_y)
            + math.rad(obj.rand(10 * scatter_angle_start + 1800, 10 * scatter_angle_end + 1800, i, 1000) * 0.1)

        local radius_angle = math.rad(obj.rand(0, 3600, i, 2000) * 0.1)
        local random_initial_radius = initial_radius * obj.rand(0, 1000, i, 3000) * 0.001

        local velocity_x = speed * math.sin(trajectory_angle)
        local velocity_y = speed * math.cos(trajectory_angle)

        local particle_x = velocity_x * particle_age
            + spawn_x
            - obj.getvalue("particle_x")
            + random_initial_radius * math.cos(radius_angle)
        local particle_y = velocity_y * particle_age
            + spawn_y
            - obj.getvalue("particle_y")
            + random_initial_radius * math.sin(radius_angle)
        local zoom = inverse_life_progress + final_zoom * life_progress
        local alpha = inverse_life_progress + final_alpha * life_progress
        obj.draw(particle_x, particle_y, 0, zoom, alpha)
    end
end
