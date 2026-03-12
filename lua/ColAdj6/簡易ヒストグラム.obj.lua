--label:tim2\色調整
---$track:レイヤー
---min=1
---max=100
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
local efR = 1

---$check:R表示
local Rap = 1

---$check:G表示
local Gap = 1

---$check:B表示
local Bap = 1

---$check:輝度表示
local check0 = true

local function is_enabled(value)
    return value == true or value == 1
end

Lw = Lw or 3
local w = track_width
local h = track_height
local T_Color_Module = obj.module("tim2")
obj.load("layer", track_layer, is_enabled(efR))
local w0, h0 = obj.getpixel()
obj.effect("領域拡張", "右", 256 - w0, "下", h - h0)
local userdata, w1, h1 = obj.getpixeldata("object", "bgra")
T_Color_Module.color_create_histogram(
    userdata,
    256,
    h,
    w0,
    h0,
    w1,
    h1,
    track_vertical_scale_percent / 100,
    is_enabled(check0),
    is_enabled(Rap),
    is_enabled(Gap),
    is_enabled(Bap)
)
obj.putpixeldata("object", userdata, w1, h1, "bgra")
obj.effect(
    "クリッピング",
    "中心の位置を変更",
    1,
    "右",
    math.max(0, w1 - 256),
    "下",
    math.max(0, h1 - h)
)
obj.effect("リサイズ", "ドット数でサイズ指定", 1, "X", w, "Y", h)
obj.effect("縁取り", "サイズ", 1, "ぼかし", 0, "color", 0x0)
obj.effect("縁取り", "サイズ", 2, "ぼかし", 0, "color", 0xffffff)
