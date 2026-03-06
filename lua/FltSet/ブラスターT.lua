--label:tim2\未分類\T_Filter_Module.anm
---$track:しきい値
---min=0
---max=255
---step=1
local track_threshold = 128

---$track:なめらか
---min=1
---max=100
---step=1
local track_smooth = 3

---$track:向き
---min=0
---max=7
---step=1
local track_direction = 1

---$track:距離
---min=1
---max=10
---step=1
local track_distance = 5

---$color:シャドウ
local col1 = 0x0

---$color:ハイライト
local col2 = 0xffffff

---$value:エッジ強度
local ed = 100

require("T_Filter_Module")
local Len = track_distance
local Vec = track_direction
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

obj.effect("ぼかし", "範囲", track_smooth, "サイズ固定", 1)
userdata, w, h = obj.getpixeldata()
T_Filter_Module.easybinarization(userdata, w, h, track_threshold)
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
