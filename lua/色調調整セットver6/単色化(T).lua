--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
--filter

---$color:色
local monochrome_color = nil

--group:RGB
---$track:R
---min=0
---max=255
---step=0.1
local track_red = 150

---$track:G
---min=0
---max=255
---step=0.1
local track_green = 0

---$track:B
---min=0
---max=255
---step=0.1
local track_blue = 0

if monochrome_color ~= nil then
    track_red, track_green, track_blue = RGB(monochrome_color)
end

--[[pixelshader@monochromatic
---$include "./shaders/monochromatic.hlsl"
]]

obj.pixelshader("monochromatic", "object", "object", {
    track_red,
    track_green,
    track_blue,
})
