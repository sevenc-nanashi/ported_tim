--label:tim2\色調整\@T_Color_Module.anm
--filter
---$track:範囲
---min=0
---max=500
---step=1
local track_range = 30

---$track:補正量
---min=-500
---max=500
---step=0.1
local track_adjust_amount = 100

---$track:オフセット
---min=-300
---max=300
---step=0.1
local track_offset = 0

---$track:偏差閾値
---min=0
---max=1000
---step=0.1
local track_threshold = 0

---$check:偏差補正
local check0 = false

--require("T_Color_Module")
local T_Color_Module = obj.module("tim2")
local userdata, w, h = obj.getpixeldata("object", "bgra")
T_Color_Module.color_bias_deletion(
    userdata,
    w,
    h,
    track_range,
    track_adjust_amount,
    track_offset,
    track_threshold,
    check0
)
obj.putpixeldata("object", userdata, w, h, "bgra")
