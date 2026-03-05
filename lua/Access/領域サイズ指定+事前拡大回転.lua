--label:tim2\サイズ修正T.anm
---$track:幅
---min=0
---max=5000
---step=0.1
local width = 300

---$track:高さ
---min=0
---max=5000
---step=0.1
local height = 300

---$track:回転角
---min=-3600
---max=3600
---step=0.1
local angle = 0

---$track:拡大率
---min=0
---max=5000
---step=0.1
local scale = 100

obj.setoption("drawtarget", "tempbuffer", width, height)
obj.draw(0, 0, 0, scale * 0.01, 1, 0, 0, angle)
obj.load("tempbuffer")