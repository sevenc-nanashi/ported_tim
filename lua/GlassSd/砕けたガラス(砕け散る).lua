--label:tim2\アニメーション効果\砕けたガラス.anm
---$track:粉砕度
---min=0
---max=10000
---step=0.1
local track_shatter_amount = 50

---$track:サイズ
---min=10
---max=1000
---step=0.1
local track_size = 150

---$track:屈折率
---min=0
---max=5000
---step=0.1
local track_refractive_index = 25

---$track:動径速度
---min=0
---max=500
---step=0.1
local track_diameter_speed = 10

---$check:オリジナル表示
local chk = 0

---$value:回転速度
local rotv = 5

---$value:Z速度
local vz = 7

---$value:XY速度中心
local pos = { 0, 0 }

---$value:重力方向
local gr = { 0, 100, 0 }

---$value:ぼかし
local blur = 25

---$value:透明度[%]
local alpha = 25

---$value:厚さ
local d = 5

---$value:光線方向
local L = { 1, 0, 1 }

---$value:正反射強度[%]
local refp = 75

---$value:形状&速度ﾗﾝﾀﾞﾑ性[%]
local fvrd = { 70, 50 }

---$value:乱数パターン
local rnd = 100

function sqsplit1()
    local frdm = frd * 0.0001
    local Nw = -math.floor(-w / gsize)
    local Nh = -math.floor(-h / gsize)

    NN = Nw * Nh

    for k = 0, Nw - 1 do
        for j = 0, Nh - 1 do
            i = k + Nw * j

            xx[i] = {}
            xx[i][0] = gsize * (k + frdm * obj.rand(-50, 50, j, k + rnd)) - whf
            xx[i][1] = gsize * (k + 1 + frdm * obj.rand(-50, 50, j, k + 1 + rnd)) - whf
            xx[i][2] = gsize * (k + 1 + frdm * obj.rand(-50, 50, j + 1, k + 1 + rnd)) - whf
            xx[i][3] = gsize * (k + frdm * obj.rand(-50, 50, j + 1, k + rnd)) - whf

            yy[i] = {}
            yy[i][0] = gsize * (j + frdm * obj.rand(-50, 50, j, k + rnd)) - hhf
            yy[i][1] = gsize * (j + frdm * obj.rand(-50, 50, j, k + 1 + rnd)) - hhf
            yy[i][2] = gsize * (j + 1 + frdm * obj.rand(-50, 50, j + 1, k + 1 + rnd)) - hhf
            yy[i][3] = gsize * (j + 1 + frdm * obj.rand(-50, 50, j + 1, k + rnd)) - hhf
        end
    end

    for j = 0, Nh - 1 do
        i = Nw * j
        xx[i][0] = -whf
        xx[i][3] = -whf
        i = Nw - 1 + Nw * j
        xx[i][1] = whf
        xx[i][2] = whf

        if xx[i - 1][1] > whf then
            xx[i - 1][1] = whf
        end
        if xx[i - 1][2] > whf then
            xx[i - 1][2] = whf
        end
        if xx[i][0] > whf then
            xx[i][0] = whf
        end
        if xx[i][3] > whf then
            xx[i][3] = whf
        end
    end

    for k = 0, Nw - 1 do
        yy[k][0] = -hhf
        yy[k][1] = -hhf
        i = k + Nw * (Nh - 1)
        yy[i][2] = hhf
        yy[i][3] = hhf

        if yy[i - Nw][2] > hhf then
            yy[i - Nw][2] = hhf
        end
        if yy[i - Nw][3] > hhf then
            yy[i - Nw][3] = hhf
        end

        if yy[i][0] > hhf then
            yy[i][0] = hhf
        end
        if yy[i][1] > hhf then
            yy[i][1] = hhf
        end
    end
end

function sqsplit2()
    for i = 0, NN - 1 do
        xx[i + NN] = {}
        yy[i + NN] = {}

        if obj.rand(0, 100, i, 10000 + rnd) > 50 then
            xx[i + NN][0] = xx[i][0]
            xx[i + NN][1] = xx[i][0]
            xx[i + NN][2] = xx[i][1]
            xx[i + NN][3] = xx[i][3]
            yy[i + NN][0] = yy[i][0]
            yy[i + NN][1] = yy[i][0]
            yy[i + NN][2] = yy[i][1]
            yy[i + NN][3] = yy[i][3]
            xx[i][0] = xx[i][1]
            yy[i][0] = yy[i][1]
        else
            xx[i + NN][0] = xx[i][0]
            xx[i + NN][1] = xx[i][0]
            xx[i + NN][2] = xx[i][1]
            xx[i + NN][3] = xx[i][2]
            yy[i + NN][0] = yy[i][0]
            yy[i + NN][1] = yy[i][0]
            yy[i + NN][2] = yy[i][1]
            yy[i + NN][3] = yy[i][2]
            xx[i][1] = xx[i][0]
            yy[i][1] = yy[i][0]
        end
    end
    NN = 2 * NN
