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
local track_all_channels = 100

-- require("T_Color_Module")
local red_gamma, green_gamma, blue_gamma
if track_all_channels == 100 then
    red_gamma = 100 / track_red
    green_gamma = 100 / track_green
    blue_gamma = 100 / track_blue
else
    red_gamma = 100 / track_all_channels
    green_gamma, blue_gamma = red_gamma, red_gamma
end

--[[pixelshader@gamma_correction
---$include "./shaders/gamma_correction.hlsl"
]]

obj.pixelshader("gamma_correction", "object", "object", {
    red_gamma,
    green_gamma,
    blue_gamma,
})
