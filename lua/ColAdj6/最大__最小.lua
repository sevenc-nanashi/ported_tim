--label:tim2\未分類\T_Color_Module.anm
---$track:MAX/MIN
---min=1
---max=2
---step=1
local track_max_min = 1

---$track:チャンネル
---min=1
---max=4
---step=1
local track_channel = 1

---$track:範囲
---min=1
---max=1000
---step=1
local track_range = 10

---$track:角度
---min=-3600
---max=3600
---step=0.1
local track_angle = 0

---$check:水平
local HC = true

---$check:垂直
local VC = true

---$track:縦横比
---min=1
---max=100
---step=0.01
local asp = 100

---$check:範囲対称
local Sym2 = true

---$check:色も保存
local svC2 = false

---$select:形状
---四角=0
---円=1
---菱形=2
---十字=3
---六角形=4
local fig = 0

---$track:限界範囲
---min=1
---max=1000
---step=1
local lmt = 50

---$value:α拡張
local Aen = 0

---$check:結果を保存(同条件1度のみ)
local check0 = false

-- require("T_Color_Module")
local T_Color_Module = obj.module("tim2")
local Deg = -track_angle % 360
local asp2 = (asp or 100) / 100
local fig2 = math.floor(fig or 0)
local lmt2 = (lmt or 50)
local Rng = track_range
local Aen2 = Aen or 0
if fig2 > 0 then
    if fig2 ~= 3 then
        Rng = math.min(Rng, lmt2)
    end
end
Rng = math.max(1, Rng)
local ckr = 0
if check0 then
    local userdata, w, h = obj.getpixeldata("object", "bgra")
    ckr = T_Color_Module.minimax_check(
        userdata,
        w,
        h,
        math.floor(track_max_min),
        math.floor(track_channel),
        Rng,
        Deg,
        HC,
        VC,
        asp2,
        Sym2,
        svC2,
        fig2,
        0,
        0
    )
    if ckr == 1 then
        obj.putpixeldata("object", userdata, w, h, "bgra")
    end
end
if ckr == 0 then
    local w0, h0 = obj.getpixel()
    if Deg ~= 0 then
        local RR = Deg / 180 * math.pi
        local w1 = w0 * math.abs(math.cos(RR)) + h0 * math.abs(math.sin(RR))
        local h1 = h0 * math.abs(math.cos(RR)) + w0 * math.abs(math.sin(RR))
        local w2 = w1 + (w1 - w0) % 2
        local h2 = h1 + (h1 - h0) % 2
        local RH = 0
        local wr, hr = w0, h0
        if w1 < w0 then
            obj.effect("ローテーション", "90度回転", 1)
            RH = 1
            wr, hr = hr, wr
        end
        obj.effect("領域拡張", "右", w2 - wr, "下", h2 - hr)
        local userdata, w, h = obj.getpixeldata("object", "bgra")
        T_Color_Module.minimax_rot(userdata, w, h, wr, hr, RR, RH, track_max_min)
        obj.putpixeldata("object", userdata, w, h, "bgra")
    end
    local userdata, w, h = obj.getpixeldata("object", "bgra")
    T_Color_Module.minimax(
        userdata,
        w,
        h,
        track_max_min,
        Rng,
        track_channel,
        HC,
        VC,
        Sym2,
        asp2,
        svC2,
        fig2,
        Aen2
    )
    obj.putpixeldata("object", userdata, w, h, "bgra")
    if Deg ~= 0 then
        obj.setoption("drawtarget", "tempbuffer", w0, h0)
        obj.draw(0, 0, 0, 1, 1, 0, 0, -Deg)
        obj.copybuffer("object", "tempbuffer")
    end
    if check0 then
        local userdata, w, h = obj.getpixeldata("object", "bgra")
        T_Color_Module.MinimaxSave(userdata, w, h)
    end
end
obj.cx = 0
obj.cy = 0