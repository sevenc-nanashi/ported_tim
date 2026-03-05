--label:tim2\T_Color_Module.anm
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

---$track:ガンマ値
---min=1
---max=1000
---step=0.1
local gamma = 100

---$color:明部色
local bright_color = 0xffffff

---$color:暗部色
local dark_color = 0x0

bright_color = bright_color or 0xffffff
dark_color = dark_color or 0x0
-- require("T_Color_Module")

local T_Color_Module = obj.module("tim2")

local userdata, w, h = obj.getpixeldata("object", "bgra")
T_Color_Module.grayscale(userdata, w, h, gray_mode, bright_color, dark_color, 100 / gamma)
obj.putpixeldata("object", userdata, w, h)