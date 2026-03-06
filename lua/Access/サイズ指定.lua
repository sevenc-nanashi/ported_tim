--label:tim2\基本効果\サイズ修正T.anm
---$track:横
---min=0
---max=5000
---step=0.1
local width = 320

---$track:縦
---min=0
---max=5000
---step=0.1
local height = 180

---$track:基準X[%]
---min=-100
---max=100
---step=0.1
local center_x = 0

---$track:基準Y[%]
---min=-100
---max=100
---step=0.1
local center_y = 0

local ow = width * 0.5
local oh = height * 0.5
local cx = ow * center_x * 0.01
local cy = oh * center_y * 0.01

obj.setoption("drawtarget", "tempbuffer", 2 * ow + 2, 2 * oh + 2)
obj.drawpoly(-ow, -oh, 0, ow, -oh, 0, ow, oh, 0, -ow, oh, 0)
obj.load("tempbuffer")
obj.cx = cx
obj.cy = cy