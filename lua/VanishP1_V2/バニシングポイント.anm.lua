--label:tim2
---$track:移動X
---min=-50000
---max=50000
---step=0.1
local rename_me_track0 = 0

---$track:移動Y
---min=-50000
---max=50000
---step=0.1
local rename_me_track1 = 0

---$track:浮上X
---min=-20000
---max=20000
---step=0.1
local rename_me_track2 = 0

---$track:浮上Y
---min=-20000
---max=20000
---step=0.1
local rename_me_track3 = 0

---$value:反転[0..3]
local ReI = 0

---$check:参照領域
local tar = 1

---$check:オリジナル表示
local ora = 1

---$value:分割数
local N = 10

---$check:アンチエイリアス
local ANT = 1

---$value:領域
local are = { -80, -100, 80, -105, 100, 105, -100, 100 }

function cal_koten(a, b, c, d)
    local g
    local f = (d.y - c.y) * (c.x - a.x) - (d.x - c.x) * (c.y - a.y)
    local z = (b.x - a.x) * (d.y - c.y) - (b.y - a.y) * (d.x - c.x)
    if z ~= 0 then
        g = f / z
    else
        g = f > 0 and 2000000000 or -2000000000
    end
    return a.x + g * (b.x - a.x), a.y + g * (b.y - a.y)
end

function muki(a, b, c, d)
    return (b.x - a.x) * (d.y - c.y) - (b.y - a.y) * (d.x - c.x) > 0 and -1 or 1
end

function Lrate(x, y, ex, ey, fx, fy)
    return (1 - (x * ex + y * ey) / (ex * ex + ey * ey)) * (1 - (x * fx + y * fy) / (fx * fx + fy * fy))
end

function cal_pos(p1, p2)
    local x, y = cal_koten(p1, c, p2, b)
    hi = Lrate(x - tx, y - ty, b.x - tx, b.y - ty, c.x - tx, c.y - ty)
    return x + flx * hi, y + fly * hi
end

local ReI = ReI or 0
obj.setanchor("are", 4, "loop")
w, h = obj.getpixel()
w2 = w / 2
h2 = h / 2
ps = {}
ps[1] = { x = are[1], y = are[2] }
ps[2] = { x = are[3], y = are[4] }
ps[3] = { x = are[5], y = are[6] }
ps[4] = { x = are[7], y = are[8] }

if muki(ps[1], ps[2], ps[2], ps[3]) == 1 then
    ps[1], ps[2] = ps[2], ps[1]
    ps[3], ps[4] = ps[4], ps[3]
end

dx = rename_me_track0 / 100
dy = rename_me_track1 / 100

flx = rename_me_track2
fly = rename_me_track3

b = {}
c = {}
b.x, b.y = cal_koten(ps[1], ps[2], ps[4], ps[3])
c.x, c.y = cal_koten(ps[1], ps[4], ps[2], ps[3])

bmuki = muki(b, ps[1], ps[1], ps[4])
cmuki = muki(c, ps[2], ps[2], ps[1])

w0 = math.sqrt((ps[1].x - ps[2].x) ^ 2 + (ps[1].y - ps[2].y) ^ 2)
h0 = math.sqrt((ps[1].x - ps[4].x) ^ 2 + (ps[1].y - ps[4].y) ^ 2)
if bmuki > 0 then
    wa = math.sqrt((ps[1].x - b.x) ^ 2 + (ps[1].y - b.y) ^ 2)
else
    dx = -dx
    wa = math.sqrt((ps[2].x - b.x) ^ 2 + (ps[2].y - b.y) ^ 2)
end

if cmuki > 0 then
    ha = math.sqrt((ps[1].x - c.x) ^ 2 + (ps[1].y - c.y) ^ 2)
else
    dy = -dy
    ha = math.sqrt((ps[4].x - c.x) ^ 2 + (ps[4].y - c.y) ^ 2)
end

tx = (ps[1].x + ps[2].x + ps[3].x + ps[4].x) / 4
ty = (ps[1].y + ps[2].y + ps[3].y + ps[4].y) / 4

ss = 1 - w0 / wa
tt = 1 - h0 / ha

lx1 = (1 - ss ^ dx) / (1 - ss)
lx2 = (1 - ss ^ (dx + 1)) / (1 - ss)
qx = {}

if bmuki > 0 then
    qx[1] = { x = ps[1].x + (ps[2].x - ps[1].x) * lx1, y = ps[1].y + (ps[2].y - ps[1].y) * lx1 }
    qx[2] = { x = ps[1].x + (ps[2].x - ps[1].x) * lx2, y = ps[1].y + (ps[2].y - ps[1].y) * lx2 }
else
    qx[2] = { x = ps[2].x + (ps[1].x - ps[2].x) * lx1, y = ps[2].y + (ps[1].y - ps[2].y) * lx1 }
    qx[1] = { x = ps[2].x + (ps[1].x - ps[2].x) * lx2, y = ps[2].y + (ps[1].y - ps[2].y) * lx2 }
end

ly1 = (1 - tt ^ dy) / (1 - tt)
ly2 = (1 - tt ^ (1 + dy)) / (1 - tt)
qy = {}

if cmuki > 0 then
    qy[1] = { x = ps[1].x + (ps[4].x - ps[1].x) * ly1, y = ps[1].y + (ps[4].y - ps[1].y) * ly1 }
    qy[2] = { x = ps[1].x + (ps[4].x - ps[1].x) * ly2, y = ps[1].y + (ps[4].y - ps[1].y) * ly2 }
else
    qy[2] = { x = ps[4].x + (ps[1].x - ps[4].x) * ly1, y = ps[4].y + (ps[1].y - ps[4].y) * ly1 }
    qy[1] = { x = ps[4].x + (ps[1].x - ps[4].x) * ly2, y = ps[4].y + (ps[1].y - ps[4].y) * ly2 }
