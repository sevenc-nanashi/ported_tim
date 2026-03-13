--label:tim2\カスタムオブジェクト
---$track:外円サイズ
---min=0
---max=5000
---step=1
local track_size = 300

---$track:分割量
---min=2
---max=400
---step=1
local track_split_amount = 120

---$track:最大長%
---min=0
---max=2000
---step=0.1
local track_max_percent = 30

---$track:音量上限
---min=1
---max=100000
---step=1
local track_upper_limit = 30000

---$color:波形色1
local wave_color_1 = 0xc19ec1

---$color:波形色2
local wave_color_2 = 0x40acac

---$color:波形色3
local wave_color_3 = 0x5a72ec

---$color:円色1
local circle_color_1 = 0x40acac

---$color:円色2
local circle_color_2 = 0xed7aff

---$track:音量下限
---min=0
---max=100000
---step=1
local track_lower_limit = 0

---$track:境界補正
---min=0
---max=20
---step=1
local track_boundary_adjust = 2

---$value:サイズ配列
local size_array = { 4, 3, 4, 4, 1 }

---$value:個数配列
local count_array = { 100, 230, 180 }

---$value:速度配列
local speed_array = { 2, 2.8, 0 }

---$check:オリジナル背景設定
local check_original_background = false

---$track:└波形透明度％
---min=0
---max=100
---step=0.1
local track_wave_opacity_percent = 35

---$track:└時間オフセット
---min=-10000
---max=10000
---step=1
local track_time_offset = 1000

---$value:PI
local _0 = nil

---$check:波形反転
local check_reverse_waveform = false

local floor = math.floor
local abs = math.abs
local max = math.max
local min = math.min
local sin = math.sin
local cos = math.cos
local mpi = math.pi
local exp = math.exp
_0 = _0 or {}
local aoi = _0
if _0[1] == "蒼井" then
    _0 = {}
end
local Rev = _0[0] == nil and check_reverse_waveform or _0[0]
local Siz = math.floor(_0[1] or track_size)
local SpN = floor(_0[2] or track_split_amount)
local MxL = (_0[3] or track_max_percent) * Siz / 100
local SdU = floor(_0[4] or track_upper_limit)
local SdD = floor(track_lower_limit or 0)
local col1 = wave_color_1 or 0xc19ec1
local col2 = wave_color_2 or 0x40acac
local col3 = wave_color_3 or 0x5a72ec
local col4 = circle_color_1 or 0x40acac
local col5 = circle_color_2 or 0xed7aff
local Bor = track_boundary_adjust or 2
local S1, S2, S3, S4, S5 = unpack(size_array or { 4, 3, 4, 4, 1 })
local N1, N2, N3 = unpack(count_array or { 100, 230, 180 })
local V1, V2, V3 = unpack(speed_array or { 2, 2.8, 0 })
local Bap = check_original_background
local Wal = (track_wave_opacity_percent or 35) / 100
local Tof = (track_time_offset or 1000) + obj.time
_0 = nil
wave_color_1 = nil
wave_color_2 = nil
wave_color_3 = nil
circle_color_1 = nil
circle_color_2 = nil
track_lower_limit = nil
track_boundary_adjust = nil
size_array = nil
count_array = nil
speed_array = nil
check_original_background = nil
track_wave_opacity_percent = nil
track_time_offset = nil
check_reverse_waveform = nil
local SizH = Siz / 300
local dt = -obj.time / 180
S1 = (S1 or 4) * SizH
S1 = max(S1, 1)
S2 = (S2 or 1) * SizH
S2 = max(S2, 1)
S3 = (S3 or 4) * SizH
S3 = max(S3, 1)
S4 = (S4 or 3) * SizH
S4 = max(S4, 1)
S5 = (S5 or 4) * SizH
S5 = max(S5, 1)
N1 = N1 or 100
N2 = N2 or 230
N3 = N3 or 180
V1 = (V1 or 2) * dt
V2 = (V2 or 2.8) * dt
V3 = (V3 or 0) * dt
local N, rate, buf = obj.getaudio(nil, "audiobuffer", "pcm", 5000)
local Mus = {}
local SN = 3 * SpN
Bor = min(Bor, SpN - 1)
for i = 1, SN do
    local k = floor(1 + (i - 1) * (N - 1) / (SN - 1))
    local L = abs(buf[k])
    L = max(L, SdD)
    L = min(L, SdU)
    Mus[i] = L * MxL / SdU
end
if Rev then
    for i = 1, SN / 2 do
        Mus[i], Mus[SN - i + 1] = Mus[SN - i + 1], Mus[i]
    end
end
if Bor > 0 then
    for k = 0, 2 do
        local kSpN = k * SpN + 1
        local M = (Mus[kSpN + SpN - 1] + Mus[kSpN]) / 2
        Mus[kSpN] = M
        for i = 1, Bor - 1 do
            Mus[kSpN + i] = (Mus[kSpN + i] * i + M * (Bor - i)) / Bor
            Mus[kSpN + SpN - i] = (Mus[kSpN + SpN - i] * i + M * (Bor - i)) / Bor
        end
    end
