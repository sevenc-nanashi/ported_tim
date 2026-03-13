--label:tim2\配置\@簡易リピーター.anm
---$track:ｵﾌｾｯﾄ(S)
---min=-5000
---max=5000
---step=0.1
local track_offset_s = 0

---$track:送り(mS)
---min=-50000
---max=50000
---step=0.1
local track_ms = 40

---$track:ループ
---min=0
---max=1
---step=1
local track_loop = 1

---$track:α読込
---min=0
---max=1
---step=1
local track_alpha_load = 1

---$file:ファイル
local file = ""
file = file

repeater_SS = track_offset_s + obj.time
repeater_dS = track_ms * 0.001
repeater_mrp = track_loop
repeater_alf = track_alpha_load
repeater_rep = 1
