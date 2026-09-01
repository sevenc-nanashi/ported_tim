--label:${ROOT_CATEGORY}\アニメーション効果
---$track:αレイヤー
---min=1
---max=1000
---step=1
local track_alpha_layer = 1

---$select:指定方法
---α=0
---R=1
---G=2
---B=3
---グレー=4
local select_target_channel = 0

---$check:エフェクト適用
local check_apply_effects = 1

---$check:サイズを揃える
local check_match_size = 1

---$check:透明度反転
local check_invert_alpha = false

--[[
指定方法
0:α
1:R
2:G
3:B
4:グレー
--]]
--[[pixelshader@set_alpha_from_channel
---$include "./shaders/set_alpha_from_channel.hlsl"
]]

local original_width, original_height = obj.getpixel()
obj.copybuffer("cache:original", "object")
if obj.layer == track_alpha_layer and check_apply_effects == 1 then
    error("エフェクトが有効の場合、自分自身をαレイヤーに指定することはできません。")
end
obj.load("layer", track_alpha_layer, (check_apply_effects == 1))
obj.pixelshader("set_alpha_from_channel", "object", "object", {
    select_target_channel,
})
obj.effect("反転", "透明度反転", check_invert_alpha and 0 or 1)

obj.copybuffer("tempbuffer", "cache:original")
obj.setoption("drawtarget", "tempbuffer")
obj.setoption("blend", "alpha_sub")

if check_match_size == 1 then
    local half_original_width, half_original_height = original_width * 0.5, original_height * 0.5
    obj.drawpoly(
        -half_original_width,
        -half_original_height,
        0,
        half_original_width,
        -half_original_height,
        0,
        half_original_width,
        half_original_height,
        0,
        -half_original_width,
        half_original_height,
        0
    )
else
    obj.draw()
end
obj.load("tempbuffer")
obj.setoption("blend", 0)
