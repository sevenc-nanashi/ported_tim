--label:tim2\T_Color_Module.anm
---$track:Fシフト
---min=0
---max=5000
---step=0.1
local rename_me_track0 = 0

---$track:ｻｲｸﾙ数
---min=0
---max=20
---step=0.01
local rename_me_track1 = 1

---$track:最大色数
---min=1
---max=6
---step=1
local rename_me_track2 = 6

---$color:色1
local col1 = 0xffffff

---$color:色2
local col2 = 0xffff00

---$color:色3
local col3 = 0x00ff00

---$value:色4
local col4 = 0x00ffff

---$value:色5
local col5 = 0x0000ff

---$value:色6
local col6 = 0xff00ff

---$color:取得用
local col7 = 0x000000

local maxN = math.floor(rename_me_track2)
if maxN < 1 then
    maxN = 6
end
require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.Colorama(
    userdata,
    w,
    h,
    rename_me_track0 / 100,
    rename_me_track1,
    maxN,
    col1,
    col2,
    col3,
    col4,
    col5,
    col6
)
obj.putpixeldata(userdata)
