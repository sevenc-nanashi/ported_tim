--label:tim2\カスタムオブジェクト\@任意多角形
---$track:厚み
---min=0
---max=1000
---step=0.1
local track_thickness = 0

---$color:色
local col = 0xffffff

function muki(ax, ay, bx, by)
    if ax * by - ay * bx > 0 then
        return 1
    else
        return -1
    end
end

function intersectM(p1, p2, p3, p4)
    return ((p1.x - p2.x) * (p3.y - p1.y) + (p1.y - p2.y) * (p1.x - p3.x))
        * ((p1.x - p2.x) * (p4.y - p1.y) + (p1.y - p2.y) * (p1.x - p4.x))
end

function PosIncludeTriEx(tp1, tp2, tp3, xp)
    if (tp1.x - tp3.x) * (tp1.y - tp2.y) == (tp1.x - tp2.x) * (tp1.y - tp3.y) then
        return 0
    elseif
        (intersectM(tp1, tp2, xp, tp3) < 0)
        or (intersectM(tp1, tp3, xp, tp2) < 0)
        or (intersectM(tp2, tp3, xp, tp1) < 0)
    then
        return 0
    else
        return 1
    end
end

function mydp(p1, p2, p3)
    obj.drawpoly(p1.x, p1.y, 0, p1.x, p1.y, 0, p2.x, p2.y, 0, p3.x, p3.y, 0)
end

TC = track_thickness / 2

if NTBS_N < 3 then
    return
end

N = NTBS_N
pos = {}
N2 = N
pos2 = {}
for i = 0, N + 1 do
    pos[i] = {}
    pos[i].x = NTBS_pos[i].x
    pos[i].y = NTBS_pos[i].y
    pos2[i] = {}
    pos2[i].x = pos[i].x
    pos2[i].y = pos[i].y
end

maxX = math.abs(pos[1].x)
maxY = math.abs(pos[1].y)
rr = maxX * maxX + maxY * maxY
maxi = 1
for i = 2, N do
    maxX = math.max(math.abs(pos[i].x), maxX)
    maxY = math.max(math.abs(pos[i].y), maxY)
    if rr < pos[i].x * pos[i].x + pos[i].y * pos[i].y then
        rr = pos[i].x * pos[i].x + pos[i].y * pos[i].y
        maxi = i
    end
end

obj.load("figure", "四角形", col, 2 * math.max(maxX, maxY))

obj.setoption("dst", "tmp", 2 * maxX, 2 * maxY)
obj.setoption("blend", "alpha_add")

hmuki = muki(
    pos[maxi].x - pos[maxi - 1].x,
    pos[maxi].y - pos[maxi - 1].y,
    pos[maxi + 1].x - pos[maxi].x,
    pos[maxi + 1].y - pos[maxi].y
)
repeat
    i = 0
    repeat
        han = 0
        i = i + 1
        imuki = muki(pos[i].x - pos[i - 1].x, pos[i].y - pos[i - 1].y, pos[i + 1].x - pos[i].x, pos[i + 1].y - pos[i].y)
        if imuki == hmuki then
            plot_han = 0
            for j = 1, N do
                if j < i - 1 or j > i + 1 then
                    plot_han = PosIncludeTriEx(pos[i - 1], pos[i], pos[i + 1], pos[j])
                end --if
                if plot_han == 1 then
                    break
                end
            end --j
            if plot_han == 0 then
                han = 1
            end
        end
    until han == 1
    mydp(pos[i - 1], pos[i], pos[i + 1])
    for j = i + 1, N do
        pos[j - 1] = pos[j]
    end
    N = N - 1
    pos[0] = pos[N]
    pos[N + 1] = pos[1]
until N < 4
mydp(pos[1], pos[2], pos[3])
obj.load("tempbuffer")

if TC ~= 0 then
    obj.setoption("dst", "frm")
    obj.oz = TC
    obj.draw()
    obj.oz = -TC
    obj.draw()

    obj.load("figure", "四角形", col, 500)
    for i = 1, N2 do
        obj.drawpoly(
            pos2[i].x,
            pos2[i].y,
            -TC,
            pos2[i].x,
            pos2[i].y,
            TC,
            pos2[i + 1].x,
            pos2[i + 1].y,
            TC,
            pos2[i + 1].x,
            pos2[i + 1].y,
            -TC
        )
    end
end
