--label:tim2\変形
---$track:角数
---min=3
---max=100
---step=1
local track_sides = 6

---$track:高さ
---min=0
---max=20000
---step=0.1
local track_height = 200

---$track:上半径
---min=0
---max=10000
---step=0.1
local track_upper_radius = 100

---$track:下半径
---min=0
---max=10000
---step=0.1
local track_lower_radius = 300

---$check:蓋
local Futa = 0

---$check:中心基準
local cchk = 1

---$check:両面化
local rev = 0

---$check:星型化
local star = 0

---$value:くびれ率
local cst = 50

---$value:角を整数化[0/1]
local int = 0

---$value:ｱﾝﾁｴｲﾘｱｽ[0/1]
local ant = 0

local zoom = obj.getvalue("zoom") * 0.01
local N = track_sides
local H = track_height * zoom
local R1 = track_upper_radius * zoom
local R2 = track_lower_radius * zoom
local obh = obj.h
local iso = Futa and math.pi * 0.5 or 0
ant = ant or 1
int = int or 0
Futa = Futa or 0
cchk = cchk or 1
rev = rev or 0
star = star or 0
cst = cst or 50
local uX = {}
local uZ = {}
local dX = {}
local dZ = {}
obj.setoption("antialias", ant)
if int == 1 then
    N = math.floor(N)
end
if star == 0 then
    for i = 0, N do
        local rad = 2 * i * math.pi / N + iso
        local cos = math.cos(rad)
        local sin = math.sin(rad)
        uX[i] = R1 * cos
        uZ[i] = R1 * sin
        dX[i] = R2 * cos
        dZ[i] = R2 * sin
    end
else
    cst = 1 - cst * 0.01
    N = 2 * N
    for i = 0, N, 2 do
        local rad = 2 * i * math.pi / N + iso
        local cos = math.cos(rad)
        local sin = math.sin(rad)
        uX[i] = R1 * cos
        uZ[i] = R1 * sin
        dX[i] = R2 * cos
        dZ[i] = R2 * sin
    end
    R1 = R1 * cst
    R2 = R2 * cst
    for i = 1, N, 2 do
        local rad = 2 * i * math.pi / N + iso
        local cos = math.cos(rad)
        local sin = math.sin(rad)
        uX[i] = R1 * cos
        uZ[i] = R1 * sin
        dX[i] = R2 * cos
        dZ[i] = R2 * sin
    end
end

local U = {}
for i = 0, N do
    U[i] = i / N * obj.w
end

local Y1, Y2
if cchk == 1 and rev == 0 then
    Y1 = -H * 0.5
    Y2 = H * 0.5
else
    Y1 = -H
    Y2 = 0
end

for i = 0, N - 1 do
    obj.drawpoly(
        uX[i],
        Y1,
        uZ[i],
        uX[i + 1],
        Y1,
        uZ[i + 1],
        dX[i + 1],
        Y2,
        dZ[i + 1],
        dX[i],
        Y2,
        dZ[i],
        U[i],
        0,
        U[i + 1],
        0,
        U[i + 1],
        obh,
        U[i],
        obh
    )
end

if rev == 0 then
    if Futa == 1 then
        for i = 0, N - 1 do
            obj.drawpoly(
                0,
                Y1,
                0,
                0,
                Y1,
                0,
                uX[i + 1],
                Y1,
                uZ[i + 1],
                uX[i],
                Y1,
                uZ[i],
                U[i],
                0,
                U[i + 1],
                0,
                U[i + 1],
                0,
                U[i],
                0
            )
            obj.drawpoly(
                0,
                Y2,
                0,
                0,
                Y2,
                0,
                dX[i],
                Y2,
                dZ[i],
                dX[i + 1],
                Y2,
                dZ[i + 1],
                U[i + 1],
                obh,
                U[i],
                obh,
                U[i],
                obh,
                U[i + 1],
                obh
            )
        end
    end
else
    for i = 0, N - 1 do
        obj.drawpoly(
            uX[i + 1],
            -Y1,
            uZ[i + 1],
            uX[i],
            -Y1,
            uZ[i],
            dX[i],
            0,
            dZ[i],
            dX[i + 1],
            0,
            dZ[i + 1],
            U[i + 1],
            0,
            U[i],
            0,
            U[i],
            obh,
            U[i + 1],
            obh
        )
    end

    if Futa == 1 then
        for i = 0, N - 1 do
            obj.drawpoly(
                0,
                Y1,
                0,
                0,
                Y1,
                0,
                uX[i + 1],
                Y1,
                uZ[i + 1],
                uX[i],
                Y1,
                uZ[i],
                U[i],
                0,
                U[i + 1],
                0,
                U[i + 1],
                0,
                U[i],
                0
            )
            obj.drawpoly(
                0,
                -Y1,
                0,
                0,
                -Y1,
                0,
                uX[i],
                -Y1,
                uZ[i],
                uX[i + 1],
                -Y1,
                uZ[i + 1],
                U[i + 1],
                0,
                U[i],
                0,
                U[i],
                0,
                U[i + 1],
                0
            )
        end
    end
end
