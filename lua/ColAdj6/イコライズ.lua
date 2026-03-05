--label:tim2\T_Color_Module.anm
---$track:計算法
---min=0
---max=2
---step=1
local rename_me_track0 = 0

local CType = rename_me_track0
require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
if CType < 2 then
    T_Color_Module.equalize(userdata, w, h, CType)
elseif CType == 2 then
    T_Color_Module.equalizeRGB(userdata, w, h)
end
obj.putpixeldata(userdata)