end
local w = Siz + MxL + S4
if Bap then
    w = max(w, Siz * 678 / 300)
end
w = 2 * floor(w / 2) + 10
local h = w
w = w + abs(obj.screen_w - w) % 2
h = h + abs(obj.screen_h - h) % 2
if Bap then
    obj.setoption("drawtarget", "tempbuffer")
    obj.load("figure", "四角形", 0x00001e, 1)
    obj.effect("リサイズ", "ドット数でサイズ指定", 1, "X", w, "Y", h)
    obj.copybuffer("tmp", "obj")
    obj.load("figure", "円", 0x508787, Siz * 1.2)
    obj.effect("ぼかし", "範囲", Siz / 3 * 1.2)
    obj.draw()

    obj.load("figure", "円", 0x4a6074, 36 * SizH)
    for k = 1, 5 do
        local R = SizH * (150 + 36 * k)
        local dS = (k + 3) / (12 * k + 50)
        local n = 2 * mpi / dS
        local bai = (k + 4) / 18
        for i = 0, n do
            local sBai = bai * (n - i) / n
            local ss = i * dS - Tof * exp((0.205 * (k - 1)) ^ 3) / 35
            local x = R * cos(ss)
            local y = R * sin(ss)
            obj.draw(x, y, 0, sBai, 0.5)
        end
    end
    if Wal > 0 then
        obj.copybuffer("cache:wave", "tmp")
    end
else
    obj.setoption("drawtarget", "tempbuffer", w, h)
end
local MakeCircle = function(col, SS, NN, Vt, RR)
    obj.load("figure", "円", col, SS * 2)
    for i = 0, NN - 1 do
        local s = (i / NN * 2 + Vt) * mpi
        obj.draw(RR * cos(s), RR * sin(s), 0, 0.5)
    end
end
MakeCircle(col4, S1, N1, V1, Siz / 4)
MakeCircle(col4, S2, N2, V1, Siz / 2 * 0.95)
MakeCircle(col5, S3, N3, V2, Siz / 2)
local MakeWave = function(col, KK, RR)
    local NN1 = floor((KK - 1) * N / 3 + 1) -- N>2
    local NN2 = floor(KK * N / 3)
    local DD = (KK - 1) / 3
    local dt = (KK - 1) * SpN + 1
    obj.load("figure", "円", col, S4 * 2)
    for i = 0, SpN - 1 do
        local L2 = Mus[i + dt] / 2
        local s = ((i + DD) / SpN * 2 + V3) * mpi
        obj.draw((RR - L2) * cos(s), (RR - L2) * sin(s), 0, 0.5)
        obj.draw((RR + L2) * cos(s), (RR + L2) * sin(s), 0, 0.5)
    end
    for i = 0, SpN - 1 do
        local L = Mus[i + dt]
        local s = ((i + DD) / SpN * 2 + V3) * mpi
        local d = (i + DD) / SpN * 360 + 90 + V3 * 180
        obj.load("figure", "四角形", col, 1)
        obj.effect("リサイズ", "ドット数でサイズ指定", 1, "X", S5, "Y", L)
        obj.draw(RR * cos(s), RR * sin(s), 0, 1, 1, 0, 0, d)
    end
end
MakeWave(col1, 1, Siz * 5 / 16)
MakeWave(col2, 2, Siz * 6 / 16)
MakeWave(col3, 3, Siz * 7 / 16)
if Bap and Wal > 0 then
    obj.copybuffer("obj", "cache:wave")
    obj.draw(0, 0, 0, 1, Wal)
end
if aoi[1] == "蒼井" then
    local Lw = aoi[3] or Siz / 10
    local sf = { aoi[2] or "", Lw, aoi[4] or 3, aoi[5] or 0xffffff, aoi[6] or 0x0 }
    local txt1 = "前は・・・だれもまもれなかった・・・"
    local txt2 = "こんどはまもれましたか・・・？"
    local t = 3 * floor(6 * (obj.time - 2))
    obj.setfont(unpack(sf))
    obj.load("text", txt1)
    local w0 = obj.getpixel()
    txt1 = txt1:sub(1, max(t, 0))
    txt2 = txt2:sub(1, max(t - 54, 0))
    local w
    if txt1 ~= "" then
        obj.setfont(unpack(sf))
        obj.load("text", txt1)
        w = obj.getpixel()
        obj.draw(-w0 / 2 + w / 2, -Lw / 2 * 1.2)
        if txt2 ~= "" then
            obj.setfont(unpack(sf))
            obj.load("text", txt2)
            w = obj.getpixel()
            obj.draw(-w0 / 2 + w / 2, Lw / 2 * 1.2)
        end
    end
end
obj.copybuffer("object", "tempbuffer")
