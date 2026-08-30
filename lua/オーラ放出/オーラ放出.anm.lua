--label:${ROOT_CATEGORY}\光効果
---$track:範囲
---min=1
---max=500
---step=0.1
local track_range = 50

---$track:サイクル
---min=1
---max=20
---step=1
local track_cycle = 2

---$track:速度
---min=-1000
---max=1000
---step=0.1
local track_speed = 100

---$track:オフセット
---min=0
---max=1000
---step=0.1
local track_offset = 0

---$check:ミッドトーン無視
local check_ignore_midtone = 0

---$color:ハイライト
local highlight_color = 0xffffff

---$color:ミッドトーン
local midtone_color = 0x0080ff

---$color:シャドウ
local shadow_color = 0x0080ff

---$track:ぼかし
---min=0
---max=1000
---step=1
local track_blur = 1

---$check:オリジナル表示
local check_show_original = true

--hide@midtone_color:check_ignore_midtone==1

local original_origin_x, original_origin_y, original_origin_z = obj.ox, obj.oy, obj.oz
local original_center_x, original_center_y, original_center_z = obj.cx, obj.cy, obj.cz
obj.copybuffer("cache:ori", "object")

local aura_range = track_range

local cycle_count = math.floor(track_cycle)
local phase_offset = ((obj.time * track_speed + track_offset) % 100) * 0.01

local highlight_red, highlight_green, highlight_blue = RGB(highlight_color)
local shadow_red, shadow_green, shadow_blue = RGB(shadow_color)
local midtone_red, midtone_green, midtone_blue
if check_ignore_midtone == 0 then
    midtone_red, midtone_green, midtone_blue = RGB(midtone_color)
else
    midtone_red, midtone_green, midtone_blue =
        math.floor((highlight_red + shadow_red) * 0.5),
        math.floor((highlight_green + shadow_green) * 0.5),
        math.floor((highlight_blue + shadow_blue) * 0.5)
end

obj.effect("単色化", "color", 0xffffff, "輝度を保持する", 0)
obj.effect("縁取り", "サイズ", aura_range * 0.5, "ぼかし", 0, "color", 0xffffff)
obj.effect("縁取り", "サイズ", aura_range * 0.5, "ぼかし", 0, "color", 0x0)
obj.effect("ぼかし", "範囲", aura_range)

--[[pixelshader@colorama
---$include "../色調調整セットver6/shaders/colorama.hlsl"
]]

obj.pixelshader("colorama", "object", "object", {
    phase_offset,
    cycle_count,
    2,
    255,
    255,
    255,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
    0,
})

local width, height = obj.w, obj.h

obj.copybuffer("cache:wave", "object")

obj.load("figure", "四角形", 0x0, (width < height and height or width))
obj.setoption("drawtarget", "tempbuffer", width, height)
obj.draw()
obj.copybuffer("object", "cache:wave")
obj.draw()
obj.copybuffer("object", "tempbuffer")

obj.effect(
    "チャンネルシフト@T_Color_Module@tim.anm2",
    "アルファ",
    "赤",
    "赤",
    "赤",
    "緑",
    "赤",
    "青",
    "赤"
)

-- local userdata, w, h = obj.getpixeldata("object", "bgra")
-- T_Color_Module.color_tritone_v2(userdata, w, h, r1, g1, b1, r2, g2, b2, r3, g3, b3, 255, 128, 0)
-- obj.putpixeldata("object", userdata, w, h, "bgra")
obj.effect("ぼかし", "範囲", track_blur)
obj.effect(
    "トライトーン@T_Color_Module@tim.anm2",
    "シャドウ",
    RGB(shadow_red, shadow_green, shadow_blue),
    "ミッドトーン",
    RGB(midtone_red, midtone_green, midtone_blue),
    "ハイライト",
    RGB(highlight_red, highlight_green, highlight_blue),
    "飽和点1",
    255,
    "中心点",
    128,
    "飽和点2",
    0
)

if check_show_original then
    obj.copybuffer("tempbuffer", "object")
    obj.copybuffer("object", "cache:ori")
    obj.draw()
    obj.copybuffer("object", "tempbuffer")
end
obj.setoption("draw_state", false)
obj.ox, obj.oy, obj.oz = original_origin_x, original_origin_y, original_origin_z
obj.cx, obj.cy, obj.cz = original_center_x, original_center_y, original_center_z
