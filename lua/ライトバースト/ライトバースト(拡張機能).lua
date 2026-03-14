--label:tim2\光効果\@ライトバースト
---$track:発光中心X
---min=-10000
---max=10000
---step=0.1
local track_glow_center_x = 0

---$track:発光中心Y
---min=-10000
---max=10000
---step=0.1
local track_glow_center_y = 0

--trackgroup@track_glow_center_x,track_glow_center_y

---$track:サイズ補正X
---min=0
---max=5000
---step=1
local track_size_adjust_x = 0

---$track:サイズ補正Y
---min=0
---max=5000
---step=1
local track_size_adjust_y = 0

komorebikakutyou = 1
obj.setanchor("track_glow_center_x,track_glow_center_y", 0, "line")
Dpos = { track_glow_center_x, track_glow_center_y }
dw = track_size_adjust_x
dh = track_size_adjust_y
