--label:tim2\加工\@T_Filter_Module
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

local T_Filter_Module = obj.module("tim2")

--[[pixelshader@graphicpen
---$include "./shaders/graphicpen.hlsl"
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
local threshold = track_threshold / 255
if auto_threshold then
    local userdata, w, h = obj.getpixeldata("object", "bgra")
    threshold = T_Filter_Module.filter_graphicpen_threshold(userdata, w, h) / 255
end

local line_length = Lng
local step_x, step_y = 1, 0
if direction == 0 then
    line_length = math.floor(Lng * 0.7 + 0.5)
    step_x, step_y = 1, 1
elseif direction == 1 then
    step_x, step_y = 0, 1
elseif direction == 2 then
    line_length = math.floor(Lng * 0.7 + 0.5)
    step_x, step_y = 1, -1
end

obj.pixelshader("graphicpen", "object", { "object", "random" }, {
    threshold,
    1.0 - track_white_line_amount * 0.02,
    1.0 - track_black_line_amount * 0.02,
    line_length,
    math.max(1, math.ceil(line_length * 0.5 + 1)),
    step_x,
    step_y,
    seed,
    r1 / 255,
    g1 / 255,
    b1 / 255,
    r2 / 255,
    g2 / 255,
    b2 / 255,
})
obj.effect("クリッピング", "上", Lng, "下", Lng, "左", Lng, "右", Lng)
