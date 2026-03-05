--label:tim2\T_RandomBlur_Module.anm\ランダムブラー
--track0:最大ｽﾞﾚ量,0,5000,100
--track1:角度,-3600,3600,0
--track2:基準位置,-100,100,0
--track3:変化固定,0,1000,0,1

--value@ck:サイズ保持/chk,1

local zure = obj.track0
local deg = obj.track1
local RC = obj.track3
local userdata, w, h
w, h = obj.getpixel()
if ck == 0 then
    obj.setoption(
        "drawtarget",
        "tempbuffer",
        w + math.abs(2 * zure * math.cos(math.pi * deg / 180)),
        h + math.abs(2 * zure * math.sin(math.pi * deg / 180))
    )
    obj.draw()
    obj.load("tempbuffer")
    obj.setoption("drawtarget", "framebuffer")
end
require("T_RandomBlur_Module")
userdata, w, h = obj.getpixeldata()
work = obj.getpixeldata("work")
local LUD = T_RandomBlur_Module.PalRandBlur(userdata, work, w, h, zure, deg, RC, obj.track2 * 0.01)
obj.putpixeldata(LUD)
