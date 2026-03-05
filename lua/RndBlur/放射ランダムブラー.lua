--label:tim2\T_RandomBlur_Module.anm\放射ランダムブラー
--track0:中心X,-5000,5000,0
--track1:中心Y,-5000,5000,0
--track2:最大ｽﾞﾚ量,0,5000,200
--track3:基準,-100,100,0
--value@ck:サイズ保持/chk,1
--value@RC:変化固定,0
local userdata, w, h
w, h = obj.getpixel()
r = math.sqrt(w * w + h * h)
if ck == 0 then
    obj.setoption("drawtarget", "tempbuffer", r, r)
    obj.draw()
    obj.load("tempbuffer")
    obj.setoption("drawtarget", "framebuffer")
end
require("T_RandomBlur_Module")
userdata, w, h = obj.getpixeldata()
obj.setanchor("track", 0, "line")
dx = obj.track0
dy = obj.track1
work = obj.getpixeldata("work")
local LUD = T_RandomBlur_Module.RadRandBlur(userdata, work, w, h, obj.track2, r / 2, dx, dy, RC, obj.track3 * 0.01)
obj.putpixeldata(LUD)
