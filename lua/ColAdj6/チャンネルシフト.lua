--label:tim2\T_Color_Module.anm\チャンネルシフト
--track0:アルファ,0,6,0,1
--track1:赤,0,6,1,1
--track2:緑,0,6,2,1
--track3:青,0,6,3,1
--value@Dchk:チャンネル表示/chk,0
--value@fs:フォントサイズ,34
require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.ShiftChannels(userdata, w, h, obj.track0, obj.track1, obj.track2, obj.track3)
obj.putpixeldata(userdata)
if obj.getinfo("saving") == false and Dchk == 1 then
    obj.setoption("drawtarget", "tempbuffer", w, h)
    obj.draw()
    local text = "チャンネル\n 0:アルファ\n 1:赤\n 2:緑\n 3:青\n 4:色相\n 5:彩度\n 6:明度"
    obj.setfont("", fs, 1, 0xffffff, 0x000000)
    obj.load("text", text)
    obj.draw()
    obj.load("tempbuffer")
end
