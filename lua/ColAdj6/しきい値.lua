--label:tim2\色調整\T_Color_Module.anm
--filter
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

-- ---$track:判定法
-- ---min=0
-- ---max=4
-- ---step=1
---$select:判定法
---平均=0
---視覚補正=1
---R=2
---G=3
---B=4
local track_detect_method = 0

---$track:透明度
---min=-100
---max=100
---step=0.1
local track_opacity = 0

---$color:置換色
local col = 0x0

---$check:範囲を反転
local invert_range = false

-- require("T_Color_Module")
local T_Color_Module = obj.module("tim2")
local userdata, w, h = obj.getpixeldata("object", "bgra")
T_Color_Module.color_threshold(
    userdata,
    w,
    h,
    track_threshold_1,
    track_threshold_2,
    track_detect_method,
    track_opacity,
    col,
    invert_range
)
obj.putpixeldata("object", userdata, w, h, "bgra")
