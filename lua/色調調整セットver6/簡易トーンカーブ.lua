--label:tim2\色調整\@T_Color_Module
--filter
---$check:赤カーブ全体統一
local check0 = false

---$check:データクリア
local DCL = 0

-- require("T_Color_Module")
local T_Color_Module = obj.module("tim2")
local DCL2 = DCL or 0
if T_ToneCurve_R == nil then
    T_Color_Module.color_set_tone_curve_mode_0(0, 1, 0, 0)
end
if T_ToneCurve_G == nil then
    T_Color_Module.color_set_tone_curve_mode_0(1, 1, 0, 0)
end
if T_ToneCurve_B == nil then
    T_Color_Module.color_set_tone_curve_mode_0(2, 1, 0, 0)
end
local userdata, w, h = obj.getpixeldata("object", "bgra")
T_Color_Module.color_sim_tone_curve(userdata, w, h, check0)
obj.putpixeldata("object", userdata, w, h, "bgra")
if DCL2 == 1 then
    T_ToneCurve_R = nil
    T_ToneCurve_G = nil
    T_ToneCurve_B = nil
end
