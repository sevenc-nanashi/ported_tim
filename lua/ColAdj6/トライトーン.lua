--label:tim2\T_Color_Module.anm\トライトーン
--track0:飽和点1,0,255,0,1
--track1:中心点,0,255,128,1
--track2:飽和点2,0,255,255,1
--value@egm:ミッドトーン色無視/chk,0
--value@col3:シャドウ/col,0x000000
--value@col2: ミッドトーン/col,0xb5982c
--value@col1: ハイライト/col,0xffffff
--check0:新バージョン,1
local p1, p2, p3
if obj.check0 then
    p3 = math.floor(obj.track0)
    p2 = math.floor(obj.track1)
    p1 = math.floor(obj.track2)
    p1, p3 = math.max(p1, p3), math.min(p1, p3)
else
    p1, p2, p3 = 255, 128, 0
end
require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.TritoneV3(userdata, w, h, col1, col2, col3, p1, p2, p3, egm or 0)
obj.putpixeldata(userdata)
