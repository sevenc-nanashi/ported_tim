--label:tim2\T_Color_Module.anm\チャンネルミキサー(表示+SetB)
--track0:青←赤％,-300,300,0
--track1:青←緑％,-300,300,0
--track2:青←青％,-300,300,100
--track3:青←定数,-300,300,0
--value@RR:赤←赤％,100
--value@RG:赤←緑％,0
--value@RB:赤←青％,0
--value@RC:赤←定数,0
--value@GR:緑←赤％,0
--value@GG:緑←緑％,100
--value@GB:緑←青％,0
--value@GC:緑←定数,0
--value@BR:青←赤％,0
--value@BG:青←緑％,0
--value@BB:青←青％,100
--value@BC:青←定数,0
if ChannelMixerRate then
    ChannelMixerRate[9] = obj.track0
    ChannelMixerRate[10] = obj.track1
    ChannelMixerRate[11] = obj.track2
    ChannelMixerRate[12] = obj.track3
else
    ChannelMixerRate = { RR, RG, RB, RC, GR, GG, GB, GC, BR, BG, BB, BC }
end
require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.ChannelMixer(userdata, w, h, unpack(ChannelMixerRate))
obj.putpixeldata(userdata)
ChannelMixerRate = nil
