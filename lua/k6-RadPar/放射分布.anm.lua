--label:tim2
--track0:速度,0,10000,30
--track1:放射度,0,100,100
--track2:初期半径,0,10000,100
--track3:個数,1,10000,30,1
--value@dv:速度誤差,1.5
--value@reg:均等動径配置/chk,0
--value@deg:均等角配置/chk,0
--value@fv:初期回転角誤差,360
--value@rv:最大回転速度,45
--value@endlife:消滅時間,0.3
--value@endv:消滅速度,10
--value@cp:中心,{0,0}
--value@seed:乱数シード,200

local v = obj.track0
local dr = obj.track1 * 0.01
local r1 = obj.track2
local N = math.floor(obj.track3)
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
