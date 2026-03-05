--label:tim2\簡易リピーター.anm\リピーター(+時間)
--track0:ｵﾌｾｯﾄ(S),-5000,5000,0
--track1:送り(mS),-50000,50000,40
--track2:ループ,0,1,1,1
--track3:α読込,0,1,1,1
--file:
repeater_SS = obj.track0 + obj.time
repeater_dS = obj.track1 * 0.001
repeater_mrp = obj.track2
repeater_alf = obj.track3
repeater_rep = 1
