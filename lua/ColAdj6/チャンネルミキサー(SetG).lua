--label:tim2\T_Color_Module.anm\チャンネルミキサー(SetG)
---$track:緑←赤％
---min=-300
---max=300
---step=0.1
local rename_me_track0 = 0

---$track:緑←緑％
---min=-300
---max=300
---step=0.1
local rename_me_track1 = 100

---$track:緑←青％
---min=-300
---max=300
---step=0.1
local rename_me_track2 = 0

---$track:緑←定数
---min=-300
---max=300
---step=0.1
local rename_me_track3 = 0

ChannelMixerRate = ChannelMixerRate or {}
ChannelMixerRate[5] = rename_me_track0
ChannelMixerRate[6] = rename_me_track1
ChannelMixerRate[7] = rename_me_track2
ChannelMixerRate[8] = rename_me_track3
