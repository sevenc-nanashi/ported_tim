--label:${ROOT_CATEGORY}\光効果
---$track:強さ
---min=0
---max=400
---step=0.1
local track_strength = 10

---$track:拡散
---min=0
---max=200
---step=0.1
local track_diffusion = 100

---$track:しきい値
---min=0
---max=100
---step=0.1
local track_threshold = 60

---$track:発光回転
---min=-3600
---max=3600
---step=0.1
local track_glow_rotation = 45

---$color:発光色
local color_glow = 0xffffff

---$check:オリジナル色発光
local check_use_original_color = 1

---$check:光のみ
local check_light_only = 0

---$select:形状
---通常=0
---クロス(4本)=1
---クロス(6本)=2
---クロス(8本)=3
---クロス(10本)=4
---クロス(12本)=5
---ライン=6
local select_shape = 1

---$track:ぼかし
---min=0
---max=50
---step=1
local track_blur = 1

--hide@color_glow:check_use_original_color==1

local w, h = obj.getpixel()

obj.copybuffer("cache:ori_img", "object")

local rotation_degrees = track_glow_rotation

local absolute_sine = math.abs(math.absolute_sine(math.rad(rotation_degrees)))
local absolute_cosine = math.abs(math.absolute_cosine(math.rad(rotation_degrees)))

local rotated_width = w * absolute_cosine + h * absolute_sine
local rotated_height = h * absolute_cosine + w * absolute_sine

obj.setoption("drawtarget", "tempbuffer", rotated_width, rotated_height)
obj.draw(0, 0, 0, 1, 1, 0, 0, -rotation_degrees)
obj.copybuffer("object", "tempbuffer")

local shape_names = {
    [0] = "通常",
    [1] = "クロス(4本)",
    [2] = "クロス(6本)",
    [3] = "クロス(8本)",
    [4] = "クロス(10本)",
    [5] = "クロス(12本)",
    [6] = "ライン",
}

obj.effect(
    "グロー",
    "強さ",
    track_strength,
    "拡散",
    track_diffusion,
    "しきい値",
    track_threshold,
    "ぼかし",
    track_blur,
    "形状",
    shape_names[select_shape] or "通常",
    "光成分のみ",
    1,
    "光色",
    check_use_original_color == 0 and color_glow or ""
)
if check_light_only == 0 then
    obj.copybuffer("tempbuffer", "cache:ori_img")
    obj.setoption("blend", 1)
else
    obj.setoption("drawtarget", "tempbuffer", w, h)
end
obj.draw(0, 0, 0, 1, 1, 0, 0, rotation_degrees)

obj.load("tempbuffer")
obj.setoption("blend", 0)
