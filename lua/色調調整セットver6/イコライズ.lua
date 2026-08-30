--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
--filter
---$select:計算法
---イコライズ+RGB補正=0
---イコライズ=1
---RGB補正=2
local select_calculation_method = 0

--[[pixelshader@equalize
---$include "./shaders/equalize.hlsl"
]]

-- require("T_Color_Module")
local color_module = obj.module("tim2")
local pixel_data, width, height = obj.getpixeldata("object", "bgra")

obj.clearbuffer("cache:equalize_lut", 1021, 1)
local lookup_table, lookup_table_width, lookup_table_height = obj.getpixeldata("cache:equalize_lut", "bgra")
local equalize_parameters = color_module.color_prepare_equalize_lut(
    pixel_data,
    width,
    height,
    lookup_table,
    lookup_table_width,
    lookup_table_height,
    select_calculation_method
)

if equalize_parameters[3] >= 0.5 then
    obj.putpixeldata("cache:equalize_lut", lookup_table, lookup_table_width, lookup_table_height, "bgra")
    obj.pixelshader("equalize", "object", { "object", "cache:equalize_lut" }, {
        equalize_parameters[1],
        equalize_parameters[2],
        select_calculation_method,
        equalize_parameters[3],
    })
end
