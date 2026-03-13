--label:tim2\装飾
---$track:サイズ
---min=0
---max=3000
---step=1
local track_size = 200

---$track:線幅
---min=1
---max=500
---step=1
local track_line_width = 5

---$track:変動量
---min=-500
---max=500
---step=0.1
local track_fluctuation_amount = 10

---$track:変動長
---min=2
---max=5000
---step=1
local track_fluctuation_length = 70

---$color:線色
local param_line_color = 0xffffff

---$figure:形状
local param_figure = "円"

---$track:延長%
---min=-100
---max=500
---step=0.1
local param_extension_pct = 10

---$track:縦横比
---min=-100
---max=100
---step=0.1
local param_aspect_ratio = 0

---$track:点間隔
---min=0
---max=200
---step=1
local param_dot_spacing = 2

---$track:追加角度
---min=-360
---max=360
---step=0.1
local param_additional_angle = 0

---$check:└自動方向
local param_auto_direction = 0

---$track:分割精度
---min=1
---max=200
---step=1
local param_subdivision_precision = 10

---$track:重ね描き
---min=1
---max=20
---step=1
local param_overdraw_count = 1

---$check:└自動調整
local param_auto_adjust_overdraw = 1

---$track:シード
---min=0
---max=1000000
---step=1
local param_seed = 0

---$track:└変化間隔
---min=0
---max=10000
---step=1
local param_seed_change_interval = 0

---$value: PI
local param_override = {}

---$check:単一線
local check0 = false

param_override = param_override or {}
local FgS = math.floor(param_override[1] or track_size)
local LnW = math.floor(param_override[2] or track_line_width)
local LnA = (param_override[3] or track_fluctuation_amount)
local LnL = math.floor(param_override[4] or track_fluctuation_length)
local Col = param_line_color or 0xffffff
local Fig = param_figure or "円"
local SmL = (param_extension_pct or 0) / 100
local Asp = (param_aspect_ratio or 0) / 100
local DoS = math.floor(param_dot_spacing or 1)
local drz = param_additional_angle or 0
local AuA = param_auto_direction == 1
local Sn = math.floor(param_subdivision_precision or 10)
local Ju = math.floor(param_overdraw_count or 1)
local JA = param_auto_adjust_overdraw == 1
local SeD = param_seed or 0
local ChI = param_seed_change_interval or 0
local SL = param_override[0] == nil and check0 or param_override[0]
if DoS == 0 then
    DoS = math.floor(2 * math.sqrt(0.2 * (2 * LnW - 0.2)))
end --円と円の交わりによる窪みが0.2ピクセル以下
DoS = math.max(DoS, 1)
Sn = math.max(Sn, 1)
if JA and LnW < 4 then
    Ju = ({ 5, 3, 2 })[LnW]
end
Asp = math.max(Asp, -1)
Asp = math.min(Asp, 1)
if string.find(tostring(SeD), "table:") then
    local ss = SeD[1] or 0
    SeD[1] = math.abs(math.floor(ss)) + 2
    for i = 2, 4 do
        SeD[i] = math.abs(math.floor(SeD[i] or ss)) + 2
    end
else
    SeD = math.abs(math.floor(SeD or 0)) + 2
    SeD = { SeD, SeD, SeD, SeD }
end
if ChI > 0 then
    iS = math.floor(obj.time * obj.framerate / ChI)
    for i = 1, 4 do
        SeD[i] = SeD[i] + iS
    end
end
obj.load("figure", Fig, Col, LnW * 2)
obj.effect("リサイズ", "拡大率", 50 * obj.zoom)
obj.zoom = 1
local Pset = function(X0, Y0, sgn, Cx, Cy, NN, LL, XX, YY, Rot, Sdn)
    local ds = DoS
    local x0, y0 = X0, Y0
    local x1, y1 = XX[sgn], YY[sgn]
    local rz0 = 90 * (4 - sgn - 2 * math.abs(Sdn - 2.5)) --({0,180,180,0})[Sdn]
    for i = 1, NN do
        local x2, y2 = XX[sgn * (i + 1)], YY[sgn * (i + 1)]
        local Lng = math.sqrt((x1 - x0) * (x1 - x0) + (y1 - y0) * (y1 - y0))
        local rz = drz
        if AuA then
            rz = rz + math.atan2(y2 - y0, x2 - x0) / math.pi * 180 + rz0
        end
        while Lng > ds do
            local s = ds / Lng
            local X, Y = (1 - s) * x0 + s * x1, (1 - s) * y0 + s * y1
            if 2 * sgn * ((1 - Rot) * X + Rot * Y) > LL then
                return
            end
            obj.draw(X + Cx, Y + Cy, 0, 1, 1, 0, 0, rz)
            ds = ds + DoS
        end
        ds = ds - Lng
        x0, y0, x1, y1 = x1, y1, x2, y2
    end
