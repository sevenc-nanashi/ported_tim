--label:tim2\色調整\@T_Color_Module
---$track:X or R
---min=-10000
---max=10000
---step=0.1
local track_x_or_r = 0

---$track:Y or θ
---min=-10000
---max=10000
---step=0.1
local track_y_or_theta = 0

---$track:角度
---min=-3600
---max=3600
---step=0.1
local track_angle = 0

---$track:幅％
---min=1
---max=500
---step=0.1
local track_width_percent = 100

---$value:中心
local CC = { 0, 0 }

---$color:線色
local col = 0xff0000

---$check:線を非表示
local Lck = false

---$check:極座標移動
local check0 = false

col = col or 0x0
obj.setanchor("CC", 1)
-- require("T_Color_Module")
local T_Color_Module = obj.module("tim2")
local CSET = track_x_or_r
local userdata, w, h = obj.getpixeldata("object", "bgra")
local X, Y = track_x_or_r, track_y_or_theta
local Deg = track_angle
if check0 then
    Deg = Deg + Y
    X, Y = -X * math.sin(Y / 180 * math.pi), X * math.cos(Y / 180 * math.pi)
end
X, Y = X + CC[1], Y + CC[2]
T_Color_Module.color_image_tone_curve(userdata, w, h, X, Y, Deg, w * track_width_percent * 0.01, col, Lck)
obj.putpixeldata("object", userdata, w, h, "bgra")
T_ToneCurve_R = 1
T_ToneCurve_G = 1
T_ToneCurve_B = 1
