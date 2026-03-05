--label:tim2\T_RandomBlur_Module.anm
---$track:最大ｽﾞﾚ量
---min=0
---max=5000
---step=0.1
local rename_me_track0 = 100

---$track:角度
---min=-3600
---max=3600
---step=0.1
local rename_me_track1 = 0

---$track:基準位置
---min=-100
---max=100
---step=0.1
local rename_me_track2 = 0

---$track:変化固定
---min=0
---max=1000
---step=1
local rename_me_track3 = 0

---$check:サイズ保持
local ck = 1

local zure = rename_me_track0
local deg = rename_me_track1
local RC = rename_me_track3
local userdata, w, h
w, h = obj.getpixel()
if ck == 0 then
    obj.setoption(
        "drawtarget",
        "tempbuffer",
        w + math.abs(2 * zure * math.cos(math.pi * deg / 180)),
        h + math.abs(2 * zure * math.sin(math.pi * deg / 180))
    )
    obj.draw()
    obj.load("tempbuffer")
    obj.setoption("drawtarget", "framebuffer")
end
require("T_RandomBlur_Module")
userdata, w, h = obj.getpixeldata()
work = obj.getpixeldata("work")
local LUD = T_RandomBlur_Module.PalRandBlur(userdata, work, w, h, zure, deg, RC, rename_me_track2 * 0.01)
obj.putpixeldata(LUD)
