--label:tim2\集中線T.obj
---$track:発生確率
---min=0
---max=100
---step=0.1
local track_spawn_probability = 40

---$track:線幅
---min=1
---max=400
---step=0.1
local track_line_width = 15

---$track:中心
---min=0
---max=100
---step=0.1
local track_center = 15

---$track:局所性
---min=0
---max=100
---step=0.1
local track_locality = 0

---$color:色
local color = 0xffffff

---$value:中心位置
local CC = { 0, 0 }

---$value:中心ランダム度
local rnd = 30

---$value:局所ジャンプ率％
local Ljp = 15

---$value:変化速度
local sp = 0

---$value:ぼかし
local blur = 0

---$value:最大本数
local maxN = 500

---$value:シード
local seed = 0

---$value:幅
local w = nil

---$value:高さ
local h = nil

---$value:中心追尾
local ad = 0

---$check:最大本数自動計算
local check0 = false

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

local P = track_spawn_probability
local ws = track_line_width
local Cen = track_center * 0.01
local Lt = 1 - math.log(track_locality + 1) / math.log(101)
local screen_w = w or obj.screen_w
local screen_h = h or obj.screen_h
local size = math.sqrt(screen_w * screen_w + screen_h * screen_h)
if check0 then
    maxN = math.floor(200 * math.pi / ws)
end
rnd = rnd * 0.01
ws = ws * size / 1000
Cen = Cen * size
seed = seed + math.floor(obj.time * obj.framerate * sp)
obj.load("figure", "四角形", color, 1)
obj.setoption("drawtarget", "tempbuffer", screen_w, screen_h)
local calP = {}
if track_locality == 0 or P == 100 then
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
