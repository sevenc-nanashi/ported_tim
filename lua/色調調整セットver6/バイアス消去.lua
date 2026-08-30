--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
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
local check_enable_deviation_correction = false

--hide@track_threshold:check_enable_deviation_correction==0

--require("T_Color_Module")
local color_module = obj.module("tim2")
local pixel_data, width, height = obj.getpixeldata("object", "bgra")
color_module.color_bias_deletion(
    pixel_data,
    width,
    height,
    track_range,
    track_adjust_amount,
    track_offset,
    track_threshold,
    check_enable_deviation_correction
)
obj.putpixeldata("object", pixel_data, width, height, "bgra")
