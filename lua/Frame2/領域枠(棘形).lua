--label:tim2\装飾\@領域枠.anm
---$track:画線幅％
---min=0
---max=100
---step=0.1
local track_stroke_width_percent = 10

---$track:密度
---min=1
---max=200
---step=1
local track_density = 10

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

---$track:棘幅ランダム性[%]
---min=0
---max=200
---step=0.1
local wpar = 50

---$value:棘高さ[%]
local hpar = { 20, 30 }

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

---$value:基準
local base = { 0, 0 }

local w, h = obj.getpixel()
local lw = track_stroke_width_percent * 0.01
local cou = math.floor(track_density)
local pt = track_change
local pt1 = math.floor(pt)
local pt2 = pt1 + 1
pt = pt - pt1
wpar = wpar * 0.5
crot = math.rad(crot)
base = base or { 0, 0 }
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
local w1 = w * 0.5
local h1 = h * 0.5
local swh = math.max(w, h)

--オリジナル保存
obj.copybuffer("cache:cache-ori", "obj")

--座標計算
local radi1 = {}
local radi2 = {}
radi1[0] = 0
radi2[0] = 0
for i = 1, cou do
    radi1[i] = obj.rand(100 - wpar, 100 + wpar, i, pt1 + 1000) + radi1[i - 1]
    radi2[i] = obj.rand(100 - wpar, 100 + wpar, i, pt2 + 1000) + radi2[i - 1]
end

for i = 0, cou do
    radi1[i] = radi1[i] / radi1[cou] * 2 * math.pi - crot
    radi2[i] = radi2[i] / radi2[cou] * 2 * math.pi - crot
end

local posx1 = {}
local posx2 = {}
local posy1 = {}
local posy2 = {}

for i = 0, cou do
    posx1[i], posy1[i] = w1 * math.cos(radi1[i]), h1 * math.sin(radi1[i])
    posx2[i], posy2[i] = w1 * math.cos(radi2[i]), h1 * math.sin(radi2[i])
end

for i = 0, cou do
    posx1[i] = (1 - pt) * posx1[i] + pt * posx2[i]
    posy1[i] = (1 - pt) * posy1[i] + pt * posy2[i]
end

local dswh = 2 * swh * math.max(hpar[1], hpar[2]) * 0.01
w = w + dswh
h = h + dswh
local wh = math.max(w, h)
local toghx = {}
local toghy = {}
local toghx1 = {}
local toghy1 = {}
local toghx2 = {}
local toghy2 = {}
for i = 0, cou - 1 do
    local x = posx1[i + 1] - posx1[i]
    local y = posy1[i + 1] - posy1[i]
    local r = math.sqrt(x * x + y * y)
    local togh = ((1 - pt) * obj.rand(hpar[1], hpar[2], i, pt1 + 3000) + pt * obj.rand(hpar[1], hpar[2], i, pt2 + 3000))
        * 0.01
        * swh
    toghx[i] = togh * y / r
    toghy[i] = -togh * x / r
    toghx1[i] = (posx1[i + 1] + posx1[i]) * 0.5 + toghx[i]
    toghy1[i] = (posy1[i + 1] + posy1[i]) * 0.5 + toghy[i]
    toghx2[i] = (posx1[i + 1] + posx1[i]) * 0.5 + toghx[i] * (1 - lw)
    toghy2[i] = (posy1[i + 1] + posy1[i]) * 0.5 + toghy[i] * (1 - lw)
end

for i = 1, cou - 1 do
    posx2[i] = posx1[i] - (toghx[i - 1] + toghx[i]) * 0.5 * lw
    posy2[i] = posy1[i] - (toghy[i - 1] + toghy[i]) * 0.5 * lw
end
posx2[0] = posx1[0] - (toghx[cou - 1] + toghx[0]) * 0.5 * lw
posy2[0] = posy1[0] - (toghy[cou - 1] + toghy[0]) * 0.5 * lw
posx2[cou] = posx1[cou] - (toghx[cou - 1] + toghx[0]) * 0.5 * lw
posy2[cou] = posy1[cou] - (toghy[cou - 1] + toghy[0]) * 0.5 * lw

--描画
obj.setoption("drawtarget", "tempbuffer", w, h)

obj.load("figure", "四角形", col2, swh)
obj.setoption("blend", "alpha_add")
for i = 0, cou - 1 do
    obj.drawpoly(0, 0, 0, posx2[i], posy2[i], 0, toghx2[i], toghy2[i], 0, posx2[i + 1], posy2[i + 1], 0)
end

obj.load("figure", "四角形", 0xffffff, wh)
obj.setoption("blend", "alpha_sub")
obj.draw(0, 0, 0, 1, 1 - backC)

obj.copybuffer("obj", "cache:cache-ori")
obj.setoption("blend", 0)
obj.draw()

obj.load("figure", "四角形", col1, swh)
obj.setoption("blend", "alpha_add")
for i = 0, cou - 1 do
    obj.drawpoly(posx1[i], posy1[i], 0, toghx1[i], toghy1[i], 0, toghx2[i], toghy2[i], 0, posx2[i], posy2[i], 0)
    obj.drawpoly(
        posx2[i + 1],
        posy2[i + 1],
        0,
        toghx2[i],
        toghy2[i],
        0,
        toghx1[i],
        toghy1[i],
        0,
        posx1[i + 1],
        posy1[i + 1],
        0
    )
end

obj.load("tempbuffer")
obj.setoption("blend", 0)
obj.cx = obj.cx + w * base[1] * 0.01
obj.cy = obj.cy + h * base[2] * 0.01
