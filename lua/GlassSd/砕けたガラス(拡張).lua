--label:tim2\砕けたガラス.anm
---$track:分割ﾊﾟﾀｰﾝ
---min=0
---max=4
---step=1
local track_split_pattern = 1

---$track:限界ｻｲｽﾞ
---min=5
---max=1000
---step=0.1
local track_size = 50

---$track:光散乱
---min=1
---max=100
---step=0.1
local track_light_scatter = 30

---$track:拡大率
---min=0
---max=1000
---step=0.1
local track_scale = 100

---$file:ファイル
local file = ""
file = file

kudaketagarasu_sppt = track_split_pattern
kudaketagarasu_spsiz = track_size
kudaketagarasu_LimL = (100 - track_light_scatter) * 0.01
kudaketagarasu_zoom = track_scale * 0.01
kudaketagarasu_file = file

-----------------------------------------------------------
