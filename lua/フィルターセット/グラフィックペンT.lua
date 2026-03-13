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
local Lng = track_line_length
obj.effect("単色化")
obj.effect("領域拡張", "塗りつぶし", 1, "上", Lng, "下", Lng, "左", Lng, "右", Lng)

if not seed_fixed then
    seed = seed + obj.time * obj.framerate
end
direction = math.floor(((direction or 2) % 4))
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

userdata, w, h = obj.getpixeldata("object", "bgra")
local r1, g1, b1 = RGB(col1)
local r2, g2, b2 = RGB(col2)
T_Filter_Module.filter_gray_color(userdata, w, h, r1, g1, b1, r2, g2, b2)
obj.putpixeldata("object", userdata, w, h, "bgra")
obj.effect("クリッピング", "上", Lng, "下", Lng, "左", Lng, "右", Lng)
