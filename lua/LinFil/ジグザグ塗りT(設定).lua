--label:tim2\ジグザグ塗りT.anm\ジグザグ塗りT(設定)
--track0:角度,-3600,3600,20
--track1:本体α,0,100,100
--track2:ラインα,0,100,100
--track3:ぼかし,0,500,0,1
T_LineFill = T_LineFill or {}
T_LineFill.K = obj.track0
T_LineFill.OgA = obj.track1
T_LineFill.LnA = obj.track2
T_LineFill.B = obj.track3
