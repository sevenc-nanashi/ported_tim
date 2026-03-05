--label:tim2\T_Color_Module.anm
---$track:変化
---min=0
---max=100
---step=0.1
local rename_me_track0 = 0

---$track:定数
---min=-1000
---max=1000
---step=0.1
local rename_me_track1 = 0

---$track:スケール
---min=-1000
---max=1000
---step=0.1
local rename_me_track2 = 100

---$color:指定色1
local col1 = 0x0

---$color:指定色2
local col2 = 0xffffff

---$check:指定色からの距離
local rename_me_check0 = false

require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.StandardColor(
    userdata,
    w,
    h,
    col1,
    col2,
    rename_me_track0 / 100,
    rename_me_track1,
    rename_me_track2,
    rename_me_check0
)
obj.putpixeldata(userdata)
