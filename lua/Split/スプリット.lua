--label:tim2\変形\スプリット.anm
---$track:ｽﾌﾟﾘｯﾄ1
---min=0
---max=100
---step=0.1
local track_n_1 = 30

---$track:ｽﾌﾟﾘｯﾄ2
---min=0
---max=100
---step=0.1
local track_n_2 = 30

---$track:形状
---min=0
---max=300
---step=0.1
local track_shape = 100

---$track:影響範囲
---min=100
---max=1000
---step=0.1
local track_range = 100

---$check:上下を揃える
local spC = 0

---$check:穴だけ開ける
local hoC = 0

---$value:横分割数
local spN = 30

---$value:縦分割数
local spNy = 30

---$value:位置
local pos = { -100, 0, 100, 0 }

---$value:透明度境界ボカシ
local bl = 1

local sp1 = track_n_1 * 0.01
local sp2 = track_n_2 * 0.01
local fig = track_shape * 0.01
local maxP = track_range * 0.01

if fig > 1 then
    fig = 10 * fig - 9
end

spN = math.floor(math.abs(spN))
if spN < 2 then
    spN = 2
end
spNy = -math.floor(-math.abs(spNy / 2))
if spNy < 2 then
    spNy = 2
end

local w, h = obj.getpixel()
local w2, h2 = w * 0.5, h * 0.5
local split_CX, split_CY, split_W, split_ROT

if T_split_CX == nil then
    obj.setanchor("pos", 2, "line")
    local dx = pos[3] - pos[1]
    local dy = pos[4] - pos[2]
    split_CX = (pos[1] + pos[3]) / 2
    split_CY = (pos[2] + pos[4]) / 2
    split_W = math.sqrt(dx * dx + dy * dy)
    split_ROT = math.atan2(dy, dx)
else
    split_CX = T_split_CX
    split_CY = T_split_CY
    split_W = T_split_W
    split_ROT = T_split_ROT
end

--配列の宣言

local x = {}
local z = {}
local ys1 = {}
local ys2 = {}
local xs1 = {}
local xs2 = {}
local us1 = {}
local us2 = {}
local vs1 = {}
local vs2 = {}

for i = 0, spN do
    xs1[i] = {}
    xs2[i] = {}
    ys1[i] = {}
    ys2[i] = {}
    us1[i] = {}
    us2[i] = {}
    vs1[i] = {}
    vs2[i] = {}
end

--基準座標計算

if T_line_data_fl == 1 then
    local Fn = #T_line_data
    for i = 0, spN do
        x[i] = (i - spN / 2) * 2 / spN
        local t = (Fn - 1) * i / spN + 1
        local t1 = math.floor(t)
        local t0 = t1 - 1
        local t2 = t1 + 1
        local t3 = t1 + 2
        if t0 < 1 then
            t0 = 1
        end
        if t2 > Fn then
            t2 = Fn
        end
        if t3 > Fn then
            t3 = Fn
        end
        z[i] = obj.interpolation(t - t1, T_line_data[t0], T_line_data[t1], T_line_data[t2], T_line_data[t3])
    end
elseif T_line_data_fl == 2 then
    local Fn = #T_line_data
    for i = 0, spN do
        x[i] = (i - spN / 2) * 2 / spN
        local t = math.floor((Fn - 1) * i / spN + 1.5)
        if t > Fn then
            t = Fn
        end
        z[i] = T_line_data[t]
    end
else
    for i = 0, spN do
        x[i] = (i - spN / 2) * 2 / spN
        local abx = math.abs(x[i])
        z[i] = (abx - 1) * (abx - 1) * (3 * abx * abx + 2 * abx + 1)
    end
end

for i = 0, spN do
    local z1 = sp1 * (z[i] ^ fig)
    local z2 = sp2 * (z[i] ^ fig)

    if spC == 1 then
        z2 = z1
    end
    z1 = -z1

    for j = 0, spNy do
        ys1[i][j] = z1 * (1 - j / spNy) - j / spNy
        ys2[i][j] = z2 * (1 - j / spNy) + j / spNy
    end --j
end --i

