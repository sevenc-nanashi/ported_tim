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

---$value:速度誤差
local dv = 1.5

---$check:均等動径配置
local reg = 0

---$check:均等角配置
local deg = 0

---$value:初期回転角誤差
local fv = 360

---$value:最大回転速度
local rv = 45

---$value:消滅時間
local endlife = 0.3

---$value:消滅速度
local endv = 10

---$value:中心
local cp = { 0, 0 }

---$value:乱数シード
local seed = 200

local v = track_speed
local dr = track_radial_amount * 0.01
local r1 = track_radius
local N = math.floor(track_count)
fv = 10 * (fv or 360) -- 旧Ver対策
reg = reg or 0 -- 旧Ver対策
deg = deg or 0 -- 旧Ver対策
cp = cp or { 0, 0 } -- 旧Ver対策
local spN = math.min(N, 8)
if reg == 1 then
    reg = 1000
else
    reg = 0
end

local T = obj.time
local TT = obj.totaltime
obj.setoption("drawtarget", "tempbuffer", obj.screen_w, obj.screen_h)
for i = 1, N do
    local p = obj.rand(0, 1000, i, seed) * 0.001
    local q = obj.rand(reg, 1000, i, 1000 + seed) * 0.001
    local r = r1 * math.sqrt(q) + v * (1 + dv * obj.rand(0, 1000, i, 2000 + seed) * 0.001) * T
    local spi = i % spN
    local d1
    if deg == 1 then
        d1 = 2 * math.pi * (i - 1) / N
    else
        d1 = 2 * math.pi * obj.rand(spi / spN * 1000, (spi + 1) / spN * 1000, i, 3000 + seed) * 0.001
    end
    r = r * dr
    local x = r * math.cos(d1)
    local y = r * math.sin(d1)
    local rot = obj.rand(0, fv, i, 4000 + seed) * 0.1 + rv * obj.rand(-1000, 1000, i, 5000 + seed) * 0.001 * T
    local alp = 1
    local limT = TT - i / N * endlife
    if T > limT then
        alp = math.max(0, 1 - endv * (T - limT))
    end
    obj.draw(x + cp[1], y + cp[2], 0, dr, alp, 0, 0, rot)
end

obj.copybuffer("obj", "tmp")
