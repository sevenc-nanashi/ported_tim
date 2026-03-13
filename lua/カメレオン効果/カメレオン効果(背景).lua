--label:tim2\色調整\@カメレオン効果
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
local col = 0xffffff

---$track:枠幅
---min=0
---max=100
---step=1
local Lw = 2

local tim2 = obj.module("tim2")
local userdata, w, h = obj.getpixeldata("object", "bgra")
tim2.famili_set_color(userdata, w, h, track_center_x, track_center_y, track_width, track_height, check0, col, Lw)
obj.putpixeldata("object", userdata, w, h, "bgra")
