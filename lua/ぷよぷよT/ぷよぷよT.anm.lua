--label:tim2\アニメーション効果
--group:基本,true

---$track:枠サイズ
---min=0
---max=500
---step=0.1
local track_size = 50

---$track:変形量
---min=0
---max=500
---step=0.1
local track_deform_amount = 20

---$track:回転
---min=-3600
---max=3600
---step=0.1
local track_rotation = 0

---$track:変形速度
---min=0
---max=5000
---step=0.1
local track_deform_speed = 100

--group:波形,false

---$track:波数
---min=1
---max=32
---step=1
local track_wave_count = 4

---$track:波形分割
---min=2
---max=200
---step=1
local track_wave_division = 20

---$track:凹凸ランダム性%
---min=0
---max=100
---step=0.1
local track_roughness_random = 30

---$value:中心＆マスク座標
local Cen = { 0, 0, 50, 0 }

--group:マスク,false

---$figure:形状
local Mfg = "円"

---$color:色
local Mcl = 0xff0000

---$track:サイズ
---min=0
---max=5000
---step=0.1
local track_mask_size = 0

---$track:縦横比%
---min=-100
---max=100
---step=0.1
local track_mask_aspect = 0

---$track:マスク回転
---min=-3600
---max=3600
---step=0.1
local track_mask_rotation = 0

---$track:境界ブラー
---min=0
---max=1000
---step=0.1
local track_mask_blur = 0

--group:マップ,false

---$track:マップサイズ
---min=32
---max=4096
---step=1
local track_map_size = 256

---$track:滑らかさ
---min=0
---max=100
---step=0.1
local track_smoothness = 1

---$track:乱数シード
---min=0
---max=100000
---step=1
local track_seed = 0

---$check:マップ表示
local check_map_display = false

---$check:マスク表示
local check_mask_display = false

--group:

local Ratio = function(a, b, t)
    local s = (2 * t + 1) * (t - 1) ^ 2
    return s * a + (1 - s) * b
end

local Cor = 1 + track_size * 0.01
local Tra = track_deform_amount
local Rot = track_rotation % 360
local SpC = track_deform_speed * 0.01
local Num = math.floor(track_wave_count)
local spN = math.floor(track_wave_division)
local RgRnd = track_roughness_random
local StR = track_mask_size
local Asp = track_mask_aspect
local MsRt = track_mask_rotation
local Blur = track_mask_blur
local MS = math.floor(track_map_size)
local BL = track_smoothness
local seed = math.floor(track_seed)
local MapAP = check_map_display
local check0 = check_mask_display

RgRnd = RgRnd * 0.01
seed = math.abs(seed)

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

if not MapAP then
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
    if check0 then
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
