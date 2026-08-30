--label:${ROOT_CATEGORY}\アニメーション効果
---$track:しきい値
---min=0
---max=255
---step=1
local track_threshold = 10

---$track:ずれ
---min=-500
---max=500
---step=1
local track_offset = 10

---$track:ぼかし
---min=0
---max=500
---step=1
local track_blur = 0

---$track:ｶﾞﾗｽ強度
---min=-1000
---max=1000
---step=0.1
local track_glass_intensity = 100

---$track:ガラス画像
---min=1
---max=1000
---step=1
local glass_image_file = 1

---$check:境界を透過
local check_transparent_boundary = 0

---$color:マップ背景色
local map_background_color = 0x0

---$track:パターン
---min=0
---max=10000
---step=1
local select_pattern = 0

---$check:マップ表示
local check_show_map = false

--hide@track_offset:check_show_map==1
--hide@track_glass_intensity:check_show_map==1
--hide@check_transparent_boundary:check_show_map==1

local threshold = track_threshold
local blur_amount = track_blur
select_pattern = math.abs(select_pattern or 0)
-- require("T_CrackedGlass_Module")
local t_cracked_glass_module = obj.module("tim2")
local original_transform =
    { obj.ox, obj.oy, obj.oz, obj.rx, obj.ry, obj.rz, obj.cx, obj.cy, obj.cz, obj.zoom, obj.alpha, obj.aspect }
local image_width, image_height = obj.getpixel()
obj.effect("ぼかし", "範囲", blur_amount, "サイズ固定", 1)
obj.copybuffer("cache:CG_ORG", "object")
obj.load("layer", glass_image_file or 1, true)
local glass_width, glass_height = obj.getpixel()
local glass_scale
if image_width * glass_height < image_height * glass_width then
    glass_scale = image_height / glass_height
else
    glass_scale = image_width / glass_width
end
obj.setoption("drawtarget", "tempbuffer", image_width, image_height)
obj.draw(0, 0, 0, glass_scale)
obj.copybuffer("object", "tempbuffer")
local userdata, image_width, image_height = obj.getpixeldata("object", "bgra")
t_cracked_glass_module.cracked_glass_cracked_glass(
    userdata,
    image_width,
    image_height,
    threshold,
    select_pattern,
    check_show_map,
    map_background_color or 0
)
obj.putpixeldata("object", userdata, image_width, image_height, "bgra")
if not check_show_map then
    obj.copybuffer("tempbuffer", "object")
    obj.copybuffer("object", "cache:CG_ORG")
    local displacement_amount = track_offset
    local glass_intensity = track_glass_intensity
    obj.effect(
        "ディスプレイスメントマップ",
        "変形X",
        displacement_amount,
        "変形Y",
        displacement_amount,
        "ぼかし",
        0,
        "元のサイズに合わせる",
        1,
        "変形方法",
        "移動変形",
        "マップの種類",
        "*tempbuffer"
    )
    userdata, image_width, image_height = obj.getpixeldata("object", "bgra")
    t_cracked_glass_module.cracked_glass_add_glass(
        userdata,
        image_width,
        image_height,
        glass_intensity,
        check_transparent_boundary,
        threshold
    )
    obj.putpixeldata("object", userdata, image_width, image_height, "bgra")
end
obj.ox, obj.oy, obj.oz, obj.rx, obj.ry, obj.rz, obj.cx, obj.cy, obj.cz, obj.zoom, obj.alpha, obj.aspect =
    unpack(original_transform)
