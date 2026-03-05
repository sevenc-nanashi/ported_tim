--label:tim2\領域枠.anm
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

obj.copybuffer("cache:cache1", "obj")
local w, h = obj.getpixel()
local lw = track_stroke_width
local pw = track_extra_width
local ph = track_extra_height
local backC = track_density * 0.01
local w, h = pw + w + 2 * lw, ph + h + 2 * lw
w = ((w > 1) and w) or 1
h = ((h > 1) and h) or 1
base = base or { 0, 0 }
obj.setoption("drawtarget", "tempbuffer", w, h)
local wh = math.max(w, h)
obj.load("figure", "四角形", col2, wh)
obj.draw(0, 0, 0, 1, backC)
obj.copybuffer("obj", "cache:cache1")
obj.draw()
obj.load("figure", "四角形", col1, wh)
if lw > 0 then
    local w1 = w * 0.5
    local h1 = h * 0.5
    local w0 = w1 - lw
    local h0 = h1 - lw
    w0 = ((w0 > 0) and w0) or 0
    h0 = ((h0 > 0) and h0) or 0
    obj.drawpoly(-w1, -h1, 0, w1, -h1, 0, w1, -h0, 0, -w1, -h0, 0)
    obj.drawpoly(-w1, h0, 0, w1, h0, 0, w1, h1, 0, -w1, h1, 0)
    obj.drawpoly(w0, -h1, 0, w1, -h1, 0, w1, h1, 0, w0, h1, 0)
    obj.drawpoly(-w1, -h1, 0, -w0, -h1, 0, -w0, h1, 0, -w1, h1, 0)
end
obj.load("tempbuffer")
obj.cx = obj.cx + w * base[1] * 0.01
obj.cy = obj.cy + h * base[2] * 0.01
