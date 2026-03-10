--label:tim2\加工
---$track:サイズ
---min=3
---max=300
---step=1
local track_size = 10

---$track:位置ズレ[%]
---min=0
---max=100
---step=0.1
local track_position_offset_percent = 50

---$track:ピッチ[%]
---min=50
---max=100
---step=0.1
local track_pitch_percent = 75

---$track:色幅
---min=0
---max=255
---step=1
local track_color_width = 32

---$check:背景に着色
local check_colorize_background = false

---$color:└背景色
local color_background = 0xffffff

---$check:└背景を元絵に
local check_use_original_background = false

---$check:3D表示
local check_enable_3d = false

---$track:└環境光[%]
---min=0
---max=100
---step=1
local track_ambient_light = 20

---$track:└拡散光[%]
---min=0
---max=100
---step=1
local track_diffuse_light = 80

---$track:└鏡面光[%]
---min=0
---max=100
---step=1
local track_specular_light = 60

---$track:└光沢度
---min=0
---max=100
---step=1
local track_shininess = 30

---$track:乱数シード
---min=0
---max=1000000
---step=1
local track_random_seed = 0

---$track:└変化間隔
---min=0
---max=1000
---step=1
local track_seed_change_interval = 0

---$value: PI
local _0 = nil

---$check:色参照位置固定
local check_lock_color_reference = false

local tim2 = obj.module("tim2")
local is_enabled = function(value)
    return value == true or value == 1
end

_0 = _0 or {}
local size = _0[1] or track_size
local position_offset_percent = _0[2] or track_position_offset_percent
local pitch_percent = _0[3] or track_pitch_percent
local color_width = _0[4] or track_color_width
local lock_color_reference = _0[0] == nil and is_enabled(check_lock_color_reference) or is_enabled(_0[0])
_0 = nil
local background_mode = (is_enabled(check_colorize_background) and 1 or 0)
    + (is_enabled(check_use_original_background) and 2 or 0)
local background_color = color_background or 0xffffff
local enable_3d = is_enabled(check_enable_3d) and 1 or 0
local ambient_light = track_ambient_light
local diffuse_light = track_diffuse_light
local specular_light = track_specular_light
local shininess = track_shininess
local random_seed = track_random_seed
local seed_change_interval = track_seed_change_interval
if seed_change_interval > 0 then
    random_seed = random_seed + math.floor(obj.time * obj.framerate / seed_change_interval)
end
local userdata, w, h = obj.getpixeldata("object", "bgra")
tim2.sketch_sketch(
    userdata,
    w,
    h,
    size,
    position_offset_percent,
    pitch_percent,
    color_width,
    background_mode,
    background_color,
    enable_3d,
    ambient_light,
    diffuse_light,
    specular_light,
    shininess,
    random_seed,
    lock_color_reference
)
obj.putpixeldata("object", userdata, w, h, "bgra")
