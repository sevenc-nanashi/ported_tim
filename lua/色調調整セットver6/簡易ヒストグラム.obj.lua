--label:${ROOT_CATEGORY}\色調整
---$track:レイヤー
---min=1
---max=1000
---step=1
local track_layer = 1

---$track:幅
---min=100
---max=1000
---step=1
local track_width = 256

---$track:高さ
---min=100
---max=1000
---step=1
local track_height = 200

---$track:縦倍率%
---min=1
---max=1000
---step=0.1
local track_vertical_scale_percent = 100

---$check:エフェクト読込
local check_load_effects = 1

---$check:R表示
local check_show_red = 1

---$check:G表示
local check_show_green = 1

---$check:B表示
local check_show_blue = 1

---$check:輝度表示
local check_show_luminance = true

local function is_enabled(value)
    return value == true or value == 1
end

local output_width = track_width
local output_height = track_height
local color_module = obj.module("tim2")
obj.load("layer", track_layer, is_enabled(check_load_effects))
local source_width, source_height = obj.getpixel()
obj.effect("領域拡張", "右", 256 - source_width, "下", output_height - source_height)
local pixel_data, processed_width, processed_height = obj.getpixeldata("object", "bgra")
color_module.color_create_histogram(
    pixel_data,
    256,
    output_height,
    source_width,
    source_height,
    processed_width,
    processed_height,
    track_vertical_scale_percent / 100,
    is_enabled(check_show_luminance),
    is_enabled(check_show_red),
    is_enabled(check_show_green),
    is_enabled(check_show_blue)
)
obj.putpixeldata("object", pixel_data, processed_width, processed_height, "bgra")
obj.effect(
    "クリッピング",
    "中心の位置を変更",
    1,
    "右",
    math.max(0, processed_width - 256),
    "下",
    math.max(0, processed_height - output_height)
)
obj.effect("リサイズ", "ドット数でサイズ指定", 1, "X", output_width, "Y", output_height)
obj.effect("縁取り", "サイズ", 1, "ぼかし", 0, "color", 0x0)
obj.effect("縁取り", "サイズ", 2, "ぼかし", 0, "color", 0xffffff)
