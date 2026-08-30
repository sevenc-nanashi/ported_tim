--label:${ROOT_CATEGORY}\加工
---$track:分割数
---min=10
---max=500
---step=0.1
local track_split_count = 80

---$track:ライン細％
---min=0
---max=100
---step=0.1
local track_percent = 10

---$track:ライン太％
---min=0
---max=100
---step=0.1
local track_percent_2 = 60

---$track:シフト
---min=-10000
---max=10000
---step=0.1
local track_shift = 0

---$color:ライン色
local line_color = 0x000000

---$color:背景色
local background_color = 0xffffff

---$check:背景色非表示
local check_hide_background_color = 0

---$track:横分割倍率%
---min=1
---max=1000
---step=0.1
local track_horizontal_split_scale_percent = 200

---$check:反転
local check_invert = 0

--hide@background_color:check_hide_background_color==1

--[[pixelshader@linetone_t
---$include "./shaders/linetone_t.hlsl"
]]

local vertical_split_count = track_split_count
local horizontal_split_count =
    math.max(1, math.floor(vertical_split_count * track_horizontal_split_scale_percent * 0.01))
local minimum_line_ratio = track_percent * 0.01
local line_ratio_range = math.max(track_percent_2 - track_percent, 0) * 0.01
local vertical_shift = track_shift

local image_width, image_height = obj.getpixel()
local cell_width = image_width / horizontal_split_count
local cell_height = image_height / vertical_split_count
vertical_shift = vertical_shift % cell_height
obj.copybuffer("cache:ori_img", "object")

obj.setoption("drawtarget", "tempbuffer", image_width, image_height)
obj.pixelshader("linetone_t", "tempbuffer", "cache:ori_img", {
    image_width,
    image_height,
    horizontal_split_count,
    vertical_split_count,
    cell_width,
    cell_height,
    vertical_shift,
    minimum_line_ratio,
    line_ratio_range,
    check_invert,
    check_hide_background_color,
    line_color,
    background_color,
})

obj.copybuffer("object", "cache:ori_img")
obj.effect("反転", "透明度反転", 1)
obj.setoption("blend", "alpha_sub")
obj.draw()
obj.load("tempbuffer")
obj.setoption("blend", "none")
