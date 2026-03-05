--label:tim2
--track0:出力頻度,1,5000,30
--track1:出力速度,0,5000,30
--track2:初期半径,0,10000,50
--track3:生存時間,0,10000,300

--value@col1:色1/col,0xffff00
--value@col2:色2/col,0xffffff
--value@zV:最終拡大率,50
--value@aV:最終透過度,20
--value@Fai:拡散角度,{-180,180}

local T = obj.time
local dn = obj.track0
local V = obj.track1
local R0 = obj.track2
local Life = obj.track3 * 0.01
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
