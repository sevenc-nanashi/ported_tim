--label:tim2\加工
---$track:サイズ
---min=50
---max=1000
---step=0.1
local track_size = 100

---$track:幅
---min=0
---max=100
---step=0.1
local track_width = 10

---$track:高さ
---min=0
---max=3
---step=0.1
local track_height = 1.5

---$track:角度
---min=-360
---max=360
---step=0.1
local track_angle = -45

---$track:エンボス透明度
---min=0
---max=100
---step=0.01
local alp = 0

obj.setoption("antialias", 0)

bsi = track_size
if bsi < 50 then
    bsi = 50
end
wh = track_width
si = bsi - 2 * wh
if si < 0 then
    wh = bsi / 2
end
dsi = si / 2
alp = (100 - alp) / 100

n = math.floor(obj.w / bsi)
nx = math.floor((n + 1) / 2)

n = math.floor(obj.h / bsi)
ny = math.floor((n + 1) / 2)

for i = -nx, nx do
    for j = -ny, ny do
        bim = bsi * i - 0.5 * si
        bip = bsi * i + 0.5 * si
        bjm = bsi * j - 0.5 * si
        bjp = bsi * j + 0.5 * si

        bims = bim + obj.w / 2
        bips = bip + obj.w / 2
        bjms = bjm + obj.h / 2
        bjps = bjp + obj.h / 2

        -- 中心
        x0 = bim
        x1 = bip
        y0 = bjm
        y1 = bjp
        u0 = bims
        u1 = bips
        v0 = bjms
        v1 = bjps
        obj.drawpoly(x0, y0, 0, x1, y0, 0, x1, y1, 0, x0, y1, 0, u0, v0, u1, v0, u1, v1, u0, v1)

        -- 上
        x0 = bim
        x1 = bip
        y0 = bjm - wh
        y1 = bjm
        u0 = bims
        u1 = bips
        v0 = bjms - si / 2
        v1 = bjms
        obj.drawpoly(x0, y0, 0, x1, y0, 0, x1, y1, 0, x0, y1, 0, u0, v0, u1, v0, u1, v1, u0, v1)

        -- 下
        x0 = bim
        x1 = bip
        y0 = bjp
        y1 = bjp + wh
        u0 = bims
        u1 = bips
        v0 = bjps
        v1 = bjps + si / 2
        obj.drawpoly(x0, y0, 0, x1, y0, 0, x1, y1, 0, x0, y1, 0, u0, v0, u1, v0, u1, v1, u0, v1)

        -- 左
        x0 = bim - wh
        x1 = bim
        y0 = bjm
        y1 = bjp
        u0 = bims - si / 2
        u1 = bims
        v0 = bjms
        v1 = bjps
        obj.drawpoly(x0, y0, 0, x1, y0, 0, x1, y1, 0, x0, y1, 0, u0, v0, u1, v0, u1, v1, u0, v1)

        -- 右
        x0 = bip
        x1 = bip + wh
        y0 = bjm
        y1 = bjp
        u0 = bips
        u1 = bips + si / 2
        v0 = bjms
        v1 = bjps
        obj.drawpoly(x0, y0, 0, x1, y0, 0, x1, y1, 0, x0, y1, 0, u0, v0, u1, v0, u1, v1, u0, v1)

        -- 左上
        x0 = bim - wh
        x1 = bim
        y0 = bjm - wh
        y1 = bjm
        u0 = bims - si / 2
        u1 = bims
        v0 = bjms - si / 2
        v1 = bjms
        obj.drawpoly(x0, y0, 0, x1, y0, 0, x1, y1, 0, x0, y1, 0, u0, v0, u1, v0, u1, v1, u0, v1)

        -- 右上
        x0 = bip
        x1 = bip + wh
        y0 = bjm - wh
        y1 = bjm
        u0 = bips
        u1 = bips + si / 2
        v0 = bjms - si / 2
        v1 = bjms
        obj.drawpoly(x0, y0, 0, x1, y0, 0, x1, y1, 0, x0, y1, 0, u0, v0, u1, v0, u1, v1, u0, v1)

        -- 左下
        x0 = bim - wh
        x1 = bim
        y0 = bjp
        y1 = bjp + wh
        u0 = bims - si / 2
        u1 = bims
        v0 = bjps
        v1 = bjps + si / 2
        obj.drawpoly(x0, y0, 0, x1, y0, 0, x1, y1, 0, x0, y1, 0, u0, v0, u1, v0, u1, v1, u0, v1)

        -- 右下
        x0 = bip
        x1 = bip + wh
        y0 = bjp
        y1 = bjp + wh
        u0 = bips
        u1 = bips + si / 2
        v0 = bjps
        v1 = bjps + si / 2
        obj.drawpoly(x0, y0, 0, x1, y0, 0, x1, y1, 0, x0, y1, 0, u0, v0, u1, v0, u1, v1, u0, v1)
    end
end

obj.load("figure", "四角形", 0xffffff, bsi)
obj.setoption("blend", 3)
obj.effect("凸エッジ", "幅", wh, "高さ", track_height, "角度", track_angle)
obj.effect("画像ループ", "横回数", 2 * nx + 1, "縦回数", 2 * ny + 1)
obj.alpha = alp
obj.draw()

obj.load("figure", "四角形", 0x0, bsi)
obj.setoption("blend", 1)
obj.effect("凸エッジ", "幅", wh, "高さ", track_height, "角度", track_angle)
obj.effect("画像ループ", "横回数", 2 * nx + 1, "縦回数", 2 * ny + 1)
obj.alpha = alp
obj.draw()