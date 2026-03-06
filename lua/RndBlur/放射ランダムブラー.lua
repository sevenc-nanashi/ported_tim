--label:tim2\ぼかし\T_RandomBlur_Module.anm
---$track:中心X
---min=-5000
---max=5000
---step=0.1
local track_center_x = 0

---$track:中心Y
---min=-5000
---max=5000
---step=0.1
local track_center_y = 0

---$track:最大ｽﾞﾚ量
---min=0
---max=5000
---step=0.1
local track_max_offset = 200

---$track:基準
---min=-100
---max=100
---step=0.1
local track_base = 0

---$check:サイズ保持
local ck = 1

---$value:変化固定
local RC = 0

local userdata, w, h
w, h = obj.getpixel()
r = math.sqrt(w * w + h * h)
if ck == 0 then
    obj.setoption("drawtarget", "tempbuffer", r, r)
    obj.draw()
    obj.load("tempbuffer")
    obj.setoption("drawtarget", "framebuffer")
end
require("T_RandomBlur_Module")
userdata, w, h = obj.getpixeldata()
obj.setanchor("track", 0, "line")
dx = track_center_x
dy = track_center_y
work = obj.getpixeldata("work")
local LUD =
    T_RandomBlur_Module.RadRandBlur(userdata, work, w, h, track_max_offset, r / 2, dx, dy, RC, track_base * 0.01)
obj.putpixeldata(LUD)
