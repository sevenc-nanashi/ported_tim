--label:tim2\T_Color_Module.anm
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

ChannelMixerRate = ChannelMixerRate or {}
ChannelMixerRate[5] = track_green_red_percent
ChannelMixerRate[6] = track_green_green_percent
ChannelMixerRate[7] = track_green_blue_percent
ChannelMixerRate[8] = track_green_count
