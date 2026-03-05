--label:tim2\T_Color_Module.anm
---$track:強度
---min=0
---max=100
---step=0.1
local rename_me_track0 = 100

---$track:彩度
---min=0
---max=100
---step=0.1
local rename_me_track1 = 70

---$track:ガンマ値
---min=1
---max=1000
---step=0.1
local rename_me_track2 = 120

require("T_Color_Module")
local alp = rename_me_track0 * 0.01
local sai = alp * rename_me_track1 + (1 - alp) * 100
local r = alp * 100 / rename_me_track2 + 1 - alp
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
