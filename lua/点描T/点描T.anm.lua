--label:${ROOT_CATEGORY}\加工
---$track:サイズ
---min=3
---max=300
---step=1
local track_point_size = 10

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

--group:背景に着色
---$check:背景に着色::背景に着色
local check_colorize_background = false

---$check:背景を元絵に
local check_use_original_background = false

---$color:背景色
local color_background = 0xffffff

--group:3D
---$check:3D表示
local check_enable_3d = false

---$track:環境光[%]
---min=0
---max=100
---step=1
local track_ambient_light = 20

---$track:拡散光[%]
---min=0
---max=100
---step=1
local track_diffuse_light = 80

---$track:鏡面光[%]
---min=0
---max=100
---step=1
local track_specular_light = 60

---$track:光沢度
---min=0
---max=100
---step=1
local track_shininess = 30
--group:乱数
---$track:シード
---min=0
---max=1000000
---step=1
local track_random_seed = 0

---$track:変化間隔
---min=0
---max=1000
---step=1
local track_seed_change_interval = 0
--group:

--hide@color_background:check_colorize_background==0
--hide@color_background:check_use_original_background==1
--hide@check_use_original_background:check_colorize_background==0
--hide@track_ambient_light:check_enable_3d==0
--hide@track_diffuse_light:check_enable_3d==0
--hide@track_specular_light:check_enable_3d==0
--hide@track_shininess:check_enable_3d==0

---$value: PI
local point_cache = nil

---$check:色参照位置固定
local check_lock_color_reference = false

local tim_module = obj.module("tim2")
local is_enabled = function(value)
    return value == true or value == 1
end

point_cache = point_cache or {}
local point_size = point_cache[1] or track_point_size
local position_offset_percent = point_cache[2] or track_position_offset_percent
local pitch_percent = point_cache[3] or track_pitch_percent
local color_width = point_cache[4] or track_color_width
local lock_color_reference = point_cache[0] == nil and is_enabled(check_lock_color_reference)
    or is_enabled(point_cache[0])
point_cache = nil
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
tim_module.sketch_sketch(
    userdata,
    w,
    h,
    point_size,
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
