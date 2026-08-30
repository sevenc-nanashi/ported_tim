--label:${ROOT_CATEGORY}\加工\@T_Filter_Module
--filter
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
local select_direction = 1

---$track:距離
---min=1
---max=10
---step=1
local track_distance = 5

---$color:シャドウ
local color_shadow = 0x0

---$color:ハイライト
local color_highlight = 0xffffff

---$track:エッジ強度
---min=0
---max=300
---step=1
local track_edge_strength = 100

local blur_distance = track_distance
local direction_index = select_direction
local image_width, image_height

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

image_width, image_height = obj.getpixel()
obj.setoption("drawtarget", "tempbuffer", image_width, image_height)
obj.draw()
obj.effect("反転", "透明度反転", 1)
obj.setoption("blend", "alpha_add")
obj.draw()
obj.load("tempbuffer")
obj.setoption("blend", "none")

obj.effect("ぼかし", "範囲", track_smooth, "サイズ固定", 1)
obj.pixelshader("blaster_binarization", "object", "object", { track_threshold / 255 })
obj.copybuffer("cache:saveimg", "object")

obj.setoption("drawtarget", "tempbuffer", image_width, image_height)

obj.effect("ぼかし", "範囲", blur_distance, "サイズ固定", 1)
obj.effect("領域拡張", "塗りつぶし", 1, "上", 3, "下", 3, "左", 3, "右", 3)
obj.clearbuffer("cache:blaster", image_width, image_height)
obj.pixelshader("blaster_prepare", "cache:blaster", "object", { direction_index, track_edge_strength * 0.01 })
obj.pixelshader("blaster", "object", "cache:blaster")
obj.copybuffer("cache:1", "object")

obj.draw()

obj.copybuffer("object", "cache:saveimg")
obj.effect("エッジ抽出", "color", 0x808080, "しきい値", 100)
obj.effect("ぼかし", "範囲", 1, "サイズ固定", 1)
obj.draw()

obj.copybuffer("cache:saveimg", "tempbuffer")

obj.load("figure", "四角形", 0xffffff, math.max(image_width, image_height))
obj.effect(
    "グラデーション",
    "角度",
    -45 + 45 * direction_index,
    "幅",
    math.max(image_width, image_height),
    "color",
    0xeeeeee,
    "color2",
    0x111111
)
obj.draw()
obj.copybuffer("object", "cache:saveimg")
obj.draw()

obj.load("tempbuffer")
local shadow_red, shadow_green, shadow_blue = RGB(color_shadow)
local highlight_red, highlight_green, highlight_blue = RGB(color_highlight)
obj.pixelshader("blaster_gray_color", "object", "object", {
    shadow_red / 255,
    shadow_green / 255,
    shadow_blue / 255,
    highlight_red / 255,
    highlight_green / 255,
    highlight_blue / 255,
})

obj.copybuffer("tempbuffer", "object")
obj.copybuffer("object", "cache:original")
obj.effect("反転", "透明度反転", 1)
obj.setoption("blend", "alpha_sub")
obj.draw()
obj.load("tempbuffer")
obj.setoption("blend", "none")
