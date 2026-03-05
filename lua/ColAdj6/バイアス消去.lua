--label:tim2\T_Color_Module.anm
---$track:範囲
---min=0
---max=500
---step=1
local rename_me_track0 = 30

---$track:補正量
---min=-500
---max=500
---step=0.1
local rename_me_track1 = 100

---$track:ｵﾌｾｯﾄ
---min=-300
---max=300
---step=0.1
local rename_me_track2 = 0

---$track:偏差閾値
---min=0
---max=1000
---step=0.1
local rename_me_track3 = 0

---$check:偏差補正
local rename_me_check0 = true

require("T_Color_Module")
userdata, w, h = obj.getpixeldata()
T_Color_Module.BiasDeletion(
    userdata,
    w,
    h,
    rename_me_track0,
    rename_me_track1,
    rename_me_track2,
    rename_me_track3,
    rename_me_check0
)
obj.putpixeldata(userdata)
