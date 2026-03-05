--label:tim2\簡易リピーター.anm
---$track:ｵﾌｾｯﾄ(S)
---min=-5000
---max=5000
---step=0.1
local rename_me_track0 = 0

---$track:送り(mS)
---min=-50000
---max=50000
---step=0.1
local rename_me_track1 = 40

---$track:ループ
---min=0
---max=1
---step=1
local rename_me_track2 = 1

---$track:α読込
---min=0
---max=1
---step=1
local rename_me_track3 = 1

---$file:ファイル
local rename_me_file = ""
file = rename_me_file

repeater_SS = rename_me_track0 + obj.time
repeater_dS = rename_me_track1 * 0.001
repeater_mrp = rename_me_track2
repeater_alf = rename_me_track3
repeater_rep = 1
