--label:tim2\T_Color_Module.anm\イコライズ
--track0:計算法,0,2,0,1
local CType = obj.track0
require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
if CType < 2 then
    T_Color_Module.equalize(userdata, w, h, CType)
elseif CType == 2 then
    T_Color_Module.equalizeRGB(userdata, w, h)
end
obj.putpixeldata(userdata)
