--label:tim2\T_Filter_Module.anm\ブラスターT
--track0:しきい値,0,255,128,1
--track1:なめらか,1,100,3,1,1
--track2:向き,0,7,1,1
--track3:距離,1,10,5,1
--value@col1:シャドウ/col,0x0
--value@col2:ハイライト/col,0xffffff
--value@ed:エッジ強度,100

require("T_Filter_Module")
local Len = obj.track3
local Vec = obj.track2
local userdata, w, h, w0, h0

obj.copybuffer("cache:original", "obj")

w0, h0 = obj.getpixel()
obj.setoption("drawtarget", "tempbuffer", w0, h0)
obj.draw()
obj.effect("反転", "透明度反転", 1)
obj.setoption("blend", "alpha_add")
obj.draw()
obj.load("tempbuffer")
obj.setoption("blend", 0)

obj.effect("ぼかし", "範囲", obj.track1, "サイズ固定", 1)
userdata, w, h = obj.getpixeldata()
T_Filter_Module.easybinarization(userdata, w, h, obj.track0)
obj.putpixeldata(userdata)
obj.copybuffer("cache:saveimg", "obj")

obj.setoption("drawtarget", "tempbuffer", w0, h0)

obj.effect("ぼかし", "範囲", Len, "サイズ固定", 1)
obj.effect("領域拡張", "塗りつぶし", 1, "上", 3, "下", 3, "左", 3, "右", 3)
userdata, w, h = obj.getpixeldata()
T_Filter_Module.Blaster(userdata, w, h, Vec, ed * 0.01)
obj.putpixeldata(userdata)
obj.draw()

obj.copybuffer("obj", "cache:saveimg")
obj.effect("エッジ抽出", "color", 0x808080, "しきい値", 100)
obj.effect("ぼかし", "範囲", 1, "サイズ固定", 1)
obj.draw()

obj.copybuffer("cache:saveimg", "tmp")

obj.load("figure", "四角形", 0xffffff, math.max(w0, h0))
obj.effect(
    "グラデーション",
    "角度",
    -45 + 45 * Vec,
    "幅",
    math.max(w0, h0),
    "color",
    0xeeeeee,
    "color2",
    0x111111
)
obj.draw()
obj.copybuffer("obj", "cache:saveimg")
obj.draw()

obj.load("tempbuffer")
userdata, w, h = obj.getpixeldata()
local r1, g1, b1 = RGB(col1)
local r2, g2, b2 = RGB(col2)
T_Filter_Module.GrayColor(userdata, w, h, r1, g1, b1, r2, g2, b2)
obj.putpixeldata(userdata)

obj.copybuffer("tmp", "obj")
obj.copybuffer("obj", "cache:original")
obj.effect("反転", "透明度反転", 1)
obj.setoption("blend", "alpha_sub")
obj.draw()
obj.load("tempbuffer")
obj.setoption("blend", 0)
