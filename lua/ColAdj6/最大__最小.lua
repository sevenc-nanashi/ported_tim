--label:tim2\T_Color_Module.anm
---$track:MAX/MIN
---min=1
---max=2
---step=1
local rename_me_track0 = 1

---$track:ﾁｬﾝﾈﾙ
---min=1
---max=4
---step=1
local rename_me_track1 = 1

---$track:範囲
---min=1
---max=1000
---step=1
local rename_me_track2 = 10

---$track:角度
---min=-3600
---max=3600
---step=0.1
local rename_me_track3 = 0

---$check:水平
local HC = 1

---$check:垂直
local VC = 1

---$value:縦横比
local asp = 100

---$check:範囲対称
local Sym = 1

---$check:色も保存
local svC = 0

---$value:形状[0..4]
local fig = 0

---$value:限界範囲
local lmt = 50

---$value:α拡張
local Aen = 0

---$check:結果を保存(同条件1度のみ)
local rename_me_check0 = false

require("T_Color_Module")
local Deg = -rename_me_track3 % 360
local Sym2 = Sym or 0
local asp2 = (asp or 100) / 100
local svC2 = svC or 0
local fig2 = math.floor(fig or 0)
local lmt2 = (lmt or 50)
local Rng = rename_me_track2
local Aen2 = Aen or 0
if fig2 > 0 then
    if fig2 ~= 3 then
        Rng = math.min(Rng, lmt2)
    end
end
Rng = math.max(1, Rng)
local ckr = 0
if rename_me_check0 then
    local userdata, w, h = obj.getpixeldata()
    ckr = T_Color_Module.MinimaxCheck(
        userdata,
        w,
        h,
        math.floor(rename_me_track0),
        math.floor(rename_me_track1),
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
        obj.putpixeldata(userdata)
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
        local userdata, w, h = obj.getpixeldata()
        T_Color_Module.MinmaxRot(userdata, w, h, wr, hr, RR, RH, rename_me_track0)
        obj.putpixeldata(userdata)
    end
    local userdata, w, h = obj.getpixeldata()
    T_Color_Module.Minimax(
        userdata,
        w,
        h,
        rename_me_track0,
        Rng,
        rename_me_track1,
        HC,
        VC,
        Sym2,
        asp2,
        svC2,
        fig2,
        Aen2
    )
    obj.putpixeldata(userdata)
    if Deg ~= 0 then
        obj.setoption("drawtarget", "tempbuffer", w0, h0)
        obj.draw(0, 0, 0, 1, 1, 0, 0, -Deg)
        obj.copybuffer("obj", "tmp")
    end
    if rename_me_check0 then
        local userdata, w, h = obj.getpixeldata()
        T_Color_Module.MinimaxSave(userdata, w, h)
    end
end
obj.cx = 0
obj.cy = 0
