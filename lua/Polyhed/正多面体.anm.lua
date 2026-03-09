--label:tim2\変形
--group:基本,true

---$track:サイズ
---min=0
---max=5000
---step=0.1
local track_size = 200

---$select:タイプ
---正四面体=1
---立方体=2
---正八面体=3
---正二十面体=4
---正十二面体=5
local track_type = 1

---$track:枠％
---min=0
---max=100
---step=0.1
local track_percent = 0

---$color:枠色
local col = 0xffffff

---$check:縮尺補正
local aspchk = false

---$check:90度回転
local rotchk = false

obj.setoption("blend", 0) --念のため

local create_DP = function(c72, c36, s72, s36, Stype)
    local sc1 = (1 - c72) / (1 + c36)
    local sc2 = 1 / 2 + 1 / (2 + 4 * c72)
    local sc3 = 1 / 2 - 1 / (2 + 4 * c72)
    local ww, hh = obj.w, obj.h

    if Stype == 2 then
        return function(PT, p1, p2, p3, p4)
            obj.drawpoly(
                PT[p1][1],
                PT[p1][2],
                PT[p1][3],
                PT[p2][1],
                PT[p2][2],
                PT[p2][3],
                PT[p3][1],
                PT[p3][2],
                PT[p3][3],
                PT[p4][1],
                PT[p4][2],
                PT[p4][3]
            )
        end
    elseif Stype == 4 then
        return function(PT, p1, p2, p3, p4, p5)
            obj.drawpoly(
                PT[p1][1],
                PT[p1][2],
                PT[p1][3],
                PT[p1][1],
                PT[p1][2],
                PT[p1][3],
                PT[p2][1],
                PT[p2][2],
                PT[p2][3],
                PT[p5][1],
                PT[p5][2],
                PT[p5][3],
                ww / 2,
                0,
                ww / 2,
                0,
                ww,
                sc1 * hh,
                0,
                sc1 * hh
            )

            obj.drawpoly(
                PT[p2][1],
                PT[p2][2],
                PT[p2][3],
                PT[p3][1],
                PT[p3][2],
                PT[p3][3],
                PT[p4][1],
                PT[p4][2],
                PT[p4][3],
                PT[p5][1],
                PT[p5][2],
                PT[p5][3],
                ww,
                sc1 * hh,
                ww * sc2,
                hh,
                ww * sc3,
                hh,
                0,
                sc1 * hh
            )
        end
    else
        return function(PT, p1, p2, p3)
            obj.drawpoly(
                PT[p1][1],
                PT[p1][2],
                PT[p1][3],
                PT[p1][1],
                PT[p1][2],
                PT[p1][3],
                PT[p2][1],
                PT[p2][2],
                PT[p2][3],
                PT[p3][1],
                PT[p3][2],
                PT[p3][3],
                ww / 2,
                0,
                ww / 2,
                0,
                ww,
                hh,
                0,
                hh
            )
        end
    end
end

local size = track_size --内接球の半径
local Stype = track_type
local N = { 4, 8, 6, 20, 12 }
local c72, c36, s72, s36 = 0, 0, 0, 0
local PT = {}
local waku = track_percent * 0.01

--最初から規格化すれば良いのだけれど・・めんどくさいので＞＜
if Stype == 1 then
    PT = { { 0, -math.sqrt(8 / 3), -1 / math.sqrt(3) }, { 0, 0, -math.sqrt(3) }, { -1, 0, 0 }, { 1, 0, 0 } }
elseif Stype == 2 then
    PT = {
        { 1, -1, -1 },
        { -1, -1, -1 },
        { -1, -1, 1 },
        { 1, -1, 1 },
        { 1, 1, -1 },
        { -1, 1, -1 },
        { -1, 1, 1 },
        {
            1,
            1,
            1,
        },
    }
elseif Stype == 3 then
    PT = { { 0, -math.sqrt(2), 0 }, { 1, 0, -1 }, { -1, 0, -1 }, { -1, 0, 1 }, { 1, 0, 1 }, { 0, math.sqrt(2), 0 } }
