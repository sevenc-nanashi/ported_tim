--label:tim2\抽出
---$track:変形量
---min=0
---max=1000
---step=0.1
local track_deform_amount = 20

---$track:X周期
---min=0
---max=200
---step=0.01
local track_period_x = 2

---$track:変化速度
---min=0
---max=50
---step=0.1
local track_change_speed = 0

---$select:形状
---1=1
---2=2
---3=3
---4=4
---5=5
---6=6
local select_shape = 1

---$track:Y周期
---min=0
---max=200
---step=0.01
local track_period_y = 2

---$check:X周期と同じ
local check_link_y_period = true

---$track:乱数シード
---min=0
---max=100000
---step=1
local track_random_seed = 0

---$check:周囲を少し残す
local check_keep_border = false

local is_enabled = function(value)
    return value == true or value == 1
end

local deform_amount = track_deform_amount
local period_x = track_period_x
local period_y = is_enabled(check_link_y_period) and period_x or track_period_y
local change_speed = track_change_speed
local noise_shape = select_shape - 1
local random_seed = track_random_seed
local w, h = obj.getpixel()
obj.copybuffer("cache:ORI", "obj")

obj.setoption("drawtarget", "tempbuffer", w, h)
obj.load("四角形", 0xffffff, math.max(w, h))
obj.draw()
obj.copybuffer("obj", "tmp")
obj.effect(
    "ノイズ",
    "周期X",
    period_x,
    "周期Y",
    period_x,
    "変化速度",
    change_speed,
    "type",
    noise_shape,
    "seed",
    random_seed,
    "mode",
    1
)
obj.effect("グラデーション", "color", 0xff0000, "color2", 0xff0000, "blend", 3)
obj.draw()
obj.effect("単色化", "color", 0xffffff, "輝度を保持する", 0)
obj.effect(
    "ノイズ",
    "周期X",
    period_y,
    "周期Y",
    period_y,
    "変化速度",
    change_speed,
    "type",
    noise_shape,
    "seed",
    random_seed + 1000,
    "mode",
    1
)
obj.effect("グラデーション", "color", 0x00ff00, "color2", 0x00ff00, "blend", 3)
obj.setoption("blend", 1)
obj.draw()

if not is_enabled(check_keep_border) then
    obj.copybuffer("obj", "cache:ORI")
    obj.effect(
        "ディスプレイスメントマップ",
        "type",
        0,
        "name",
        "*tempbuffer",
        "元のサイズに合わせる",
        1,
        "param0",
        deform_amount,
        "param1",
        deform_amount
    )
    obj.effect("反転", "透明度反転", 1)
    obj.copybuffer("cache:MAP", "obj")
end

obj.copybuffer("obj", "cache:ORI")
obj.effect(
    "ディスプレイスメントマップ",
    "type",
    0,
    "name",
    "*tempbuffer",
    "元のサイズに合わせる",
    1,
    "param0",
    -deform_amount,
    "param1",
    -deform_amount
)
obj.effect("反転", "透明度反転", 1)

obj.copybuffer("tmp", "cache:ORI")
obj.setoption("blend", "alpha_sub")
obj.draw()

if not is_enabled(check_keep_border) then
    obj.copybuffer("obj", "cache:MAP")
    obj.setoption("blend", "alpha_sub")
    obj.draw()
end

obj.load("tempbuffer")
obj.setoption("blend", 0)
