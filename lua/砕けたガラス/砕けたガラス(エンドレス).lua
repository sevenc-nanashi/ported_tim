--label:tim2\アニメーション効果\@砕けたガラス
---$track:サイズ
---min=-1000
---max=1000
---step=0.1
local track_size = 100

---$track:ガラス量
---min=0
---max=5000
---step=1
local track_glass_amount = 20

---$track:屈折率
---min=0
---max=5000
---step=0.1
local track_refractive_index = 25

---$track:移動速度
---min=-500
---max=500
---step=0.1
local track_move_speed = 10

---$check:オリジナル表示
local chk = false

---$track:回転速度
---min=0
---max=100
---step=0.1
local rotv = 5

---$track:ぼかし
---min=0
---max=500
---step=0.1
local blur = 25

---$track:透明度[%]
---min=0
---max=100
---step=0.1
local alpha = 20

---$track:厚さ
---min=0
---max=100
---step=0.1
local d = 3

---$value:光線方向
local L = { 1, 0, 1 }

---$track:正反射強度[%]
---min=0
---max=200
---step=0.1
local refp = 75

---$track:形状ランダム性[%]
---min=0
---max=200
---step=0.1
local frd = 100

---$track:サイズランダム性[%]
---min=0
---max=100
---step=0.1
local zornM = 0

---$track:小サイズ出現度
---min=10
---max=500
---step=0.1
local Sbeki = 100

---$track:速度ランダム性[%]
---min=0
---max=200
---step=0.1
local vrd = 100

---$track:乱数パターン
---min=0
---max=10000
---step=1
local rnd = 100

w, h = obj.getpixel()

obj.setoption("drawtarget", "tempbuffer", w, h)

if chk then
    obj.draw()
end

alpha = 1 - alpha / 100

local NN = track_glass_amount
local v = track_move_speed
local of = obj.time * obj.framerate

local sgn = 1
local gsize = track_size
if gsize < 0 then
    gsize = -gsize
    sgn = 0
end
if gsize < 10 then
    gsize = 10
end

local gsize_h = gsize / 2
local nk = track_refractive_index
local apsz_w = w + gsize
local apsz_h = h + gsize

frd = frd * 0.0001
vrd = vrd * 0.0001
refp = refp * 0.01
L[3] = math.abs(L[3])

local zorn = (zornM or 0) * 0.01
if zorn > 1 then
    zorn = 1
end
if zorn < 0 then
    zorn = 0
end

Sbeki = (Sbeki or 100) * 0.01
if Sbeki < 0.1 then
    Sbeki = 0.1
end

xx = {}
yy = {}

w2 = {}
h2 = {}
z2 = {}

for i = 1, NN do
    xx[i] = {}
    yy[i] = {}
    if sgn == 1 then
        xx[i][0], yy[i][0] =
            -gsize_h * (1 + frd * obj.rand(-50, 50, i, 1 + rnd)), -gsize_h * (1 + frd * obj.rand(-50, 50, i, 5 + rnd))
        xx[i][1], yy[i][1] =
            gsize_h * (1 + frd * obj.rand(-50, 50, i, 2 + rnd)), -gsize_h * (1 + frd * obj.rand(-50, 50, i, 6 + rnd))
    else
        xx[i][0], yy[i][0] =
            -gsize_h * frd * obj.rand(-100, 100, i, 1 + rnd), -gsize_h * (1 + frd * obj.rand(-50, 50, i, 5 + rnd))
        xx[i][1], yy[i][1] = xx[i][0], yy[i][0]
    end
    xx[i][2], yy[i][2] =
        gsize_h * (1 + frd * obj.rand(-50, 50, i, 3 + rnd)), gsize_h * (1 + frd * obj.rand(-50, 50, i, 7 + rnd))
    xx[i][3], yy[i][3] =
        -gsize_h * (1 + frd * obj.rand(-50, 50, i, 4 + rnd)), gsize_h * (1 + frd * obj.rand(-50, 50, i, 8 + rnd))

    local t1 = math.rad(obj.rand(0, 360, i, 9 + rnd) + obj.rand(-100, 100, i, 11 + rnd) / 100 * rotv * of)
    local t2 = math.rad(obj.rand(0, 360, i, 10 + rnd) + obj.rand(-100, 100, i, 12 + rnd) / 100 * rotv * of)
    local t3 = math.rad(obj.rand(0, 360, i, 10 + rnd) + obj.rand(-100, 100, i, 13 + rnd) / 100 * rotv * of)

    local dyori = obj.rand(0, apsz_h, i, 14 + rnd) + v * of * (1 + vrd * obj.rand(0, 100, i, 1000 + rnd))
    local dy = dyori % apsz_h - apsz_h / 2

    local dx = obj.rand(-apsz_w / 2, apsz_w / 2, i + math.floor(dyori / apsz_h), 3000 + rnd)
    dx = (dx + apsz_w / 2) % apsz_w - apsz_w / 2

    local c1 = math.cos(t1)
    local s1 = math.sin(t1)
    local c2 = math.cos(t2)
    local s2 = math.sin(t2)
    local c3 = math.cos(t3)
    local s3 = math.sin(t3)

    local zoom = obj.rand(0, 100, i, 2000 + rnd) * 0.01
    zoom = zoom ^ Sbeki
    zoom = 1 - zorn + zoom * zorn

    for s = 0, 3 do
        local z = -s2 * xx[i][s]
        xx[i][s] = c2 * xx[i][s]
        xx[i][s], yy[i][s] = c1 * xx[i][s] + s1 * yy[i][s], -s1 * xx[i][s] + c1 * yy[i][s]
        yy[i][s] = c3 * yy[i][s] + s3 * z
        xx[i][s], yy[i][s] = zoom * xx[i][s] + dx, zoom * yy[i][s] + dy
    end

    w2[i] = -c1 * s2
    h2[i] = s1 * s2 * c3 - c2 * s3
    z2[i] = -c2 * c3 - s1 * s2 * s3
