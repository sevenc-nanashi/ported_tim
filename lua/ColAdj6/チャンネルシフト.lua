--label:tim2\T_Color_Module.anm\チャンネルシフト
---$track:アルファ
---min=0
---max=6
---step=1
local rename_me_track0 = 0

---$track:赤
---min=0
---max=6
---step=1
local rename_me_track1 = 1

---$track:緑
---min=0
---max=6
---step=1
local rename_me_track2 = 2

---$track:青
---min=0
---max=6
---step=1
local rename_me_track3 = 3

---$check:チャンネル表示
local Dchk = 0

---$value:フォントサイズ
local fs = 34

require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.ShiftChannels(userdata, w, h, rename_me_track0, rename_me_track1, rename_me_track2, rename_me_track3)
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
