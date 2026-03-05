--label:tim2\グループ補助.anm\グループ補助1
--track0:X,-20000,20000,0
--track1:Y,-20000,20000,0
--track2:Z,-20000,20000,0
--track3:拡大率,0,5000,100
obj.ox = obj.ox + obj.track0
obj.oy = obj.oy + obj.track1
obj.oz = obj.oz + obj.track2
obj.zoom = obj.zoom * obj.track3 * 0.01
