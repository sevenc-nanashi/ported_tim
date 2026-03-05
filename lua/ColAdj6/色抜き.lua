--label:tim2\T_Color_Module.anm\色抜き
--track0:色抜き量,0,100,100
--track1:色差範囲,0,500,50,1
--track2:エッジ,0,100,50
--track3:ﾏｯﾁﾝｸﾞ法,1,4,1,1
--value@col:抽出色/col,0xff0000
--value@Dchk:ﾏｯﾁﾝｸﾞ法表示/chk,0
--value@fs:フォントサイズ,34
local r, g, b = RGB(col)
require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.LeaveColor(userdata, w, h, r, g, b, obj.track0, obj.track1, obj.track2, obj.track3)
obj.putpixeldata(userdata)
if obj.getinfo("saving") == false and Dchk == 1 then
    obj.setoption("drawtarget", "tempbuffer", w, h)
    obj.draw()
    local text = "ﾏｯﾁﾝｸﾞ法\n 1:RGB\n 2:L*a*b*色相\n 3:L*a*b*輝度、色相\n 4:HSV色相"
    obj.setfont("", fs, 1, 0xffffff, 0x000000)
    obj.load("text", text)
    obj.draw()
    obj.load("tempbuffer")
end
