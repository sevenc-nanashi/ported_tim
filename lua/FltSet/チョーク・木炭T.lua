--label:tim2\T_Filter_Module.anm\チョーク・木炭T
--track0:木炭適用,0,100,0
--track1:ﾁｭｰｸ適用,0,100,0
--track2:筆圧,0,100,50
--track3:しきい値,0,255,0,1
--value@len:長さ[1-10],7
--value@np:ノイズ強度,30
--value@col1:シャドウ/col,0x0
--value@col2:ハイライト/col,0xffffff
--value@sechk:シード固定/chk,1
--value@seed:シード,0
--check0:しきい値を自動計算,1;

require("T_Filter_Module")
if sechk == 0 then
    seed = seed + obj.time * obj.framerate
end
if len < 1 then
    len = 1
elseif len > 10 then
    len = 10
end
obj.effect("単色化")
local userdata, w, h = obj.getpixeldata()
T_Filter_Module.Preprocessing(
    userdata,
    w,
    h,
    obj.track0 * 0.01,
    obj.track1 * 0.01,
    obj.track2 * 0.01,
    obj.track3,
    obj.check0
)
obj.putpixeldata(userdata)
obj.setoption("drawtarget", "tempbuffer", w, h)
obj.draw()
obj.effect("単色化", "輝度を保持する", 0)
obj.effect("ノイズ", "強さ", 100, "周期X", 50, "周期Y", 50, "type", 0, "mode", 1, "seed", seed)
obj.effect("ぼかし", "範囲", 3, "サイズ固定", 1)
obj.setoption("blend", 5)
obj.draw(0, 0, 0, 1, np * 0.01)
obj.load("tempbuffer")
userdata, w, h = obj.getpixeldata()
local r1, g1, b1 = RGB(col1)
local r2, g2, b2 = RGB(col2)
T_Filter_Module.ChalkCharcoal(userdata, w, h, len, r1, g1, b1, r2, g2, b2)
obj.putpixeldata(userdata)
obj.setoption("blend", 0)
