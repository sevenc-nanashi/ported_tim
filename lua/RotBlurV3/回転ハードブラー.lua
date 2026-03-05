--label:tim2\T_RotBlur_Module.anm\回転ハードブラー
--track0:中心X,-5000,5000,0
--track1:中心Y,-5000,5000,0
--track2:ブラー量,0,500,20
--track3:凹凸量,1,1000,40,1
--value@ck:サイズ保持/chk,1
--value@BasP:基準[-100〜100],0
--value@AmpR:幅ランダム%,50
--value@EG:丸み[-100〜100],0
--value@BM:簡易補正/chk,0
--value@BMC:└係数%,100
--value@rnds:パターン,1

local Br = obj.track2
if Bx ~= 0 then
    local dx = obj.track0
    local dy = obj.track1
    local NN = obj.track3
    local BasP = RotBlur_BasP or (BasP or 0)
    local AmpR = RotBlur_AmpR or (AmpR or 100)
    local EG = RotBlur_EG or (EG or 0)
    BasP = 0.01 * math.max(-100, math.min(100, BasP))
    AmpR = 1 - 0.01 * math.max(0, math.min(100, AmpR))
    EG = 0.01 * math.max(-100, math.min(100, EG))
    local BM = BM or 0
    local BMC = BMC or 100
    rnds = math.abs(math.floor(rnds))
    obj.setanchor("track", 0, "line")

    local userdata, w, h
    w, h = obj.getpixel()
    local r = math.sqrt(w * w + h * h)
    if ck == 0 then
        local addX, addY = math.ceil((r - w) / 2 + 1), math.ceil((r - h) / 2 + 1)
        obj.effect("領域拡張", "上", addY, "下", addY, "右", addX, "左", addX)
    end
    require("T_RotBlur_Module")
    userdata, w, h = obj.getpixeldata()
    if rnds == 0 then
        rnds = math.floor(obj.time * obj.framerate)
    end
    if BM == 1 then
        T_RotBlur_Module.RotBlur_L(userdata, w, h, Br * NN / r * BMC * 0.015, dx, dy, 0, 1)
        obj.putpixeldata(userdata)
        userdata, w, h = obj.getpixeldata()
    end
    work = obj.getpixeldata("work")
    local LUD = T_RotBlur_Module.RotHardBlur(userdata, work, w, h, Br, r / 2, dx, dy, NN, AmpR, EG, BasP, rnds)
    obj.putpixeldata(LUD)
    RotBlur_BasP = nil
    RotBlur_AmpR = nil
    RotBlur_EG = nil
end
