--label:${ROOT_CATEGORY}\アニメーション効果
---$track:指定位置X
---min=-10000
---max=10000
---step=1
local track_target_position_x = 0

---$track:指定位置Y
---min=-10000
---max=10000
---step=1
local track_target_position_y = 0

--trackgroup@track_target_position_x,track_target_position_y:指定位置

---$track:α調整
---min=1
---max=255
---step=1
local track_alpha = 255

---$track:透明度
---min=0
---max=100
---step=0.1
local track_opacity = 0

---$color:塗り潰し色
local fill_color = 0xffcccc

---$check:改良計算
local check_use_improved_calculation = true

local tim2 = obj.module("tim2")

obj.setanchor("track_target_position_x,track_target_position_y", 0)
local r, g, b = RGB(fill_color)
local pixel_data, width, height = obj.getpixeldata("object", "bgra")
tim2.alpha_fill_color(
    pixel_data,
    width,
    height,
    r,
    g,
    b,
    track_target_position_x,
    track_target_position_y,
    track_alpha,
    check_use_improved_calculation,
    1 - track_opacity * 0.01
)
obj.putpixeldata("object", pixel_data, width, height, "bgra")
