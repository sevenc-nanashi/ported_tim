--label:tim2\色調整\T_Color_Module.anm
--filter
---$track:色相範囲
---min=0.1
---max=360
---step=0.1
local track_hue_range = 100

---$track:彩度範囲
---min=0
---max=255
---step=0.1
local track_saturation_range = 255

---$track:輝度調整
---min=0
---max=500
---step=0.1
local track_luminance_adjust = 100

---$track:境界補正
---min=1
---max=360
---step=0.1
local track_boundary_adjust = 2

---$color:変更前
local col1 = 0x0000ff

---$color:変更後
local col2 = 0xff0000

---$track:彩度調整
---min=0
---max=100
---step=0.1
local pS = 100

local pS2 = pS or 100
-- require("T_Color_Module")
local T_Color_Module = obj.module("tim2")
local userdata, w, h = obj.getpixeldata("object", "bgra")
T_Color_Module.color_change_to_color(
    userdata,
    w,
    h,
    col1,
    col2,
    track_hue_range,
    track_saturation_range,
    pS2 * 0.01,
    track_luminance_adjust * 0.01,
    track_boundary_adjust
)
obj.putpixeldata("object", userdata, w, h, "bgra")
