--label:tim2\T_Color_Module.anm
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

ChannelMixerRate = ChannelMixerRate or {}
ChannelMixerRate[1] = track_red_red_percent
ChannelMixerRate[2] = track_red_green_percent
ChannelMixerRate[3] = track_red_blue_percent
ChannelMixerRate[4] = track_red_count
