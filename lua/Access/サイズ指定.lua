--label:tim2\サイズ修正T.anm\サイズ指定
--track0:横,0,5000,320
--track1:縦,0,5000,180
--track2:基準X[%],-100,100,0
--track3:基準Y[%],-100,100,0

local ow = obj.track0 * 0.5
local oh = obj.track1 * 0.5
local cx = ow * obj.track2 * 0.01
local cy = oh * obj.track3 * 0.01

obj.setoption("drawtarget", "tempbuffer", 2 * ow + 2, 2 * oh + 2)
obj.drawpoly(-ow, -oh, 0, ow, -oh, 0, ow, oh, 0, -ow, oh, 0)
obj.load("tempbuffer")
obj.cx = cx
obj.cy = cy
