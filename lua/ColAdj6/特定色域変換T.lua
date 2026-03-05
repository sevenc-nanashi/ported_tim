--label:tim2\T_Color_Module.anm\特定色域変換T
---$track:色相範囲
---min=0
---max=360
---step=0.1
local rename_me_track0 = 100

---$track:彩度範囲
---min=0
---max=255
---step=0.1
local rename_me_track1 = 255

---$track:輝度調整
---min=0
---max=500
---step=0.1
local rename_me_track2 = 100

---$track:境界補正
---min=1
---max=360
---step=0.1
local rename_me_track3 = 2

---$value:変更前/col
local col1 = 0x0000ff

---$value: 変更後/col
local col2 = 0xff0000

---$value:彩度調整
local pS = 100

local pS2 = pS or 100
require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.ChangeToColor(
    userdata,
    w,
    h,
    col1,
    col2,
    rename_me_track0,
    rename_me_track1,
    pS2 * 0.01,
    rename_me_track2 * 0.01,
    rename_me_track3
)
obj.putpixeldata(userdata)
