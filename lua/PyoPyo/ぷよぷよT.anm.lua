--label:tim2
--track0:枠サイズ,0,500,50
--track1:変形量,0,500,20
--track2:回転,-3600,3600,0
--track3:変形速度,0,5000,100
--value@Num:波数,4
--value@spN:波形分割,20
--value@RgRnd:凹凸ﾗﾝﾀﾞﾑ性%,30
--value@Cen:中心＆ﾏｽｸ座標,{0,0,50,0}
--value@Mfg:マスク形状/fig,"円"
--value@Mcl:マスク色/col,0xff0000
--value@StR:マスクサイズ,0
--value@Asp:ﾏｽｸ縦横比%,0
--value@MsRt:マスク回転,0
--value@Blur:ﾏｽｸ境界ブラー,0
--value@MS:マップサイズ,256
--value@BL:滑らかさ,1
--value@seed:乱数シード,0
--value@MapAP:マップ表示/chk,0
--check0:マスク表示,0

local Ratio = function(a, b, t)
    local s = (2 * t + 1) * (t - 1) ^ 2
    return s * a + (1 - s) * b
end

local Cor = 1 + obj.track0 * 0.01
local Tra = obj.track1
local Rot = obj.track2 % 360
local SpC = obj.track3 * 0.01

RgRnd = RgRnd * 0.01
seed = math.abs(seed)
spN = math.floor(spN)

obj.setanchor("Cen", 2)

local w, h = obj.getpixel()
local maxwh = math.max(w, h)
local wh = maxwh * Cor

local Cx, Cy = Cen[1] / maxwh, Cen[2] / maxwh
local Dx, Dy = Cen[3], Cen[4]

local dw = math.floor((wh - w) / 2)
local dh = math.floor((wh - h) / 2)
obj.effect("領域拡張", "上", dh, "下", dh, "右", dw, "左", dw)
obj.copybuffer("cache:ORI", "obj")

local ALL = Num * spN
local Sp = {}
local dR = {}
local OT = obj.time * SpC
local OT1 = math.floor(OT)
local OT2 = OT - OT1
for i = 0, Num - 1 do
    local s0 = 1 - RgRnd * obj.rand(0, 2000, -(i + seed + 100), 1000 + OT1) * 0.001
    local s1 = 1 - RgRnd * obj.rand(0, 2000, -(i + seed + 100), 1001 + OT1) * 0.001
    Sp[i] = Ratio(s0, s1, OT2)
end
Sp[Num] = Sp[0]
local k = 0
for i = 0, Num - 1 do
    for j = 0, spN - 1 do
        dR[k] = ((spN - j) * Sp[i] + j * Sp[i + 1]) / spN
        k = k + 1
    end
end
local dA = {}
for i = 0, ALL - 1 do
    dA[i] = (1 + dR[i] * math.sin(i / spN * 2 * math.pi)) / 2
end
dA[ALL] = dA[0]

obj.load("figure", "四角形", 0xffffff, MS)
obj.pixeloption("type", "rgb")
Cx, Cy = MS * (Cx / Cor + 0.5), MS * (Cy / Cor + 0.5)
local MS2 = MS / 2
local Rb = math.sqrt(math.max(Cx, MS - Cx) ^ 2 + math.max(Cy, MS - Cy) ^ 2)
for i = 0, MS - 1 do
    for j = 0, MS - 1 do
        local x, y = i - Cx, j - Cy
        local fai = math.atan2(y, x)
        local r = 127.5 * math.sqrt(x * x + y * y) / Rb
        local th = (((fai / math.pi + 1) / 2 - Rot / 360) % 1) * ALL
        local th1 = math.floor(th)
        local th2 = th - th1
        if th2 > 0 then
            r = r * Ratio(dA[th1], dA[th1 + 1], th2)
        else
            r = r * dA[th1]
        end
        local rr = 127.5 - r * math.cos(fai)
        local gg = 127.5 - r * math.sin(fai)
        obj.putpixel(i, j, rr, gg, 0, 255)
    end
end
obj.copybuffer("tmp", "obj")
if StR > 0 then
    local MSC = MS / Cor
    local Dx, Dy = Dx * MSC / maxwh + 0.5, Dy * MSC / maxwh
    obj.load("figure", Mfg, RGB(127, 127, 127), StR)
    if Asp > 0 then
        obj.effect("リサイズ", "X", 100 - Asp)
    elseif Asp < 0 then
        obj.effect("リサイズ", "Y", 100 + Asp)
    end
    obj.effect("ぼかし", "範囲", Blur)
    obj.setoption("drawtarget", "tempbuffer")
    obj.draw(Dx, Dy, 0, MSC / maxwh, 1, 0, 0, MsRt)
end

if MapAP == 0 then
    obj.copybuffer("obj", "cache:ORI")
    local Rf = Tra * Cor
    obj.effect(
        "ディスプレイスメントマップ",
        "type",
        0,
        "name",
        "*tempbuffer",
        "元のサイズに合わせる",
        1,
        "param0",
        Rf,
        "param1",
        Rf,
        "ぼかし",
        BL
    )
    if obj.check0 then
        obj.copybuffer("tmp", "obj")
        obj.load("figure", Mfg, Mcl, StR)
        if Asp > 0 then
            obj.effect("リサイズ", "X", 100 - Asp)
        elseif Asp < 0 then
            obj.effect("リサイズ", "Y", 100 + Asp)
        end
        obj.effect("ぼかし", "範囲", Blur)
        obj.setoption("drawtarget", "tempbuffer")
        obj.draw(Dx, Dy, 0, 1, 0.75, 0, 0, MsRt)
        obj.copybuffer("obj", "tmp")
    end
else
    obj.copybuffer("obj", "tmp")
end
