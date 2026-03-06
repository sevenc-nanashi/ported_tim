--label:tim2\未分類\T_Filter_Module.anm
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

---$value:向き[0..3]
local Vec = 2

---$color:シャドウ
local col1 = 0x0

---$color:ハイライト
local col2 = 0xffffff

---$check:シード固定
local sechk = 1

---$value:シード
local seed = 0

---$check:しきい値を自動計算
local check0 = true

require("T_Filter_Module")
local Lng = track_line_length
obj.effect("単色化")
obj.effect("領域拡張", "塗りつぶし", 1, "上", Lng, "下", Lng, "左", Lng, "右", Lng)

if sechk == 0 then
    seed = seed + obj.time * obj.framerate
end
Vec = math.floor(((Vec or 2) % 4))
local userdata, w, h = obj.getpixeldata()
T_Filter_Module.Graphicpen(
    userdata,
    w,
    h,
    Lng,
    track_threshold,
    track_white_line_amount * 0.01,
    track_black_line_amount * 0.01,
    Vec,
    seed,
    check0
)
obj.putpixeldata(userdata)

userdata, w, h = obj.getpixeldata()
local r1, g1, b1 = RGB(col1)
local r2, g2, b2 = RGB(col2)
T_Filter_Module.GrayColor(userdata, w, h, r1, g1, b1, r2, g2, b2)
obj.putpixeldata(userdata)
obj.effect("クリッピング", "上", Lng, "下", Lng, "左", Lng, "右", Lng)
