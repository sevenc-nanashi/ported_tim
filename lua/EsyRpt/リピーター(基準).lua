--label:tim2\簡易リピーター.anm\リピーター(基準)
---$track:X
---min=-5000
---max=5000
---step=0.1
local rename_me_track0 = 300

---$track:Y
---min=-5000
---max=5000
---step=0.1
local rename_me_track1 = 0

---$track:回転
---min=-3600
---max=3600
---step=0.1
local rename_me_track2 = 0

---$track:拡大%
---min=00
---max=5000
---step=0.1
local rename_me_track3 = 100

obj.setanchor("track", 0, "line")
repeater_dx = obj.getvalue("track.rename_me_track0")
repeater_dy = obj.getvalue("track.rename_me_track1")
repeater_dr = rename_me_track2
repeater_dk = rename_me_track3 * 0.01
repeater_rep = 0
