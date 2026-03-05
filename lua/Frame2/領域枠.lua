--label:tim2\領域枠.anm\領域枠
--track0:画線幅,0,5000,10
--track1:追加幅,-5000,5000,0
--track2:追加高さ,-5000,5000,0
--track3:背景濃度,0,100,20
--value@col1:枠色/col,0xffffff
--value@col2:背景色/col,0xccccff
--value@base:基準,{0,0}

obj.copybuffer("cache:cache1", "obj")
local w, h = obj.getpixel()
local lw = obj.track0
local pw = obj.track1
local ph = obj.track2
local backC = obj.track3 * 0.01
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
