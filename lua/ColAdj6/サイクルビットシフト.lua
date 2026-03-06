--label:tim2\未分類\T_Color_Module.anm
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

---$check:24ビットでシフト
local shift_24bit = false

---$track:24bit
---min=-100
---max=100
---step=1
local track_n_24bit = 0

-- require("T_Color_Module")
local T_Color_Module = obj.module("tim2")
local r = math.floor(track_r8bit)
local g = math.floor(track_g8bit)
local b = math.floor(track_b8bit)
if shift_24bit then
    r = math.floor(track_n_24bit)
end
local userdata, w, h = obj.getpixeldata("object", "bgra")
T_Color_Module.cycle_bit_shift(userdata, w, h, r, g, b, shift_24bit)
obj.putpixeldata("object", userdata, w, h, "bgra")