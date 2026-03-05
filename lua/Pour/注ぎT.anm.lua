--label:tim2
--track0:水位,-5000,5000,0
--track1:振幅,-1000,1000,10
--track2:波長,2,5000,100,1
--track3:本体α,0,100,100
--value@Ta:波─α,100
--value@col:└色/col,0x80ffff
--value@S:└振動速度,0
--value@D:└位相ズレ,0
--value@V:└位相速度,0
--value@Rw:反転波─表示/chk,0
--value@colr:└色/col,0x53c9c9
--value@colw:枠─色/col,0xffffff
--value@ws:└幅,6
--value@wb:└ぼかし,4
local pi = math.pi
local Pr = { obj.ox, obj.oy, obj.oz, obj.rx, obj.ry, obj.rz, obj.cx, obj.cy, obj.cz, obj.zoom, obj.alpha, obj.aspect }
local Z = -obj.track0
local A = obj.track1
local L = math.floor(obj.track2)
local T = obj.track3 / 100
local SG = 1
A = A * math.cos(obj.time * 2 * pi * S)
if A < 0 then
    A, SG = -A, -1
end
local w0, h0 = obj.getpixel()
local w, h = w0 + 20, math.floor(4 * math.ceil(A))
local w2, h2 = w / 2, h / 2
D = D + V * obj.time
if Rw == 1 then
    col, colr = colr, col
end
obj.copybuffer("cache:OrgW", "obj")
obj.setoption("drawtarget", "tempbuffer", w, h)
obj.load("figure", "四角形", 0xffffff, 1)
obj.effect("リサイズ", "X", w, "Y", 1, "ドット数でサイズ指定", 1)
obj.pixeloption("type", "rgb")
for i = 0, w - 1 do
    local g = 127.5 * math.sin(2 * pi * (i - w2 - D) / L)
    if math.abs(g) <= 0.5 then
        obj.putpixel(i, 0, 0, 0, 0, 0)
    else
        g = 127.5 + g
        obj.putpixel(i, 0, 0, g, 0, 255)
    end
end
obj.drawpoly(-w2, -h2, 0, w2, -h2, 0, w2, h2, 0, -w2, h2, 0)
obj.load("figure", "四角形", col, 1)
obj.effect("リサイズ", "X", w, "Y", h2, "ドット数でサイズ指定", 1)
obj.effect("領域拡張", "上", h2)
obj.effect(
    "ディスプレイスメントマップ",
    "param1",
    SG * A,
    "元のサイズに合わせる",
    1,
    "type",
    0,
    "name",
    "*tempbuffer",
    "ぼかし",
    0
)
obj.setoption("drawtarget", "tempbuffer", w0, h0)
obj.draw(0, Z, 0, 1, 1, 0, Rw * 180, 0)
obj.draw(0, Z + h2 / 2, 0, 1, 1, 0, Rw * 180, 0)
obj.load("figure", "四角形", col, 1)
h1, h2 = Z + A + 0.5, h0 / 2
obj.drawpoly(-w2, h1, 0, w2, h1, 0, w2, h2, 0, -w2, h2, 0)
if Rw == 1 then
    obj.copybuffer("cache:WaveW", "tmp")
    obj.copybuffer("obj", "cache:WaveW")
    obj.effect("単色化", "輝度を保持する", 0, "color", colr)
    obj.effect("反転", "左右反転", 1)
    obj.draw()
end
obj.copybuffer("obj", "cache:OrgW")
obj.effect("反転", "透明度反転", 1)
obj.setoption("blend", "alpha_sub")
obj.draw()
obj.copybuffer("cache:WaveW", "tmp")
obj.copybuffer("obj", "cache:OrgW")
obj.effect("縁取り", "ぼかし", wb, "サイズ", ws)
obj.effect("単色化", "輝度を保持する", 0, "color", colw)
obj.copybuffer("tmp", "obj")
obj.copybuffer("obj", "cache:OrgW")
obj.setoption("blend", "alpha_sub")
obj.draw()
obj.setoption("blend", "alpha_add2")
obj.copybuffer("obj", "cache:WaveW")
obj.draw(0, 0, 0, 1, Ta / 100)
obj.copybuffer("cache:WaveW", "tmp") --フリンジ対策で先に波と縁を合成
obj.copybuffer("obj", "cache:OrgW")
obj.draw(0, 0, 0, 1, T)
obj.copybuffer("obj", "cache:WaveW")
obj.setoption("blend", 0)
obj.draw()
obj.copybuffer("obj", "tmp")
obj.ox, obj.oy, obj.oz, obj.rx, obj.ry, obj.rz, obj.cx, obj.cy, obj.cz, obj.zoom, obj.alpha, obj.aspect = unpack(Pr)
