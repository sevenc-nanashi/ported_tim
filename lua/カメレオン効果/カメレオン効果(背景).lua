--label:${ROOT_CATEGORY}\色調整\@カメレオン効果
---$track:中心X
---min=-10000
---max=10000
---step=1
local track_center_x = 0

---$track:中心Y
---min=-10000
---max=10000
---step=1
local track_center_y = 0

---$track:幅
---min=0
---max=10000
---step=1
local track_range_width = 5000

---$track:高さ
---min=0
---max=10000
---step=1
local track_range_height = 5000

---$check:範囲を表示
local check_show_range = false

---$color:枠色
local color_border = 0xffffff

---$track:枠幅
---min=0
---max=100
---step=1
local track_border_width = 2

--hide@color_border:check_show_range==0
--hide@track_border_width:check_show_range==0

obj.setanchor("track_center_x,track_center_y", 2)
local tim_module = obj.module("tim2")
local userdata, w, h = obj.getpixeldata("object", "bgra")
tim_module.famili_set_color(
    userdata,
    w,
    h,
    track_center_x,
    track_center_y,
    track_range_width,
    track_range_height,
    check_show_range,
    color_border,
    track_border_width
)
obj.putpixeldata("object", userdata, w, h, "bgra")