--表示座標計算
local split_W2 = split_W * 0.5
local split_H2 = split_W2 * maxP
local cos = math.cos(split_ROT)
local sin = math.sin(split_ROT)

for i = 0, spN do
    x[i] = x[i] * split_W2
    for j = 0, spNy do
        ys1[i][j] = ys1[i][j] * split_H2
        ys2[i][j] = ys2[i][j] * split_H2

        --回転させて、中心ずらす
        xs1[i][j], ys1[i][j] = cos * x[i] - sin * ys1[i][j] + split_CX, sin * x[i] + cos * ys1[i][j] + split_CY
        xs2[i][j], ys2[i][j] = cos * x[i] - sin * ys2[i][j] + split_CX, sin * x[i] + cos * ys2[i][j] + split_CY
    end --j
end --i

if hoC == 0 then
    for j = 0, spNy do
        local v = split_H2 * j / spNy
        for i = 0, spN do
            us1[i][j], vs1[i][j] = cos * x[i] + sin * v + split_CX + w2, sin * x[i] - cos * v + split_CY + h2
            us2[i][j], vs2[i][j] = cos * x[i] - sin * v + split_CX + w2, sin * x[i] + cos * v + split_CY + h2
        end
    end
end

--表示
--オリジナルの上に描画、穴あけは、スプリットを回転させた場合のホール対策

obj.setoption("drawtarget", "tempbuffer", w, h)
obj.draw()

obj.setoption("antialias", 0)
if hoC == 0 then
    for j = 0, spNy - 1 do
        for i = 0, spN - 1 do
            local x0, y0 = xs1[i][j], ys1[i][j]
            local x1, y1 = xs1[i + 1][j], ys1[i + 1][j]
            local x2, y2 = xs1[i + 1][j + 1], ys1[i + 1][j + 1]
            local x3, y3 = xs1[i][j + 1], ys1[i][j + 1]
            local u0, v0 = us1[i][j], vs1[i][j]
            local u1, v1 = us1[i + 1][j], vs1[i + 1][j]
            local u2, v2 = us1[i + 1][j + 1], vs1[i + 1][j + 1]
            local u3, v3 = us1[i][j + 1], vs1[i][j + 1]
            obj.drawpoly(x0, y0, 0, x1, y1, 0, x2, y2, 0, x3, y3, 0, u0, v0, u1, v1, u2, v2, u3, v3)

            local x0, y0 = xs2[i][j], ys2[i][j]
            local x1, y1 = xs2[i + 1][j], ys2[i + 1][j]
            local x2, y2 = xs2[i + 1][j + 1], ys2[i + 1][j + 1]
            local x3, y3 = xs2[i][j + 1], ys2[i][j + 1]
            local u0, v0 = us2[i][j], vs2[i][j]
            local u1, v1 = us2[i + 1][j], vs2[i + 1][j]
            local u2, v2 = us2[i + 1][j + 1], vs2[i + 1][j + 1]
            local u3, v3 = us2[i][j + 1], vs2[i][j + 1]
            obj.drawpoly(x0, y0, 0, x1, y1, 0, x2, y2, 0, x3, y3, 0, u0, v0, u1, v1, u2, v2, u3, v3)
        end --i
    end --j
end

--穴あけ
obj.load("figure", "四角形", 0xffffff, math.max(w, h))
obj.setoption("antialias", 1)
obj.setoption("blend", "alpha_sub")
for i = 0, spN - 1 do
    local x0, y0 = xs1[i][0], ys1[i][0]
    local x1, y1 = xs1[i + 1][0], ys1[i + 1][0]
    local x2, y2 = xs2[i + 1][0], ys2[i + 1][0]
    local x3, y3 = xs2[i][0], ys2[i][0]
    obj.drawpoly(x0, y0, 0, x1, y1, 0, x2, y2, 0, x3, y3, 0)
end

obj.load("tempbuffer")
obj.effect("境界ぼかし", "範囲", bl, "透明度の境界をぼかす", 1)
--obj.setoption("blend",0)
T_split_CX = nil
T_split_CY = nil
T_split_W = nil
T_split_ROT = nil
T_line_data_fl = nil
