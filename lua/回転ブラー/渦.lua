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

---$track:渦量
---min=-3000
---max=3600
---step=0.1
local track_swirl_amount = 100

---$select:変化
---二乗減衰=0
---指数減衰=1
local select_change_mode = 0

---$check:サイズ保持
local check_keep_size = true

local is_enabled = function(value)
    return value == true or value == 1
end

obj.setanchor("track", 0, "line")
local center_x = track_center_x
local center_y = track_center_y
local swirl_amount = track_swirl_amount
local change_mode = select_change_mode
local userdata, w, h
w, h = obj.getpixel()
local r = math.sqrt(w * w + h * h)
if not is_enabled(check_keep_size) then
    local addX, addY = math.ceil((r - w) / 2 + 1), math.ceil((r - h) / 2 + 1)
    obj.effect("領域拡張", "上", addY, "下", addY, "右", addX, "左", addX)
end

local tim2 = obj.module("tim2")
userdata, w, h = obj.getpixeldata("object", "bgra")
obj.clearbuffer("cache:work", w, h)
local work = obj.getpixeldata("cache:work", "bgra")
tim2.rotblur_whirlpool(userdata, work, w, h, swirl_amount, r / 2, center_x, center_y, change_mode)
obj.putpixeldata("object", work, w, h, "bgra")