end
local Lset = function(LL, Cx, Cy, Sdn, Rot)
    local Ns = math.ceil(LL / LnL / 2) + 3
    local Ps = {}
    local RND = 4 * SeD[Sdn] + Sdn
    Ps[0] = LnA * obj.rand(-500, 500, -2, RND) / 1000
    for i = 1, Ns do
        Ps[i] = LnA * obj.rand(-500, 500, -(2 * i + 2), RND) / 1000
        Ps[-i] = LnA * obj.rand(-500, 500, -(2 * i + 1), RND) / 1000
    end
    local XX = {}
    local YY = {}
    local NN = -1
    local x0, y0, z0, x1, y1, z1, x2, y2, z2 = -LnL, Ps[-1], Ps[1], 0, Ps[0], Ps[0], LnL, Ps[1], Ps[-1]
    for i = 0, Ns - 2 do
        local x3, y3, z3 = LnL * (i + 2), Ps[i + 2], Ps[-i - 2]
        for j = 0, Sn - 1 do
            local t = j / Sn
            NN = NN + 1
            XX[NN], YY[NN] = obj.interpolation(t, x0, y0, x1, y1, x2, y2, x3, y3)
            XX[-NN], YY[-NN] = obj.interpolation(t, -x0, z0, -x1, z1, -x2, z2, -x3, z3)
        end
        x0, y0, z0, x1, y1, z1, x2, y2, z2 = x1, y1, z1, x2, y2, z2, x3, y3, z3
    end
    if Rot == 1 then
        XX, YY = YY, XX
    end
    local X0, Y0 = XX[0], YY[0]
    local rz = drz
    if AuA then
        rz = rz + (math.atan2(YY[1] - YY[-1], XX[1] - XX[-1]) / math.pi + 1.5 - math.abs(Sdn - 2.5)) * 180
    end
    obj.draw(X0 + Cx, Y0 + Cy, 0, 1, 1, 0, 0, rz)
    Pset(X0, Y0, 1, Cx, Cy, NN, LL, XX, YY, Rot, Sdn)
    Pset(X0, Y0, -1, Cx, Cy, NN, LL, XX, YY, Rot, Sdn)
end
local LL1, LL2 = FgS, FgS
local dL = FgS * 2 * SmL
local idL = math.max(dL, 0)
local WS, HS
if SL then
    HS = LnW + 10
    WS = HS + FgS + idL
    HS = HS + math.abs(LnA)
else
    if Asp > 0 then
        LL2 = LL2 * (1 - Asp)
    else
        LL1 = LL1 * (1 + Asp)
    end
    local LA2 = math.abs(LnA) + idL + LnW + 10
    WS, HS = math.floor(LL1 + LA2), math.floor(LL2 + LA2)
end
obj.setoption("drawtarget", "tempbuffer", WS + (obj.screen_w - WS) % 2, HS + (obj.screen_h - HS) % 2)
if SL then
    Lset(LL1 + dL, 0, 0, 1, 0)
else
    Lset(LL1 + dL, 0, -LL2 / 2, 1, 0) --上
    Lset(LL1 + dL, 0, LL2 / 2, 2, 0) --下
    Lset(LL2 + dL, -LL1 / 2, 0, 3, 1) --左
    Lset(LL2 + dL, LL1 / 2, 0, 4, 1) --右
end
obj.copybuffer("obj", "tmp")
for i = 2, Ju do
    obj.draw()
    obj.copybuffer("obj", "tmp")
end
