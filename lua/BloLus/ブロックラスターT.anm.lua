--label:tim2
---$track:高さ
---min=1
---max=1000
---step=0.1
local track_height = 30

---$track:振幅
---min=-5000
---max=5000
---step=0.1
local track_width = 100

---$track:波長
---min=1
---max=5000
---step=0.1
local track_wavelength = 600

---$track:ﾗﾝﾀﾞﾑ性
---min=-100
---max=100
---step=0.1
local track_randomness = 0

---$check:縦方向
local check0 = false

---$value:速度(px/s)
local rtv = 100

---$value:ｵﾌｾｯﾄ(px)
local sfh = 0

---$value:振幅単位
local aut = 0

---$check:画像もシフト(px)
local ick = 0

---$value:開始振幅%
local dw1 = 100

---$value:終了振幅%
local dw2 = 100

---$value:シード
local seed = 0

local A = track_width
if A ~= 0 then
    if check0 then
        obj.effect("ローテーション", "90度回転", 1)
    end

    local pi = math.pi
    local sin = math.sin
    local L = track_height
    local D = track_wavelength
    local R = track_randomness / 100
    local w, h = obj.getpixel()
    rtv = rtv or 0
    sfh = sfh or 0
    aut = aut or 0
    ick = ick or 0
    dw1 = math.min(100, math.max(0, dw1 or 100)) / 100
    dw2 = math.min(100, math.max(0, dw2 or 100)) / 100
    seed = -1 - math.abs(seed or 0)
    local d = rtv * obj.time
    local w2, h2, L2 = w / 2, h / 2, L / 2

    if ick == 1 then
        obj.setoption("drawtarget", "tempbuffer", w, h)
        obj.setoption("blend", "alpha_add2")
        local dy = d % h
        obj.draw(0, dy)
        obj.draw(0, dy - h)
        obj.load("tempbuffer")
    end

    local dd = d + L2 + sfh
    local n = math.floor((-h2 - dd) / L)
    local y1 = dd + n * L
    local s = 1

    obj.setoption("drawtarget", "tempbuffer", w + 2 * math.abs(A), h)
    obj.setoption("blend", "alpha_add2")

    while y1 < h2 do
        local y2 = y1 + L
        local y = y2 - dd
        local x1 = sin(2 * pi * y / D)
        if R > 0 then
            local x0 = 0
            local B = 0
            for i = 1, 4 do
                local B0 = obj.rand(1, 1000, seed, i) / 1000
                local C0 = obj.rand(1, 1000, seed, i + 1000) / 1000
                x0 = x0 + B0 * sin(2 * i * pi * (y / D + C0))
                B = B + B0
            end
            x0 = x0 / B
            x1 = (1 - R) * x1 + R * x0
        elseif R < 0 then
            n = n + 1
            local x0 = obj.rand(-1000, 1000, seed, n) / 1000
            x1 = (1 + R) * x1 - R * x0
        end
        x1 = A * x1
        if aut > 0 then
            if x1 > 0 then
                x1 = aut * math.floor(x1 / aut)
            else
                x1 = -aut * math.floor(-x1 / aut)
            end
        end
        x1 = x1 * (dw1 + (dw2 - dw1) * (y1 + h2) / h)
        x1 = x1 - w2
        local x2 = x1 + w
        y1 = math.max(y1, -h2)
        y2 = math.min(y2, h2)
        local v1, v2 = y1 + h2, y2 + h2
        obj.drawpoly(x1, y1, 0, x2, y1, 0, x2, y2, 0, x1, y2, 0, 0, v1, w, v1, w, v2, 0, v2)
        y1 = y2
        s = s + 1
    end
    obj.load("tempbuffer")
    if check0 then
        obj.effect("ローテーション", "90度回転", -1)
    end
end
