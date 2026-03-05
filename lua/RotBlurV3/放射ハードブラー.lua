--label:tim2\T_RotBlur_Module.anm\放射ハードブラー
--track0:中心X,-5000,5000,0
--track1:中心Y,-5000,5000,0
--track2:ブラー量,0,200,20
--track3:凸数,3,500,20,1
--value@ck:サイズ保持/chk,1
--value@BasP:基準[-100〜100],0
--value@AmpR:幅ランダム%,50
--value@EG:丸み[-100〜100],0
--value@BM:簡易補正/chk,0
--value@BMC:└係数%,100
--value@rnds:パターン,1
--value@Sbai:表示限界倍率,3

local Br = obj.track2 * 0.01
if Bx ~= 0 then
    local dx = obj.track0
    local dy = obj.track1
    local NN = obj.track3
    BasP = RotBlur_BasP or (BasP or 0)
    AmpR = RotBlur_AmpR or (AmpR or 100)
    EG = RotBlur_EG or (EG or 0)
    BasP = 0.01 * math.max(-100, math.min(100, BasP))
    AmpR = 1 - 0.01 * math.max(0, math.min(100, AmpR))
    EG = 0.01 * math.max(-100, math.min(100, EG))
    rnds = math.abs(math.floor(rnds))
    obj.setanchor("track", 0, "line")
    BMC = BMC or 100

    local userdata, w, h
    w, h = obj.getpixel()
    local r = math.sqrt(w * w + h * h)

    if ck == 0 and Br > 0 then
        Sbai = math.max(0, (Sbai - 1) / 2)
        local iw, ih = w * Sbai, h * Sbai
        local iBr = Br / 2 * (1 + BasP)
        local addX, addY
        if iBr < 1 then
            iBr = iBr / (1 - iBr)
            addX, addY = (w / 2 + math.abs(dx)) * iBr + 1, (h / 2 + math.abs(dy)) * iBr + 1
            addX = (addX > iw) and iw or addX
            addY = (addY > ih) and ih or addY
        else
            addX, addY = iw, ih
        end
        addX, addY = math.ceil(addX), math.ceil(addY)
        obj.effect("領域拡張", "上", addY, "下", addY, "右", addX, "左", addX)
    end
    require("T_RotBlur_Module")
    userdata, w, h = obj.getpixeldata()
    if rnds == 0 then
        rnds = math.floor(obj.time * obj.framerate)
    end

    if BM == 1 then
        T_RotBlur_Module.RadBlur(userdata, w, h, BMC * Br * NN / 600, dx, dy, 0)
        obj.putpixeldata(userdata)
        userdata, w, h = obj.getpixeldata()
    end
    work = obj.getpixeldata("work")
    local LUD = T_RotBlur_Module.RadHardBlur(userdata, work, w, h, Br, dx, dy, NN, AmpR, EG, BasP, rnds)
    obj.putpixeldata(LUD)
    RotBlur_BasP = nil
    RotBlur_AmpR = nil
    RotBlur_EG = nil
end
