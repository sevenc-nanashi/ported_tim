--label:tim2\ジグザグ塗りT.anm
---$track:進捗
---min=0
---max=100
---step=0.01
local track_progress = 100

---$track:サイズ
---min=2
---max=1000
---step=1
local track_size = 20

---$track:線間隔
---min=4
---max=1000
---step=1
local track_line_spacing = 10

---$track:領域調整
---min=-500
---max=500
---step=1
local track_area_adjust = 0

---$value:表示モード[0..5]
local Md = 0

---$value:角度
local K = 20

---$color:線色
local col = 0xffffff

---$value:本体α[0..100]
local OgA = 100

---$value:ﾗｲﾝα[0..100]
local LnA = 100

---$value:ぼかし
local B = 0

---$value:水平ランダム
local RX = 0

---$value:垂直ランダム
local RY = 0

---$value:シード
local Sd = 0

---$value:└変動ﾌﾚｰﾑ長
local Cf = 0

---$value:αしきい値
local T = 127

---$check:距離∝時間ﾓｰﾄﾞ
local CV = 1

---$value:イージング
local EZ = 0

---$check:角丸なし
local check0 = true

require("T_LineFill_Module")
local P = track_progress / 100
local D = math.floor(track_size)
local S = math.floor(track_line_spacing)
local E = math.floor(track_area_adjust)
TLF = T_LineFill or {}
K = TLF.K or K
local R = math.rad(K)
OgA = (TLF.OgA or OgA) / 100
LnA = (TLF.LnA or LnA) / 100
B = TLF.B or B
Cf = math.abs(Cf)
EZ = 1 + math.abs((EZ or 0))
if Cf > 1 then
    local RR = math.floor(obj.time * obj.framerate / Cf)
    Sd = Sd + rand(0, 10000, -RR, Sd)
end
obj.copybuffer("cache:LT_ORG", "obj")
local w, h = obj.getpixel()
if K ~= 0 then
    local cos = math.abs(math.cos(R))
    local sin = math.abs(math.sin(R))
    local wr, hr = w * cos + h * sin + 2, w * sin + h * cos + 2
    obj.setoption("drawtarget", "tempbuffer", wr, hr)
    obj.draw(0, 0, 0, 1, 1, 0, 0, K)
    obj.copybuffer("obj", "tmp")
end
if E > 0 then
    obj.effect("縁取り", "サイズ", E, "ぼかし", 0)
elseif E < 0 then
    obj.effect("領域拡張", "上", 1, "下", 1, "左", 1, "右", 1, "塗りつぶし", 0)
    obj.setoption("drawtarget", "tempbuffer")
    obj.copybuffer("tmp", "obj")
    obj.effect("反転", "透明度反転", 1)
    obj.effect("縁取り", "サイズ", -E, "ぼかし", 0)
    obj.setoption("blend", "alpha_sub")
    obj.draw()
    obj.copybuffer("obj", "tmp")
    obj.setoption("blend", 0)
