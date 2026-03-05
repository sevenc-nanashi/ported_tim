--label:tim2\T_Color_Module.anm
---$track:彩度
---min=0
---max=100
---step=0.1
local saturation = 70

---$track:明度
---min=0
---max=100
---step=0.1
local brightness = 70

---$track:しきい値
---min=0
---max=100
---step=0.1
local threshold = 10

---$track:色付ｴｯｼﾞ
---min=0
---max=100
---step=0.1
local colored_edge = 50

---$value:しきい値ぼかし
local shw = 8

---$value:縁補正
local edc = 1

---$value:エッジ強さ
local pow = 100

---$value:エッジしきい値
local sh = 0

---$value:エッジぼかし
local blur = 1

-- require("T_Color_Module")
local T_Color_Module = obj.module("tim2")

local Ces = colored_edge / 100
if Ces > 0 then
    obj.setoption("drawtarget", "tempbuffer", obj.w, obj.h)
    obj.copybuffer("cache:org", "object")
    obj.copybuffer("tempbuffer", "object")
    obj.setoption("drawtarget", "tempbuffer")
    obj.effect(
        "エッジ抽出",
        "強さ",
        pow,
        "しきい値",
        sh,
        "輝度エッジを抽出",
        1,
        "透明度エッジを抽出",
        0
    )
    obj.effect("縁取り", "サイズ", edc, "ぼかし", blur, "color", 0xffffff)
    obj.effect("反転", "透明度反転", 1)
    obj.setoption("blend", "alpha_sub")
    obj.draw()
    obj.setoption("blend", "none")
    obj.copybuffer("cache:Edg", "tempbuffer")
    obj.copybuffer("object", "cache:org")
end
local userdata, w, h = obj.getpixeldata("object", "bgra")
T_Color_Module.pastel(userdata, w, h, saturation, brightness, threshold, shw or 0)
obj.putpixeldata("object", userdata, w, h, "bgra")
obj.setoption("draw_state", false)
if Ces > 0 then
    obj.copybuffer("tempbuffer", "object")
    obj.copybuffer("object", "cache:Edg")
    obj.draw(0, 0, 0, 1, Ces)
    obj.copybuffer("object", "tempbuffer")
end