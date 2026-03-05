--label:tim2\グループ補助.anm
---$track:X
---min=-20000
---max=20000
---step=0.1
local rename_me_track0 = 0

---$track:Y
---min=-20000
---max=20000
---step=0.1
local rename_me_track1 = 0

---$track:Z
---min=-20000
---max=20000
---step=0.1
local rename_me_track2 = 0

---$track:拡大率
---min=0
---max=5000
---step=0.1
local rename_me_track3 = 100

obj.ox = obj.ox + rename_me_track0
obj.oy = obj.oy + rename_me_track1
obj.oz = obj.oz + rename_me_track2
obj.zoom = obj.zoom * rename_me_track3 * 0.01
