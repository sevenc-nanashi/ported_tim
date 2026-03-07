--label:tim2\色調整\T_Color_Module.anm
---$track:中心
---min=-255
---max=255
---step=0.1
local track_center = 0

---$track:強度
---min=-200
---max=200
---step=0.1
local track_intensity = 100

---$track:明るさ
---min=-255
---max=255
---step=0.1
local track_brightness = 0

---$track:なめらか
---min=0
---max=100
---step=0.001
local track_smooth = 50

---$track:カーブサイズ
---min=100
---max=1000
---step=1
local curve_size = 260

---$check:カーブ表示
local show_curve = false

-- require("T_Color_Module")
local T_Color_Module = obj.module("tim2")
if show_curve then
    obj.load("figure", "四角形", 0xffffff, math.max(100, curve_size or 260))
end
local userdata, w, h = obj.getpixeldata("object", "bgra")
T_Color_Module.color_extended_contrast(
    userdata,
    w,
    h,
    track_center,
    track_intensity / 100,
    track_brightness,
    track_smooth / 100,
    show_curve
)
obj.putpixeldata("object", userdata, w, h, "bgra")