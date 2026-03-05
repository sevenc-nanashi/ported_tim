--label:tim2\T_Color_Module.anm\メタル化
--filter
---$track:反転濃度1
---min=0
---max=255
---step=1
local flip_lower = 85

---$track:反転濃度2
---min=0
---max=255
---step=1
local flip_upper = 170

-- ---$track:ｸﾞﾚｰ処理
-- ---min=0
-- ---max=2
-- ---step=1
-- local gray_mode = 1
---$select:グレー処理
---RGB平均=0
---NTSC加重平均法=1
---HDTV法=2
local gray_mode = 1

--require("T_Color_Module")
local T_Color_Module = obj.module("tim2")
local userdata, w, h = obj.getpixeldata("object")
T_Color_Module.metal(userdata, w, h, flip_lower, flip_upper, gray_mode)
obj.putpixeldata("object", userdata, w, h)