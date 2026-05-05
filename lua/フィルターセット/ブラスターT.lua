--label:tim2\加工\@T_Filter_Module
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

---$select:向き
---右下=0
---下=1
---左下=2
---左=3
---左上=4
---上=5
---右上=6
---右=7
local direction = 1

---$track:距離
---min=1
---max=10
---step=1
local track_distance = 5

---$color:シャドウ
local col1 = 0x0

---$color:ハイライト
local col2 = 0xffffff

---$track:エッジ強度
---min=0
---max=300
---step=1
local track_edge_strength = 100

local Len = track_distance
local Vec = direction
local w0, h0

--[[pixelshader@blaster_binarization
---$include "./shaders/blaster_binarization.hlsl"
]]
--[[pixelshader@blaster_prepare
---$include "./shaders/blaster_prepare.hlsl"
]]
--[[pixelshader@blaster
---$include "./shaders/blaster.hlsl"
]]
--[[pixelshader@blaster_gray_color
---$include "./shaders/blaster_gray_color.hlsl"
]]

obj.copybuffer("cache:original", "object")

w0, h0 = obj.getpixel()
obj.setoption("drawtarget", "tempbuffer", w0, h0)
obj.draw()
obj.effect("反転", "透明度反転", 1)
obj.setoption("blend", "alpha_add")
obj.draw()
obj.load("tempbuffer")
obj.setoption("blend", "none")

obj.effect("ぼかし", "範囲", track_smooth, "サイズ固定", 1)
obj.pixelshader("blaster_binarization", "object", "object", { track_threshold / 255 })
obj.copybuffer("cache:saveimg", "object")

obj.setoption("drawtarget", "tempbuffer", w0, h0)

obj.effect("ぼかし", "範囲", Len, "サイズ固定", 1)
obj.effect("領域拡張", "塗りつぶし", 1, "上", 3, "下", 3, "左", 3, "右", 3)
obj.clearbuffer("cache:blaster", w0, h0)
obj.pixelshader("blaster_prepare", "cache:blaster", "object", { Vec, track_edge_strength * 0.01 })
obj.pixelshader("blaster", "object", "cache:blaster")
obj.copybuffer("cache:1", "object")

obj.draw()

obj.copybuffer("object", "cache:saveimg")
obj.effect("エッジ抽出", "color", 0x808080, "しきい値", 100)
obj.effect("ぼかし", "範囲", 1, "サイズ固定", 1)
obj.draw()

obj.copybuffer("cache:saveimg", "tempbuffer")

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
obj.copybuffer("object", "cache:saveimg")
obj.draw()

obj.load("tempbuffer")
local r1, g1, b1 = RGB(col1)
local r2, g2, b2 = RGB(col2)
obj.pixelshader("blaster_gray_color", "object", "object", {
    r1 / 255,
    g1 / 255,
    b1 / 255,
    r2 / 255,
    g2 / 255,
    b2 / 255,
})

obj.copybuffer("tempbuffer", "object")
obj.copybuffer("object", "cache:original")
obj.effect("反転", "透明度反転", 1)
obj.setoption("blend", "alpha_sub")
obj.draw()
obj.load("tempbuffer")
obj.setoption("blend", "none")
