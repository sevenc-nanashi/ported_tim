--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
--filter
---$track:反転濃度1
---min=0
---max=255
---step=1
local track_lower_flip_threshold = 85

---$track:反転濃度2
---min=0
---max=255
---step=1
local track_upper_flip_threshold = 170

-- ---$track:ｸﾞﾚｰ処理
-- ---min=0
-- ---max=2
-- ---step=1
-- local gray_mode = 1
---$select:グレー処理
---RGB平均=0
---NTSC加重平均法=1
---HDTV法=2
local select_grayscale_method = 1

--[[pixelshader@metal
---$include "./shaders/metal.hlsl"
]]

local sorted_flip_thresholds = { track_lower_flip_threshold, track_upper_flip_threshold }
table.sort(sorted_flip_thresholds)

obj.pixelshader("metal", "object", "object", {
    sorted_flip_thresholds[1] / 255,
    sorted_flip_thresholds[2] / 255,
    select_grayscale_method,
})
