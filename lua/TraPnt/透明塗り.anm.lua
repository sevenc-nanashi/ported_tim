--label:tim2\アニメーション効果
-- ---$track:指定位置X
-- ---min=-10000
-- ---max=10000
-- ---step=1
-- local track_target_position_x = 0
--
-- ---$track:指定位置Y
-- ---min=-10000
-- ---max=10000
-- ---step=1
-- local track_target_position_y = 0
--track0:指定位置X,-10000,10000,0,1
--track1:指定位置Y,-10000,10000,0,1
local track_target_position_x = obj.track0
local track_target_position_y = obj.track1

---$track:α調整
---min=1
---max=255
---step=1
local track_alpha = 255

---$track:透明度
---min=0
---max=100
---step=0.1
local track_opacity = 0

---$color:塗り潰し色
local col = 0xffcccc

---$check:改良計算
local check0 = true

local T_Alpha_Module = obj.module("tim2")

obj.setanchor("track", 0)
local r, g, b = RGB(col)
local userdata, w, h = obj.getpixeldata("object", "bgra")
T_Alpha_Module.alpha_fill_color(
    userdata,
    w,
    h,
    r,
    g,
    b,
    track_target_position_x,
    track_target_position_y,
    track_alpha,
    check0,
    1 - track_opacity * 0.01
)
obj.putpixeldata("object", userdata, w, h, "bgra")
