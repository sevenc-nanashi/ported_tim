--label:tim2\変形
---$track:サイズ補正
---min=0
---max=20000
---step=0.1
local track_size_adjust = 200

---$select:表示モード
---ガイド=0
---プレビュー=1
---変形=2
local display_mode = 0

---$track:視X/深度
---min=-10000
---max=10000
---step=0.1
local track_view_x_depth = 100

---$track:視点Y
---min=-10000
---max=10000
---step=0.1
local track_view_point_y = 100

---$track:分割数
---min=1
---max=300
---step=1
local N = 30

---$value:領域
local are = { -100, -100, 100, 100, 0, 0 }

---$track:ガイド径
---min=1
---max=500
---step=1
local gr = 40

---$track:ライン幅
---min=1
---max=100
---step=1
local lw = 4

-- ---$check:アンチエイリアス
-- local ANT = 1

function LineDraw(p1, p2)
    local dx = p2.x - p1.x
    local dy = p2.y - p1.y
    local r = math.sqrt(dx * dx + dy * dy)
    dx, dy = lw * dy / r, -lw * dx / r
    obj.drawpoly(p1.x + dx, p1.y + dy, 0, p1.x - dx, p1.y - dy, 0, p2.x - dx, p2.y - dy, 0, p2.x + dx, p2.y + dy, 0)
end

function sdp(a, b)
    obj.drawpoly(
        ps[a].x - vx,
        ps[a].y - vy,
        0,
        ps[b].x - vx,
        ps[b].y - vy,
        0,
        qs[b].x + bvx,
        qs[b].y + bvy,
        0,
        qs[a].x + bvx,
        qs[a].y + bvy,
        0,
        ps[a].x + iw / 2,
        ps[a].y + ih / 2,
        ps[b].x + iw / 2,
        ps[b].y + ih / 2,
        qs[b].x + iw / 2,
        qs[b].y + ih / 2,
        qs[a].x + iw / 2,
        qs[a].y + ih / 2
    )
end

function dtd(a, b)
    for i = 0, N - 1 do
        local xxa_1 = (1 - i / N) * ps[a].x + i / N * qs[a].x
        local xxa_2 = (1 - (i + 1) / N) * ps[a].x + (i + 1) / N * qs[a].x
        local xxb_1 = (1 - i / N) * ps[b].x + i / N * qs[b].x
        local xxb_2 = (1 - (i + 1) / N) * ps[b].x + (i + 1) / N * qs[b].x

        local yya_1 = (1 - i / N) * ps[a].y + i / N * qs[a].y
        local yya_2 = (1 - (i + 1) / N) * ps[a].y + (i + 1) / N * qs[a].y
        local yyb_1 = (1 - i / N) * ps[b].y + i / N * qs[b].y
        local yyb_2 = (1 - (i + 1) / N) * ps[b].y + (i + 1) / N * qs[b].y

        K1 = L * ((qs[a].x - vp.x + cp.x) / (xxa_1 - vp.x + cp.x) - 1)
        K2 = L * ((qs[a].x - vp.x + cp.x) / (xxa_2 - vp.x + cp.x) - 1)
        obj.drawpoly(
            zoom * (qs[a].x - qcp.x),
            zoom * (qs[a].y - qcp.y),
            zoom * K1,
            zoom * (qs[b].x - qcp.x),
            zoom * (qs[b].y - qcp.y),
            zoom * K1,
            zoom * (qs[b].x - qcp.x),
            zoom * (qs[b].y - qcp.y),
            zoom * K2,
            zoom * (qs[a].x - qcp.x),
            zoom * (qs[a].y - qcp.y),
            zoom * K2,
            zoom * (xxa_1 + w2),
            zoom * (yya_1 + h2),
            zoom * (xxb_1 + w2),
            zoom * (yyb_1 + h2),
            zoom * (xxb_2 + w2),
            zoom * (yyb_2 + h2),
            zoom * (xxa_2 + w2),
            zoom * (yya_2 + h2)
        )
    end
end

obj.setanchor("are", 3)
local Rsize = track_size_adjust / 100
local va = display_mode or 0
local w, h = obj.getpixel()
-- if ANT == nil then
--     ANT = 0
-- elseif ANT == false then
--     ANT = 0
-- elseif ANT == true then
--     ANT = 1
-- end
ps = {}
ps[1] = { x = are[1], y = are[2] }
ps[2] = { x = are[3], y = are[2] }
ps[3] = { x = are[3], y = are[4] }
ps[4] = { x = are[1], y = are[4] }
vp = {}
vp.x = are[5]
vp.y = are[6]
qs = {}
for i = 1, 4 do
    qs[i] = { x = Rsize * (ps[i].x - vp.x) + vp.x, y = Rsize * (ps[i].y - vp.y) + vp.y }
end

