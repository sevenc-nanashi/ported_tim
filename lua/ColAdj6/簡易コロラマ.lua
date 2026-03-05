--label:tim2\T_Color_Module.anm\簡易コロラマ
--track0:Fシフト,0,5000,0
--track1:ｻｲｸﾙ数,0,20,1,0.01
--track2:最大色数,1,6,6,1
--value@col1:色1/col,0xffffff
--value@col2:色2/col,0xffff00
--value@col3:色3/col,0x00ff00
--value@col4:色4,0x00ffff
--value@col5:色5,0x0000ff
--value@col6:色6,0xff00ff
--value@col7:取得用/col,0x000000
local maxN = math.floor(obj.track2)
if maxN < 1 then
    maxN = 6
end
require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.Colorama(userdata, w, h, obj.track0 / 100, obj.track1, maxN, col1, col2, col3, col4, col5, col6)
obj.putpixeldata(userdata)
