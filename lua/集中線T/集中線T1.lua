--label:tim2\カスタムオブジェクト\@集中線T
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

---$track:中心位置X
---min=-5000
---max=5000
---step=0.1
local track_center_x = 0

---$track:中心位置Y
---min=-5000
---max=5000
---step=0.1
local track_center_y = 0

--trackgroup@track_center_x,track_center_y:中心位置

---$track:中心ランダム度
---min=0
---max=1000
---step=0.1
local track_center_randomness = 30

---$track:局所ジャンプ率[%]
---min=0
---max=100
---step=0.1
local track_local_jump_probability = 15

---$track:変化速度
---min=-100
---max=100
---step=0.1
local track_change_speed = 0

---$track:ぼかし
---min=0
---max=1000
---step=0.1
local track_blur = 0

---$track:最大本数
---min=1
---max=5000
---step=1
local track_max_line_count = 500

---$track:シード
---min=0
---max=1000000
---step=1
local track_seed = 0

---$track:幅
---min=0
---max=10000
---step=1
local track_width = 0

---$track:高さ
---min=0
---max=10000
---step=1
local track_height = 0

---$track:中心追尾レイヤー
---min=0
---max=1000
---step=1
local track_follow_center_layer = 0

---$check:最大本数自動計算
local check_auto_max_line_count = false

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
if track_follow_center_layer == nil or track_follow_center_layer == 0 then
    obj.setanchor("track_center_x,track_center_y", 0)
    Cx = track_center_x
    Cy = track_center_y
else
    Cx = obj.getvalue("layer" .. track_follow_center_layer .. ".x")
    Cy = obj.getvalue("layer" .. track_follow_center_layer .. ".y")
end

local P = track_spawn_probability
local ws = track_line_width
local Cen = track_center * 0.01
local Lt = 1 - math.log(track_locality + 1) / math.log(101)
local screen_w = track_width > 0 and track_width or obj.screen_w
local screen_h = track_height > 0 and track_height or obj.screen_h
local maxN = track_max_line_count
local size = math.sqrt(screen_w * screen_w + screen_h * screen_h)
if check_auto_max_line_count then
    maxN = math.floor(200 * math.pi / ws)
end
local rnd = track_center_randomness * 0.01
local Ljp = track_local_jump_probability
ws = ws * size / 1000
Cen = Cen * size
local seed = track_seed + math.floor(obj.time * obj.framerate * track_change_speed)
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
obj.effect("ぼかし", "範囲", track_blur, "サイズ固定", 1)
