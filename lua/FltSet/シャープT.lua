--label:tim2\T_Filter_Module.anm\シャープT
--track0:強さ,0,1000,100
--track1:半径,1,100,1,1
--check0:アンシャープマスク,1;
require("T_Filter_Module")
local St = obj.track0 * 0.01

if obj.check0 then
    local userdata, w, h = obj.getpixeldata()
    T_Filter_Module.SetPublicImage(userdata, w, h)
    obj.effect("ぼかし", "範囲", obj.track1, "サイズ固定", 1)
    userdata, w, h = obj.getpixeldata()
    T_Filter_Module.UnSharpMask(userdata, w, h, St)
    obj.putpixeldata(userdata)
else
    obj.effect("領域拡張", "塗りつぶし", 1, "上", 1, "下", 1, "左", 1, "右", 1)
    local userdata, w, h = obj.getpixeldata()
    T_Filter_Module.Sharp(userdata, w, h, St)
    obj.putpixeldata(userdata)
    obj.effect("クリッピング", "上", 1, "下", 1, "左", 1, "右", 1)
end
