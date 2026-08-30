--label:${ROOT_CATEGORY}\装飾\@ストロークT
---$track:誤差X
---min=0
---max=10000
---step=1
local track_error_x = 100

---$track:誤差Y
---min=0
---max=10000
---step=1
local track_error_y = 100

---$track:誤差サイズ
---min=0
---max=1000
---step=1
local track_error_size = 80

---$track:誤差角度
---min=0
---max=3600
---step=0.1
local track_error_angle = 180

---$track:誤差透明度
---min=0
---max=100
---step=0.1
local track_error_alpha = 50

---$track:乱数シード
---min=0
---max=100000
---step=1
local track_random_seed = 0

---$value:拡大率変動[%]
local scale_values = { 100, 100, 100 }

---$value:角度変動
local rotation_values = { 0, 0, 0 }

---$value:透明度変動[%]
local alpha_values = { 0, 0, 0 }

T_STROKE_ERROR_X = track_error_x
T_STROKE_ERROR_Y = track_error_y
T_STROKE_ERROR_SCALE = track_error_size
T_STROKE_ERROR_ROTATION = track_error_angle
T_STROKE_ERROR_ALPHA = track_error_alpha
T_STROKE_SEED = track_random_seed
T_STROKE_ZOOM_VALUES = scale_values
T_STROKE_ROTATION_VALUES = rotation_values
T_STROKE_ALPHA_VALUES = alpha_values
T_STROKE_RANDOM_ENABLED = 1

---$embed
local common = require("common")
if common.is_last_chain() then
    T_STROKE_DRAW()
    T_STROKE_ANCHORS = nil
    T_STROKE_ANCHOR_COUNT = nil
end