elseif Stype == 4 then
    c72 = math.cos(2 * math.pi / 5)
    c36 = math.cos(math.pi / 5)
    s72 = math.sin(2 * math.pi / 5)
    s36 = math.sin(math.pi / 5)
    a = (1 + math.sqrt(5)) / 2
    PT = {
        { 0, 1, 1 },
        { s72, c72, 1 },
        { s36, -c36, 1 },
        { -s36, -c36, 1 },
        { -s72, c72, 1 },
        { 0, a, 0 },
        { a * s72, a * c72, 0 },
        { a * s36, -a * c36, 0 },
        { -a * s36, -a * c36, 0 },
        { -a * s72, a * c72, 0 },
        { a * s36, a * c36, 1 - a },
        { a * s72, -a * c72, 1 - a },
        { 0, -a, 1 - a },
        { -a * s72, -a * c72, 1 - a },
        { -a * s36, a * c36, 1 - a },
        { 0, -1, -a },
        { -s72, -c72, -a },
        { -s36, c36, -a },
        { s36, c36, -a },
        { s72, -c72, -a },
    }
else --(Stype==5)
    local a = 1 / math.sqrt(5)
    local b = (1 - a) / 2
    local c = (1 + a) / 2
    local d = math.sqrt(b)
    local e = math.sqrt(c)
    PT = {
        { 0, -1, 0 },
        { 0, -a, 2 * a },
        { e, -a, b },
        { d, -a, -c },
        { -d, -a, -c },
        { -e, -a, b },
        { d, a, c },
        { e, a, -b },
        { 0, a, -2 * a },
        { -e, a, -b },
        { -d, a, c },
        { 0, 1, 0 },
    }
end

--縦横比補正
if aspchk then
    local a, b
    local w, h = obj.getpixel()
    if Stype == 2 then
        a = 1
    elseif Stype == 4 then
        a = 2 * s72 / (1 + c36)
    else
        a = 2 / math.sqrt(3)
    end
    if w > h * a then
        a, b = h * a, h
    else
        a, b = w, w / a
    end
    obj.setoption("drawtarget", "tempbuffer", a, b)
    obj.draw()
    obj.load("tempbuffer")
    obj.setoption("drawtarget", "framebuffer")
end

--枠
if waku > 0 then
    local w, h = obj.getpixel()
    obj.setoption("drawtarget", "tempbuffer", w, h)
    obj.draw()
    obj.load("figure", "四角形", col, math.max(w, h))

    local w2 = w / 2
    local h2 = h / 2

    if Stype == 2 then
        local wf = w2 - w2 * waku
        local hf = h2 - h2 * waku
        obj.drawpoly(-w2, -h2, 0, w2, -h2, 0, w2, -hf, 0, -w2, -hf, 0)
        obj.drawpoly(-w2, hf, 0, w2, hf, 0, w2, h2, 0, -w2, h2, 0)
        obj.drawpoly(-w2, -h2, 0, -wf, -h2, 0, -wf, h2, 0, -w2, h2, 0)
        obj.drawpoly(wf, -h2, 0, w2, -h2, 0, w2, h2, 0, wf, h2, 0)
    elseif Stype == 4 then
        local hg = h / (1 + c36)
        local a = hg * c36 * waku
        local hf = h2 - a
        obj.drawpoly(-w2, hf, 0, w2, hf, 0, w2, h2, 0, -w2, h2, 0)
        local b = hg * (1 - c72)
        local hm = -h2 + b
        local c = w * (1 + c36) / (2 * s72 * h)
        local dw = c * a * b / math.sqrt(w2 * w2 + b * b)
        local dh = a * w2 / math.sqrt(w2 * w2 + b * b)
        obj.drawpoly(-dw, -h2 + dh, 0, dw, -h2 - dh, 0, w2 + dw, hm - dh, 0, w2 - dw, hm + dh, 0)
        obj.drawpoly(-dw, -h2 - dh, 0, dw, -h2 + dh, 0, -w2 + dw, hm + dh, 0, -w2 - dw, hm - dh, 0)
        local wm = c * s36 * hg
        local d = hg * (s72 - s36)
        local e = h - b
        local dw = c * a * e / math.sqrt(d * d + e * e)
        local dh = a * d / math.sqrt(d * d + e * e)
        obj.drawpoly(w2 - dw, hm - dh, 0, w2 + dw, hm + dh, 0, wm + dw, h2 + dh, 0, wm - dw, h2 - dh, 0)
        obj.drawpoly(-w2 - dw, hm + dh, 0, -w2 + dw, hm - dh, 0, -wm + dw, h2 - dh, 0, -wm - dw, h2 + dh, 0)
    else
        local hf = h2 - h / 3 * waku
        local a = w * h / (3 * h * h + 0.75 * w * w) * waku
        local ah = a * h
        local aw = a * w2
        local hp = h2 + aw
        local hm = h2 - aw
        obj.drawpoly(-w2, hf, 0, w2, hf, 0, w2, h2, 0, -w2, h2, 0)
        obj.drawpoly(-ah, -hm, 0, ah, -hp, 0, w2 + ah, hm, 0, w2 - ah, hp, 0)
        obj.drawpoly(-ah, -hp, 0, ah, -hm, 0, -w2 + ah, hp, 0, -w2 - ah, hm, 0)
    end
    obj.load("tempbuffer")
    obj.setoption("drawtarget", "framebuffer")
