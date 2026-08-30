--label:${ROOT_CATEGORY}\光効果
---$track:ズレ量
---min=0
---max=100
---step=0.1
local track_offset = 2

---$track:放射ボカシ
---min=0
---max=100
---step=0.1
local track_radial_blur = 2

---$track:焦点ズレ
---min=0
---max=100
---step=0.1
local track_focus_offset = 0

---$track:オリジナル
---min=0
---max=100
---step=0.1
local track_original = 0

---$check:位置ズレ補正
local check_correct_position = 1

---$select:色配置
---RGB=0
---GRB=1
---RBG=2
local select_color_layout = 0

---$track:ピンボケ量
---min=0
---max=100
---step=0.1
local track_defocus = 0

---$check:逆順
local check_reverse_order = false

local original_object_x = obj.ox
local original_object_y = obj.oy
local original_center_x = obj.cx
local original_center_y = obj.cy
local correct_position = check_correct_position or 0

local scale_offset = track_offset * 0.01
local radial_blur_amount = track_radial_blur
local focus_center = 2 * track_focus_offset * 0.01
local original_alpha = track_original * 0.01
local color_layout = select_color_layout or 0
local defocus_amount = track_defocus or 0

local red_scale, green_scale, blue_scale
local red_blur, green_blur, blue_blur
if check_reverse_order then
    red_scale = 1 + (2 - focus_center) * scale_offset
    green_scale = 1 + (1 - focus_center) * scale_offset
    blue_scale = 1 + -focus_center * scale_offset
    red_blur = defocus_amount * math.abs(2 - focus_center) / 2
    green_blur = defocus_amount * math.abs(1 - focus_center) / 2
    blue_blur = defocus_amount * math.abs(-focus_center) / 2
else
    red_scale = 1 + -focus_center * scale_offset
    green_scale = 1 + (1 - focus_center) * scale_offset
    blue_scale = 1 + (2 - focus_center) * scale_offset
    red_blur = defocus_amount * math.abs(-focus_center) / 2
    green_blur = defocus_amount * math.abs(1 - focus_center) / 2
    blue_blur = defocus_amount * math.abs(2 - focus_center) / 2
end

if color_layout == 1 then
    red_scale, green_scale = green_scale, red_scale
    red_blur, green_blur = green_blur, red_blur
elseif color_layout == 2 then
    blue_scale, green_scale = green_scale, blue_scale
    blue_blur, green_blur = green_blur, blue_blur
end

local image_width, image_height = obj.getpixel()
obj.setoption("drawtarget", "tempbuffer", image_width, image_height)

obj.copybuffer("cache:ori_img", "object")
obj.setoption("blend", 1)

--red処理
obj.effect("グラデーション", "color", 0xff0000, "color2", 0xff0000, "blend", 3)
obj.effect("ぼかし", "範囲", red_blur, "サイズ固定", 1)
obj.effect("放射ブラー", "範囲", radial_blur_amount, "サイズ固定", 1)
obj.draw(0, 0, 0, red_scale)

--green処理
obj.copybuffer("object", "cache:ori_img")
obj.effect("グラデーション", "color", 0x00ff00, "color2", 0x00ff00, "blend", 3)
obj.setoption("blend", 1)
obj.effect("ぼかし", "範囲", green_blur, "サイズ固定", 1)
obj.effect("放射ブラー", "範囲", radial_blur_amount, "サイズ固定", 1)
obj.draw(0, 0, 0, green_scale)

--blue処理
obj.copybuffer("object", "cache:ori_img")
obj.effect("グラデーション", "color", 0x0000ff, "color2", 0x0000ff, "blend", 3)
obj.setoption("blend", 1)
obj.effect("ぼかし", "範囲", blue_blur, "サイズ固定", 1)
obj.effect("放射ブラー", "範囲", radial_blur_amount, "サイズ固定", 1)
obj.draw(0, 0, 0, blue_scale)

--オリジナル
obj.copybuffer("object", "cache:ori_img")
obj.setoption("blend", 0)
obj.draw(0, 0, 0, 1, original_alpha)

obj.load("tempbuffer")
obj.setoption("blend", 0)

if correct_position == 1 then
    obj.ox = original_object_x
    obj.oy = original_object_y
    obj.cx = original_center_x
    obj.cy = original_center_y
end
