--label:tim2\グループ補助.anm\グループ補助2
---$track:透過率
---min=0
---max=100
---step=0.1
local rename_me_track0 = 0

---$track:X回転
---min=-3600
---max=3600
---step=0.1
local rename_me_track1 = 0

---$track:Y回転
---min=-3600
---max=3600
---step=0.1
local rename_me_track2 = 0

---$track:Z回転
---min=-3600
---max=3600
---step=0.1
local rename_me_track3 = 0

obj.alpha = obj.alpha * (1 - rename_me_track0 * 0.01)
obj.rx = obj.rx + rename_me_track1
obj.ry = obj.ry + rename_me_track2
obj.rz = obj.rz + rename_me_track3
