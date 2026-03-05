--label:tim2\T_Color_Module.anm\最大/最小
--track0:MAX/MIN,1,2,1,1
--track1:ﾁｬﾝﾈﾙ,1,4,1,1
--track2:範囲,1,1000,10,1
--track3:角度,-3600,3600,0
--value@HC:水平/chk,1
--value@VC:垂直/chk,1
--value@asp:縦横比,100
--value@Sym:範囲対称/chk,1
--value@svC:色も保存/chk,0
--value@fig:形状[0..4],0
--value@lmt:限界範囲,50
--value@Aen:α拡張,0
--check0:結果を保存(同条件1度のみ),0
require("T_Color_Module")
local Deg = -obj.track3 % 360
local Sym2 = Sym or 0
local asp2 = (asp or 100) / 100
local svC2 = svC or 0
local fig2 = math.floor(fig or 0)
local lmt2 = (lmt or 50)
local Rng = obj.track2
local Aen2 = Aen or 0
if fig2 > 0 then
    if fig2 ~= 3 then
        Rng = math.min(Rng, lmt2)
    end
end
Rng = math.max(1, Rng)
local ckr = 0
if obj.check0 then
    local userdata, w, h = obj.getpixeldata()
    ckr = T_Color_Module.MinimaxCheck(
        userdata,
        w,
        h,
        math.floor(obj.track0),
        math.floor(obj.track1),
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
        T_Color_Module.MinmaxRot(userdata, w, h, wr, hr, RR, RH, obj.track0)
        obj.putpixeldata(userdata)
    end
    local userdata, w, h = obj.getpixeldata()
    T_Color_Module.Minimax(userdata, w, h, obj.track0, Rng, obj.track1, HC, VC, Sym2, asp2, svC2, fig2, Aen2)
    obj.putpixeldata(userdata)
    if Deg ~= 0 then
        obj.setoption("drawtarget", "tempbuffer", w0, h0)
        obj.draw(0, 0, 0, 1, 1, 0, 0, -Deg)
        obj.copybuffer("obj", "tmp")
    end
    if obj.check0 then
        local userdata, w, h = obj.getpixeldata()
        T_Color_Module.MinimaxSave(userdata, w, h)
    end
end
obj.cx = 0
obj.cy = 0
