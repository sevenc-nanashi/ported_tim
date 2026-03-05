--label:tim2\グループ補助.anm\グループ補助2
--track0:透過率,0,100,0
--track1:X回転,-3600,3600,0
--track2:Y回転,-3600,3600,0
--track3:Z回転,-3600,3600,0
obj.alpha = obj.alpha * (1 - obj.track0 * 0.01)
obj.rx = obj.rx + obj.track1
obj.ry = obj.ry + obj.track2
obj.rz = obj.rz + obj.track3
