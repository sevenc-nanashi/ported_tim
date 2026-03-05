--label:tim2\集中線T.obj\集中線T1
--track0:発生確率,0,100,40
--track1:線幅,1,400,15
--track2:中心,0,100,15
--track3:局所性,0,100,0
--value@color:色/col,0xffffff
--value@CC:中心位置,{0,0}
--value@rnd:中心ランダム度,30
--value@Ljp:局所ジャンプ率％,15
--value@sp:変化速度,0
--value@blur:ぼかし,0
--value@maxN:最大本数,500
--value@seed:シード,0
--value@w:幅,nil
--value@h:高さ,nil
--value@ad:中心追尾,0
--check0:最大本数自動計算,0;

local CalXY = function(x0, y0, x1, y1, a, b)
    local AA = ((x1 - x0) / a) ^ 2 + ((y1 - y0) / b) ^ 2
    local BB = x0 * (x1 - x0) / (a * a) + y0 * (y1 - y0) / (b * b)
    local CC = x0 * x0 / (a * a) + y0 * y0 / (b * b) - 1
    local k = (-BB + math.sqrt(BB * BB - AA * CC)) / AA
    local xx = x0 + k * (x1 - x0)
    local yy = y0 + k * (y1 - y0)
    return xx, yy
end

local Cx
local Cy
if ad == nil or ad == 0 then
    obj.setanchor("CC", 1)
    Cx = CC[1]
    Cy = CC[2]
else
    Cx = obj.getvalue("layer" .. ad .. ".x")
    Cy = obj.getvalue("layer" .. ad .. ".y")
end

local P = obj.track0
local ws = obj.track1
local Cen = obj.track2 * 0.01
local Lt = 1 - math.log(obj.track3 + 1) / math.log(101)
local screen_w = w or obj.screen_w
local screen_h = h or obj.screen_h
local size = math.sqrt(screen_w * screen_w + screen_h * screen_h)
if obj.check0 then
    maxN = math.floor(200 * math.pi / ws)
end
rnd = rnd * 0.01
ws = ws * size / 1000
Cen = Cen * size
seed = seed + math.floor(obj.time * obj.framerate * sp)
obj.load("figure", "四角形", color, 1)
obj.setoption("drawtarget", "tempbuffer", screen_w, screen_h)
local calP = {}
if obj.track3 == 0 or P == 100 then
    for i = 1, maxN do
        if P >= obj.rand(0, 100, -i, seed + 1000) then
            calP[i] = 1
        end
    end
else
    local BlockN = 3 + (maxN / 4 - 3) * Lt
    local Lnum = maxN / BlockN
    P = P * 0.01
    for j = 0, BlockN - 1 do
        for k = 0, P * Lnum - 1 do
            local i = math.floor(k + Lnum * j + 1)
            calP[i] = 1
        end
    end
    for i = 1, maxN do
        if Ljp >= obj.rand(0, 100, -i, seed + 2000) and Ljp > 0 then
            local j = obj.rand(1, maxN, -i, seed + 4000)
            calP[i], calP[j] = calP[j], calP[i]
        end
    end
end
local const1 = 2 * math.pi / maxN
local const2 = obj.rand(0, 3600, -1, seed + 4000) * math.pi / 1800
local a = screen_w / math.sqrt(2)
local b = screen_h / math.sqrt(2)
for i = 1, maxN do
    if calP[i] == 1 then
        local rad = const1 * i + const2
        local r1 = Cen + size * rnd * obj.rand(0, 1000, -i, seed + 5000) / 1000
        local r2 = r1 + size
        local x0 = r1 * math.sin(rad)
        local y0 = r1 * math.cos(rad)
        local x1 = -ws * math.cos(rad) + r2 * math.sin(rad)
        local y1 = ws * math.sin(rad) + r2 * math.cos(rad)
        local x2 = ws * math.cos(rad) + r2 * math.sin(rad)
        local y2 = -ws * math.sin(rad) + r2 * math.cos(rad)

        x1, y1 = CalXY(x0, y0, x1, y1, a, b)
        x2, y2 = CalXY(x0, y0, x2, y2, a, b)
        local xm = (x1 + x2) / 2 - Cx
        local ym = (y1 + y2) / 2 - Cy
        local ds = math.sqrt(xm * xm + ym * ym)
        x0, y0 = Cx + xm * r1 / ds, Cy + ym * r1 / ds
        local dx = (x1 + x2) / 2 - x0
        local dy = (y1 + y2) / 2 - y0

        if dx * xm + dy * ym > 0 then
            obj.drawpoly(x0, y0, 0, x0, y0, 0, x1, y1, 0, x2, y2, 0)
        end
    end
end
obj.load("tempbuffer")
obj.effect("ぼかし", "範囲", blur, "サイズ固定", 1)
