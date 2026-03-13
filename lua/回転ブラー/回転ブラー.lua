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
local track_blur_amount = 30

---$track:基準位置
---min=-100
---max=100
---step=0.1
local track_base_position = 0

---$check:サイズ保持
local check_keep_size = true

---$track:角度解像度ダウン
---min=0
---max=8
---step=1
local track_angle_resolution_down = 0

---$check:高精度表示
local check_high_quality_preview = true

---$check:高精度出力
local check_high_quality_export = true

local is_enabled = function(value)
    return value == true or value == 1
end

local userdata, w, h
w, h = obj.getpixel()
local r = math.sqrt(w * w + h * h)
if not is_enabled(check_keep_size) then
    local addX, addY = math.ceil((r - w) / 2 + 1), math.ceil((r - h) / 2 + 1)
    obj.effect("領域拡張", "上", addY, "下", addY, "右", addX, "左", addX)
end

local tim2 = obj.module("tim2")
userdata, w, h = obj.getpixeldata("object", "bgra")
obj.setanchor("track", 0, "line")
local center_x = track_center_x
local center_y = track_center_y
local use_high_quality = (not obj.getinfo("saving") and is_enabled(check_high_quality_preview))
    or (obj.getinfo("saving") and is_enabled(check_high_quality_export))
local blur_fn = use_high_quality and tim2.rotblur_rot_blur_s or tim2.rotblur_rot_blur_l
blur_fn(userdata, w, h, track_blur_amount, center_x, center_y, track_base_position * 0.01, track_angle_resolution_down)
obj.putpixeldata("object", userdata, w, h, "bgra")
