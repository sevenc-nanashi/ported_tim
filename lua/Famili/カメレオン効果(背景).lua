--label:tim2\カメレオン効果.anm
---$track:中心X
---min=-10000
---max=10000
---step=1
local rename_me_track0 = 0

---$track:中心Y
---min=-10000
---max=10000
---step=1
local rename_me_track1 = 0

---$track:幅
---min=0
---max=10000
---step=1
local rename_me_track2 = 5000

---$track:高さ
---min=0
---max=10000
---step=1
local rename_me_track3 = 5000

---$check:範囲を表示
local rename_me_check0 = true

---$color:枠色
local col = oxffffff

---$value:枠幅
local Lw = 2

require("T_Familiar_Module")
local userdata, w, h = obj.getpixeldata()
T_Familiar_Module.SetColor(
    userdata,
    w,
    h,
    rename_me_track0,
    rename_me_track1,
    rename_me_track2,
    rename_me_track3,
    rename_me_check0,
    col,
    Lw
)
obj.putpixeldata(userdata)
