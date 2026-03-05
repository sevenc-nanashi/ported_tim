--label:tim2
---$track:変換範囲
---min=0
---max=100
---step=0.1
local rename_me_track0 = 100

---$track:適用度
---min=0
---max=100
---step=0.1
local rename_me_track1 = 100

---$track:逆変換
---min=0
---max=1
---step=1
local rename_me_track2 = 0

require("T_PolarConversion_Module")
local userdata, w, h = obj.getpixeldata()
local work = obj.getpixeldata("work")
local LUD
if rename_me_track2 == 0 then
    LUD =
        T_PolarConversion_Module.PolarConversion(userdata, work, w, h, rename_me_track0 * 0.01, rename_me_track1 * 0.01)
else
    LUD =
        T_PolarConversion_Module.PolarInversion(userdata, work, w, h, rename_me_track0 * 0.01, rename_me_track1 * 0.01)
end
obj.putpixeldata(LUD)
