--label:tim2\ぼかし\T_RotBlur_Module.anm
---$track:中心X
---min=-5000
---max=5000
---step=0.1
local track_center_x = 0

---$track:中心Y
---min=-5000
---max=5000
---step=0.1
local track_center_y = 0

---$track:ブラー量
---min=0
---max=500
---step=0.1
local track_blur_amount = 20

---$track:凹凸量
---min=1
---max=1000
---step=1
local track_bump_amount = 40

---$check:サイズ保持
local ck = 1

---$value:基準[-100〜100]
local BasP = 0

---$value:幅ランダム%
local AmpR = 50

---$value:丸み[-100〜100]
local EG = 0

---$check:簡易補正
local BM = 0

---$value:└係数%
local BMC = 100

---$value:パターン
local rnds = 1

local Br = track_blur_amount
if Bx ~= 0 then
    local dx = track_center_x
    local dy = track_center_y
    local NN = track_bump_amount
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
