--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
--filter
---$track:Fシフト
---min=0
---max=5000
---step=0.1
local track_phase_shift = 0

---$track:ｻｲｸﾙ数
---min=0
---max=20
---step=0.01
local track_cycle_count = 1

---$track:最大色数
---min=1
---max=6
---step=1
local track_color_count = 6

---$color:色1
local palette_color_1 = 0xffffff

---$color:色2
local palette_color_2 = 0xffff00

---$color:色3
local palette_color_3 = 0x00ff00

---$color:色4
local palette_color_4 = 0x00ffff

---$color:色5
local palette_color_5 = 0x0000ff

---$color:色6
local palette_color_6 = 0xff00ff

local color_count = math.floor(track_color_count)
if color_count < 1 then
    color_count = 6
end
local palette_1_red, palette_1_green, palette_1_blue = RGB(palette_color_1)
local palette_2_red, palette_2_green, palette_2_blue = RGB(palette_color_2)
local palette_3_red, palette_3_green, palette_3_blue = RGB(palette_color_3)
local palette_4_red, palette_4_green, palette_4_blue = RGB(palette_color_4)
local palette_5_red, palette_5_green, palette_5_blue = RGB(palette_color_5)
local palette_6_red, palette_6_green, palette_6_blue = RGB(palette_color_6)

--[[pixelshader@colorama
---$include "./shaders/colorama.hlsl"
]]

obj.pixelshader("colorama", "object", "object", {
    track_phase_shift / 100,
    track_cycle_count,
    color_count,
    palette_1_red,
    palette_1_green,
    palette_1_blue,
    palette_2_red,
    palette_2_green,
    palette_2_blue,
    palette_3_red,
    palette_3_green,
    palette_3_blue,
    palette_4_red,
    palette_4_green,
    palette_4_blue,
    palette_5_red,
    palette_5_green,
    palette_5_blue,
    palette_6_red,
    palette_6_green,
    palette_6_blue,
})
