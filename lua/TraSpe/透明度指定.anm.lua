--label:tim2
--track0:αﾚｲﾔｰ,1,100,1,1
--track1:指定方法,0,4,0,1
--value@effect:ｴﾌｪｸﾄ適用/chk,1
--value@cksize:ｻｲｽﾞを揃える/chk,1
--check0:透明度反転,0;

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

obj.load("layer", obj.track0, (effect == 1))
local userdata, w, h = obj.getpixeldata()
obj.putpixeldata(T_Alpha_Module.AlphaDataSet(userdata, w, h, obj.track1))
obj.effect("反転", "透明度反転", obj.check0 and 0 or 1)

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
