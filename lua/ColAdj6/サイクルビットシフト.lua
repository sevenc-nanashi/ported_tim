--label:tim2\T_Color_Module.anm
---$track:R8bit
---min=-100
---max=100
---step=1
local rename_me_track0 = 0

---$track:G8bit
---min=-100
---max=100
---step=1
local rename_me_track1 = 0

---$track:B8bit
---min=-100
---max=100
---step=1
local rename_me_track2 = 0

---$track:24bit
---min=-100
---max=100
---step=1
local rename_me_track3 = 0

---$check:24ビットでシフト
local rename_me_check0 = false

require("T_Color_Module")
local r = math.floor(rename_me_track0)
local g = math.floor(rename_me_track1)
local b = math.floor(rename_me_track2)
if rename_me_check0 then
    r = math.floor(rename_me_track3)
end
local userdata, w, h = obj.getpixeldata()
T_Color_Module.CycleBitShift(userdata, w, h, r, g, b, rename_me_check0)
obj.putpixeldata(userdata)
