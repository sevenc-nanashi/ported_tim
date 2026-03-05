--label:tim2\T_RotBlur_Module.anm\渦
---$track:中心X
---min=-5000
---max=5000
---step=0.1
local rename_me_track0 = 0

---$track:中心Y
---min=-5000
---max=5000
---step=0.1
local rename_me_track1 = 0

---$track:渦量
---min=-3000
---max=3600
---step=0.1
local rename_me_track2 = 100

---$track:変化
---min=0
---max=1
---step=1
local rename_me_track3 = 0

---$value:サイズ保持/chk
local ck = 1

obj.setanchor("track", 0, "line")
local dx = rename_me_track0
local dy = rename_me_track1
local sw = rename_me_track2
local ch = rename_me_track3
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
