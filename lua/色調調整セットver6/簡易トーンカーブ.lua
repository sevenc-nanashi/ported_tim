--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
--filter
---$check:赤カーブ全体統一
local check_unify_red_curve = false

---$check:データクリア
local check_clear_data = 0

-- require("T_Color_Module")
local color_module = obj.module("tim2")
local clear_data_flag = check_clear_data or 0
if T_TONE_CURVE_R == nil then
    color_module.color_set_tone_curve(0, 0, 1, 0, 0)
end
if T_TONE_CURVE_G == nil then
    color_module.color_set_tone_curve(1, 0, 1, 0, 0)
end
if T_TONE_CURVE_B == nil then
    color_module.color_set_tone_curve(2, 0, 1, 0, 0)
end

--[[pixelshader@tone_curve
---$include "./shaders/tone_curve.hlsl"
]]

obj.clearbuffer("cache:tone_curve_lut", 256, 1)
local lookup_table, lookup_table_width, lookup_table_height = obj.getpixeldata("cache:tone_curve_lut", "bgra")
color_module.color_prepare_tone_curve_lut(lookup_table, lookup_table_width, lookup_table_height, check_unify_red_curve)
obj.putpixeldata("cache:tone_curve_lut", lookup_table, lookup_table_width, lookup_table_height, "bgra")
obj.pixelshader("tone_curve", "object", { "object", "cache:tone_curve_lut" })
if clear_data_flag == 1 then
    T_TONE_CURVE_R = nil
    T_TONE_CURVE_G = nil
    T_TONE_CURVE_B = nil
end
