--label:tim2\T_Color_Module.anm\ガンマ補正
---$track:赤
---min=1
---max=1000
---step=0.1
local rename_me_track0 = 100

---$track:緑
---min=1
---max=1000
---step=0.1
local rename_me_track1 = 100

---$track:青
---min=1
---max=1000
---step=0.1
local rename_me_track2 = 100

---$track:ALL
---min=1
---max=1000
---step=0.1
local rename_me_track3 = 100

require("T_Color_Module")
local r, g, b
if rename_me_track3 == 100 then
    r = 100 / rename_me_track0
    g = 100 / rename_me_track1
    b = 100 / rename_me_track2
else
    r = 100 / rename_me_track3
    g, b = r, r
end
local userdata, w, h = obj.getpixeldata()
T_Color_Module.GammaCorrection(userdata, w, h, r, g, b)
obj.putpixeldata(userdata)
