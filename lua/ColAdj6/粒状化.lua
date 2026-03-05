--label:tim2\T_Color_Module.anm\粒状化
--track0:量,0,100,50
--track1:ｺﾝﾄﾗｽﾄ,-400,400,100
--track2:シード,1,10000,1,1
--track3:処理法,1,3,1,1
--value@col1:色1/col,0xffffff
--value@col2: 色2/col,0x0
--check0:時間変動,0;
local N = obj.track2
if obj.check0 then
    N = obj.rand(0, 10000, -obj.time * obj.framerate, 1)
end
require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.grainy(userdata, w, h, obj.track0, obj.track1, obj.track3, N, col1, col2)
obj.putpixeldata(userdata)
