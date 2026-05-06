--label:${ROOT_CATEGORY}\装飾
---$track:描画度
---min=0
---max=100
---step=0.1
local track_draw_amount = 100

---$track:線幅
---min=0
---max=1000
---step=0.1
local track_line_width = 10

---$track:開始点
---min=0
---max=100
---step=0.1
local track_start_point = 0

---$track:閾値
---min=0
---max=255
---step=1
local track_threshold = 128

---$color:色
local col = 0xffffff

---$check:逆回転
local rev = 0

---$check:輪郭のみ
local rin = 0

---$check:輪郭を下に
local Rover = 0

---$check:中心補正
local reC = 1

---$track:スキャン粗さ
---min=1
---max=100
---step=1
local Scsp = 1

--group:拡張機能,false

---$check:拡張機能を使用
local use_extension = 0

---$track:破線周期
---min=0
---max=100
---step=0.01
local track_line_period = 5

---$track:破線間隔
---min=0
---max=100
---step=0.01
local track_line_spacing = 2.5

---$track:滑らかさ
---min=0
---max=1000
---step=1
local track_smoothness = 0

---$track:本体透明度
---min=0
---max=100
---step=0.1
local track_opacity = 0

---$figure:形状
local extension_figure = "円"

---$check:進行方向
local extension_direction = 0

---$check:先端表示
local extension_tip_enabled = 0

---$figure:先端図形
local extension_tip_figure = "三角形"

---$track:先端サイズ
---min=0
---max=1000
---step=1
local extension_tip_size = 50

--group:

local icx = obj.cx
local icy = obj.cy
reC = reC or 0

local fig, ivf, ivl, td, sm, halp, senp, senz, sens

if use_extension == 1 then
    fig = extension_figure
    ivf = track_line_period * 0.01
    ivl = track_line_spacing * 0.01
    td = extension_direction
    sm = math.floor(track_smoothness)
    halp = 1 - track_opacity * 0.01
    senp = extension_tip_enabled
    senz = extension_tip_figure
    sens = extension_tip_size
elseif Trin_ehn == nil then
    fig = "円"
    ivf = 1
    ivl = 0
    td = 0
    sm = 0
    halp = 1
    senp = 0
    senz = nil
    sens = nil
else
    fig = Trin_ehn.fig
    ivf = Trin_ehn.ivf
    ivl = Trin_ehn.ivl
    td = Trin_ehn.td
    sm = Trin_ehn.sm
    halp = Trin_ehn.halp
    senp = Trin_ehn.senp
    senz = Trin_ehn.senz
    sens = Trin_ehn.sens
end

local hp = track_draw_amount * 0.01
local lw = track_line_width
local zure = track_start_point * 0.01
local T = track_threshold
Scsp = math.floor(Scsp or 1)
Scsp = (Scsp < 1 and 1) or Scsp

local tim2 = obj.module("tim2")
local userdata, w, h = obj.getpixeldata("object", "bgra")
local nn, ALL, points = tim2.rgline_trace_contour(userdata, w, h, T, Scsp, sm)
local ii = math.floor(nn * zure)

obj.setoption("drawtarget", "tempbuffer", w + lw, h + lw)

if rin == 0 and Rover ~= 1 then
    obj.draw(0, 0, 0, 1, halp)
else
    obj.copybuffer("cache:IMG", "obj")
end

obj.load("figure", fig, col, lw)

local ALP = ALL * hp
local AL = 0
local i = 0
local oz
local px
local py

if ALP > 0 and ALL > 0 and nn > 0 then
    repeat
        i = i + 1
        ii = (i + math.floor(nn * zure)) % nn
        if rev == 0 then
            ii = nn - ii - 1
        end
        ii = ii + 1
        local base = (ii - 1) * 4
        px = points[base + 1]
        py = points[base + 2]
        AL = AL + points[base + 3]

        local hanl = AL / ALL
        local count = math.floor(hanl / ivf)

        if count * ivf < hanl and hanl <= (count + 1) * ivf - ivl then
            if td == 1 then
                oz = points[base + 4]
            else
                oz = 0
            end
            obj.draw(px - w / 2, py - h / 2, 0, 1, 1, 0, 0, oz)
        end
    until AL >= ALP

    if senp == 1 then
        obj.load("figure", senz, col, sens)
        obj.draw(px - w / 2, py - h / 2, 0, 1, 1, 0, 0, (oz or 0) - 90)
    end
end

if rin == 0 and Rover == 1 then
    obj.copybuffer("obj", "cache:IMG")
    obj.draw(0, 0, 0, 1, halp)
end

obj.load("tempbuffer")

if reC == 1 then
    obj.cx = icx
    obj.cy = icy
end
