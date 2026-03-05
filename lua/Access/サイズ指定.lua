--label:tim2\サイズ修正T.anm
---$track:横
---min=0
---max=5000
---step=0.1
local rename_me_track0 = 320

---$track:縦
---min=0
---max=5000
---step=0.1
local rename_me_track1 = 180

---$track:基準X[%]
---min=-100
---max=100
---step=0.1
local rename_me_track2 = 0

---$track:基準Y[%]
---min=-100
---max=100
---step=0.1
local rename_me_track3 = 0

local ow = rename_me_track0 * 0.5
local oh = rename_me_track1 * 0.5
local cx = ow * rename_me_track2 * 0.01
local cy = oh * rename_me_track3 * 0.01

obj.setoption("drawtarget", "tempbuffer", 2 * ow + 2, 2 * oh + 2)
obj.drawpoly(-ow, -oh, 0, ow, -oh, 0, ow, oh, 0, -ow, oh, 0)
obj.load("tempbuffer")
obj.cx = cx
obj.cy = cy