end

--重心移動
if Stype == 1 or Stype == 4 then
    local s = { 0, 0, 0 }
    for j = 1, 3 do
        for i = 1, N[Stype] do
            s[j] = s[j] + PT[i][j]
        end
        s[j] = s[j] / N[Stype]
    end
    for i = 1, N[Stype] do
        for j = 1, 3 do
            PT[i][j] = PT[i][j] - s[j]
        end
    end
end

--サイズ変更
for i = 1, N[Stype] do
    local R = 0
    for j = 1, 3 do
        R = R + PT[i][j] * PT[i][j]
    end
    R = math.sqrt(R)
    for j = 1, 3 do
        PT[i][j] = size * PT[i][j] / R
    end
end

--回転
if Stype == 4 then
    rotchk = not rotchk
end
if rotchk then
    for i = 1, N[Stype] do
        PT[i][2], PT[i][3] = -PT[i][3], PT[i][2]
    end
end

local drpoly = create_DP(c72, c36, s72, s36, Stype)

--描画
if Stype == 1 then
    drpoly(PT, 1, 2, 3)
    drpoly(PT, 1, 3, 4)
    drpoly(PT, 1, 4, 2)
    drpoly(PT, 2, 4, 3)
elseif Stype == 2 then
    drpoly(PT, 3, 4, 1, 2)
    drpoly(PT, 2, 1, 5, 6)
    drpoly(PT, 3, 2, 6, 7)
    drpoly(PT, 4, 3, 7, 8)
    drpoly(PT, 1, 4, 8, 5)
    drpoly(PT, 6, 5, 8, 7)
elseif Stype == 3 then
    drpoly(PT, 1, 2, 3)
    drpoly(PT, 1, 3, 4)
    drpoly(PT, 1, 4, 5)
    drpoly(PT, 1, 5, 2)
    drpoly(PT, 6, 3, 2)
    drpoly(PT, 6, 4, 3)
    drpoly(PT, 6, 5, 4)
    drpoly(PT, 6, 2, 5)
elseif Stype == 4 then
    drpoly(PT, 1, 2, 3, 4, 5)
    drpoly(PT, 11, 7, 2, 1, 6)
    drpoly(PT, 12, 8, 3, 2, 7)
    drpoly(PT, 13, 9, 4, 3, 8)
    drpoly(PT, 14, 10, 5, 4, 9)
    drpoly(PT, 15, 6, 1, 5, 10)
    drpoly(PT, 6, 15, 18, 19, 11)
    drpoly(PT, 10, 14, 17, 18, 15)
    drpoly(PT, 9, 13, 16, 17, 14)
    drpoly(PT, 8, 12, 20, 16, 13)
    drpoly(PT, 7, 11, 19, 20, 12)
    drpoly(PT, 16, 20, 19, 18, 17)
else --(Stype==5)
    drpoly(PT, 1, 2, 3)
    drpoly(PT, 1, 3, 4)
    drpoly(PT, 1, 4, 5)
    drpoly(PT, 1, 5, 6)
    drpoly(PT, 1, 6, 2)
    drpoly(PT, 2, 11, 7)
    drpoly(PT, 3, 7, 8)
    drpoly(PT, 4, 8, 9)
    drpoly(PT, 5, 9, 10)
    drpoly(PT, 6, 10, 11)
    drpoly(PT, 7, 3, 2)
    drpoly(PT, 8, 4, 3)
    drpoly(PT, 9, 5, 4)
    drpoly(PT, 10, 6, 5)
    drpoly(PT, 11, 2, 6)
    drpoly(PT, 12, 7, 11)
    drpoly(PT, 12, 8, 7)
    drpoly(PT, 12, 9, 8)
    drpoly(PT, 12, 10, 9)
    drpoly(PT, 12, 11, 10)
end