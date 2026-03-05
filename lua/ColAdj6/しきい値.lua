--label:tim2\T_Color_Module.anm
---$track:しきい値1
---min=0
---max=255
---step=0.1
local track_threshold_1 = 0

---$track:しきい値2
---min=0
---max=255
---step=0.1
local track_threshold_2 = 128

---$track:判定法
---min=0
---max=4
---step=1
local track_detect_method = 0

---$track:透明度
---min=-100
---max=100
---step=0.1
local track_opacity = 0

---$color:置換色
local col = 0x0

---$check:範囲を反転
local check0 = false

require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.Threshold(
    userdata,
    w,
    h,
    track_threshold_1,
    track_threshold_2,
    track_detect_method,
    track_opacity,
    col,
    check0
)
obj.putpixeldata(userdata)
