--label:tim2\未分類
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

---$value:最終拡大率
local zV = 50

---$value:最終透過度
local aV = 20

---$value:拡散角度
local Fai = { -180, 180 }

local T = obj.time
local dn = track_output_frequency
local V = track_speed
local R0 = track_radius
local Life = track_lifetime * 0.01
local dS = 1 / dn
local i1 = math.max(math.floor(1 + (T - Life) * dn), 0)
local i2 = math.floor(T * dn)
zV = zV * 0.01
aV = aV * 0.01

for i = i1, i2 do
    local T0 = i * dS
    local dTi = T - T0

    if dTi < Life then
        local p1 = dTi / Life
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

        local th = math.atan2(ddx, ddy) + math.rad(obj.rand(10 * Fai[1] + 1800, 10 * Fai[2] + 1800, i, 1000) * 0.1)

        local Pth = math.rad(obj.rand(0, 3600, i, 2000) * 0.1)
        local iR0 = R0 * obj.rand(0, 1000, i, 3000) * 0.001

        local vx = V * math.sin(th)
        local vy = V * math.cos(th)

        local x = vx * dTi + dx - obj.getvalue("x") + iR0 * math.cos(Pth)
        local y = vy * dTi + dy - obj.getvalue("y") + iR0 * math.sin(Pth)
        local zoom = p2 + zV * p1
        local alpha = p2 + aV * p1
        obj.draw(x, y, 0, zoom, alpha)
    end
end
