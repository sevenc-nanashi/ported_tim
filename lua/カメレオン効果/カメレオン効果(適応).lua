--label:tim2\色調整\@カメレオン効果.anm
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
local check0 = false

---$check:輝度補正
local CkV = true

---$check:彩度補正
local CkS = true

---$color:逆光色
local col = nil

---$check:逆光自動調整
local BLA = false

---$track:逆光強度補正
---min=0
---max=300
---step=0.1
local BLL = 100

---$check:事前無彩色補正
local reC = false

---$track:└強度
---min=0
---max=100
---step=0.1
local reH = 30

local tim2 = obj.module("tim2")

local P = track_adapt_rate / 100
local L = track_lightness_adjust / 100
local GL = track_backlight_intensity
local GD = track_backlight_diffusion

BLL = (BLL or 100) / 100

if check0 then
    local Pr =
        { obj.ox, obj.oy, obj.oz, obj.rx, obj.ry, obj.rz, obj.cx, obj.cy, obj.cz, obj.zoom, obj.alpha, obj.aspect }
    obj.copybuffer("cache:org", "obj")
    obj.load("framebuffer")
    local userdata, w, h = obj.getpixeldata("object", "bgra")
    tim2.famili_set_color(userdata, w, h, 0, 0, 5000, 5000, false, 0, 0)
    obj.copybuffer("obj", "cache:org")
    obj.ox, obj.oy, obj.oz, obj.rx, obj.ry, obj.rz, obj.cx, obj.cy, obj.cz, obj.zoom, obj.alpha, obj.aspect = unpack(Pr)
end

if reC then
    reH = (reH or 30)
    local r, g, b = tim2.famili_get_color()
    local col = RGB(r, g, b)
    obj.effect("単色化", "強さ", reH, "color", col)
end

local userdata, w, h = obj.getpixeldata("object", "bgra")
tim2.famili_familiar(userdata, w, h, P, L, CkS, CkV)
obj.putpixeldata("object", userdata, w, h, "bgra")

if GL > 0 and GD > 0 then
    local r, g, b
    if col == nil then
        r, g, b = tim2.famili_get_color()
        if BLA then
            local mx = math.max(r, g, b)
            if mx == 0 then
                r, g, b = 0, 0, 0
            else
                r, g, b = 255 * r / mx, 255 * g / mx, 255 * b / mx
            end
        end
    else
        r, g, b = RGB(col)
    end

    r, g, b = r * BLL, g * BLL, b * BLL
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
