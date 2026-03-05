--label:tim2\T_Color_Module.anm\しきい値
---$track:しきい値1
---min=0
---max=255
---step=0.1
local rename_me_track0 = 0

---$track:しきい値2
---min=0
---max=255
---step=0.1
local rename_me_track1 = 128

---$track:判定法
---min=0
---max=4
---step=1
local rename_me_track2 = 0

---$track:透明度
---min=-100
---max=100
---step=0.1
local rename_me_track3 = 0

---$value:置換色/col
local col = 0x0

---$check:範囲を反転
local rename_me_check0 = false

require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.Threshold(
    userdata,
    w,
    h,
    rename_me_track0,
    rename_me_track1,
    rename_me_track2,
    rename_me_track3,
    col,
    rename_me_check0
)
obj.putpixeldata(userdata)
