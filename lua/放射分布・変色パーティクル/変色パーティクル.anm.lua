--label:tim2\アニメーション効果
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
local col1 = 0xffff00

---$color:色2
local col2 = 0xffffff

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

local T = obj.time
local output_frequency = track_output_frequency
local speed = track_speed
local initial_radius = track_radius
local lifetime = track_lifetime * 0.01
local spawn_interval = 1 / output_frequency
local first_index = math.max(math.floor(1 + (T - lifetime) * output_frequency), 0)
local last_index = math.floor(T * output_frequency)
local final_zoom = track_final_zoom_percent * 0.01
local final_alpha = track_final_alpha_percent * 0.01
local scatter_angle_start = math.min(track_scatter_angle_start or -180, track_scatter_angle_end or 180)
local scatter_angle_end = math.max(track_scatter_angle_start or -180, track_scatter_angle_end or 180)

for i = first_index, last_index do
    local T0 = i * spawn_interval
    local dTi = T - T0

    if dTi < lifetime then
        local p1 = dTi / lifetime
        local p2 = 1 - p1
        local r1, g1, b1 = RGB(col1)
        local r2, g2, b2 = RGB(col2)

        obj.effect(
            "単色化",
            "color",
            RGB(r1 * p2 + r2 * p1, g1 * p2 + g2 * p1, b1 * p2 + b2 * p1),
            "輝度を保持する",
            0
        )

        local dx = obj.getvalue("x", T0, 0)
        local dy = obj.getvalue("y", T0, 0)

        local ddx = dx - obj.getvalue("x", T0 - 1 / obj.framerate, 0)
        local ddy = dy - obj.getvalue("y", T0 - 1 / obj.framerate, 0)

        local th = math.atan2(ddx, ddy)
            + math.rad(obj.rand(10 * scatter_angle_start + 1800, 10 * scatter_angle_end + 1800, i, 1000) * 0.1)

        local Pth = math.rad(obj.rand(0, 3600, i, 2000) * 0.1)
        local iR0 = initial_radius * obj.rand(0, 1000, i, 3000) * 0.001

        local vx = speed * math.sin(th)
        local vy = speed * math.cos(th)

        local x = vx * dTi + dx - obj.getvalue("x") + iR0 * math.cos(Pth)
        local y = vy * dTi + dy - obj.getvalue("y") + iR0 * math.sin(Pth)
        local zoom = p2 + final_zoom * p1
        local alpha = p2 + final_alpha * p1
        obj.draw(x, y, 0, zoom, alpha)
    end
end
