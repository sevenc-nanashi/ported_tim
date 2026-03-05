--label:tim2\T_Color_Module.anm
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

---$value:赤←赤％
local RR = 100

---$value:赤←緑％
local RG = 0

---$value:赤←青％
local RB = 0

---$value:赤←定数
local RC = 0

---$value:緑←赤％
local GR = 0

---$value:緑←緑％
local GG = 100

---$value:緑←青％
local GB = 0

---$value:緑←定数
local GC = 0

---$value:青←赤％
local BR = 0

---$value:青←緑％
local BG = 0

---$value:青←青％
local BB = 100

---$value:青←定数
local BC = 0

if ChannelMixerRate then
    ChannelMixerRate[9] = track_blue_red_percent
    ChannelMixerRate[10] = track_blue_green_percent
    ChannelMixerRate[11] = track_blue_blue_percent
    ChannelMixerRate[12] = track_blue_count
else
    ChannelMixerRate = { RR, RG, RB, RC, GR, GG, GB, GC, BR, BG, BB, BC }
end
require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.ChannelMixer(userdata, w, h, unpack(ChannelMixerRate))
obj.putpixeldata(userdata)
ChannelMixerRate = nil
