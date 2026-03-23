--label:tim2\色調整\@T_Color_Module
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

--[[pixelshader@metal
---$include "./shaders/metal.hlsl"
]]

local flips = { flip_lower, flip_upper }
table.sort(flips)

obj.pixelshader("metal", "object", "object", {
    flips[1] / 255,
    flips[2] / 255,
    gray_mode,
})
