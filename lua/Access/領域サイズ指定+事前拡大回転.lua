--label:tim2\サイズ修正T.anm\領域サイズ指定+事前拡大回転
---$track:幅
---min=0
---max=5000
---step=0.1
local rename_me_track0 = 300

---$track:高さ
---min=0
---max=5000
---step=0.1
local rename_me_track1 = 300

---$track:回転角
---min=-3600
---max=3600
---step=0.1
local rename_me_track2 = 0

---$track:拡大率
---min=0
---max=5000
---step=0.1
local rename_me_track3 = 100

obj.setoption("drawtarget", "tempbuffer", rename_me_track0, rename_me_track1)
obj.draw(0, 0, 0, rename_me_track3 * 0.01, 1, 0, 0, rename_me_track2)
obj.load("tempbuffer")
