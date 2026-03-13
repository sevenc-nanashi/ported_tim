--label:tim2\加工\@網点分解T.anm
---$track:サイズ
---min=5
---max=1000
---step=0.1
local track_size = 10

---$track:最小
---min=0
---max=500
---step=0.1
local track_min = 0

---$track:最大
---min=0
---max=500
---step=0.1
local track_max = 120

---$track:ボカシ補正
---min=0
---max=500
---step=1
local track_adjust = 50

---$figure:形状
local fig = "円"

---$track:網点角度C
---min=0
---max=360
---step=0.1
local deg1 = 15

---$track:網点角度M
---min=0
---max=360
---step=0.1
local deg2 = 75

---$track:網点角度Y
---min=0
---max=360
---step=0.1
local deg3 = 30

---$check:網点も回転
local Drt = 0

---$track:公転速度
---min=-10
---max=10
---step=0.1
local rV = 0

---$track:自転速度
---min=-10
---max=10
---step=0.1
local mV = 0

---$color:背景色
local Bcol = 0xffffff

---$select:型抜法
---なし=0
---網点のみ=1
---網点と元画像=2
local Dcut = 2

---$check:簡易表示
local check0 = false

local EAP = 0
if check0 and obj.getinfo("saving") == false then
    EAP = 1
end

local siz = track_size
local tsi1 = track_min * 0.01
local tsi2 = track_max * 0.01
local BS = track_adjust * 0.01 * siz

if EAP == 1 then
    siz = siz / 4
    BS = BS / 4
    obj.effect("リサイズ", "拡大率", 25)
end

local w, h = obj.getpixel()
local w2, h2 = w / 2, h / 2

local oT = obj.time * rV
local mT = obj.time * mV

local al = {}
local posx = {}
local posy = {}
local cl = {}
local rad = {}
local Num = {}

local MakeData = function(dim, rot)
    local rot2 = math.pi * ((rot + oT) % 90) / 180 --dxが0になることはない
    local cos, sin = math.cos(rot2), math.sin(rot2) --cos,sin>=0
    local dx, dy = siz * cos, siz * sin
    local nx = math.floor((w2 * sin + h2 * cos) / siz)
    local Pnum = 0

    al[dim] = {}
    posx[dim] = {}
    posy[dim] = {}
    cl[dim] = {}

    for k = -nx, nx do
        local Cx = -k * dy
        local Cy = k * dx
        local L1 = math.ceil(math.max((-w2 - Cx) / math.abs(dx), (-h2 - Cy) / math.abs(dy))) --dy=0でもうまくいく
        local L2 = math.floor(math.min((w2 - Cx) / math.abs(dx), (h2 - Cy) / math.abs(dy)))
        for j = L1, L2 do
            local Lposx = j * dx + Cx
            local Lposy = j * dy + Cy
            local C = {}
            local a
            C[1], C[2], C[3], a = obj.getpixel(Lposx + w2, Lposy + h2, "rgb")
            if a > 0 then
                Pnum = Pnum + 1
                al[dim][Pnum] = a / 255
                posx[dim][Pnum] = Lposx
                posy[dim][Pnum] = Lposy
                cl[dim][Pnum] = math.sqrt((255 - C[dim]) / 255) * (tsi2 - tsi1) + tsi1
            end
        end
    end
    rad[dim] = rot * Drt + oT + mT
    Num[dim] = Pnum
end

local MakeImage = function(col, dim)
    obj.setoption("drawtarget", "tempbuffer", w, h)

    if siz < 100 then
        obj.load("figure", fig, col, 100)
        obj.effect("リサイズ", "拡大率", siz)
    else
        obj.load("figure", fig, col, siz)
    end

    for i = 1, Num[dim] do
        obj.draw(posx[dim][i], posy[dim][i], 0, cl[dim][i], al[dim][i], 0, 0, rad[dim])
    end
    obj.copybuffer("cache:C" .. dim, "tmp")
end

obj.copybuffer("cache:ori_img", "obj")

obj.effect("ぼかし", "範囲", BS, "縦横比", 0, "光の強さ", 0, "サイズ固定", 1)
obj.copybuffer("cache:ori_img", "obj")

MakeData(1, deg1)
MakeData(2, deg2)
MakeData(3, deg3)

MakeImage(0xff0000, 1)
MakeImage(0x00ff00, 2)
MakeImage(0x0000ff, 3)

obj.setoption("drawtarget", "tempbuffer", w, h)
if Dcut > 0 then
    obj.copybuffer("obj", "cache:C1")
    obj.effect("単色化", "強さ", 100, "輝度を保持する", 0, "color", Bcol)
    obj.draw()
    obj.copybuffer("obj", "cache:C2")
    obj.effect("単色化", "強さ", 100, "輝度を保持する", 0, "color", Bcol)
    obj.draw()
    obj.copybuffer("obj", "cache:C3")
    obj.effect("単色化", "強さ", 100, "輝度を保持する", 0, "color", Bcol)
    obj.draw()
    if Dcut == 2 then
        obj.copybuffer("obj", "cache:ori_img")
        obj.effect("単色化", "強さ", 100, "輝度を保持する", 0, "color", Bcol)
        obj.draw()
    end
else
    obj.load("figure", "四角形", Bcol, 1)
    obj.drawpoly(-w2, -h2, 0, w2, -h2, 0, w2, h2, 0, -w2, h2, 0)
end

obj.setoption("blend", 2)
obj.copybuffer("obj", "cache:C1")
obj.draw()
obj.copybuffer("obj", "cache:C2")
obj.draw()
obj.copybuffer("obj", "cache:C3")
obj.draw()

obj.load("tempbuffer")
if EAP == 1 then
    obj.effect("リサイズ", "拡大率", 400)
end
obj.setoption("blend", 0)