local max_w = math.max(ps[1].x, ps[2].x, ps[3].x, ps[4].x, qs[1].x, qs[2].x, qs[3].x, qs[4].x, w / 2)
local min_w = math.min(ps[1].x, ps[2].x, ps[3].x, ps[4].x, qs[1].x, qs[2].x, qs[3].x, qs[4].x, -w / 2)
local max_h = math.max(ps[1].y, ps[2].y, ps[3].y, ps[4].y, qs[1].y, qs[2].y, qs[3].y, qs[4].y, h / 2)
local min_h = math.min(ps[1].y, ps[2].y, ps[3].y, ps[4].y, qs[1].y, qs[2].y, qs[3].y, qs[4].y, -h / 2)
cp = { x = (max_w + min_w) / 2, y = (max_h + min_h) / 2 }

iw = max_w - min_w + gr
ih = max_h - min_h + gr

for i = 1, 4 do
    ps[i].x = ps[i].x - cp.x
    ps[i].y = ps[i].y - cp.y
    qs[i].x = qs[i].x - cp.x
    qs[i].y = qs[i].y - cp.y
end

obj.setoption("drawtarget", "tempbuffer", iw, ih)
obj.draw(-cp.x, -cp.y, 0)

if va == 0 then
    lw = lw / 2
    obj.load("figure", "円", 0xff5555, gr)
    obj.draw(vp.x - cp.x, vp.y - cp.y, 0)
    obj.load("figure", "円", 0xffffff, gr)
    obj.draw(ps[1].x, ps[1].y, 0)
    obj.draw(ps[3].x, ps[3].y, 0)
    obj.load("figure", "円", 0x5555ff, gr)
    obj.draw(ps[2].x, ps[2].y, 0)
    obj.draw(ps[4].x, ps[4].y, 0)
    obj.load("figure", "円", 0x00ff00, gr)
    for i = 1, 4 do
        obj.draw(qs[i].x, qs[i].y, 0)
    end
    obj.load("figure", "四角形", 0xffffff, gr)
    LineDraw(ps[1], ps[2])
    LineDraw(ps[2], ps[3])
    LineDraw(ps[3], ps[4])
    LineDraw(ps[4], ps[1])
    LineDraw(qs[1], qs[2])
    LineDraw(qs[2], qs[3])
    LineDraw(qs[3], qs[4])
    LineDraw(qs[4], qs[1])
    LineDraw(ps[1], qs[1])
    LineDraw(ps[2], qs[2])
    LineDraw(ps[3], qs[3])
    LineDraw(ps[4], qs[4])
    obj.load("tempbuffer")
    obj.cx = obj.cx - cp.x
    obj.cy = obj.cy - cp.y
elseif va == 1 then
    obj.load("tempbuffer")
    -- obj.setoption("antialias", ANT)
    vx = track_view_x_depth
    vy = track_view_point_y
    bvx = Rsize * vx
    bvy = Rsize * vy
    obj.setoption("drawtarget", "tempbuffer", iw + 2 * math.abs(bvx), ih + 2 * math.abs(bvy)) --面倒臭くなって適当＞＜;
    obj.setoption("antialias", 0)
    obj.drawpoly(
        ps[1].x - vx,
        ps[1].y - vy,
        0,
        ps[2].x - vx,
        ps[2].y - vy,
        0,
        ps[3].x - vx,
        ps[3].y - vy,
        0,
        ps[4].x - vx,
        ps[4].y - vy,
        0,
        ps[1].x + iw / 2,
        ps[1].y + ih / 2,
        ps[2].x + iw / 2,
        ps[2].y + ih / 2,
        ps[3].x + iw / 2,
        ps[3].y + ih / 2,
        ps[4].x + iw / 2,
        ps[4].y + ih / 2
    )
    sdp(1, 4)
    sdp(3, 2)
    sdp(1, 2)
    sdp(3, 4)
    obj.load("tempbuffer")
    obj.cx = obj.cx - cp.x
    obj.cy = obj.cy - cp.y
else
    obj.load("tempbuffer")
    -- obj.setoption("antialias", ANT)
    w, h = obj.getpixel()
    obj.setoption("drawtarget", "framebuffer")
    zoom = obj.getvalue("zoom") * 0.01
    w2 = w / 2 --/zoom
    h2 = h / 2 --/zoom
    L = w * track_view_x_depth / 100
    qcp = { x = (qs[1].x + qs[2].x) / 2, y = (qs[1].y + qs[4].y) / 2 }
    K = L * (Rsize - 1)

    obj.drawpoly(
        zoom * (qs[1].x - qcp.x),
        zoom * (qs[1].y - qcp.y),
        zoom * K,
        zoom * (qs[2].x - qcp.x),
        zoom * (qs[2].y - qcp.y),
        zoom * K,
        zoom * (qs[3].x - qcp.x),
        zoom * (qs[3].y - qcp.y),
        zoom * K,
        zoom * (qs[4].x - qcp.x),
        zoom * (qs[4].y - qcp.y),
        zoom * K,
        zoom * (ps[1].x + w2),
        zoom * (ps[1].y + h2),
        zoom * (ps[2].x + w2),
        zoom * (ps[2].y + h2),
        zoom * (ps[3].x + w2),
        zoom * (ps[3].y + h2),
        zoom * (ps[4].x + w2),
        zoom * (ps[4].y + h2)
    )
    dtd(3, 2)
    dtd(4, 1)
    dtd(1, 2)
    dtd(3, 4)
end
