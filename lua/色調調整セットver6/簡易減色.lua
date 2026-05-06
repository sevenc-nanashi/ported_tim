--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
--filter
---$track:減色量
---min=0
---max=7
---step=1
local track_color = 3

--[[pixelshader@color_reduction
---$include "./shaders/color_reduction.hlsl"
]]

obj.pixelshader("color_reduction", "object", "object", {
    track_color,
})
