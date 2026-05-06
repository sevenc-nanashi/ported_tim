--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
--filter
---$check:赤カーブ全体統一
local check0 = false

---$check:データクリア
local DCL = 0

-- require("T_Color_Module")
local T_Color_Module = obj.module("tim2")
local DCL2 = DCL or 0
if T_ToneCurve_R == nil then
    T_Color_Module.color_set_tone_curve(0, 0, 1, 0, 0)
end
if T_ToneCurve_G == nil then
    T_Color_Module.color_set_tone_curve(1, 0, 1, 0, 0)
end
if T_ToneCurve_B == nil then
    T_Color_Module.color_set_tone_curve(2, 0, 1, 0, 0)
end

--[[pixelshader@tone_curve
---$include "./shaders/tone_curve.hlsl"
]]

obj.clearbuffer("cache:tone_curve_lut", 256, 1)
local lut, lut_w, lut_h = obj.getpixeldata("cache:tone_curve_lut", "bgra")
T_Color_Module.color_prepare_tone_curve_lut(lut, lut_w, lut_h, check0)
obj.putpixeldata("cache:tone_curve_lut", lut, lut_w, lut_h, "bgra")
obj.pixelshader("tone_curve", "object", { "object", "cache:tone_curve_lut" })
if DCL2 == 1 then
    T_ToneCurve_R = nil
    T_ToneCurve_G = nil
    T_ToneCurve_B = nil
end
