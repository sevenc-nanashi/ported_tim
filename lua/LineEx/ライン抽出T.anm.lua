--label:tim2
--track0:半径,1,500,1,1
--track1:強度,0,1000,300
--track2:粒子化幅,0,1000,0,1
--track3:しきい値,0,255,0,1
--value@col1:ライン色/col,0xff0000
--value@col2:背景色/col,0xffffff
--value@Bal:背景透明度,0
--value@Oal:ｵﾘｼﾞﾅﾙ透明度,100
--value@Lr:輝度反転/chk,0
--value@par:粒子[移動/参照]/chk,0
--value@dir:└飛散方向,{0,360}
--value@dck:└飛散ループ/chk,1
--value@arc:追加領域サイズ,0
--value@seed:シード,0
--value@sR:└変化間隔,0
--check0:ラインのみ,0;
dir = dir or { 0, 360 }
seed = seed or 0
if sR > 0 then
    seed = seed + math.floor(obj.time * obj.framerate / sR)
end
require("T_LineExtra_Module")
if Lr == 1 then
    obj.effect("反転", "輝度反転", 1)
end
if arc > 0 then
    arc = (arc + 1) / 2
    obj.effect("領域拡張", "上", arc, "下", arc, "右", arc, "左", arc)
end
local userdata, w, h = obj.getpixeldata()
T_LineExtra_Module.SetPublicImage(userdata, w, h)
obj.effect("ぼかし", "範囲", obj.track0, "サイズ固定", 1)
userdata, w, h = obj.getpixeldata()
T_LineExtra_Module.LineExt(
    userdata,
    w,
    h,
    obj.track1,
    obj.track2,
    obj.track3,
    obj.check0,
    Bal,
    Oal,
    col1,
    col2,
    par,
    dck,
    dir[1],
    dir[2],
    seed
)
obj.putpixeldata(userdata)
