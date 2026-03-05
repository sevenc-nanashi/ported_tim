--label:tim2\砕けたガラス.anm\砕けたガラス(拡張)
---$track:分割ﾊﾟﾀｰﾝ
---min=0
---max=4
---step=1
local rename_me_track0 = 1

---$track:限界ｻｲｽﾞ
---min=5
---max=1000
---step=0.1
local rename_me_track1 = 50

---$track:光散乱
---min=1
---max=100
---step=0.1
local rename_me_track2 = 30

---$track:拡大率
---min=0
---max=1000
---step=0.1
local rename_me_track3 = 100

---$file:ファイル
local rename_me_file = ""
file = rename_me_file

kudaketagarasu_sppt = rename_me_track0
kudaketagarasu_spsiz = rename_me_track1
kudaketagarasu_LimL = (100 - rename_me_track2) * 0.01
kudaketagarasu_zoom = rename_me_track3 * 0.01
kudaketagarasu_file = file

-----------------------------------------------------------
