--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
--filter
---$select:アルファ
---アルファ=0
---赤=1
---緑=2
---青=3
---色相=4
---彩度=5
---明度=6
local select_alpha_source = 0

---$select:赤
---アルファ=0
---赤=1
---緑=2
---青=3
---色相=4
---彩度=5
---明度=6
local select_red_source = 1

---$select:緑
---アルファ=0
---赤=1
---緑=2
---青=3
---色相=4
---彩度=5
---明度=6
local select_green_source = 2

---$select:青
---アルファ=0
---赤=1
---緑=2
---青=3
---色相=4
---彩度=5
---明度=6
local select_blue_source = 3

-- require("T_Color_Module")
--[[pixelshader@channel_shift
---$include "./shaders/channel_shift.hlsl"
]]

obj.pixelshader("channel_shift", "object", "object", {
    select_alpha_source,
    select_red_source,
    select_green_source,
    select_blue_source,
})
