--label:tim2\未分類\領域枠.anm
---$track:画線幅
---min=0
---max=5000
---step=0.1
local track_stroke_width = 10

---$track:追加幅
---min=-5000
---max=5000
---step=0.1
local track_extra_width = 0

---$track:追加高さ
---min=-5000
---max=5000
---step=0.1
local track_extra_height = 0

---$track:背景濃度
---min=0
---max=100
---step=0.1
local track_density = 20

---$color:枠色
local col1 = 0xffffff

---$color:背景色
local col2 = 0xccccff

---$value:基準
local base = { 0, 0 }

local w, h = obj.getpixel()
local lw = track_stroke_width
local pw = track_extra_width
local ph = track_extra_height
local backC = track_density * 0.01
local w, h = pw + w + 2 * lw, ph + h + 2 * lw
base = base or { 0, 0 }
w = ((w > 1) and w) or 1
h = ((h > 1) and h) or 1
local w1 = w * 0.5
local h1 = h * 0.5
local w0 = w1 - lw
local h0 = h1 - lw
w0 = ((w0 > 0) and w0) or 0
h0 = ((h0 > 0) and h0) or 0
local wh = math.max(w, h)

obj.copybuffer("cache:cache-ori", "obj") --オリジナル保存

obj.setoption("drawtarget", "tempbuffer", w + 10, h + 10)
obj.load("figure", "円", 0xffffff, 2 * wh)
obj.drawpoly(-w0, -h0, 0, w0, -h0, 0, w0, h0, 0, -w0, h0, 0)
obj.copybuffer("cache:cache-Itiji", "tmp")
obj.load("figure", "四角形", col1, wh)
obj.draw()
obj.copybuffer("obj", "cache:cache-Itiji")
obj.setoption("blend", "alpha_sub")
obj.draw()
obj.setoption("blend", 0)
obj.copybuffer("cache:cache-waku", "tmp") --枠保存

obj.setoption("drawtarget", "tempbuffer", w + 10, h + 10)
obj.load("figure", "円", 0xffffff, 2 * wh)
obj.drawpoly(-w1, -h1, 0, w1, -h1, 0, w1, h1, 0, -w1, h1, 0)
obj.copybuffer("cache:cache-Itiji", "tmp")
obj.load("figure", "四角形", 0xffffff, wh)
obj.draw()
obj.copybuffer("obj", "cache:cache-Itiji")
obj.setoption("blend", "alpha_sub")
obj.draw()
obj.setoption("blend", 0)
obj.copybuffer("cache:cache-del", "tmp") --背景保存

--描画
obj.setoption("drawtarget", "tempbuffer", w, h)
obj.load("figure", "四角形", col2, wh)
obj.draw(0, 0, 0, 1, backC)

obj.copybuffer("obj", "cache:cache-ori")
obj.draw()

obj.copybuffer("obj", "cache:cache-waku")
obj.draw()

obj.copybuffer("obj", "cache:cache-del")
obj.setoption("blend", "alpha_sub")
obj.draw()

obj.load("tempbuffer")
obj.setoption("blend", 0)
obj.cx = obj.cx + w * base[1] * 0.01
obj.cy = obj.cy + h * base[2] * 0.01
