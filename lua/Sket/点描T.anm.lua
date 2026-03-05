--label:tim2
--track0:サイズ,3,300,10,1
--track1:位置ｽﾞﾚ%,0,100,50
--track2:ピッチ%,50,100,75
--track3:色幅,0,255,32,1
--value@_1:背景に着色/chk,0
--value@_2:└背景色/col,0xffffff
--value@_3:└背景を元絵に/chk,0
--value@_4:3D的表示/chk,0
--value@_5:└環境光,20
--value@_6:└拡散光,80
--value@_7:└鏡面光,60
--value@_8:　└光沢度,30
--value@_9:シード,0
--value@_10:└変化間隔,0
--value@_0: PI,nil
--check0:色参照位置固定,0;
require("T_Sketch_Module")
_0 = _0 or {}
local Sz = _0[1] or obj.track0
local Dx = _0[2] or obj.track1
local Pt = _0[3] or obj.track2
local Cw = _0[4] or obj.track3
local Oc = _0[0] == nil and obj.check0 or _0[0]
_0 = nil
local ck1 = _1 or 0
local Bol = _2 or 0xffffff
local ck2 = _3 or 0
local ck3 = _4 or 0
local La = _5 or 20
local Ld = _6 or 80
local Ls = _7 or 60
local Ns = _8 or 30
local SD = _9 or 0
local sR = _10 or 0
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
if sR > 0 then
    SD = SD + math.floor(obj.time * obj.framerate / sR)
end
local userdata, w, h = obj.getpixeldata()
T_Sketch_Module.Sketch(userdata, w, h, Sz, Dx, Pt, Cw, ck1 + 2 * ck2, Bol, ck3, La, Ld, Ls, Ns, SD, Oc)
obj.putpixeldata(userdata)
