--label:tim2\色調整\@T_Color_Module
--filter
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
--[[pixelshader@cycle_bit_shift
---$include "./shaders/cycle_bit_shift.hlsl"
]]
local r = math.floor(track_r8bit)
local g = math.floor(track_g8bit)
local b = math.floor(track_b8bit)
if shift_24bit then
    r = math.floor(track_n_24bit)
end
obj.pixelshader("cycle_bit_shift", "object", "object", {
    r,
    g,
    b,
    shift_24bit and 1 or 0,
})
