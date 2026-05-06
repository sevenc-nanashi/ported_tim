--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
--filter
---$select:計算法
---イコライズ+RGB補正=0
---イコライズ=1
---RGB補正=2
local calc_method = 0

--[[pixelshader@equalize
---$include "./shaders/equalize.hlsl"
]]

-- require("T_Color_Module")
local T_Color_Module = obj.module("tim2")
local userdata, w, h = obj.getpixeldata("object", "bgra")

obj.clearbuffer("cache:equalize_lut", 1021, 1)
local lut, lut_w, lut_h = obj.getpixeldata("cache:equalize_lut", "bgra")
local params = T_Color_Module.color_prepare_equalize_lut(userdata, w, h, lut, lut_w, lut_h, calc_method)

if params[3] >= 0.5 then
    obj.putpixeldata("cache:equalize_lut", lut, lut_w, lut_h, "bgra")
    obj.pixelshader("equalize", "object", { "object", "cache:equalize_lut" }, {
        params[1],
        params[2],
        calc_method,
        params[3],
    })
end
