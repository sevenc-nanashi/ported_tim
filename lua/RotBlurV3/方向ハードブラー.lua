--label:tim2\T_RotBlur_Module.anm\方向ハードブラー
---$track:ブラー量
---min=0
---max=2000
---step=0.1
local rename_me_track0 = 100

---$track:凹凸ｻｲｽﾞ
---min=1
---max=1000
---step=1
local rename_me_track1 = 30

---$track:角度
---min=-3600
---max=3600
---step=0.1
local rename_me_track2 = 0

---$track:丸み
---min=-100
---max=100
---step=0.1
local rename_me_track3 = 0

---$check:サイズ保持
local ck = 1

---$value:基準[-100〜100]
local BasP = 0

---$value:幅ランダム%
local AmpR = 50

---$check:簡易補正
local BM = 0

---$value:└係数%
local BMC = 100

---$value:パターン
local rnds = 1

---$value:表示限界倍率
local Sbai = 3

local Bx = rename_me_track0
if Bx ~= 0 then
    local dS = rename_me_track1
    local deg = rename_me_track2
    local EG = rename_me_track3 * 0.01
    local rad = deg * math.pi / 180
    BasP = RotBlur_BasP or (BasP or 0)
    AmpR = RotBlur_AmpR or (AmpR or 100)
    BasP = 0.01 * math.max(-100, math.min(100, BasP))
    AmpR = 1 - 0.01 * math.max(0, math.min(100, AmpR))
    BMC = BMC or 100
    rnds = math.abs(math.floor(rnds))
    if rnds == 0 then
        rnds = math.floor(obj.time * obj.framerate)
    end
    local userdata, w, h
    w, h = obj.getpixel()
    if ck == 0 then
        local cos, sin = math.cos(rad), math.sin(rad)
        Sbai = math.max(0, (Sbai - 1) / 2)
        local iw, ih = w * Sbai, h * Sbai
        local ds1 = Bx * (1 - BasP) / 2
        local ds2 = -Bx * (1 + BasP) / 2
        local addX1, addY1 = ds1 * cos, ds1 * sin
        local addX2, addY2 = ds2 * cos, ds2 * sin
        addX1, addX2 = math.max(addX1, addX2), -math.min(addX1, addX2)
        addY1, addY2 = math.max(addY1, addY2), -math.min(addY1, addY2)
        addX1 = (addX1 > iw) and iw or addX1
        addX2 = (addX2 > iw) and iw or addX2
        addY1 = (addY1 > ih) and ih or addY1
        addY2 = (addY2 > ih) and ih or addY2
        addX1, addY1 = math.ceil(math.max(addX1, 1)), math.ceil(math.max(addY1, 1))
        addX2, addY2 = math.ceil(math.max(addX2, 1)), math.ceil(math.max(addY2, 1))
        obj.effect("領域拡張", "上", addY2, "下", addY1, "右", addX1, "左", addX2)
    end
    if BM == 1 then
        obj.effect("方向ブラー", "範囲", BMC * 0.01 * Bx / dS / 2, "角度", 90 + deg, "サイズ固定", 1)
    end
    require("T_RotBlur_Module")
    userdata, w, h = obj.getpixeldata()
    work = obj.getpixeldata("work")
    local LUD = T_RotBlur_Module.DirHardBlur(userdata, work, w, h, Bx, dS, rad, AmpR, EG, BasP, rnds)
    obj.putpixeldata(LUD)
    RotBlur_BasP = nil
    RotBlur_AmpR = nil
    RotBlur_EG = nil
end
