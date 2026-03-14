--label:tim2\配置\@簡易リピーター
---$track:X
---min=-5000
---max=5000
---step=0.1
local track_x = 300

---$track:Y
---min=-5000
---max=5000
---step=0.1
local track_y = 0

--trackgroup@track_x,track_y

---$track:回転
---min=-3600
---max=3600
---step=0.1
local track_rotation = 0

---$track:拡大%
---min=00
---max=5000
---step=0.1
local track_scale_percent = 100

obj.setanchor("track_x,track_y", 0, "line")
repeater_dx = track_x
repeater_dy = track_y
repeater_dr = track_rotation
repeater_dk = track_scale_percent * 0.01
repeater_rep = 0
