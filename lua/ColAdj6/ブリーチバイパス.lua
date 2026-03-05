--label:tim2\T_Color_Module.anm
---$track:強度
---min=0
---max=100
---step=0.1
local track_intensity = 100

---$track:彩度
---min=0
---max=100
---step=0.1
local track_saturation = 70

---$track:ガンマ値
---min=1
---max=1000
---step=0.1
local track_gamma = 120

require("T_Color_Module")
local alp = track_intensity * 0.01
local sai = alp * track_saturation + (1 - alp) * 100
local r = alp * 100 / track_gamma + 1 - alp
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
