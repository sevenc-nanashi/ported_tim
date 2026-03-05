--label:tim2
---$track:αﾚｲﾔｰ
---min=1
---max=100
---step=1
local track_alpha_layer = 1

---$track:指定方法
---min=0
---max=4
---step=1
local track_target_method = 0

---$check:ｴﾌｪｸﾄ適用
local effect = 1

---$check:ｻｲｽﾞを揃える
local cksize = 1

---$check:透明度反転
local check0 = true

--[[
指定方法
0:α
1:R
2:G
3:B
4:ｸﾞﾚｰ
--]]
require("T_Alpha_Module")

local w0, h0 = obj.getpixel()
obj.copybuffer("cache:original", "obj")

obj.load("layer", track_alpha_layer, (effect == 1))
local userdata, w, h = obj.getpixeldata()
obj.putpixeldata(T_Alpha_Module.AlphaDataSet(userdata, w, h, track_target_method))
obj.effect("反転", "透明度反転", check0 and 0 or 1)

obj.copybuffer("tmp", "cache:original")
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
