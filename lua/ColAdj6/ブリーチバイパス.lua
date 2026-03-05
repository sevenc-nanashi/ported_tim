--label:tim2\T_Color_Module.anm\ブリーチバイパス
--track0:強度,0,100,100
--track1:彩度,0,100,70
--track2:ガンマ値,1,1000,120
require("T_Color_Module")
local alp = obj.track0 * 0.01
local sai = alp * obj.track1 + (1 - alp) * 100
local r = alp * 100 / obj.track2 + 1 - alp
obj.copybuffer("tmp", "obj")
obj.setoption("drawtarget", "tempbuffer")
obj.setoption("blend", 5)
obj.effect("単色化")
obj.draw(0, 0, 0, 1, alp)
obj.load("tempbuffer")
obj.setoption("blend", 0)
obj.effect("色調補正", "彩度", sai)
local userdata, w, h = obj.getpixeldata()
T_Color_Module.GammaCorrection(userdata, w, h, r, r, r)
obj.putpixeldata(userdata)
