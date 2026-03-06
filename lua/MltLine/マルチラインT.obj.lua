--label:tim2
---$track:ｱﾝｶｰ数
---min=1
---max=16
---step=1
local track_count = 4

---$track:線幅
---min=0
---max=1000
---step=0.1
local track_line_width = 20

---$track:矢尻幅％
---min=0
---max=1000
---step=0.1
local track_width_percent = 200

---$track:矢尻長％
---min=0
---max=1000
---step=0.1
local track_percent = 240

---$color:線色
local line_col = 0xff0000

---$value:表示指示
local po = "10"

---$check:角丸
local roc = 0

---$check:結合
local alc = 0

---$value:Xスナップ
local xsp = 0

---$value:Yスナップ
local ysp = 0

---$value:座標
local anc = { -150, -100, 150, -100, -150, 100, 150, 100 }

---$check:矢印位置反転
local check0 = false

--ver1.1

local line_col = line_col or 0xff0000
local po = po or 1
local roc = roc
local alc = alc
local xsp = math.abs(xsp or 0)
local ysp = math.abs(ysp or 0)

local acN = track_count

local Lw = track_line_width
local Aw = Lw * track_width_percent * 0.01
local Ah = Lw * track_percent * 0.01

obj.setanchor("anc", acN, "line")

local DataL = string.len(po)
local mset = {}
for i = 1, DataL do
    mset[i] = tonumber(string.sub(po, i, i))
end

local X = {}
local Y = {}

for i = 1, acN do
    X[i] = anc[2 * i - 1]
    Y[i] = anc[2 * i]

    if xsp > 0 then
        X[i] = X[i] + xsp * 0.5
        local N = math.floor(X[i] / xsp)
        X[i] = N * xsp
    end
    if ysp > 0 then
        Y[i] = Y[i] + ysp * 0.5
        local N = math.floor(Y[i] / ysp)
        Y[i] = N * ysp
    end

    j = ((i - 1) % DataL) + 1
    mset[i] = mset[j]
end

if check0 then
    for i = 1, acN / 2 do
        X[i], X[acN + 1 - i] = X[acN + 1 - i], X[i]
        Y[i], Y[acN + 1 - i] = Y[acN + 1 - i], Y[i]
        mset[i], mset[acN + 0 - i] = mset[acN + 0 - i], mset[i]
    end
end

local max_x = math.max(unpack(X))
local min_x = math.min(unpack(X))
local max_y = math.max(unpack(Y))
local min_y = math.min(unpack(Y))

local cx = (max_x + min_x) * 0.5
local cy = (max_y + min_y) * 0.5

for i = 1, acN do
    X[i] = X[i] - cx
    Y[i] = Y[i] - cy
end

arke = {}
if alc == 1 then
    for i = 1, acN - 2 do
        if mset[i + 1] == 1 then
            arke[i] = 0
        else
            arke[i] = 1
        end
    end

    arke[acN - 1] = 1
else
    for i = 1, acN - 1 do
        arke[i] = 1
    end
end

local sadd = math.max(Aw, Lw)
obj.setoption("drawtarget", "tempbuffer", max_x - min_x + sadd, max_y - min_y + sadd)
obj.setoption("blend", "alpha_add")
obj.load("figure", "四角形", line_col, 1)

for i = 1, acN - 1 do
    if mset[i] == 1 then
        local Ah = Ah * arke[i] --Ahを局所定義

        local AX = X[i + 1] - X[i]
        local AY = Y[i + 1] - Y[i]
        local LL = math.sqrt(AX * AX + AY * AY)
        local cc = Lw / LL * 0.5
        local BX = AY * cc
        local BY = -AX * cc

        local x1, y1 = X[i] - BX, Y[i] - BY
        local x2, y2 = X[i] + BX, Y[i] + BY
        local x = X[i] + AX * (LL - Ah) / LL
        local y = Y[i] + AY * (LL - Ah) / LL
        local x3, y3 = x + BX, y + BY
        local x4, y4 = x - BX, y - BY
        obj.drawpoly(x1, y1, 0, x2, y2, 0, x3, y3, 0, x4, y4, 0)

        if Ah ~= 0 then
            cc = Aw / LL * 0.5
            BX = AY * cc
            BY = -AX * cc
            x1, y1 = x + BX, y + BY
            x2, y2 = x - BX, y - BY
            obj.drawpoly(X[i + 1], Y[i + 1], 0, X[i + 1], Y[i + 1], 0, x1, y1, 0, x2, y2, 0)
        end
    end
end

if roc == 1 then
    obj.load("figure", "円", line_col, 2 * Lw)
    if mset[1] == 1 then
        obj.draw(X[1], Y[1], 0, 0.5)
    end
    for i = 2, acN - 1 do
        if mset[i] == 1 or (mset[i] == 0 and mset[i - 1] == 1 and Ah == 0) then
            obj.draw(X[i], Y[i], 0, 0.5)
        end
    end
    if mset[acN - 1] == 1 and Ah == 0 then
        obj.draw(X[acN], Y[acN], 0, 0.5)
    end
end

obj.load("tempbuffer")
obj.cx = obj.cx - cx
obj.cy = obj.cy - cy
