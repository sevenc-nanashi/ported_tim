--label:${ROOT_CATEGORY}\カスタムオブジェクト\@集中線T
---$track:発生量
---min=0
---max=100
---step=0.1
local track_spawn_amount = 35

---$track:中心
---min=0
---max=100
---step=0.1
local track_center = 60

---$track:分布
---min=0
---max=100
---step=0.01
local track_distribution = 50

---$track:放射周期
---min=0
---max=100
---step=0.1
local track_period = 0

---$color:色
local color = 0xffffff

---$track:明るさ
---min=0
---max=1000
---step=1
local track_brightness = 500

---$track:放射速度
---min=-1000
---max=1000
---step=0.1
local track_radial_speed = 0

---$track:変化速度
---min=-100
---max=100
---step=0.1
local track_change_speed = 0

---$track:回転速度
---min=-1000
---max=1000
---step=0.1
local track_rotation_speed = 0

---$track:渦巻
---min=-1000
---max=1000
---step=0.1
local track_swirl = 0

---$select:タイプ
---Type1=1
---Type2=2
---Type3=3
---Type4=4
---Type5=5
---Type6=6
local select_noise_type = 1

---$track:シード
---min=0
---max=1000000
---step=1
local track_seed = 0

---$track:幅
---min=0
---max=10000
---step=1
local track_width = 0

---$track:高さ
---min=0
---max=10000
---step=1
local track_height = 0

local noise_threshold = 100 - track_spawn_amount
local clipping_center_y = track_center
local noise_period_x = track_distribution
local noise_period_y = track_period
local screen_w = track_width > 0 and track_width or obj.screen_w
local screen_h = track_height > 0 and track_height or obj.screen_h
local glow_strength = track_brightness
local radial_speed = track_radial_speed
local noise_change_speed = track_change_speed
local rotation_speed = track_rotation_speed
local swirl = track_swirl
local noise_type = math.floor(select_noise_type or 1)
local seed = math.floor(track_seed or 0)

noise_period_x = noise_period_x * noise_period_x * 0.01
noise_period_y = noise_period_y / 25
local size = (screen_w < screen_h) and screen_h or screen_w
clipping_center_y = 0.01 * (clipping_center_y - 50) * size
obj.load("figure", "四角形", 0xffffff, size)
obj.effect(
    "ノイズ",
    "変化速度",
    noise_change_speed,
    "周期X",
    noise_period_x,
    "周期Y",
    noise_period_y,
    "速度Y",
    -radial_speed,
    "しきい値",
    noise_threshold,
    "seed",
    seed + 3000,
    "type",
    noise_type
)
obj.effect("斜めクリッピング", "角度", 180, "ぼかし", size, "中心Y", clipping_center_y)
obj.effect("極座標変換", "渦巻", swirl * 0.1, "回転", rotation_speed * obj.time)
obj.setoption("drawtarget", "tempbuffer", screen_w, screen_h)
obj.draw(0, 0, 0, 1.2)
obj.load("tempbuffer")
obj.effect("グロー", "強さ", glow_strength, "拡散", 1, "しきい値", 0, "ぼかし", 1)
obj.effect("単色化", "color", color, "輝度を保持する", 0)
