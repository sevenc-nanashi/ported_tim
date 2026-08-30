--label:${ROOT_CATEGORY}\色調整
---$track:幅
---min=0
---max=100
---step=0.1
local track_width = 0

---$track:中心ズレ1
---min=-100
---max=100
---step=0.1
local track_center_offset_1 = 0

---$track:中心ズレ2
---min=-100
---max=100
---step=0.1
local track_center_offset_2 = 0

---$track:中心ズレ3
---min=-100
---max=100
---step=0.1
local track_center_offset_3 = 0

---$color:色1
local gradient_color_1 = 0x00ff00

---$color:色2
local gradient_color_2 = 0xffff00

---$color:色3
local gradient_color_3 = 0xff0000

---$color:色4
local gradient_color_4 = 0x0000ff

local gradient_width = track_width * obj.h / 100
local center_position_1 = -(obj.h + gradient_width) / 4 + track_center_offset_1 * obj.h / 100
local center_position_2 = track_center_offset_2 * obj.h / 100
local center_position_3 = (obj.h + gradient_width) / 4 + track_center_offset_3 * obj.h / 100
obj.effect(
    "グラデーション",
    "color",
    gradient_color_1,
    "color2",
    gradient_color_2,
    "中心Y",
    center_position_1,
    "幅",
    gradient_width,
    "type",
    0
)
obj.effect(
    "グラデーション",
    "no_color",
    1,
    "color2",
    gradient_color_3,
    "中心Y",
    center_position_2,
    "幅",
    gradient_width,
    "type",
    0
)
obj.effect(
    "グラデーション",
    "no_color",
    1,
    "color2",
    gradient_color_4,
    "中心Y",
    center_position_3,
    "幅",
    gradient_width,
    "type",
    0
)
