--label:tim2
--track0:中心Y,-5000,5000,0
--track1:角度,-360,360,0
--track2:ぼかし,0,1000,100
--check0:左右反転,1;

local chk
if obj.check0 then
    chk = 1
else
    chk = 0
end
obj.setoption("drawtarget", "tempbuffer", obj.getpixel())
obj.draw()
obj.effect("斜めクリッピング", "中心Y", obj.track0, "角度", obj.track1, "ぼかし", obj.track2)
obj.effect("反転", "上下反転", 1, "左右反転", chk)
obj.draw()
obj.load("tempbuffer")
