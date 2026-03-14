--label:tim2\変形\@任意多角形カット
---$track:頂点X
---min=-50000
---max=50000
---step=0.1
local track_vertex_x = 0

---$track:頂点Y
---min=-50000
---max=50000
---step=0.1
local track_vertex_y = 0

--trackgroup@track_vertex_x,track_vertex_y

---$track:頂点数
---min=0
---max=16
---step=1
local track_vertex_count = 4

---$track:厚み
---min=0
---max=1000
---step=0.1
local track_thickness = 0

---$color:側面色
local wcol = nil

---$value:領域
local are = { -100, -100, 100, -100, 100, 100, -100, 100 }

-- ---$value:アンチエイリアス
-- local ANT = 0

while #are / 2 < track_vertex_count do
    are[#are + 1] = 0
    are[#are + 1] = 0
end

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
    if TC == 0 then
        obj.drawpoly(
            p1.x,
            p1.y,
            TC,
            p1.x,
            p1.y,
            TC,
            p2.x,
            p2.y,
            TC,
            p3.x,
            p3.y,
            TC,
            p1.x + w2,
            p1.y + h2,
            p1.x + w2,
            p1.y + h2,
            p2.x + w2,
            p2.y + h2,
            p3.x + w2,
            p3.y + h2
        )
    else
        p1x, p2x, p3x = p1.x * zoom, p2.x * zoom, p3.x * zoom
        p1y, p2y, p3y = p1.y * zoom, p2.y * zoom, p3.y * zoom
        obj.drawpoly(
            p1x,
            p1y,
            TC,
            p1x,
            p1y,
            TC,
            p2x,
            p2y,
            TC,
            p3x,
            p3y,
            TC,
            p1x + w2,
            p1y + h2,
            p1x + w2,
            p1y + h2,
            p2x + w2,
            p2y + h2,
            p3x + w2,
            p3y + h2
        )
        obj.drawpoly(
            p1x,
            p1y,
            -TC,
            p1x,
            p1y,
            -TC,
            p2x,
            p2y,
            -TC,
            p3x,
            p3y,
            -TC,
            p1x + w2,
            p1y + h2,
            p1x + w2,
            p1y + h2,
            p2x + w2,
            p2y + h2,
            p3x + w2,
            p3y + h2
        )
    end
end

TC = track_thickness / 2
N = track_vertex_count

zoom = obj.getvalue("zoom") * 0.01
w, h = obj.getpixel()
if TC == 0 then
    w2 = w / 2
    h2 = h / 2
else
    w2 = obj.w / 2
    h2 = obj.h / 2
end

if TC == 0 then
    obj.setoption("drawtarget", "tempbuffer", w, h)
    obj.setoption("blend", "alpha_add")
end

-- obj.setoption("antialias", ANT)
pos = {}
pos2 = {}

if N == 0 then
    obj.setanchor("track_vertex_x,track_vertex_y", 0, "loop")
    N = obj.getoption("section_num") + 1
    for i = 1, N - 1 do
        pos[i] = {}
        pos[i].x = obj.getvalue("track.track_vertex_x", 0, i - 1)
        pos[i].y = obj.getvalue("track.track_vertex_y", 0, i - 1)
    end
    pos[N] = {}
    pos[N].x = obj.getvalue(0, 0, -1)
    pos[N].y = obj.getvalue(1, 0, -1)
else
    obj.setanchor("are", N, "loop")
    for i = 1, N do
        pos[i] = {}
        pos[i].x = are[2 * i - 1]
        pos[i].y = are[2 * i]
    end
end

N2 = N

pos[0] = {}
pos[0] = pos[N]
pos[N + 1] = {}
pos[N + 1] = pos[1]

for i = 0, N + 1 do
    pos2[i] = { x = pos[i].x * zoom, y = pos[i].y * zoom }
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

if TC == 0 then
    obj.load("tempbuffer")
end

if TC ~= 0 then
    obj.setoption("drawtarget", "framebuffer")
    if wcol ~= "" and wcol ~= nil then
        obj.load("figure", "四角形", wcol, 100)
        -- obj.setoption("antialias", ANT)
    end
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
            -TC,
            pos2[i].x + w2,
            pos2[i].y + h2,
            pos2[i].x + w2,
            pos2[i].y + h2,
            pos2[i + 1].x + w2,
            pos2[i + 1].y + h2,
            pos2[i + 1].x + w2,
            pos2[i + 1].y + h2
        )
    end
end
