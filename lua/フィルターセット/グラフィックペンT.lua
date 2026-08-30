--label:${ROOT_CATEGORY}\加工\@t_filter_module
--filter
---$track:線長
---min=2
---max=200
---step=1
local track_line_length = 40

---$track:しきい値
---min=0
---max=255
---step=1
local track_threshold = 128

---$track:白線量
---min=0
---max=100
---step=0.1
local track_white_line_amount = 8

---$track:黒線量
---min=0
---max=100
---step=0.1
local track_black_line_amount = 8

---$select:向き
---斜め右下=0
---縦=1
---斜め左下=2
---横=3
local select_direction = 2

---$color:シャドウ
local color_shadow = 0x0

---$color:ハイライト
local color_highlight = 0xffffff

---$check:シード固定
local check_fix_seed = true

---$track:シード
---min=0
---max=99999
---step=1
local track_seed = 0

---$check:しきい値を自動計算
local check_auto_threshold = true

--group:高度な設定
---$select:処理モード
---自動=0
---CPU=1
---GPU=2
local select_processing_mode = 0

--hide@track_threshold:check_auto_threshold==1

local t_filter_module = obj.module("tim2")

--[[pixelshader@graphicpen
---$include "./shaders/graphicpen.hlsl"
]]
--[[pixelshader@graphicpen_gray_color
---$include "./shaders/graphicpen_gray_color.hlsl"
]]

local line_length = track_line_length
obj.effect("単色化")
obj.effect(
    "領域拡張",
    "塗りつぶし",
    1,
    "上",
    line_length,
    "下",
    line_length,
    "左",
    line_length,
    "右",
    line_length
)

if not check_fix_seed then
    track_seed = track_seed + obj.time * obj.framerate
end
select_direction = math.floor(((select_direction or 2) % 4))
local shadow_red, shadow_green, shadow_blue = RGB(color_shadow)
local highlight_red, highlight_green, highlight_blue = RGB(color_highlight)
local threshold = track_threshold
if check_auto_threshold then
    local userdata, w, h = obj.getpixeldata("object", "bgra")
    threshold = t_filter_module.filter_graphicpen_threshold(userdata, w, h)
end

local use_gpu
if select_processing_mode == 0 then
    -- シェーダーはすべてのピクセルでlng回のループが走るので、lngが小さいときのみ使う
    use_gpu = line_length < 100
elseif select_processing_mode == 1 then
    use_gpu = false
elseif select_processing_mode == 2 then
    use_gpu = true
end

if use_gpu then
    -- TODO: もっと最適化する
    local direction_x, direction_y, length
    if select_direction == 0 then
        direction_x = 1
        direction_y = 1
        length = line_length * 0.7
    elseif select_direction == 1 then
        direction_x = 1
        direction_y = 0
        length = line_length
    elseif select_direction == 2 then
        direction_x = -1
        direction_y = 1
        length = line_length * 0.7
    elseif select_direction == 3 then
        direction_x = 0
        direction_y = 1
        length = line_length
    end

    obj.pixelshader("graphicpen", "object", "object", {
        track_seed,
        length,
        threshold,
        track_white_line_amount * 0.01,
        track_black_line_amount * 0.01,
        direction_x,
        direction_y,
    })
else
    local userdata, w, h = obj.getpixeldata("object", "bgra")
    t_filter_module.filter_graphicpen(
        userdata,
        w,
        h,
        line_length,
        track_threshold,
        track_white_line_amount * 0.01,
        track_black_line_amount * 0.01,
        select_direction,
        track_seed,
        check_auto_threshold
    )
    obj.putpixeldata("object", userdata, w, h, "bgra")
end

obj.pixelshader("graphicpen_gray_color", "object", "object", {
    shadow_red / 255,
    shadow_green / 255,
    shadow_blue / 255,
    highlight_red / 255,
    highlight_green / 255,
    highlight_blue / 255,
})
obj.effect("クリッピング", "上", line_length, "下", line_length, "左", line_length, "右", line_length)