end

x0, y0 = cal_pos(qx[1], qy[1])
x1, y1 = cal_pos(qx[2], qy[1])
x2, y2 = cal_pos(qx[2], qy[2])
x3, y3 = cal_pos(qx[1], qy[2])

if ora == 1 then
    tpw_max = math.max(x3, x2, x1, x0, w2)
    tph_max = math.max(y3, y2, y1, y0, h2)
    tpw_min = math.min(x3, x2, x1, x0, -w2)
    tph_min = math.min(y3, y2, y1, y0, -h2)
else
    tpw_max = math.max(x3, x2, x1, x0)
    tph_max = math.max(y3, y2, y1, y0)
    tpw_min = math.min(x3, x2, x1, x0)
    tph_min = math.min(y3, y2, y1, y0)
end

tpw = tpw_max - tpw_min
tph = tph_max - tph_min
cx = (tpw_max + tpw_min) / 2
cy = (tph_max + tph_min) / 2

obj.setoption("drawtarget", "tempbuffer", tpw, tph)
obj.setoption("antialias", ANT)

if ora == 1 then
    obj.draw(-cx, -cy, 0)
else
    obj.setoption("blend", "alpha_add")
end

if tar == 1 then
    x0, x1, x2, x3 = x0 - cx, x1 - cx, x2 - cx, x3 - cx
    y0, y1, y2, y3 = y0 - cy, y1 - cy, y2 - cy, y3 - cy
    u0, v0, u1, v1, u2, v2, u3, v3 =
        ps[1].x + w2, ps[1].y + h2, ps[2].x + w2, ps[2].y + h2, ps[3].x + w2, ps[3].y + h2, ps[4].x + w2, ps[4].y + h2

    if AND(ReI, 1) == 1 then
        u0, v0, u1, v1 = u1, v1, u0, v0
        u2, v2, u3, v3 = u3, v3, u2, v2
    end

    if AND(ReI, 2) == 2 then
        u0, v0, u3, v3 = u3, v3, u0, v0
        u2, v2, u1, v1 = u1, v1, u2, v2
    end

    obj.drawpoly(x0, y0, 0, x1, y1, 0, x2, y2, 0, x3, y3, 0, u0, v0, u1, v1, u2, v2, u3, v3)
else
    for i = 0, N - 1 do
        for j = 0, N - 1 do
            lx1 = (1 - ss ^ (dx + i / N)) / (1 - ss)
            lx2 = (1 - ss ^ (dx + (i + 1) / N)) / (1 - ss)
            qx = {}

            if bmuki > 0 then
                qx[1] = { x = ps[1].x + (ps[2].x - ps[1].x) * lx1, y = ps[1].y + (ps[2].y - ps[1].y) * lx1 }
                qx[2] = { x = ps[1].x + (ps[2].x - ps[1].x) * lx2, y = ps[1].y + (ps[2].y - ps[1].y) * lx2 }
            else
                qx[2] = { x = ps[2].x + (ps[1].x - ps[2].x) * lx1, y = ps[2].y + (ps[1].y - ps[2].y) * lx1 }
                qx[1] = { x = ps[2].x + (ps[1].x - ps[2].x) * lx2, y = ps[2].y + (ps[1].y - ps[2].y) * lx2 }
            end

            ly1 = (1 - tt ^ (dy + j / N)) / (1 - tt)
            ly2 = (1 - tt ^ (dy + (j + 1) / N)) / (1 - tt)
            qy = {}

            if cmuki > 0 then
                qy[1] = { x = ps[1].x + (ps[4].x - ps[1].x) * ly1, y = ps[1].y + (ps[4].y - ps[1].y) * ly1 }
                qy[2] = { x = ps[1].x + (ps[4].x - ps[1].x) * ly2, y = ps[1].y + (ps[4].y - ps[1].y) * ly2 }
            else
                qy[2] = { x = ps[4].x + (ps[1].x - ps[4].x) * ly1, y = ps[4].y + (ps[1].y - ps[4].y) * ly1 }
                qy[1] = { x = ps[4].x + (ps[1].x - ps[4].x) * ly2, y = ps[4].y + (ps[1].y - ps[4].y) * ly2 }
            end

            x0, y0 = cal_pos(qx[1], qy[1])
            x1, y1 = cal_pos(qx[2], qy[1])
            x2, y2 = cal_pos(qx[2], qy[2])
            x3, y3 = cal_pos(qx[1], qy[2])

            if bmuki < 0 then
                u1 = w * (1 - i / N)
                u0 = w * (1 - (i + 1) / N)
            else
                u0 = w * i / N
                u1 = w * (i + 1) / N
            end

            if cmuki > 0 then
                v0 = h * j / N
                v1 = h * (j + 1) / N
            else
                v1 = h * (1 - j / N)
                v0 = h * (1 - (j + 1) / N)
            end

            x0, x1, x2, x3 = x0 - cx, x1 - cx, x2 - cx, x3 - cx
            y0, y1, y2, y3 = y0 - cy, y1 - cy, y2 - cy, y3 - cy

            if AND(ReI, 1) == 1 then
                u0, u1, u2, u3 = w - u0, w - u1, w - u2, w - u3
            end

            if AND(ReI, 2) == 2 then
                v0, v1, v2, v3 = h - v0, h - v1, h - v2, h - v3
            end

            obj.drawpoly(x0, y0, 0, x1, y1, 0, x2, y2, 0, x3, y3, 0, u0, v0, u1, v0, u1, v1, u0, v1)
        end
    end
end

obj.load("tempbuffer")

obj.cx = obj.cx - cx
obj.cy = obj.cy - cy
