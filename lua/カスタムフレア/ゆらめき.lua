--label:${ROOT_CATEGORY}\光効果\@カスタムフレア
---$track:サイズ
---min=10
---max=1000
---step=0.1
local track_size = 250

---$track:光芒量
---min=0
---max=100
---step=0.1
local track_ray_amount = 55

---$track:強度
---min=0
---max=200
---step=0.1
local track_intensity = 60

---$track:回転
---min=-3600
---max=3600
---step=0.1
local track_rotation = 0

---$check:ベースカラー
local check_use_base_color = 1

---$color:光芒色
local ray_color = 0x9999ff

---$track:位置％
---min=-5000
---max=5000
---step=0.1
local position_percent = -100

---$value:位置オフセット％
local position_offset = { 0, 0, 0 }

---$track:先端ぼかし％
---min=0
---max=100
---step=0.1
local tip_blur_percent = 100

---$track:光芒変化速度
---min=0
---max=5
---step=0.01
local speed = 0.2

---$select:形状
---1=1
---2=2
---3=3
---4=4
---5=5
---6=6
---7=7
---8=8
local shape_index = 5

---$value:クリップ位置幅ボカシ
local clip_settings = { 0, 0, 0 }

---$check:クリップ向き
local check_reverse_clip = 0

---$track:点滅
---min=0
---max=1
---step=0.01
local blink = 0.1

--hide@ray_color:check_use_base_color==1

obj.copybuffer("tempbuffer", "object")
obj.setoption("drawtarget", "tempbuffer")
obj.setoption("blend", T_CUSTOM_FLARE_BLEND_MODE)
if check_use_base_color == 1 then
    ray_color = T_CUSTOM_FLARE_COLOR
end
local alpha = obj.rand(0, 100) / 100 + (1 - blink)
if alpha > 1 then
    alpha = 1
end
local w = track_size
local ray_count = track_ray_amount
local intensity = track_intensity * 0.01
shape_index = math.floor(shape_index)
if shape_index > 8 then
    shape_index = 8
end
if shape_index < 1 then
    shape_index = 1
end
local draw_x = (position_percent + position_offset[1]) * 0.01 * T_CUSTOM_FLARE_DELTA_X + T_CUSTOM_FLARE_CENTER_X
local draw_y = (position_percent + position_offset[2]) * 0.01 * T_CUSTOM_FLARE_DELTA_Y + T_CUSTOM_FLARE_CENTER_Y
local draw_z = (position_percent + position_offset[3]) * 0.01 * T_CUSTOM_FLARE_DELTA_Z + T_CUSTOM_FLARE_CENTER_Z
local r = 2 * w
obj.load("figure", "四角形", ray_color, r)
if shape_index <= 4 then
    obj.effect(
        "ノイズ",
        "type",
        shape_index,
        "周期X",
        1,
        "周期Y",
        0,
        "しきい値",
        100 - ray_count,
        "速度Y",
        -speed
    )
else
    shape_index = shape_index - 4
    obj.effect(
        "ノイズ",
        "type",
        shape_index,
        "周期X",
        ray_count * 0.05,
        "周期Y",
        0,
        "しきい値",
        0,
        "速度Y",
        -speed
    )
end
obj.effect("境界ぼかし", "範囲", r * tip_blur_percent * 0.01, "縦横比", -100)
clip_settings[1] = -r * (clip_settings[1] / 360 % 1)
clip_settings[2] = r * (clip_settings[2] / 360 % 1)
if check_reverse_clip == 1 then
    clip_settings[1] = -r * (math.atan2(T_CUSTOM_FLARE_DELTA_Y, T_CUSTOM_FLARE_DELTA_X) * 0.5 + math.pi / 4) / math.pi
end
if clip_settings[2] > 0 then
    obj.effect(
        "斜めクリッピング",
        "角度",
        90,
        "中心X",
        clip_settings[1] - r,
        "幅",
        -clip_settings[2],
        "ぼかし",
        clip_settings[3]
    )
    obj.effect(
        "斜めクリッピング",
        "角度",
        90,
        "中心X",
        clip_settings[1],
        "幅",
        -clip_settings[2],
        "ぼかし",
        clip_settings[3]
    )
    obj.effect(
        "斜めクリッピング",
        "角度",
        90,
        "中心X",
        clip_settings[1] + r,
        "幅",
        -clip_settings[2],
        "ぼかし",
        clip_settings[3]
    )
end
r = r / 2.5
obj.effect("クリッピング", "上", r)
obj.effect("極座標変換", "回転", track_rotation)
local x0 = -r + draw_x
local y0 = -r + draw_y
local x1 = r + draw_x
local y1 = -r + draw_y
local x2 = r + draw_x
local y2 = r + draw_y
local x3 = -r + draw_x
local y3 = r + draw_y
alpha = alpha * intensity
if alpha <= 1 then
    obj.drawpoly(
        x0,
        y0,
        draw_z,
        x1,
        y1,
        draw_z,
        x2,
        y2,
        draw_z,
        x3,
        y3,
        draw_z,
        0,
        0,
        obj.w,
        0,
        obj.w,
        obj.h,
        0,
        obj.h,
        alpha
    )
else
    obj.drawpoly(
        x0,
        y0,
        draw_z,
        x1,
        y1,
        draw_z,
        x2,
        y2,
        draw_z,
        x3,
        y3,
        draw_z,
        0,
        0,
        obj.w,
        0,
        obj.w,
        obj.h,
        0,
        obj.h,
        1
    )
    obj.drawpoly(
        x0,
        y0,
        draw_z,
        x1,
        y1,
        draw_z,
        x2,
        y2,
        draw_z,
        x3,
        y3,
        draw_z,
        0,
        0,
        obj.w,
        0,
        obj.w,
        obj.h,
        0,
        obj.h,
        alpha - 1
    )
end
obj.load("tempbuffer")
obj.setoption("blend", 0)
