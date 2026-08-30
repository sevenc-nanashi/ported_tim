--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
--filter
---$select:補正法
---アルファ値の変更=0
---背景色の削除=1
---フリンジの上書き=2
---透明度に応じたフリンジの上書き=3
local select_adjustment_method = 1

---$track:α上限
---min=0
---max=255
---step=1
local track_alpha_upper_limit = 255

---$track:α下限
---min=0
---max=255
---step=1
local track_alpha_lower_limit = 0

---$color:色
local background_color = 0xffffff

---$check:処理後α補正
local check_adjust_alpha_after = 1

--hide@background_color:select_adjustment_method==0

--[[pixelshader@fringe_fix
---$include "./shaders/fringe_fix.hlsl"
]]

local background_red, background_green, background_blue = RGB(background_color or 0xffffff)
obj.pixelshader("fringe_fix", "object", "object", {
    select_adjustment_method,
    track_alpha_upper_limit,
    track_alpha_lower_limit,
    background_red,
    background_green,
    background_blue,
    check_adjust_alpha_after or 0,
})
