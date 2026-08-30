--label:${ROOT_CATEGORY}\色調整\@T_Color_Module
--filter
---$track:R8bit
---min=-100
---max=100
---step=1
local track_red_shift = 0

---$track:G8bit
---min=-100
---max=100
---step=1
local track_green_shift = 0

---$track:B8bit
---min=-100
---max=100
---step=1
local track_blue_shift = 0

---$check:24ビットでシフト
local check_shift_24bit = false

---$track:24bit
---min=-100
---max=100
---step=1
local track_24bit_shift = 0

--hide@track_red_shift:check_shift_24bit==1
--hide@track_green_shift:check_shift_24bit==1
--hide@track_blue_shift:check_shift_24bit==1
--hide@track_24bit_shift:check_shift_24bit==0

-- require("T_Color_Module")
--[[pixelshader@cycle_bit_shift
---$include "./shaders/cycle_bit_shift.hlsl"
]]
local red_shift = math.floor(track_red_shift)
local green_shift = math.floor(track_green_shift)
local blue_shift = math.floor(track_blue_shift)
if check_shift_24bit then
    red_shift = math.floor(track_24bit_shift)
end
obj.pixelshader("cycle_bit_shift", "object", "object", {
    red_shift,
    green_shift,
    blue_shift,
    check_shift_24bit and 1 or 0,
})
