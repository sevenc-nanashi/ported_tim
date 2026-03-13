--label:tim2\色調整\@T_Color_Module
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

--require("T_Color_Module")
local T_Color_Module = obj.module("tim2")
local userdata, w, h = obj.getpixeldata("object", "bgra")
if track_color ~= nil then
    track_r, track_g, track_b = RGB(track_color)
end
T_Color_Module.color_monochromatic(userdata, w, h, track_r, track_g, track_b)
obj.putpixeldata("object", userdata, w, h, "bgra")
