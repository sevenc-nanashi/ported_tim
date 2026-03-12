--label:tim2\アニメーション効果
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
local track_target_method = 0

---$check:エフェクト適用
local effect = 1

---$check:サイズを揃える
local cksize = 1

---$check:透明度反転
local check0 = false

--[[
指定方法
0:α
1:R
2:G
3:B
4:グレー
--]]
local T_Alpha_Module = obj.module("tim2")

local w0, h0 = obj.getpixel()
obj.copybuffer("cache:original", "object")
obj.load("layer", track_alpha_layer, (effect == 1))
local userdata, w, h = obj.getpixeldata("object", "bgra")
if not userdata and obj.layer == track_alpha_layer and effect == 1 then
    error("エフェクトが有効の場合、自分自身をαレイヤーに指定することはできません。")
end

T_Alpha_Module.alpha_data_set(userdata, w, h, track_target_method)
obj.putpixeldata("object", userdata, w, h, "bgra")
obj.effect("反転", "透明度反転", check0 and 0 or 1)

obj.copybuffer("tempbuffer", "cache:original")
obj.setoption("drawtarget", "tempbuffer")
obj.setoption("blend", "alpha_sub")

if cksize == 1 then
    local w2, h2 = w0 * 0.5, h0 * 0.5
    obj.drawpoly(-w2, -h2, 0, w2, -h2, 0, w2, h2, 0, -w2, h2, 0)
else
    obj.draw()
end
obj.load("tempbuffer")
obj.setoption("blend", 0)
