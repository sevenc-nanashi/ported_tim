--label:tim2\未分類\T_RotBlur_Module.anm
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
---max=1000
---step=0.1
local track_blur_amount = 20

---$track:基準位置
---min=-100
---max=100
---step=0.1
local track_base_position = 0

---$check:サイズ保持
local ck = 1

---$value:表示限界倍率
local Sbai = 3

obj.setanchor("track", 0, "line")
local dx = track_center_x
local dy = track_center_y
local Br = track_blur_amount
local BasP = 0.01 * track_base_position
Br = math.min(Br, 200 / (1 + BasP) - 0.1)
local userdata, w, h
local addX1, addX2, addY1, addY2 = 0, 0, 0, 0
if ck == 0 then
    local w, h = obj.getpixel()
    local w2, h2 = w / 2, h / 2
    Sbai = math.max(0, (Sbai - 1) / 2)
    local iw, ih = w * Sbai, h * Sbai
    local iBr1 = 1 / (1 - Br * (1 + BasP) / 200)
    local iBr2 = 1 / (1 + Br * (1 - BasP) / 200)
    addX1 = ((w2 > dx and iBr1 or iBr2) - 1) * (w2 - dx)
    addX2 = ((-w2 < dx and iBr1 or iBr2) - 1) * (w2 + dx)
    addY1 = ((h2 > dy and iBr1 or iBr2) - 1) * (h2 - dy)
    addY2 = ((-h2 < dy and iBr1 or iBr2) - 1) * (h2 + dy)
    addX1 = (addX1 > iw) and iw or addX1
    addX2 = (addX2 > iw) and iw or addX2
    addY1 = (addY1 > ih) and ih or addY1
    addY2 = (addY2 > ih) and ih or addY2
    addX1, addY1 = math.ceil(math.max(addX1, 1)), math.ceil(math.max(addY1, 1))
    addX2, addY2 = math.ceil(math.max(addX2, 1)), math.ceil(math.max(addY2, 1))
    obj.effect("領域拡張", "上", addY2, "下", addY1, "右", addX1, "左", addX2)
end
require("T_RotBlur_Module")
userdata, w, h = obj.getpixeldata()

T_RotBlur_Module.RadBlur(userdata, w, h, Br, dx + (addX2 - addX1) / 2, dy + (addY2 - addY1) / 2, BasP)
obj.putpixeldata(userdata)
