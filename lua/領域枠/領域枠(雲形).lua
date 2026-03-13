--label:tim2\装飾\@領域枠
---$track:画線幅％
---min=0
---max=100
---step=0.1
local track_stroke_width_percent = 10

---$track:密度
---min=1
---max=200
---step=1
local track_density = 7

---$track:形状変化
---min=1
---max=5000
---step=0.01
local track_change = 1

---$track:背景濃度
---min=0
---max=100
---step=0.1
local track_density_2 = 20

---$color:枠色
local col1 = 0xffffff

---$color:背景色
local col2 = 0xccccff

---$track:追加幅
---min=-5000
---max=5000
---step=0.1
local pw = 0

---$track:追加高さ
---min=-5000
---max=5000
---step=0.1
local ph = 0

---$track:平滑度[%]
---min=0
---max=100
---step=0.1
local par = 20

---$value:雲横位置[%]
local wpar = { 50, 100 }

---$value:雲横重なり[%]
local xpar = { 10, 40 }

---$value:雲高さ[%]
local hpar = { 70, 90 }

---$track:回転
---min=-360
---max=360
---step=0.1
local crot = 35

---$select:変形
---1=1
---2=2
---3=3
---4=4
---5=5
local hei = 1

---$track:精度
---min=0.1
---max=10
---step=0.1
local bai = 1

---$value:基準
local base = { 0, 0 }

local function make_waku(wh, w, h, col1, lw)
    obj.setoption("drawtarget", "tempbuffer", w + 10, h + 10)
    obj.load("figure", "四角形", col1, wh + 10)
    obj.draw()
    obj.copybuffer("obj", "cache:cache-Itiji")
    obj.setoption("blend", "alpha_sub")
    obj.draw(0, 0, 0, 1 - lw)
    obj.setoption("blend", 0)
end

local w, h = obj.getpixel()
local lw = track_stroke_width_percent * 0.01
local cou = math.floor(track_density)
local pt = track_change
local pt1 = math.floor(pt)
local pt2 = pt1 + 1
pt = pt - pt1

hei = math.min(math.max(hei, 1), 5)

pt = 2 * pt
if pt < 1 then
    pt = pt ^ hei
else
    pt = 2 - (2 - pt) ^ hei
end
pt = pt * 0.5

local backC = track_density_2 * 0.01

w, h = pw + w + 2 * lw, ph + h + 2 * lw

w = ((w > 0) and w) or 0
h = ((h > 0) and h) or 0
local wh = math.max(w, h)
local w1 = w * 0.5
local h1 = h * 0.5

local sw1 = bai * w
local sh1 = bai * h
local bw = 2 * sw1
local bh = 2 * sh1
local swh = math.max(sw1, sh1)
local posy = sh1 * par * 0.01
base = base or { 0, 0 }
--オリジナル保存
obj.copybuffer("cache:cache-ori", "obj")

--枠作成保存
obj.setoption("drawtarget", "tempbuffer", bw, bh)
obj.load("figure", "四角形", 0xffffff, swh)
obj.drawpoly(-sw1, -sh1, 0, sw1, -sh1, 0, sw1, posy, 0, -sw1, posy, 0)

local posx1 = {}
local posx2 = {}
posx1[0] = 0
posx2[0] = 0
for i = 1, cou do
    posx1[i] = obj.rand(wpar[1], wpar[2], i, pt1 + 1000) + posx1[i - 1]
    posx2[i] = obj.rand(wpar[1], wpar[2], i, pt2 + 1000) + posx2[i - 1]
end

for i = 0, cou do
    posx1[i] = posx1[i] / posx1[cou] * bw - sw1
    posx2[i] = posx2[i] / posx2[cou] * bw - sw1
end

obj.load("figure", "円", 0xffffff, math.min(sw1, sh1))
for i = 1, cou - 1 do
    local ox11 = posx1[i - 1]
    local ox12 = posx2[i - 1]
    local ox21 = posx1[i] + (posx1[i + 1] - posx1[i]) * obj.rand(xpar[1], xpar[2], i, pt1 + 2000) * 0.01
    local ox22 = posx2[i] + (posx2[i + 1] - posx2[i]) * obj.rand(xpar[1], xpar[2], i, pt2 + 2000) * 0.01
    local oy1 = (sh1 - posy) * obj.rand(hpar[1], hpar[2], i, pt1 + 3000) * 0.01
    local oy2 = (sh1 - posy) * obj.rand(hpar[1], hpar[2], i, pt2 + 3000) * 0.01
    local ox1 = (1 - pt) * ox11 + pt * ox12
    local ox2 = (1 - pt) * ox21 + pt * ox22
    local oy = (1 - pt) * oy1 + pt * oy2
    obj.drawpoly(ox1, -oy + posy, 0, ox2, -oy + posy, 0, ox2, oy + posy, 0, ox1, oy + posy, 0)
end
local ox11 = posx1[cou - 1]
local ox12 = posx2[cou - 1]
local ox21 = posx1[cou] + (posx1[1] - posx1[0]) * obj.rand(xpar[1], xpar[2], cou, pt1 + 2000) * 0.01
local ox22 = posx2[cou] + (posx2[1] - posx2[0]) * obj.rand(xpar[1], xpar[2], cou, pt2 + 2000) * 0.01
local oy1 = (sh1 - posy) * obj.rand(hpar[1], hpar[2], cou, pt1 + 3000) * 0.01
local oy2 = (sh1 - posy) * obj.rand(hpar[1], hpar[2], cou, pt2 + 3000) * 0.01

local ox1 = (1 - pt) * ox11 + pt * ox12
local ox2 = (1 - pt) * ox21 + pt * ox22
local oy = (1 - pt) * oy1 + pt * oy2
obj.drawpoly(ox1, -oy + posy, 0, ox2, -oy + posy, 0, ox2, oy + posy, 0, ox1, oy + posy, 0)
obj.drawpoly(ox1 - bw, -oy + posy, 0, ox2 - bw, -oy + posy, 0, ox2 - bw, oy + posy, 0, ox1 - bw, oy + posy, 0)

obj.copybuffer("obj", "tmp")
obj.effect("極座標変換", "回転", crot)
obj.setoption("drawtarget", "tempbuffer", w, h)
obj.drawpoly(-w1, -h1, 0, w1, -h1, 0, w1, h1, 0, -w1, h1, 0)
obj.copybuffer("cache:cache-Itiji", "tmp")

--枠作成保存
make_waku(wh, w, h, col1, lw)
obj.copybuffer("cache:cache-waku", "tmp")

--削除領域作成保存
make_waku(wh, w, h, col1, 0)
obj.copybuffer("cache:cache-del", "tmp")

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