end
local userdata, wc, hc = obj.getpixeldata()
local ws, hs, N, PS = T_LineFill_Module.LineFill(userdata, wc, hc, S, R, T, RX, RY, Sd)
ws, hs = math.max(ws + D, w), math.max(hs + D, h)
ws = ws + (ws - w) % 2
hs = hs + (hs - h) % 2
obj.setoption("drawtarget", "tempbuffer", ws, hs)
_T_LineFill_last_x, _T_LineFill_last_y = PS[1], PS[2]
if P > 0 and N > 0 then
    local Ne = 0
    local q
    if CV == 1 then
        local LN = 0
        local L = {}
        local x0, y0 = PS[1], PS[2]
        for i = 1, N - 1 do
            local x1, y1 = PS[2 * i + 1], PS[2 * i + 2]
            L[i] = math.sqrt((x1 - x0) * (x1 - x0) + (y1 - y0) * (y1 - y0))
            LN = LN + L[i]
            x0, y0 = x1, y1
        end
        local AL = 0
        for i = 1, N - 1 do
            AL = AL + L[i]
            if P * LN <= AL then
                Ne = i + 1
                break
            end
        end
        q = (AL - P * LN) / L[Ne - 1]
    else
        local Ps = P * (N - 1) + 1
        Ne = math.ceil(Ps)
        Ne = math.min(Ne, N)
        q = Ne - Ps
    end

    if EZ > 1 then
        if q < 0.5 then
            q = math.pow(2 * q, EZ) / 2
        else
            q = 2 - 2 * q
            q = 1 - math.pow(q, EZ) / 2
        end
    end

    _T_LineFill_last_x, _T_LineFill_last_y =
        q * PS[2 * Ne - 3] + (1 - q) * PS[2 * Ne - 1], q * PS[2 * Ne - 2] + (1 - q) * PS[2 * Ne]
    PS[2 * Ne - 1], PS[2 * Ne] = _T_LineFill_last_x, _T_LineFill_last_y
    if not check0 then
        obj.load("figure", "円", col, 2 * D)
        obj.effect("リサイズ", "拡大率", 50)
        for i = 1, Ne do
            obj.draw(PS[2 * i - 1], PS[2 * i])
        end
    end
    obj.load("figure", "四角形", col, 1)
    local x0, y0 = PS[1], PS[2]
    for i = 1, Ne - 1 do
        local x1, y1 = PS[2 * i + 1], PS[2 * i + 2]
        local dx, dy = y1 - y0, x0 - x1
        local L = 2 * math.sqrt(dx * dx + dy * dy)
        dx, dy = (D - 1) * dx / L, (D - 1) * dy / L
        obj.drawpoly(x0 + dx, y0 + dy, 0, x1 + dx, y1 + dy, 0, x1 - dx, y1 - dy, 0, x0 - dx, y0 - dy, 0)
        x0, y0 = x1, y1
    end
end
if TLF.Ly then
    local DX, DY = math.abs(TLF.DX), math.abs(TLF.DY)
    ws, hs = ws + 2 * DX, hs + 2 * DY
    obj.copybuffer("cache:LT_LIN", "tmp")
    obj.load("layer", TLF.Ly, true)
    if TLF.RS then
        obj.setoption("drawtarget", "tempbuffer", ws, hs)
        obj.draw()
    else
        obj.copybuffer("tmp", "obj")
    end
    obj.copybuffer("obj", "cache:LT_LIN")
    obj.effect("領域拡張", "上", DY, "下", DY, "左", DX, "右", DX, "塗りつぶし", 0)
    obj.effect(
        "ディスプレイスメントマップ",
        "param0",
        TLF.X,
        "param1",
        TLF.Y,
        "ぼかし",
        TLF.BL,
        "元のサイズに合わせる",
        1,
        "type",
        0,
        "name",
        "*tempbuffer",
        "mode",
        0,
        "calc",
        TLF.C
    )
    obj.effect("ぼかし", "範囲", B)
    obj.copybuffer("cache:LT_LIN", "obj")
else
    obj.copybuffer("obj", "tmp")
    obj.effect("ぼかし", "範囲", B)
    obj.copybuffer("cache:LT_LIN", "obj")
end
ws, hs = ws + B, hs + B
obj.setoption("drawtarget", "tempbuffer", ws, hs)
local CH0, CH1, A0, A1
if Md % 2 == 0 then
    CH0, CH1 = "cache:LT_ORG", "cache:LT_LIN"
    A0, A1 = OgA, LnA
else
    CH0, CH1 = "cache:LT_LIN", "cache:LT_ORG"
    A0, A1 = LnA, OgA
end
obj.copybuffer("obj", CH0)
obj.draw(0, 0, 0, 1, A0)
obj.copybuffer("obj", CH1)
if Md >= 4 then
    obj.setoption("blend", "alpha_sub")
    local wb, hb = obj.getpixel()
    local dx, dy = (ws - wb) / 2 + 1, (hs - hb) / 2 + 1
    obj.effect("領域拡張", "上", dy, "下", dy, "左", dx, "右", dx, "塗りつぶし", 0)
    obj.effect("反転", "透明度反転", 1)
elseif Md >= 2 then
    obj.setoption("blend", "alpha_sub")
end
obj.draw(0, 0, 0, 1, A1)
obj.copybuffer("obj", "tmp")
obj.setoption("blend", 0)
T_LineFill = nil
