--label:tim2\任意多角形.obj\凸多角形
--track0:ｶﾞｲﾄﾞ表示,0,1,0,1
--track1:ｶﾞｲﾄﾞｻｲｽﾞ,0,1000,50
--track2:厚み,0,1000,0
--value@col:色/col,0xffffff
--value@colG:ガイド色/col,0xff0000
--value@fig:図形/fig,"円"

size = obj.track1
TC = obj.track2 / 2
N = obj.getoption("section_num") + 1
N2 = N
pos = {}
for i = 1, N - 1 do
    pos[i] = {}
    pos[i].x = obj.getvalue("x", 0, i - 1)
    pos[i].y = obj.getvalue("y", 0, i - 1)
end
pos[N] = {}
pos[N].x = obj.getvalue("x", 0, -1)
pos[N].y = obj.getvalue("y", 0, -1)
pos[0] = {}
pos[0] = pos[N]
pos[N + 1] = {}
pos[N + 1] = pos[1]
mode = math.floor(obj.track0)

pos2 = {}
for i = 0, N + 1 do
    pos2[i] = {}
    pos2[i].x = pos[i].x
    pos2[i].y = pos[i].y
end

obj.load("figure", fig, colG, size)

if mode == 1 then
    obj.load("figure", fig, colG, size)
    obj.effect("縁取り")
    for i = 1, N do
        pos[i].x = pos[i].x - obj.getvalue("x")
        pos[i].y = pos[i].y - obj.getvalue("y")
        obj.draw(pos[i].x, pos[i].y)
    end
else
    maxX = math.abs(pos[1].x)
    maxY = math.abs(pos[1].y)
    for i = 2, N do
        maxX = math.max(math.abs(pos[i].x), maxX)
        maxY = math.max(math.abs(pos[i].y), maxY)
    end

    obj.load("figure", "四角形", col, 2 * math.max(maxX, maxY) + 10)

    for i = 1, N do
        st = math.atan2(pos[i + 1].y - pos[i].y, pos[i + 1].x - pos[i].x) * 180 / math.pi + 180
        if math.abs(pos[i + 1].x - pos[i].x) > math.abs(pos[i + 1].y - pos[i].y) then
            cx = 0
            cy = -pos[i].x * (pos[i + 1].y - pos[i].y) / (pos[i + 1].x - pos[i].x) + pos[i].y
        else
            cx = -pos[i].y * (pos[i + 1].x - pos[i].x) / (pos[i + 1].y - pos[i].y) + pos[i].x
            cy = 0
        end
        obj.effect("斜めクリッピング", "角度", st, "中心X", cx, "中心Y", cy)
    end
    obj.ox = -obj.getvalue("x")
    obj.oy = -obj.getvalue("y")

    if TC ~= 0 then
        obj.setoption("dst", "frm")
        obj.oz = TC
        obj.draw()
        obj.oz = -TC
        obj.draw()
        obj.load("figure", "四角形", col, 500)
        for i = 0, N2 + 1 do
            pos2[i].x = pos2[i].x - obj.getvalue("x")
            pos2[i].y = pos2[i].y - obj.getvalue("y")
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
                -TC
            )
        end
    end
end