end

function sqsplit3()
    NN = 0
    xx[0] = {}
    xx[0][0] = -whf
    xx[0][1] = whf
    xx[0][2] = whf
    xx[0][3] = -whf
    yy[0] = {}
    yy[0][0] = -hhf
    yy[0][1] = -hhf
    yy[0][2] = hhf
    yy[0][3] = hhf
    sqsplit3_sub(0) --ランダム４角形に割る
    NN = NN + 1
end

function sqsplit3_sub(i)
    L1 = math.sqrt((xx[i][0] - xx[i][1]) * (xx[i][0] - xx[i][1]) + (yy[i][0] - yy[i][1]) * (yy[i][0] - yy[i][1]))
    L2 = math.sqrt((xx[i][1] - xx[i][2]) * (xx[i][1] - xx[i][2]) + (yy[i][1] - yy[i][2]) * (yy[i][1] - yy[i][2]))
    L3 = math.sqrt((xx[i][2] - xx[i][3]) * (xx[i][2] - xx[i][3]) + (yy[i][2] - yy[i][3]) * (yy[i][2] - yy[i][3]))
    L4 = math.sqrt((xx[i][3] - xx[i][0]) * (xx[i][3] - xx[i][0]) + (yy[i][3] - yy[i][0]) * (yy[i][3] - yy[i][0]))

    local maxL = math.max(L1, L2, L3, L4)

    if maxL > spsiz then
        if (maxL - spsiz) / (gsize - spsiz) * 100 > obj.rand(0, 100, i + rnd, NN) then
            NN = NN + 1

            local nsave = NN

            xx[NN] = {}
            yy[NN] = {}
            p11 = obj.rand(-frd / 4, frd / 4, i + rnd, NN + 1000) * 0.01
            p21 = obj.rand(-frd / 3, frd / 3, i + rnd, NN + 2000) * 0.01
            if p11 * p21 > 0 then
                p21 = -p21
            end
            p11 = p11 + 0.5
            p21 = p21 + 0.5
            p12 = 1 - p11
            p22 = 1 - p21

            if maxL == L1 or maxL == L3 then
                u10, v10 = xx[i][0], yy[i][0]
                u11, v11 = p11 * xx[i][0] + p12 * xx[i][1], p11 * yy[i][0] + p12 * yy[i][1]
                u12, v12 = p21 * xx[i][2] + p22 * xx[i][3], p21 * yy[i][2] + p22 * yy[i][3]
                u13, v13 = xx[i][3], yy[i][3]

                xx[NN][0], yy[NN][0] = u11, v11
                xx[NN][1], yy[NN][1] = xx[i][1], yy[i][1]
                xx[NN][2], yy[NN][2] = xx[i][2], yy[i][2]
                xx[NN][3], yy[NN][3] = u12, v12
            else
                u10, v10 = xx[i][0], yy[i][0]
                u11, v11 = xx[i][1], yy[i][1]
                u12, v12 = p11 * xx[i][1] + p12 * xx[i][2], p11 * yy[i][1] + p12 * yy[i][2]
                u13, v13 = p21 * xx[i][0] + p22 * xx[i][3], p21 * yy[i][0] + p22 * yy[i][3]

                xx[NN][0], yy[NN][0] = u13, v13
                xx[NN][1], yy[NN][1] = u12, v12
                xx[NN][2], yy[NN][2] = xx[i][2], yy[i][2]
                xx[NN][3], yy[NN][3] = xx[i][3], yy[i][3]
            end

            xx[i][0], yy[i][0] = u10, v10
            xx[i][1], yy[i][1] = u11, v11
            xx[i][2], yy[i][2] = u12, v12
            xx[i][3], yy[i][3] = u13, v13

            sqsplit3_sub(i)
            sqsplit3_sub(nsave)
        end
    end
end

