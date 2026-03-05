--label:tim2\T_Color_Module.anm\白黒
--track0:R%,-500,500,100
--track1:G%,-500,500,100
--track2:B%,-500,500,100
--track3:W%,-500,500,100
--value@C:C%,100
--value@M:M%,100
--value@Y:Y%,100
--value@Ck:色付け/chk,0
--value@col:└着色/col,0xff0000
--value@gm:ガンマ値,100
local R = obj.track0 * 0.01
local G = obj.track1 * 0.01
local B = obj.track2 * 0.01
local W = obj.track3 * 0.01
C = (C or 100) * 0.01
M = (M or 100) * 0.01
Y = (Y or 100) * 0.01
Ck = Ck or 0
col = col or 0xffffff
gm = gm or 100
if gm < 1 then
    gm = 1
end
require("T_Color_Module")
local userdata, w, h = obj.getpixeldata()
T_Color_Module.EnhGrayScale(userdata, w, h, R, G, B, C, M, Y, W, 100 / gm, Ck, col)
obj.putpixeldata(userdata)
