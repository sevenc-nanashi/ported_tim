--label:tim2\T_RandomBlur_Module.anm\回転ランダムブラー
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

---$track:最大ｽﾞﾚ量
---min=0
---max=500
---step=0.1
local rename_me_track2 = 20

---$track:基準
---min=-100
---max=100
---step=0.1
local rename_me_track3 = 0

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
dx = rename_me_track0
dy = rename_me_track1
work = obj.getpixeldata("work")
local LUD =
    T_RandomBlur_Module.RotRandBlur(userdata, work, w, h, rename_me_track2, r / 2, dx, dy, RC, rename_me_track3 * 0.01)
obj.putpixeldata(LUD)
