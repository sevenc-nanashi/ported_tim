--label:tim2\色調整\T_Color_Module.anm
--filter
---$track:変化
---min=0
---max=100
---step=0.1
local track_change = 0

---$track:定数
---min=-1000
---max=1000
---step=0.1
local track_count = 0

---$track:スケール
---min=-1000
---max=1000
---step=0.1
local track_scale = 100

---$color:指定色1
local col1 = 0x0

---$color:指定色2
local col2 = 0xffffff

---$check:指定色からの距離
local use_distance_from_standard_color = false

--require("T_Color_Module")
local T_Color_Module = obj.module("tim2")
local userdata, w, h = obj.getpixeldata("object", "bgra")
T_Color_Module.color_standard_color(
    userdata,
    w,
    h,
    col1,
    col2,
    track_change / 100,
    track_count,
    track_scale,
    use_distance_from_standard_color
)
obj.putpixeldata("object", userdata, w, h, "bgra")