end

for i = 1, NN do
    local wi = w / 2 + w2[i] * nk
    local hi = h / 2 + h2[i] * nk
    obj.drawpoly(
        xx[i][0],
        yy[i][0],
        0,
        xx[i][1],
        yy[i][1],
        0,
        xx[i][2],
        yy[i][2],
        0,
        xx[i][3],
        yy[i][3],
        0,
        xx[i][0] + wi,
        yy[i][0] + hi,
        xx[i][1] + wi,
        yy[i][1] + hi,
        xx[i][2] + wi,
        yy[i][2] + hi,
        xx[i][3] + wi,
        yy[i][3] + hi
    )
end

obj.load("figure", "四角形", 0xffffff, gsize)
obj.effect("マスク", "サイズ", gsize, "マスクの反転", 1, "ぼかし", blur)

for i = 1, NN do
    obj.drawpoly(
        xx[i][0],
        yy[i][0],
        0,
        xx[i][1],
        yy[i][1],
        0,
        xx[i][2],
        yy[i][2],
        0,
        xx[i][3],
        yy[i][3],
        0,
        0,
        0,
        obj.w,
        0,
        obj.w,
        obj.h,
        0,
        obj.h,
        alpha
    )
end

obj.load("figure", "四角形", 0xffffff, gsize)
for i = 1, NN do
    local wi = d * w2[i]
    local hi = d * h2[i]

    obj.drawpoly(
        xx[i][0] - wi,
        yy[i][0] - hi,
        0,
        xx[i][0] + wi,
        yy[i][0] + hi,
        0,
        xx[i][1] + wi,
        yy[i][1] + hi,
        0,
        xx[i][1] - wi,
        yy[i][1] - hi,
        0,
        0,
        0,
        obj.w,
        0,
        obj.w,
        obj.h,
        0,
        obj.h,
        alpha
    )
    obj.drawpoly(
        xx[i][1] - wi,
        yy[i][1] - hi,
        0,
        xx[i][1] + wi,
        yy[i][1] + hi,
        0,
        xx[i][2] + wi,
        yy[i][2] + hi,
        0,
        xx[i][2] - wi,
        yy[i][2] - hi,
        0,
        0,
        0,
        obj.w,
        0,
        obj.w,
        obj.h,
        0,
        obj.h,
        alpha
    )
    obj.drawpoly(
        xx[i][2] - wi,
        yy[i][2] - hi,
        0,
        xx[i][2] + wi,
        yy[i][2] + hi,
        0,
        xx[i][3] + wi,
        yy[i][3] + hi,
        0,
        xx[i][3] - wi,
        yy[i][3] - hi,
        0,
        0,
        0,
        obj.w,
        0,
        obj.w,
        obj.h,
        0,
        obj.h,
        alpha
    )
    obj.drawpoly(
        xx[i][3] - wi,
        yy[i][3] - hi,
        0,
        xx[i][3] + wi,
        yy[i][3] + hi,
        0,
        xx[i][0] + wi,
        yy[i][0] + hi,
        0,
        xx[i][0] - wi,
        yy[i][0] - hi,
        0,
        0,
        0,
        obj.w,
        0,
        obj.w,
        obj.h,
        0,
        obj.h,
        alpha
    )
end

obj.load("figure", "四角形", 0xffffff, gsize)
obj.setoption("blend", 1)
for i = 1, NN do
    local Nx = w2[i]
    local Ny = h2[i]
    local Nz = z2[i]
    local IB = Nx * L[1] + Ny * L[2] + Nz * L[3]
    local Rz = -(L[3] - 2 * IB * Nz) / math.sqrt(L[1] * L[1] + L[2] * L[2] + L[3] * L[3])

    if Rz > 0.7 then
        obj.drawpoly(
            xx[i][0],
            yy[i][0],
            0,
            xx[i][1],
            yy[i][1],
            0,
            xx[i][2],
            yy[i][2],
            0,
            xx[i][3],
            yy[i][3],
            0,
            0,
            0,
            obj.w,
            0,
            obj.w,
            obj.h,
            0,
            obj.h,
            refp * ((Rz - 0.7) / 0.3)
        )
    end
end

obj.load("tempbuffer")
obj.setoption("blend", 0)

-----------------------------------------------------------
