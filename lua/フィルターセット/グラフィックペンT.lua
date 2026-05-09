--label:${ROOT_CATEGORY}\加工\@T_Filter_Module
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
local direction = 2

---$color:シャドウ
local col1 = 0x0

---$color:ハイライト
local col2 = 0xffffff

---$check:シード固定
local seed_fixed = true

---$track:シード
---min=0
---max=99999
---step=1
local seed = 0

---$check:しきい値を自動計算
local auto_threshold = true

--group:高度な設定
---$select:処理モード
---自動=0
---CPU=1
---GPU=2
local gpu_mode = 0

local T_Filter_Module = obj.module("tim2")

--[[pixelshader@graphicpen
---$include "./shaders/graphicpen.hlsl"
]]
--[[pixelshader@graphicpen_gray_color
---$include "./shaders/graphicpen_gray_color.hlsl"
]]

local Lng = track_line_length
obj.effect("単色化")
obj.effect("領域拡張", "塗りつぶし", 1, "上", Lng, "下", Lng, "左", Lng, "右", Lng)

if not seed_fixed then
    seed = seed + obj.time * obj.framerate
end
direction = math.floor(((direction or 2) % 4))
local r1, g1, b1 = RGB(col1)
local r2, g2, b2 = RGB(col2)
local threshold = track_threshold
if auto_threshold then
    local userdata, w, h = obj.getpixeldata("object", "bgra")
    threshold = T_Filter_Module.filter_graphicpen_threshold(userdata, w, h)
end

local use_gpu
if gpu_mode == 0 then
    -- シェーダーはすべてのピクセルでLng回のループが走るので、Lngが小さいときのみ使う
    use_gpu = Lng < 100
elseif gpu_mode == 1 then
    use_gpu = false
elseif gpu_mode == 2 then
    use_gpu = true
end

if use_gpu then
    -- TODO: もっと最適化する
    local dx, dy, length;
    if direction == 0 then
        dx = 1
        dy = 1
        length = Lng * 0.7
    elseif direction == 1 then
        dx = 1
        dy = 0
        length = Lng
    elseif direction == 2 then
        dx = -1
        dy = 1
        length = Lng * 0.7
    elseif direction == 3 then
        dx = 0
        dy = 1
        length = Lng
    end

    obj.pixelshader("graphicpen", "object", "object", {
        seed,
        length,
        threshold,
        track_white_line_amount * 0.01,
        track_black_line_amount * 0.01,
        dx,
        dy
    })
else
    local userdata, w, h = obj.getpixeldata("object", "bgra")
    T_Filter_Module.filter_graphicpen(
        userdata,
        w,
        h,
        Lng,
        track_threshold,
        track_white_line_amount * 0.01,
        track_black_line_amount * 0.01,
        direction,
        seed,
        auto_threshold
    )
    obj.putpixeldata("object", userdata, w, h, "bgra")
end

obj.pixelshader("graphicpen_gray_color", "object", "object", {
    r1 / 255,
    g1 / 255,
    b1 / 255,
    r2 / 255,
    g2 / 255,
    b2 / 255,
})
obj.effect("クリッピング", "上", Lng, "下", Lng, "左", Lng, "右", Lng)
