--label:${ROOT_CATEGORY}\配置\@簡易リピーター
---$track:X変化率
---min=-100
---max=100
---step=0.1
local track_x_change = 0

---$track:Y変化率
---min=-100
---max=100
---step=0.1
local track_y_change = 0

---$track:拡大変率
---min=-100
---max=100
---step=0.1
local track_scale_rate = 0

---$track:回転変率
---min=-100
---max=100
---step=0.1
local track_rotation_rate = 0

T_REPEATER_X_RATE = track_x_change * 0.01
T_REPEATER_Y_RATE = track_y_change * 0.01
T_REPEATER_SCALE_RATE = track_scale_rate * 0.01
T_REPEATER_ROTATION_RATE = track_rotation_rate * 0.01
