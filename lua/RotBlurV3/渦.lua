--label:tim2\T_RotBlur_Module.anm
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

---$track:渦量
---min=-3000
---max=3600
---step=0.1
local track_swirl_amount = 100

---$track:変化
---min=0
---max=1
---step=1
local track_change = 0

---$check:サイズ保持
local ck = 1

obj.setanchor("track", 0, "line")
local dx = track_center_x
local dy = track_center_y
local sw = track_swirl_amount
local ch = track_change
local userdata, w, h
w, h = obj.getpixel()
local r = math.sqrt(w * w + h * h)
if ck == 0 then
    local addX, addY = math.ceil((r - w) / 2 + 1), math.ceil((r - h) / 2 + 1)
    obj.effect("領域拡張", "上", addY, "下", addY, "右", addX, "左", addX)
end
require("T_RotBlur_Module")
userdata, w, h = obj.getpixeldata()
local work = obj.getpixeldata("work")
local LUD = T_RotBlur_Module.Whirlpool(userdata, work, w, h, sw, r / 2, dx, dy, ch)
obj.putpixeldata(LUD)
