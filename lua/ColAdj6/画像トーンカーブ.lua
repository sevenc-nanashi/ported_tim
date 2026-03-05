--label:tim2\T_Color_Module.anm\画像トーンカーブ
--track0:X or R,-10000,10000,0
--track1:Y or θ,-10000,10000,0
--track2:角度,-3600,3600,0
--track3:幅％,1,500,100
--value@CC:中心,{0,0}
--value@col:線色/col,0xff0000
--value@Lck:線を非表示/chk,0
--check0:極座標移動,0;
col = col or 0x0
obj.setanchor("CC", 1)
require("T_Color_Module")
local CSET = obj.track0
local userdata, w, h = obj.getpixeldata()
local X, Y = obj.track0, obj.track1
local Deg = obj.track2
if obj.check0 then
    Deg = Deg + Y
    X, Y = -X * math.sin(Y / 180 * math.pi), X * math.cos(Y / 180 * math.pi)
end
X, Y = X + CC[1], Y + CC[2]
T_Color_Module.ImageToneCurve(userdata, w, h, X, Y, Deg, w * obj.track3 * 0.01, col, Lck)
obj.putpixeldata(userdata)
T_ToneCurve_R = 1
T_ToneCurve_G = 1
T_ToneCurve_B = 1
