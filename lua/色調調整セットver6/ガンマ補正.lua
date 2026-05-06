--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
--filter
---$track:赤
---min=1
---max=1000
---step=0.1
local track_red = 100

---$track:緑
---min=1
---max=1000
---step=0.1
local track_green = 100

---$track:青
---min=1
---max=1000
---step=0.1
local track_blue = 100

---$track:ALL
---min=1
---max=1000
---step=0.1
local track_all = 100

-- require("T_Color_Module")
local r, g, b
if track_all == 100 then
    r = 100 / track_red
    g = 100 / track_green
    b = 100 / track_blue
else
    r = 100 / track_all
    g, b = r, r
end

--[[pixelshader@gamma_correction
---$include "./shaders/gamma_correction.hlsl"
]]

obj.pixelshader("gamma_correction", "object", "object", {
    r,
    g,
    b,
})
