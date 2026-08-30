--label:${ROOT_CATEGORY}\光効果\@カスタムフレア
---$track:形状
---min=1
---max=14
---step=1
local track_shape = 1

---$track:サイズ％
---min=0
---max=5000
---step=0.1
local track_size_percent = 30

---$track:強度
---min=0
---max=100
---step=0.1
local track_intensity = 50

---$track:ぼかし
---min=0
---max=1000
---step=0.1
local track_blur = 5

---$check:ベースカラー
local check_use_base_color = 1

---$color:色
local color = 0xccccff

---$track:位置％
---min=-5000
---max=5000
---step=0.1
local position_percent = 0

---$value:位置ズレ％
local position_offset = { 0, 0, 0 }

---$track:回転
---min=-3600
---max=3600
---step=0.1
local rotation = 0

---$check:アンカーに合わせる
local check_align_to_anchor = 0

---$track:点滅
---min=0
---max=1
---step=0.01
local blink = 0.2

--hide@color:check_use_base_color==1

obj.copybuffer("tempbuffer", "object")
obj.setoption("drawtarget", "tempbuffer")
obj.setoption("blend", T_CUSTOM_FLARE_BLEND_MODE)
if check_use_base_color == 1 then
    color = T_CUSTOM_FLARE_COLOR
end
local alpha = obj.rand(0, 100) / 100 + (1 - blink)
if alpha > 1 then
    alpha = 1
end
alpha = alpha * track_intensity * 0.01
local shape_index = track_shape
local size = track_size_percent * 0.01
local blur = track_blur
position_percent = position_percent * 0.01

-- obj.load("image", obj.getinfo("script_path") .. "CF-image\\I" .. shape_index .. ".webp")
local tim2_images = obj.module("tim2")
local data, w, h = tim2_images.custom_flare_load_image("I" .. shape_index)
obj.putpixeldata("object", data, w, h)

obj.setoption("antialias", 1)
obj.effect("グラデーション", "color", color, "color2", color, "blend", 5)
obj.effect("ぼかし", "範囲", blur)
local draw_x = T_CUSTOM_FLARE_CENTER_X
    + position_percent * T_CUSTOM_FLARE_DELTA_X
    + position_offset[1] * T_CUSTOM_FLARE_DELTA_X * 0.01
local draw_y = T_CUSTOM_FLARE_CENTER_Y
    + position_percent * T_CUSTOM_FLARE_DELTA_Y
    + position_offset[2] * T_CUSTOM_FLARE_DELTA_Y * 0.01
local draw_z = T_CUSTOM_FLARE_CENTER_Z
    + position_percent * T_CUSTOM_FLARE_DELTA_Z
    + position_offset[3] * T_CUSTOM_FLARE_DELTA_Z * 0.01
if check_align_to_anchor == 1 then
    rotation = rotation + math.deg(math.atan2(T_CUSTOM_FLARE_DELTA_Y, T_CUSTOM_FLARE_DELTA_X))
end
obj.draw(draw_x, draw_y, draw_z, size, alpha, 0, 0, rotation)
obj.load("tempbuffer")
obj.setoption("blend", 0)
