--label:tim2\T_Color_Module.anm\ポスタリゼーション
--track0:R階調数,2,256,8,1
--track1:G階調数,2,256,8,1
--track2:B階調数,2,256,8,1
--track3:サイズ,1,1000,1
--check0:全体をRで調整,0
--value@ED:誤差拡散/chk,0
local ED2 = ED or 0 --追加のため
local sz = math.max(1, obj.track3) --追加のため
local w0, h0
require("T_Color_Module")
local r, g, b
if obj.check0 then
    r = obj.track0
    g, b = r, r
else
    r, g, b = obj.track0, obj.track1, obj.track2
end
if sz > 1 then
    w0, h0 = obj.getpixel()
    obj.effect("リサイズ", "拡大率", 100 / sz)
end
local userdata, w, h = obj.getpixeldata()
T_Color_Module.Posterize(userdata, w, h, r, g, b, ED2)
obj.putpixeldata(userdata)
if sz > 1 then
    obj.effect("リサイズ", "X", w0, "Y", h0, "補間なし", 1, "ドット数でサイズ指定", 1)
end
