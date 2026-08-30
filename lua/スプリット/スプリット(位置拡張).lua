--label:${ROOT_CATEGORY}\変形\@スプリット
---$track:中心X
---min=-5000
---max=5000
---step=0.1
local track_center_x = 0

---$track:中心Y
---min=-5000
---max=5000
---step=0.1
local track_center_y = 0

---$track:幅
---min=0
---max=5000
---step=0.1
local track_width = 200

---$track:回転
---min=-3600
---max=3600
---step=0.1
local track_rotation = 0

T_SPLIT_CENTER_X = track_center_x
T_SPLIT_CENTER_Y = track_center_y
T_SPLIT_WIDTH = track_width
T_SPLIT_ROTATION = math.rad(track_rotation)
