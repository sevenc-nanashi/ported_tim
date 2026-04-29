--label:tim2\色調整\@T_Color_Module
--filter
---$select:補正法
---アルファ値の変更=0
---背景色の削除=1
---フリンジの上書き=2
---透明度に応じたフリンジの上書き=3
local track_adjust_method = 1

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
local col = 0xffffff

---$check:処理後α補正
local Af = 1

--[[pixelshader@fringe_fix
---$include "./shaders/fringe_fix.hlsl"
]]

local bg_r, bg_g, bg_b = RGB(col or 0xffffff)
obj.pixelshader("fringe_fix", "object", "object", {
    track_adjust_method,
    track_alpha_upper_limit,
    track_alpha_lower_limit,
    bg_r,
    bg_g,
    bg_b,
    Af or 0,
})
