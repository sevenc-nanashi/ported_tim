--label:tim2\T_Color_Module.anm
---$track:R8bit
---min=-100
---max=100
---step=1
local track_r8bit = 0

---$track:G8bit
---min=-100
---max=100
---step=1
local track_g8bit = 0

---$track:B8bit
---min=-100
---max=100
---step=1
local track_b8bit = 0

---$track:24bit
---min=-100
---max=100
---step=1
local track_n_24bit = 0

---$check:24ビットでシフト
local check0 = false

require("T_Color_Module")
local r = math.floor(track_r8bit)
local g = math.floor(track_g8bit)
local b = math.floor(track_b8bit)
if check0 then
    r = math.floor(track_n_24bit)
end
local userdata, w, h = obj.getpixeldata()
T_Color_Module.CycleBitShift(userdata, w, h, r, g, b, check0)
obj.putpixeldata(userdata)
