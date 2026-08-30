--label:${ROOT_CATEGORY}\加工\@T_Filter_Module
--filter
---$track:しきい値
---min=0
---max=255
---step=1
local track_threshold = 128

---$track:きめ
---min=0
---max=100
---step=0.1
local track_grain = 75

---$track:レリーフ
---min=0
---max=500
---step=0.1
local track_relief = 100

---$select:向き
---左=0
---左上=1
---上=2
---右上=3
---右=4
---右下=5
---下=6
---左下=7
local select_direction = 3

---$color:シャドウ
local color_shadow = 0x0

---$color:ハイライト
local color_highlight = 0xffffff

local w, h = obj.getpixel()

--[[pixelshader@emboss
---$include "./shaders/emboss.hlsl"
]]
--[[pixelshader@note_binarization
---$include "./shaders/note_binarization.hlsl"
]]
--[[pixelshader@note_gray_color
---$include "./shaders/note_gray_color.hlsl"
]]

obj.pixelshader("note_binarization", "object", "object", { track_threshold / 255 })
obj.pixelshader("note_gray_color", "object", "object", {
    128 / 255,
    128 / 255,
    128 / 255,
    1,
    1,
    1,
})
obj.setoption("drawtarget", "tempbuffer", w, h)
obj.draw()
obj.load("figure", "四角形", 0xffffff, math.max(w, h))
obj.effect("ノイズ", "周期X", 100, "周期Y", 100, "type", 0, "mode", 1)
obj.effect("領域拡張", "塗りつぶし", 1, "上", 1, "下", 1, "左", 1, "右", 1)
obj.pixelshader("emboss", "object", "object", { 1, 2 })
obj.effect("クリッピング", "上", 1, "下", 1, "左", 1, "右", 1)
obj.setoption("blend", 2)
obj.draw(0, 0, 0, 1, 0.5 * (1 - track_grain * 0.01))
obj.load("tempbuffer")
obj.setoption("blend", 0)
obj.pixelshader("emboss", "object", "object", { track_relief * 0.01, select_direction })
local shadow_red, shadow_green, shadow_blue = RGB(color_shadow)
local highlight_red, highlight_green, highlight_blue = RGB(color_highlight)
obj.pixelshader("note_gray_color", "object", "object", {
    shadow_red / 255,
    shadow_green / 255,
    shadow_blue / 255,
    highlight_red / 255,
    highlight_green / 255,
    highlight_blue / 255,
})
