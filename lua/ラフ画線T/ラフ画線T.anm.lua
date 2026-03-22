--label:tim2\装飾
--group:基本,true

---$track:長さ
---min=0
---max=500
---step=1
local track_length = 10

---$check:画線のみ
local check_line_only = false

---$check:スクリーン合成
local check_screen_blend = true

---$track:画線ガンマ
---min=1
---max=500
---step=1
local track_line_gamma = 100

--group:線,false

---$color:線色
local color_line = 0x0

---$track:強度上限
---min=0
---max=255
---step=1
local track_intensity_max = 128

---$track:強度下限
---min=0
---max=255
---step=1
local track_intensity_min = 0

---$track:しきい値
---min=0
---max=1000
---step=1
local track_threshold = 0

--group:背景,false

---$color:背景色
local color_background = 0xffffff

---$track:元絵比率
---min=0
---max=100
---step=1
local track_original_ratio = 0

---$track:背景透明度
---min=0
---max=100
---step=1
local track_background_alpha = 0

--group:境界補正,false

---$check:有効
local check_boundary_adjust = false

---$color:補正色
local color_boundary_adjust = 0xffffff

--group:抽出,false

---$track:抽出サイズ
---min=0
---max=500
---step=1
local track_extract_size = 1

---$track:抽出強度
---min=0
---max=1000
---step=1
local track_extract_strength = 300

---$track:抽出しきい値
---min=0
---max=255
---step=1
local track_extract_threshold = 0

--group:長さマップ,false

---$track:参照レイヤー
---min=0
---max=1000
---step=1
---zero_label=なし
local track_map_layer = 0

---$string:方向マスク
local value_direction_mask = "11110000"

--group:

---$value:PI
local param_override = {}

local is_enabled = function(v)
    return v == true or v == 1
end

param_override = param_override or {}
local length = param_override[1] or track_length
local intensity_upper = param_override[2] or track_intensity_max
local intensity_lower = param_override[3] or track_intensity_min
local line_threshold = param_override[4] or track_threshold
local line_only = param_override[0] == nil and check_line_only or param_override[0]
local line_color = color_line or 0x0
local background_color = color_background or 0xffffff
local original_ratio = track_original_ratio or 0
local background_alpha = track_background_alpha or 0
local line_gamma = track_line_gamma or 100
local screen_blend = check_screen_blend
local boundary_adjust = check_boundary_adjust
local boundary_color = color_boundary_adjust or 0xffffff
local direction_mask_bits = value_direction_mask or "11110000"
local map_layer = track_map_layer or 0
local extract_size = track_extract_size or 1
local extract_strength = track_extract_strength or 300
local extract_threshold = track_extract_threshold or 0

if is_enabled(boundary_adjust) then
    obj.effect("縁取り", "サイズ", length, "color", boundary_color, "ぼかし", 1)
end
local tim2 = obj.module("tim2")
local SeD = 0
local t = 1
for i in string.gmatch(direction_mask_bits, "[0-1]") do
    SeD = SeD + i * t
    t = t * 2
end
map_layer = map_layer or 0
if map_layer > 0 and map_layer <= 100 then
    local Lck = obj.getvalue("layer" .. map_layer .. ".x") and 1 or 0
    if Lck == 1 then
        local Pr =
            { obj.ox, obj.oy, obj.oz, obj.rx, obj.ry, obj.rz, obj.cx, obj.cy, obj.cz, obj.zoom, obj.alpha, obj.aspect }
        local w0, h0 = obj.getpixel()
        obj.copybuffer("tmp", "obj")
        obj.load("layer", map_layer, true)
        if is_enabled(boundary_adjust) then
            obj.effect("領域拡張", "上", length, "下", length, "左", length, "右", length, "塗りつぶし", 0)
        end
        obj.effect("リサイズ", "X", w0, "Y", h0, "ドット数でサイズ指定", 1)
        local userdata, w, h = obj.getpixeldata("object", "bgra")
        tim2.rgline_set_map_image(userdata, w, h)
        obj.copybuffer("obj", "tmp")
        obj.ox, obj.oy, obj.oz, obj.rx, obj.ry, obj.rz, obj.cx, obj.cy, obj.cz, obj.zoom, obj.alpha, obj.aspect =
            unpack(Pr)
    end
end
local userdata, w, h = obj.getpixeldata("object", "bgra")
tim2.rgline_set_public_image(userdata, w, h)
obj.effect("ぼかし", "範囲", extract_size, "サイズ固定", 1)
userdata, w, h = obj.getpixeldata("object", "bgra")
tim2.rgline_line_ext(
    userdata,
    w,
    h,
    length,
    intensity_upper,
    intensity_lower,
    line_threshold,
    extract_strength,
    extract_threshold,
    is_enabled(line_only),
    original_ratio,
    background_alpha,
    line_color,
    background_color,
    is_enabled(screen_blend),
    line_gamma,
    SeD
)
obj.putpixeldata("object", userdata, w, h, "bgra")
