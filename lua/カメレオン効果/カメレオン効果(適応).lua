--label:${ROOT_CATEGORY}\色調整\@カメレオン効果
---$track:適応率
---min=0
---max=100
---step=0.1
local track_adapt_rate = 70

---$track:明度補正
---min=0
---max=300
---step=0.1
local track_lightness_adjust = 100

---$track:逆光強度
---min=0
---max=300
---step=0.1
local track_backlight_intensity = 0

---$track:逆光拡散
---min=0
---max=500
---step=0.1
local track_backlight_diffusion = 15

---$check:フレームバッファを背景
local check_use_framebuffer_as_background = false

---$check:輝度補正
local check_adjust_luminance = true

---$check:彩度補正
local check_adjust_saturation = true

---$color:逆光色
local color_backlight = nil

---$check:逆光自動調整
local check_auto_adjust_backlight = false

---$track:逆光強度補正
---min=0
---max=300
---step=0.1
local track_backlight_strength_correction = 100

--group:事前無彩色補正
---$check:事前無彩色補正::有効化
local check_enable_pre_desaturation = false

---$track:強度
---min=0
---max=100
---step=0.1
local track_pre_desaturation_strength = 30

--hide@track_pre_desaturation_strength:check_enable_pre_desaturation==0

local tim_module = obj.module("tim2")

local adapt_rate_ratio = track_adapt_rate / 100
local lightness_ratio = track_lightness_adjust / 100
local backlight_intensity = track_backlight_intensity
local backlight_diffusion = track_backlight_diffusion

track_backlight_strength_correction = (track_backlight_strength_correction or 100) / 100

if check_use_framebuffer_as_background then
    local object_transform =
        { obj.ox, obj.oy, obj.oz, obj.rx, obj.ry, obj.rz, obj.cx, obj.cy, obj.cz, obj.zoom, obj.alpha, obj.aspect }
    obj.copybuffer("cache:org", "object")
    obj.load("framebuffer")
    local userdata, w, h = obj.getpixeldata("object", "bgra")
    tim_module.famili_set_color(userdata, w, h, 0, 0, 5000, 5000, false, 0, 0)
    obj.copybuffer("object", "cache:org")
    obj.ox, obj.oy, obj.oz, obj.rx, obj.ry, obj.rz, obj.cx, obj.cy, obj.cz, obj.zoom, obj.alpha, obj.aspect =
        unpack(object_transform)
end

if check_enable_pre_desaturation then
    track_pre_desaturation_strength = (track_pre_desaturation_strength or 30)
    local r, g, b = tim_module.famili_get_color()
    local color_backlight = RGB(r, g, b)
    obj.effect("単色化", "強さ", track_pre_desaturation_strength, "color", color_backlight)
end

local userdata, w, h = obj.getpixeldata("object", "bgra")
tim_module.famili_familiar(
    userdata,
    w,
    h,
    adapt_rate_ratio,
    lightness_ratio,
    check_adjust_saturation,
    check_adjust_luminance
)
obj.putpixeldata("object", userdata, w, h, "bgra")

if backlight_intensity > 0 and backlight_diffusion > 0 then
    local r, g, b
    if color_backlight == nil then
        r, g, b = tim_module.famili_get_color()
        if check_auto_adjust_backlight then
            local max_color_channel = math.max(r, g, b)
            if max_color_channel == 0 then
                r, g, b = 0, 0, 0
            else
                r, g, b = 255 * r / max_color_channel, 255 * g / max_color_channel, 255 * b / max_color_channel
            end
        end
    else
        r, g, b = RGB(color_backlight)
    end

    r, g, b =
        r * track_backlight_strength_correction,
        g * track_backlight_strength_correction,
        b * track_backlight_strength_correction
    r = math.max(math.min(r, 255), 0)
    g = math.max(math.min(g, 255), 0)
    b = math.max(math.min(b, 255), 0)

    obj.effect(
        "ライト",
        "強さ",
        track_backlight_intensity,
        "拡散",
        track_backlight_diffusion,
        "逆光",
        1,
        "color",
        RGB(r, g, b)
    )
end
