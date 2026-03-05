--label:tim2\T_Color_Module.anm\メタル化
--track0:反転濃度1,0,255,85,1
--track1:反転濃度2,0,255,170,1
--track2:ｸﾞﾚｰ処理,0,2,1,1
require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.metal(userdata, w, h, obj.track0, obj.track1, obj.track2)
obj.putpixeldata(userdata)