function sqsplit4(i, nmax)
    L1 = math.sqrt((xx[i][0] - xx[i][1]) * (xx[i][0] - xx[i][1]) + (yy[i][0] - yy[i][1]) * (yy[i][0] - yy[i][1]))
    L2 = math.sqrt((xx[i][1] - xx[i][2]) * (xx[i][1] - xx[i][2]) + (yy[i][1] - yy[i][2]) * (yy[i][1] - yy[i][2]))
    L3 = math.sqrt((xx[i][2] - xx[i][3]) * (xx[i][2] - xx[i][3]) + (yy[i][2] - yy[i][3]) * (yy[i][2] - yy[i][3]))
    L4 = math.sqrt((xx[i][3] - xx[i][0]) * (xx[i][3] - xx[i][0]) + (yy[i][3] - yy[i][0]) * (yy[i][3] - yy[i][0]))

    local minL = math.min(L1, L2, L3, L4)

    if minL > spsiz then
        if obj.rand(0, 100, i, 11000 + rnd) > 50 then
            xx[NN] = {}
            yy[NN] = {}

            if obj.rand(0, 100, i, 12000 + rnd) > 50 then
                xx[NN][0] = xx[i][0]
                yy[NN][0] = yy[i][0]
                xx[NN][1] = xx[i][0]
                yy[NN][1] = yy[i][0]
                xx[NN][2] = xx[i][2]
                yy[NN][2] = yy[i][2]
                xx[NN][3] = xx[i][3]
                yy[NN][3] = yy[i][3]

                xx[i][3] = xx[i][2]
                yy[i][3] = yy[i][2]
                xx[i][2] = xx[i][1]
                yy[i][2] = yy[i][1]
                xx[i][1] = xx[i][0]
                yy[i][1] = yy[i][0]
            else
                xx[NN][0] = xx[i][0]
                yy[NN][0] = yy[i][0]
                xx[NN][1] = xx[i][0]
                yy[NN][1] = yy[i][0]
                xx[NN][2] = xx[i][1]
                yy[NN][2] = yy[i][1]
                xx[NN][3] = xx[i][3]
                yy[NN][3] = yy[i][3]

                xx[i][0] = xx[i][1]
                yy[i][0] = yy[i][1]
            end
            NN = NN + 1
        end
    end

    if i < nmax then
        sqsplit4(i + 1, nmax)
    end
end

function sqsplit0()
    local function split(str, delim)
        if string.find(str, delim) == nil then
            return { str }
        end

        local result = {}
        local pat = "(.-)" .. delim .. "()"
        local lastPos
        for part, pos in string.gfind(str, pat) do
            table.insert(result, part)
            lastPos = pos
        end
        table.insert(result, string.sub(str, lastPos))
        return result
    end

    T_line_data = {}
    local one = io.input(kudaketagarasu_file)
    while one do
        one = io.read("*l")
        if one then
            table.insert(T_line_data, one)
        end
    end
    NN = #T_line_data

    for i = 0, NN - 1 do
        local t = split(T_line_data[i + 1], ",")

        xx[i] = {}
        xx[i][0] = t[1]
        xx[i][1] = t[3]
        xx[i][2] = t[5]
        xx[i][3] = t[7]

        yy[i] = {}
        yy[i][0] = t[2]
        yy[i][1] = t[4]
        yy[i][2] = t[6]
        yy[i][3] = t[8]
    end
end

-------------------------------------------------

local of = track_shatter_amount
gsize = track_size
local nk = track_refractive_index
local vr = track_diameter_speed

w, h = obj.getpixel()
whf = w * 0.5
hhf = h * 0.5
obj.setanchor("pos", 1)
d = d * 0.5

obj.setoption("drawtarget", "tempbuffer", w, h)

if chk == 1 then
    obj.draw()
end

alpha = 1 - alpha / 100
gr[1] = gr[1] / 1000
gr[2] = gr[2] / 1000
gr[3] = gr[3] / 100000
vz = vz / 1000

spsiz = kudaketagarasu_spsiz
local sppt = kudaketagarasu_sppt or 1
local LimL = kudaketagarasu_LimL or 0.7
kudaketagarasu_zoom = kudaketagarasu_zoom or 1

frd = fvrd[1]
refp = refp * 0.01
vrd = fvrd[2] * 0.0001
L[3] = math.abs(L[3])

xx = {}
yy = {}

w2 = {}
h2 = {}
z2 = {}

--自動分割---

if sppt == 2 then
    sqsplit1() --４角形に割る
    sqsplit2() --４角形を３角形に割る
elseif sppt == 3 then
    sqsplit3() --ランダム４角形に割る
