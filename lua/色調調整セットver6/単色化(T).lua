--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
--filter

---$color:色
local track_color = nil

--group:RGB
---$track:R
---min=0
---max=255
---step=0.1
local track_r = 150

---$track:G
---min=0
---max=255
---step=0.1
local track_g = 0

---$track:B
---min=0
---max=255
---step=0.1
local track_b = 0

if track_color ~= nil then
    track_r, track_g, track_b = RGB(track_color)
end

--[[pixelshader@monochromatic
---$include "./shaders/monochromatic.hlsl"
]]

obj.pixelshader("monochromatic", "object", "object", {
    track_r,
    track_g,
    track_b,
})
