--label:tim2\色調整\T_Color_Module.anm
---$track:赤←赤％
---min=-300
---max=300
---step=0.1
local track_red_red_percent = 100

---$track:赤←緑％
---min=-300
---max=300
---step=0.1
local track_red_green_percent = 0

---$track:赤←青％
---min=-300
---max=300
---step=0.1
local track_red_blue_percent = 0

---$track:赤←定数
---min=-300
---max=300
---step=0.1
local track_red_count = 0

---$track:緑←赤％
---min=-300
---max=300
---step=0.1
local track_green_red_percent = 0

---$track:緑←緑％
---min=-300
---max=300
---step=0.1
local track_green_green_percent = 100

---$track:緑←青％
---min=-300
---max=300
---step=0.1
local track_green_blue_percent = 0

---$track:緑←定数
---min=-300
---max=300
---step=0.1
local track_green_count = 0

---$track:青←赤％
---min=-300
---max=300
---step=0.1
local track_blue_red_percent = 0

---$track:青←緑％
---min=-300
---max=300
---step=0.1
local track_blue_green_percent = 0

---$track:青←青％
---min=-300
---max=300
---step=0.1
local track_blue_blue_percent = 100

---$track:青←定数
---min=-300
---max=300
---step=0.1
local track_blue_count = 0


local current_rate = {
    track_red_red_percent,
    track_red_green_percent,
    track_red_blue_percent,
    track_red_count,
    track_green_red_percent,
    track_green_green_percent,
    track_green_blue_percent,
    track_green_count,
    track_blue_red_percent,
    track_blue_green_percent,
    track_blue_blue_percent,
    track_blue_count,
}
-- require("T_Color_Module")
local T_Color_Module = obj.module("tim2")
local userdata, w, h = obj.getpixeldata("object", "bgra")
T_Color_Module.channel_mixer(userdata, w, h, unpack(current_rate))
obj.putpixeldata("object", userdata, w, h, "bgra")