--label:tim2\T_Color_Module.anm\拡張コントラスト
--track0:中心,-255,255,0
--track1:強度,-200,200,100
--track2:明るさ,-255,255,0
--track3:なめらか,0,100,50,0
--value@Csiz:カーブサイズ,260
--check0:カーブ表示,0;
require("T_Color_Module")
if obj.check0 then
    obj.load("figure", "四角形", 0xffffff, math.max(100, Csiz or 260))
end
local userdata, w, h = obj.getpixeldata()
T_Color_Module.ExtendedContrast(userdata, w, h, obj.track0, obj.track1, obj.track2, obj.track3 / 100, obj.check0)
obj.putpixeldata(userdata)
