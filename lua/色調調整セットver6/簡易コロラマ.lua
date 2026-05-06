--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
--filter
---$track:Fシフト
---min=0
---max=5000
---step=0.1
local track_f_shift = 0

---$track:ｻｲｸﾙ数
---min=0
---max=20
---step=0.01
local track_cycle_count = 1

---$track:最大色数
---min=1
---max=6
---step=1
local track_max_colors = 6

---$color:色1
local col1 = 0xffffff

---$color:色2
local col2 = 0xffff00

---$color:色3
local col3 = 0x00ff00

---$color:色4
local col4 = 0x00ffff

---$color:色5
local col5 = 0x0000ff

---$color:色6
local col6 = 0xff00ff

local maxN = math.floor(track_max_colors)
if maxN < 1 then
    maxN = 6
end
local col1_r, col1_g, col1_b = RGB(col1)
local col2_r, col2_g, col2_b = RGB(col2)
local col3_r, col3_g, col3_b = RGB(col3)
local col4_r, col4_g, col4_b = RGB(col4)
local col5_r, col5_g, col5_b = RGB(col5)
local col6_r, col6_g, col6_b = RGB(col6)

--[[pixelshader@colorama
---$include "./shaders/colorama.hlsl"
]]

obj.pixelshader("colorama", "object", "object", {
    track_f_shift / 100,
    track_cycle_count,
    maxN,
    col1_r,
    col1_g,
    col1_b,
    col2_r,
    col2_g,
    col2_b,
    col3_r,
    col3_g,
    col3_b,
    col4_r,
    col4_g,
    col4_b,
    col5_r,
    col5_g,
    col5_b,
    col6_r,
    col6_g,
    col6_b,
})
