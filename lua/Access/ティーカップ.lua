--label:tim2\けいおんグッズ.obj\ティーカップ
---$track:サイズ
---min=0
---max=5000
---step=0.1
local rename_me_track0 = 200

---$track:水面高さ
---min=0
---max=100
---step=0.1
local rename_me_track1 = 80

---$track:透明度
---min=0
---max=100
---step=0.1
local rename_me_track2 = 20

---$track:ｶｯﾌﾟｿｰｻｰ間
---min=-1000
---max=1000
---step=0.1
local rename_me_track3 = 13

---$value:分割数
local N = 40

---$value:カップ(色)/col
local colc = 0xffffff

---$value:ソーサー(色)/col
local cols = 0x02d2d2

---$value:ティー(色)/col
local colt = 0xa14250

---$value:ティー境界補正
local hosei = 5

---$value:取っ手幅
local tw = 0.03

---$value:取っ手位置補正
local tp = 1

---$value:ｱﾝﾁｴｲﾘｱｽ[0/1/2]
local ANT = 0

function CupLine(x)
    if x <= 0.9 then
        return 1.191156183 * x ^ 4
    else
        local BB = -12.88588146
        local CC = 26.66799905
        return BB * x * x + CC * x + 1 - BB - CC
    end
end
function Rot(u, s)
    return u * math.cos(s), u * math.sin(s)
end

local size = rename_me_track0 / 2
local ds = rename_me_track3 / 1000
ANT = math.floor(ANT)
mpi = math.pi

--ティーカップ本体作成
obj.load("figure", "四角形", colc, size)

if ANT < 2 then
    obj.setoption("antialias", ANT)
end

y1 = -size * CupLine(0) - size * ds
u1 = 0
for i = 0, N - 1 do
    if ANT >= 2 then
        if i == N - 1 then
            obj.setoption("antialias", 1)
        else
            obj.setoption("antialias", 0)
        end
    end
    v0 = (i + 1) / N
    y0 = -size * CupLine(v0) - size * ds
    u0 = size * v0
    x0, z0 = Rot(u0, 0)
    x3, z3 = Rot(u1, 0)
    for j = 0, N - 1 do
        s1 = j * 2 * mpi / N
        s2 = (j + 1) * 2 * mpi / N
        x1, z1 = Rot(u0, s2)
        x2, z2 = Rot(u1, s2)
        obj.drawpoly(x0, y0, z0, x1, y0, z1, x2, y1, z2, x3, y1, z3)
        x0, z0 = x1, z1
        x3, z3 = x2, z2
    end
    y1 = y0
    u1 = u0
end

--皿作成
obj.load("figure", "四角形", cols, size)
if ANT < 2 then
    obj.setoption("antialias", ANT)
end
v1 = 0
y1 = 0
u1 = 0
for i = 0, N - 1 do
    if ANT >= 2 then
        if i == N - 1 then
            obj.setoption("antialias", 1)
        else
            obj.setoption("antialias", 0)
        end
    end
    v0 = (i + 1) / N
    y0 = -0.26 * size * v0 ^ 2.4
    u0 = 1.5 * size * v0
    for j = 0, N - 1 do
        s1 = j * 2 * mpi / N
        s2 = (j + 1) * 2 * mpi / N
        x0, z0 = Rot(u0, s1)
        x1, z1 = Rot(u0, s2)
        x2, z2 = Rot(u1, s2)
        x3, z3 = Rot(u1, s1)
        obj.drawpoly(x0, y0, z0, x1, y0, z1, x2, y1, z2, x3, y1, z3)
    end
    v1 = v0
    y1 = y0
    u1 = u0
end

--取っ手作成
obj.load("figure", "四角形", colc, size * 0.6)
if ANT > 1 then
    ANT = 1
end
obj.setoption("antialias", ANT)
oy = size * CupLine(0.85) + size * ds
ox = (0.85 + 0.315) * size + tp
dz = size * tw
for j = 0, N - 1 do
    s1 = j * 2 * mpi / N
    s2 = (j + 1) * 2 * mpi / N
    hi1 = 1 + 0.5 * ((1 + math.cos(s1)) / 2) ^ 12
    hi2 = 1 + 0.5 * ((1 + math.cos(s2)) / 2) ^ 12
    x0, y0 = Rot(size * 0.30 * hi1, s1 + 0.7 * mpi)
    x1, y1 = Rot(size * 0.30 * hi2, s2 + 0.7 * mpi)
    x2, y2 = Rot(size * 0.24 * hi2, s2 + 0.7 * mpi)
    x3, y3 = Rot(size * 0.24 * hi1, s1 + 0.7 * mpi)
    obj.drawpoly(x0 + ox, y0 - oy, dz, x1 + ox, y1 - oy, dz, x2 + ox, y2 - oy, dz, x3 + ox, y3 - oy, dz)
    obj.drawpoly(x0 + ox, y0 - oy, -dz, x1 + ox, y1 - oy, -dz, x2 + ox, y2 - oy, -dz, x3 + ox, y3 - oy, -dz)
    obj.drawpoly(x0 + ox, y0 - oy, dz, x1 + ox, y1 - oy, dz, x1 + ox, y1 - oy, -dz, x0 + ox, y0 - oy, -dz)
    obj.drawpoly(x2 + ox, y2 - oy, dz, x3 + ox, y3 - oy, dz, x3 + ox, y3 - oy, -dz, x2 + ox, y2 - oy, -dz)
end

--紅茶作成
u1 = rename_me_track1 / 100
y1 = -size * CupLine(u1) - size * ds
u1 = size * u1 - hosei
obj.load("figure", "円", colt, 2 * u1)
if ANT > 1 then
    ANT = 1
end
obj.setoption("antialias", ANT)
obj.alpha = 1 - rename_me_track2 / 100
obj.drawpoly(-u1, y1, -u1, u1, y1, -u1, u1, y1, u1, -u1, y1, u1)
