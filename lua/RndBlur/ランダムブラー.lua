--label:tim2\未分類\T_RandomBlur_Module.anm
---$track:最大ｽﾞﾚ量
---min=0
---max=5000
---step=0.1
local track_max_offset = 100

---$track:角度
---min=-3600
---max=3600
---step=0.1
local track_angle = 0

---$track:基準位置
---min=-100
---max=100
---step=0.1
local track_base_position = 0

---$track:変化固定
---min=0
---max=1000
---step=1
local track_change = 0

---$check:サイズ保持
local ck = 1

local zure = track_max_offset
local deg = track_angle
local RC = track_change
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
local LUD = T_RandomBlur_Module.PalRandBlur(userdata, work, w, h, zure, deg, RC, track_base_position * 0.01)
obj.putpixeldata(LUD)
