--label:tim2\けいおんグッズ.obj\律部屋テーブル
---$track:サイズ
---min=0
---max=5000
---step=0.1
local rename_me_track0 = 250

---$track:厚さ補正
---min=0
---max=5000
---step=0.1
local rename_me_track1 = 100

---$track:脚長補正
---min=0
---max=5000
---step=0.1
local rename_me_track2 = 100

---$value:テーブル色/col
local tablecol = 0xc0c0a0

---$value:脚の色/col
local legcol = 0xffffff

function MkSq(x1, y1, z1, x2, y2, z2) -- 数値は対角線指定(1<2)で表裏が正確に
    Szdrawpoly(x1, y1, x2, y2, z1)
    Szdrawpoly(x1, y2, x2, y1, z2)
    Sydrawpoly(x1, x2, y1, z2, z1)
    Sydrawpoly(x1, x2, y2, z1, z2)
    Sxdrawpoly(x1, y1, y2, z2, z1)
    Sxdrawpoly(x2, y1, y2, z1, z2)
end

function Sxdrawpoly(x, y1, y2, z1, z2)
    obj.drawpoly(x, y1, z1, x, y1, z2, x, y2, z2, x, y2, z1)
end

function Sydrawpoly(x1, x2, y, z1, z2)
    obj.drawpoly(x1, y, z1, x2, y, z1, x2, y, z2, x1, y, z2)
end

function Szdrawpoly(x1, y1, x2, y2, z)
    obj.drawpoly(x1, y1, z, x2, y1, z, x2, y2, z, x1, y2, z)
end

function pole(x1, y1, z1, x2, y2, z2, size)
    local x1_1 = x1 - size
    local x1_2 = x1 + size
    local z1_1 = z1 - size
    local z1_2 = z1 + size
    local x2_1 = x2 - size
    local x2_2 = x2 + size
    local z2_1 = z2 - size
    local z2_2 = z2 + size
    Sydrawpoly(x1_1, x1_2, y1, z1_2, z1_1)
    Sydrawpoly(x2_1, x2_2, y2, z2_1, z2_2)
    obj.drawpoly(x1_1, y1, z1_1, x1_2, y1, z1_1, x2_2, y2, z2_1, x2_1, y2, z2_1)
    obj.drawpoly(x1_2, y1, z1_2, x1_1, y1, z1_2, x2_1, y2, z2_2, x2_2, y2, z2_2)
    obj.drawpoly(x1_1, y1, z1_2, x1_1, y1, z1_1, x2_1, y2, z2_1, x2_1, y2, z2_2)
    obj.drawpoly(x1_2, y1, z1_1, x1_2, y1, z1_2, x2_2, y2, z2_2, x2_2, y2, z2_1)
end

local zoom = obj.getvalue("zoom") * 0.01
local sc0 = rename_me_track0 * zoom
local scl = sc0 / 250
local td = rename_me_track1 * 0.01
local hd = rename_me_track2 * 0.01

local y1 = -150 * scl * hd
local ty = 150 * scl * (1 - hd)
local y2 = 0

obj.load("figure", "四角形", tablecol, sc0)
MkSq(-sc0, (-150 - 10 * td) * scl + ty, -sc0, sc0, -150 * scl + ty, sc0)

obj.load("figure", "四角形", legcol, 150 * scl * hd)
local tsize = 8 * scl / 2
local tc0 = (225 - 12) * scl
local tc1 = (225 + 12) * scl
local tc2 = 275 * scl

pole(-tc1, y1, -tc0, -tc2, y2, -tc2, tsize)
pole(-tc0, y1, -tc1, -tc2, y2, -tc2, tsize)
pole(tc1, y1, -tc1, tc2, y2, -tc2, tsize)
pole(tc0, y1, -tc0, tc2, y2, -tc2, tsize)
pole(tc1, y1, tc0, tc2, y2, tc2, tsize)
pole(tc0, y1, tc1, tc2, y2, tc2, tsize)
pole(-tc1, y1, tc1, -tc2, y2, tc2, tsize)
pole(-tc0, y1, tc0, -tc2, y2, tc2, tsize)
