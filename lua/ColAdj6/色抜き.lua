--label:tim2\T_Color_Module.anm
---$track:色抜き量
---min=0
---max=100
---step=0.1
local track_color_cut_amount = 100

---$track:色差範囲
---min=0
---max=500
---step=1
local track_color_difference_range = 50

---$track:エッジ
---min=0
---max=100
---step=0.1
local track_edge = 50

---$track:ﾏｯﾁﾝｸﾞ法
---min=1
---max=4
---step=1
local track_matching_method = 1

---$color:抽出色
local col = 0xff0000

---$check:ﾏｯﾁﾝｸﾞ法表示
local Dchk = 0

---$value:フォントサイズ
local fs = 34

local r, g, b = RGB(col)
require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.LeaveColor(
    userdata,
    w,
    h,
    r,
    g,
    b,
    track_color_cut_amount,
    track_color_difference_range,
    track_edge,
    track_matching_method
)
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
