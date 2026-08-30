--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
--filter
---$track:R階調数
---min=2
---max=256
---step=1
local track_red_levels = 8

---$track:G階調数
---min=2
---max=256
---step=1
local track_green_levels = 8

---$track:B階調数
---min=2
---max=256
---step=1
local track_blue_levels = 8

---$track:サイズ
---min=1
---max=1000
---step=0.1
local track_size = 1

---$check:全体をRで調整
local check_use_red_for_all_channels = false

---$check:誤差拡散
local check_error_diffusion = false

--hide@track_green_levels:check_use_red_for_all_channels==1
--hide@track_blue_levels:check_use_red_for_all_channels==1

--[[pixelshader@posterize
---$include "./shaders/posterize.hlsl"
]]

local pixel_size = math.max(1, track_size) --追加のため
local original_width, original_height
local red_levels, green_levels, blue_levels
if check_use_red_for_all_channels then
    red_levels = track_red_levels
    green_levels, blue_levels = red_levels, red_levels
else
    red_levels, green_levels, blue_levels = track_red_levels, track_green_levels, track_blue_levels
end
if pixel_size > 1 then
    original_width, original_height = obj.getpixel()
    obj.effect("リサイズ", "拡大率", 100 / pixel_size)
end
if check_error_diffusion then
    -- require("T_Color_Module")
    local color_module = obj.module("tim2")
    local pixel_data, width, height = obj.getpixeldata("object", "bgra")
    color_module.color_posterize_error_diffusion(pixel_data, width, height, red_levels, green_levels, blue_levels)
    obj.putpixeldata("object", pixel_data, width, height, "bgra")
else
    obj.pixelshader("posterize", "object", "object", {
        red_levels,
        green_levels,
        blue_levels,
    })
end
if pixel_size > 1 then
    obj.effect(
        "リサイズ",
        "X",
        original_width,
        "Y",
        original_height,
        "補間なし",
        1,
        "ドット数でサイズ指定",
        1
    )
end
