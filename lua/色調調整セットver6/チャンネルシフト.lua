--label:tim2\色調整\@T_Color_Module
--filter
---$select:アルファ
---アルファ=0
---赤=1
---緑=2
---青=3
---色相=4
---彩度=5
---明度=6
local track_alpha = 0

---$select:赤
---アルファ=0
---赤=1
---緑=2
---青=3
---色相=4
---彩度=5
---明度=6
local track_red = 1

---$select:緑
---アルファ=0
---赤=1
---緑=2
---青=3
---色相=4
---彩度=5
---明度=6
local track_green = 2

---$select:青
---アルファ=0
---赤=1
---緑=2
---青=3
---色相=4
---彩度=5
---明度=6
local track_blue = 3

-- require("T_Color_Module")
--[[pixelshader@channel_shift
---$include "./shaders/channel_shift.hlsl"
]]

obj.pixelshader("channel_shift", "object", "object", {
    track_alpha,
    track_red,
    track_green,
    track_blue,
})
