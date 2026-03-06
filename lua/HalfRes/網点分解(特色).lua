--label:tim2\加工\網点分解T.anm
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

---$track:ﾎﾞｶｼ補正
---min=0
---max=500
---step=1
local track_adjust = 50

---$figure:形状
local fig = "円"

---$value:網点角度1
local deg1 = 15

---$value:網点角度2
local deg2 = 75

---$value:網点角度3
local deg3 = 30

---$check:網点も回転
local Drt = 0

---$value:公転速度
local rV = 0

---$value:自転速度
local mV = 0

---$color:色1
local col1 = 0x00ffff

---$color:色2
local col2 = 0xff00ff

---$color:色3
local col3 = 0xffff00

---$value:背景色
local Bcol = 0xffffff

---$value:型抜法[0/1/2]
local Dcut = 2

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

local deg = { deg1, deg2, deg3 }
local w, h = obj.getpixel()
local w2, h2 = w / 2, h / 2

local oT = obj.time * rV
local mT = obj.time * mV

local Cnum
if not col1 then
    Cnum = 3
    col1 = 0x00ffff
    col2 = 0xff00ff
    col3 = 0xffff00
elseif not col2 then
    Cnum = 1
elseif not col3 then
    Cnum = 2
else
    Cnum = 3
end

local r1, g1, b1 = RGB(col1)
local r2, g2, b2 = RGB(col2 or 0x0)
local r3, g3, b3 = RGB(col3 or 0x0)
r1, g1, b1 = 255 - r1, 255 - g1, 255 - b1
r2, g2, b2 = 255 - r2, 255 - g2, 255 - b2
r3, g3, b3 = 255 - r3, 255 - g3, 255 - b3

local A = {}
if Cnum == 1 then
    local deti = 1 / (r1 * r1 + g1 * g1 + b1 * b1)
    A[1] = { r1 * deti, g1 * deti, b1 * deti }
elseif Cnum == 2 then
    local a11 = r1 * r1 + g1 * g1 + b1 * b1
    local a22 = r2 * r2 + g2 * g2 + b2 * b2
    local a12 = r1 * r2 + g1 * g2 + b1 * b2
    local deti = 1 / (a11 * a22 - a12 * a12)
    local b11 = a22 * deti
    local b12 = -a12 * deti
    local b22 = a11 * deti
    A[1] = { b11 * r1 + b12 * r2, b11 * g1 + b12 * g2, b11 * b1 + b12 * b2 }
    A[2] = { b12 * r1 + b22 * r2, b12 * g1 + b22 * g2, b12 * b1 + b22 * b2 }
else
    local deti = 1 / (r1 * g2 * b3 + r2 * g3 * b1 + r3 * g1 * b2 - r1 * g3 * b2 - r2 * g1 * b3 - r3 * g2 * b1)
    A[1] = { (g2 * b3 - g3 * b2) * deti, -(r2 * b3 - r3 * b2) * deti, (r2 * g3 - r3 * g2) * deti }
    A[2] = { -(g1 * b3 - g3 * b1) * deti, (r1 * b3 - r3 * b1) * deti, -(r1 * g3 - r3 * g1) * deti }
    A[3] = { (g1 * b2 - g2 * b1) * deti, -(r1 * b2 - r2 * b1) * deti, (r1 * g2 - r2 * g1) * deti }
end

local col = {}
col[1] = RGB(r1, g1, b1)
col[2] = RGB(r2, g2, b2)
col[3] = RGB(r3, g3, b3)

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
                local CC = A[dim][1] * (255 - C[1]) + A[dim][2] * (255 - C[2]) + A[dim][3] * (255 - C[3])
                if CC < 0 then
                    CC = 0
                elseif CC > 1 then
                    CC = 1
                end
                al[dim][Pnum] = a / 255
                posx[dim][Pnum] = Lposx
                posy[dim][Pnum] = Lposy
                cl[dim][Pnum] = math.sqrt(CC) * (tsi2 - tsi1) + tsi1
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

obj.effect("ぼかし", "範囲", BS, "縦横比", 0, "光の強さ", 0, "サイズ固定", 1)
obj.copybuffer("cache:ori_img", "obj")

for i = 1, Cnum do
    MakeData(i, deg[i])
end

for i = 1, Cnum do
    MakeImage(col[i], i)
end

if Dcut > 0 then
    for i = 1, Cnum do
        obj.copybuffer("obj", "cache:C" .. i)
        obj.effect("単色化", "強さ", 100, "輝度を保持する", 0, "color", Bcol)
        obj.draw()
    end
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
for i = 1, Cnum do
    obj.copybuffer("obj", "cache:C" .. i)
    obj.draw()
end

obj.load("tempbuffer")
if EAP == 1 then
    obj.effect("リサイズ", "拡大率", 400)
end
obj.setoption("blend", 0)
