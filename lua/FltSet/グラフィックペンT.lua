--label:tim2\T_Filter_Module.anm\グラフィックペンT
--track0:線長,2,200,40,1
--track1:しきい値,0,255,128,1
--track2:白線量,0,100,8
--track3:黒線量,0,100,8
--value@Vec:向き[0..3],2
--value@col1:シャドウ/col,0x0
--value@col2:ハイライト/col,0xffffff
--value@sechk:シード固定/chk,1
--value@seed:シード,0
--check0:しきい値を自動計算,1;

require("T_Filter_Module")
local Lng = obj.track0
obj.effect("単色化")
obj.effect("領域拡張", "塗りつぶし", 1, "上", Lng, "下", Lng, "左", Lng, "右", Lng)

if sechk == 0 then
    seed = seed + obj.time * obj.framerate
end
Vec = math.floor(((Vec or 2) % 4))
local userdata, w, h = obj.getpixeldata()
T_Filter_Module.Graphicpen(userdata, w, h, Lng, obj.track1, obj.track2 * 0.01, obj.track3 * 0.01, Vec, seed, obj.check0)
obj.putpixeldata(userdata)

userdata, w, h = obj.getpixeldata()
local r1, g1, b1 = RGB(col1)
local r2, g2, b2 = RGB(col2)
T_Filter_Module.GrayColor(userdata, w, h, r1, g1, b1, r2, g2, b2)
obj.putpixeldata(userdata)
obj.effect("クリッピング", "上", Lng, "下", Lng, "左", Lng, "右", Lng)
