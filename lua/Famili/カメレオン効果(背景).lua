--label:tim2\未分類\カメレオン効果.anm
---$track:中心X
---min=-10000
---max=10000
---step=1
local track_center_x = 0

---$track:中心Y
---min=-10000
---max=10000
---step=1
local track_center_y = 0

---$track:幅
---min=0
---max=10000
---step=1
local track_width = 5000

---$track:高さ
---min=0
---max=10000
---step=1
local track_height = 5000

---$check:範囲を表示
local check0 = false

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
    track_center_x,
    track_center_y,
    track_width,
    track_height,
    check0,
    col,
    Lw
)
obj.putpixeldata(userdata)
