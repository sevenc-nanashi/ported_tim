--label:tim2\色調整\@T_Color_Module
--filter
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

--[[pixelshader@channel_mixer
---$include "./shaders/channel_mixer.hlsl"
]]

obj.pixelshader("channel_mixer", "object", "object", {
    track_red_red_percent / 100,
    track_red_green_percent / 100,
    track_red_blue_percent / 100,
    track_red_count / 100,
    track_green_red_percent / 100,
    track_green_green_percent / 100,
    track_green_blue_percent / 100,
    track_green_count / 100,
    track_blue_red_percent / 100,
    track_blue_green_percent / 100,
    track_blue_blue_percent / 100,
    track_blue_count / 100,
})