elseif sppt == 4 then
    sqsplit3() --ランダム４角形に割る
    sqsplit4(0, NN - 1) --ランダムに４角形を３角形に割る
elseif sppt == 0 then
    sqsplit0() --ファイル読込
else
    sqsplit1() --４角形に割る
end

--------
if kudaketagarasu_zoom then
    for i = 0, NN - 1 do
        xx[i][0] = xx[i][0] * kudaketagarasu_zoom
        xx[i][1] = xx[i][1] * kudaketagarasu_zoom
        xx[i][2] = xx[i][2] * kudaketagarasu_zoom
        xx[i][3] = xx[i][3] * kudaketagarasu_zoom

        yy[i][0] = yy[i][0] * kudaketagarasu_zoom
        yy[i][1] = yy[i][1] * kudaketagarasu_zoom
        yy[i][2] = yy[i][2] * kudaketagarasu_zoom
        yy[i][3] = yy[i][3] * kudaketagarasu_zoom
    end
end

for i = 0, NN - 1 do
    local avx = (xx[i][0] + xx[i][1] + xx[i][2] + xx[i][3]) * 0.25
    local avy = (yy[i][0] + yy[i][1] + yy[i][2] + yy[i][3]) * 0.25

    local vx = vr * (avx - pos[1]) / w * (1 + vrd * obj.rand(-50, 50, i, 1000 + rnd))
    local vy = vr * (avy - pos[2]) / w * (1 + vrd * obj.rand(-50, 50, i, 2000 + rnd))

    local dx = of * vx + gr[1] * of * of
    local dy = of * vy + gr[2] * of * of

    local t1 = math.rad((obj.rand(-100, 100, i, 3000 + rnd) / 100 * rotv * of))
    local t2 = math.rad((obj.rand(-100, 100, i, 4000 + rnd) / 100 * rotv * of))
    local t3 = math.rad((obj.rand(-100, 100, i, 5000 + rnd) / 100 * rotv * of))
    local zoom = vz * of + gr[3] * of * of

    local c1 = math.cos(t1)
    local s1 = math.sin(t1)
    local c2 = math.cos(t2)
    local s2 = math.sin(t2)
    local c3 = math.cos(t3)
    local s3 = math.sin(t3)

    for s = 0, 3 do
        xx[i][s] = xx[i][s] - avx
        yy[i][s] = yy[i][s] - avy

        local z = -s2 * xx[i][s]
        xx[i][s] = c2 * xx[i][s]
        xx[i][s], yy[i][s] = c1 * xx[i][s] + s1 * yy[i][s], -s1 * xx[i][s] + c1 * yy[i][s]
        yy[i][s] = c3 * yy[i][s] + s3 * z

        xx[i][s] = xx[i][s] * (1 + zoom)
        yy[i][s] = yy[i][s] * (1 + zoom)

        xx[i][s] = xx[i][s] + avx + dx
        yy[i][s] = yy[i][s] + avy + dy
    end

    w2[i] = -c1 * s2
    h2[i] = s1 * s2 * c3 - c2 * s3
    z2[i] = -c2 * c3 - s1 * s2 * s3
end

for i = 0, NN - 1 do
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

if of > 0 then
    obj.load("figure", "四角形", 0xffffff, gsize)
    obj.effect("マスク", "サイズ", gsize, "マスクの反転", 1, "ぼかし", blur)
    for i = 0, NN - 1 do
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
end

obj.load("figure", "四角形", 0xffffff, gsize)
for i = 0, NN - 1 do
    local zoom = vz * of + gr[3] * of * of

    local wi = d * w2[i] * (1 + zoom)
    local hi = d * h2[i] * (1 + zoom)

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

for i = 0, NN - 1 do
    local Nx = w2[i]
    local Ny = h2[i]
    local Nz = z2[i]

    local IB = Nx * L[1] + Ny * L[2] + Nz * L[3]

    local Rz = -(L[3] - 2 * IB * Nz) / math.sqrt(L[1] * L[1] + L[2] * L[2] + L[3] * L[3])

    if Rz > LimL then
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
            refp * ((Rz - LimL) * 0.3) / (1 - LimL) ^ 2
        )
    end
end

obj.load("tempbuffer")
obj.setoption("blend", 0)

kudaketagarasu_file = nil
kudaketagarasu_zoom = nil
kudaketagarasu_sppt = nil
kudaketagarasu_spsiz = nil
kudaketagarasu_LimL = nil
