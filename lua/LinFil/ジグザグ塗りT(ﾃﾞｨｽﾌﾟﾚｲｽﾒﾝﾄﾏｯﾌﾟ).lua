--label:tim2\ジグザグ塗りT.anm\ジグザグ塗りT(ﾃﾞｨｽﾌﾟﾚｲｽﾒﾝﾄﾏｯﾌﾟ)
--track0:MAPﾚｲﾔ,1,100,1,1
--track1:変形X,-500,500,10
--track2:変形Y,-500,500,10
--track3:変形方法,0,2,0,1
--value@BL:ぼかし,5
--value@DX:領域拡張X,0
--value@DY:領域拡張Y,0
--check0:MAPサイズ調整,0;
T_LineFill = T_LineFill or {}
T_LineFill.Ly = math.floor(obj.track0)
T_LineFill.X = obj.track1
T_LineFill.Y = obj.track2
T_LineFill.C = obj.track3
T_LineFill.BL = BL
T_LineFill.DX = DX
T_LineFill.DY = DY
T_LineFill.RS = obj.check0
