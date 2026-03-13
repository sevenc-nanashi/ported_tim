--label:tim2\装飾\@ストロークT
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
local zoomt = { 100, 100, 100 }

---$value:角度変動
local rott = { 0, 0, 0 }

---$value:透明度変動[%]
local alpt = { 0, 0, 0 }

T_strokeTM_GosaX = track_error_x
T_strokeTM_GosaY = track_error_y
T_strokeTM_GosaS = track_error_size
T_strokeTM_GosaR = track_error_angle
T_strokeTM_GosaA = track_error_alpha
T_strokeTM_seed = track_random_seed
T_strokeTM_zoomt = zoomt
T_strokeTM_rott = rott
T_strokeTM_alpt = alpt
T_strokeTM_rnd = 1

if obj.getoption("script_name", 1, true):sub(-4, -1) ~= obj.getoption("script_name"):sub(-4, -1) then
    T_stroke_f()
    T_strokeTM_ancB = nil
    T_strokeTM_N = nil
end
