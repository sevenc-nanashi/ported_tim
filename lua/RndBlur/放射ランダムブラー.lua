--label:tim2\ぼかし\@T_RandomBlur_Module.anm
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

---$track:最大ズレ量
---min=0
---max=5000
---step=0.1
local track_max_offset = 200

---$track:基準位置
---min=-100
---max=100
---step=0.1
local track_base_position = 0

---$check:サイズ保持
local check_keep_size = true

---$track:変化固定
---min=0
---max=1000
---step=1
local track_change_seed = 0

local userdata, w, h
w, h = obj.getpixel()
local radius = math.sqrt(w * w + h * h)
if not check_keep_size then
    obj.setoption("drawtarget", "tempbuffer", radius, radius)
    obj.draw()
    obj.load("tempbuffer")
    obj.setoption("drawtarget", "framebuffer")
end
local tim2 = obj.module("tim2")
userdata, w, h = obj.getpixeldata("object", "bgra")
obj.setanchor("track", 0, "line")
local center_x = obj.track0
local center_y = obj.track1
tim2.rndblur_rad_rand_blur(
    userdata,
    w,
    h,
    track_max_offset,
    radius / 2,
    center_x,
    center_y,
    track_change_seed,
    track_base_position * 0.01
)
obj.putpixeldata("object", userdata, w, h, "bgra")
