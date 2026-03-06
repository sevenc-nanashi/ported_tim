--label:tim2\T_Color_Module.anm
---$select:計算法
---イコライズ+RGB補正=0
---イコライズ=1
---RGB補正=2
local calc_method = 0

-- require("T_Color_Module")
local T_Color_Module = obj.module("tim2")
local userdata, w, h = obj.getpixeldata("object", "bgra")
if calc_method < 2 then
    T_Color_Module.equalize(userdata, w, h, calc_method)
elseif calc_method == 2 then
    T_Color_Module.equalize_rgb(userdata, w, h)
end
obj.putpixeldata("object", userdata, w, h, "bgra")