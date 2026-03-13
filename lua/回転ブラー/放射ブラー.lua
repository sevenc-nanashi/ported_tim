--label:tim2\ぼかし\@T_RotBlur_Module.anm
-- ---$track:中心X
-- ---min=-5000
-- ---max=5000
-- ---step=0.1
-- local track_center_x = 0
--
-- ---$track:中心Y
-- ---min=-5000
-- ---max=5000
-- ---step=0.1
-- local track_center_y = 0
--track0:中心X,-5000,5000,0
--track1:中心Y,-5000,5000,0
local track_center_x = obj.track0
local track_center_y = obj.track1

---$track:ブラー量
---min=0
---max=1000
---step=0.1
local track_blur_amount = 20

---$track:基準位置
---min=-100
---max=100
---step=0.1
local track_base_position = 0

---$check:サイズ保持
local check_keep_size = true

---$track:表示限界倍率
---min=1
---max=10
---step=0.1
local track_display_limit_scale = 3

local is_enabled = function(value)
    return value == true or value == 1
end

obj.setanchor("track", 0, "line")
local center_x = track_center_x
local center_y = track_center_y
local blur_amount = track_blur_amount
local base_position = 0.01 * track_base_position
blur_amount = math.min(blur_amount, 200 / (1 + base_position) - 0.1)
local userdata, w, h
local expand_right, expand_left, expand_bottom, expand_top = 0, 0, 0, 0
if not is_enabled(check_keep_size) then
    local w0, h0 = obj.getpixel()
    local w2, h2 = w0 / 2, h0 / 2
    local display_limit_scale = math.max(0, (track_display_limit_scale - 1) / 2)
    local iw, ih = w0 * display_limit_scale, h0 * display_limit_scale
    local inner_scale = 1 / (1 - blur_amount * (1 + base_position) / 200)
    local outer_scale = 1 / (1 + blur_amount * (1 - base_position) / 200)
    expand_right = ((w2 > center_x and inner_scale or outer_scale) - 1) * (w2 - center_x)
    expand_left = ((-w2 < center_x and inner_scale or outer_scale) - 1) * (w2 + center_x)
    expand_bottom = ((h2 > center_y and inner_scale or outer_scale) - 1) * (h2 - center_y)
    expand_top = ((-h2 < center_y and inner_scale or outer_scale) - 1) * (h2 + center_y)
    expand_right = (expand_right > iw) and iw or expand_right
    expand_left = (expand_left > iw) and iw or expand_left
    expand_bottom = (expand_bottom > ih) and ih or expand_bottom
    expand_top = (expand_top > ih) and ih or expand_top
    expand_right, expand_bottom = math.ceil(math.max(expand_right, 1)), math.ceil(math.max(expand_bottom, 1))
    expand_left, expand_top = math.ceil(math.max(expand_left, 1)), math.ceil(math.max(expand_top, 1))
    obj.effect("領域拡張", "上", expand_top, "下", expand_bottom, "右", expand_right, "左", expand_left)
end

local tim2 = obj.module("tim2")
userdata, w, h = obj.getpixeldata("object", "bgra")
tim2.rotblur_rad_blur(
    userdata,
    w,
    h,
    blur_amount,
    center_x + (expand_left - expand_right) / 2,
    center_y + (expand_top - expand_bottom) / 2,
    base_position
)
obj.putpixeldata("object", userdata, w, h, "bgra")
