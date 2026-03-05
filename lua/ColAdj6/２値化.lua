--label:tim2\T_Color_Module.anm
---$track:閾値
---min=0
---max=255
---step=1
local rename_me_track0 = 128

---$track:ｸﾞﾚｰ処理
---min=0
---max=2
---step=1
local rename_me_track1 = 1

---$track:自動判定
---min=0
---max=6
---step=1
local rename_me_track2 = 0

---$color:明部色
local col1 = 0xff0000

---$color: 暗部色
local col2 = 0x0000ff

---$check:色付け
local rename_me_check0 = true

require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.binarization(
    userdata,
    w,
    h,
    rename_me_track0,
    rename_me_track1,
    rename_me_track2,
    rename_me_check0,
    col1,
    col2
)
obj.putpixeldata(userdata)
