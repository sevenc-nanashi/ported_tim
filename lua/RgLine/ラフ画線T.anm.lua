--label:tim2
--track0:長さ,0,500,10,1
--track1:強度上限,0,255,128,1
--track2:強度下限,0,255,0,1
--track3:しきい値,0,1000,0,1
--value@_1:線色/col,0x0
--value@_2:背景−色/col,0xffffff
--value@_3:└元絵比率%,0
--value@_4:└透明度%,0
--value@_5:画線ガンマ,100
--value@_6:スクリーン合成/chk,1
--value@_7:境界補正/chk,0
--value@_8:└追加色/col,0xffffff
--value@_9:方向表示指定,"11110000"
--value@_10:長さMAPﾚｲﾔｰ,0
--value@_11:抽出−サイズ,1
--value@_12:└強度,300
--value@_13:└しきい値,0
--value@_0:PI,nil
--check0:画線のみ,0;
_0 = _0 or {}
local pw = _0[1] or obj.track0
local Lu = _0[2] or obj.track1
local Ld = _0[3] or obj.track2
local Ls = _0[4] or obj.track3
local Is = _0[0] == nil and obj.check0 or _0[0]
local col1 = _1 or 0x0
local col2 = _2 or 0xffffff
local Oal = _3 or 0
local Bal = _4 or 0
local LG = _5 or 100
local SSy = _6 or 1
local OutC = _7 or 0
local col3 = _8 or 0xffffff
local Did = _9 or "11111111"
local Lay = _10 or 0
local BL = _11 or 1
local BS = _12 or 300
local BH = _13 or 0
_0 = nil
_1 = nil
_2 = nil
_3 = nil
_4 = nil
_5 = nil
_6 = nil
_7 = nil
_8 = nil
_9 = nil
_10 = nil
_11 = nil
_12 = nil
_13 = nil
if OutC == 1 then
    obj.effect("縁取り", "サイズ", pw, "color", col3, "ぼかし", 1)
end
require("T_RoughLine_Module")
local SeD = 0
local RoughLine = T_RoughLine_Module.LineExt
local t = 1
for i in string.gmatch(Did, "[0-1]") do
    SeD = SeD + i * t
    t = t * 2
end
Lay = Lay or 0
if Lay > 0 and Lay <= 100 then
    local Lck = obj.getvalue("layer" .. Lay .. ".x") and 1 or 0
    if Lck == 1 then
        local Pr =
            { obj.ox, obj.oy, obj.oz, obj.rx, obj.ry, obj.rz, obj.cx, obj.cy, obj.cz, obj.zoom, obj.alpha, obj.aspect }
        local w0, h0 = obj.getpixel()
        obj.copybuffer("tmp", "obj")
        obj.load("layer", Lay, true)
        if OutC == 1 then
            obj.effect("領域拡張", "上", pw, "下", pw, "左", pw, "右", pw, "塗りつぶし", 0)
        end
        obj.effect("リサイズ", "X", w0, "Y", h0, "ドット数でサイズ指定", 1)
        local userdata, w, h = obj.getpixeldata()
        T_RoughLine_Module.SetMapImage(userdata, w, h)
        obj.copybuffer("obj", "tmp")
        obj.ox, obj.oy, obj.oz, obj.rx, obj.ry, obj.rz, obj.cx, obj.cy, obj.cz, obj.zoom, obj.alpha, obj.aspect =
            unpack(Pr)
    end
end
local userdata, w, h = obj.getpixeldata()
T_RoughLine_Module.SetPublicImage(userdata, w, h)
obj.effect("ぼかし", "範囲", BL, "サイズ固定", 1)
userdata, w, h = obj.getpixeldata()
RoughLine(userdata, w, h, pw, Lu, Ld, Ls, BS, BH, Is, Oal, Bal, col1, col2, SSy, LG, SeD)
obj.putpixeldata(userdata)
