--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
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

---$track:中心X
---min=-10000
---max=10000
---step=0.1
local track_center_x = 0

---$track:中心Y
---min=-10000
---max=10000
---step=0.1
local track_center_y = 0

--trackgroup@track_center_x,track_center_y:中心

---$check:線を非表示
local check_hide_line = false

---$color:線色
local line_color = 0xff0000

---$check:極座標移動
local check_use_polar_movement = false

--hide@line_color:check_hide_line==1

line_color = line_color or 0x0
obj.setanchor("track_center_x,track_center_y", 0)
-- require("T_Color_Module")
local color_module = obj.module("tim2")
local pixel_data, width, height = obj.getpixeldata("object", "bgra")
local curve_x, curve_y = track_x_or_r, track_y_or_theta
local curve_angle = track_angle
if check_use_polar_movement then
    curve_angle = curve_angle + curve_y
    curve_x, curve_y = -curve_x * math.sin(curve_y / 180 * math.pi), curve_x * math.cos(curve_y / 180 * math.pi)
end
curve_x, curve_y = curve_x + track_center_x, curve_y + track_center_y
color_module.color_image_tone_curve(
    pixel_data,
    width,
    height,
    curve_x,
    curve_y,
    curve_angle,
    width * track_width_percent * 0.01,
    line_color,
    check_hide_line
)
obj.putpixeldata("object", pixel_data, width, height, "bgra")
T_TONE_CURVE_R = 1
T_TONE_CURVE_G = 1
T_TONE_CURVE_B = 1
