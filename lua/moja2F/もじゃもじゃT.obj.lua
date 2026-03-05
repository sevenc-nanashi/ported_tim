--label:tim2
--track0:サイズ,1,2000,200,1
--track1:誤差％,0,100,30
--track2:線幅,1,200,6,1
--track3:巻き数,0,200,5,0.01
--check0:時間展開,0;
--value@_1:色/col,0xff0000
--value@_2:間隔,0
--value@_3:中心ずれサイズ,{0,0}
--value@_4:減衰速度％,0
--value@_5:減衰形状,0
--value@_6:円状≦100,100
--value@_8:開始角度,0
--value@_9:半径ｵﾌｾｯﾄ,0
--value@_10:誤差比[-100..100],0
--value@_7:時間展開法[0..3],0
--value@_11:周分割≦30,4
--value@_12:分解能≦50,40
--value@_13:重ね描き,0
--value@_14:シード,0
--value@_15:└変化間隔,0
--value@_0:PI,nil
local PI = math.pi
local sin = math.sin
local cos = math.cos
local max = math.max
local min = math.min
local abs = math.abs
local sqrt = math.sqrt
local floor = math.floor
local ceil = math.ceil
_0 = _0 or {}
local SZ = (_0[1] or obj.track0) / 2
local RS = (_0[2] or obj.track1) / 100
local Lw = floor(_0[3] or obj.track2)
local RN = _0[4] or obj.track3
local CL = _1 or 0xffffff
local DN = abs(_2 or 2)
if DN < 1 then
    DN = math.log(Lw)
    DN = (0.5126 * DN + 0.4641) * DN
    DN = math.max(DN, 1)
end
local CT = _3 or { 0, 0 }
CT[1] = (CT[1] or 0) / RN
CT[2] = abs(CT[2] or 0) / RN
local AT = abs(_4 or 0) / 100
local AA = abs(_5 or 0) + 1
local HP = (_6 or 100) / 100
HP = max(HP, 0)
HP = min(HP, 1)
local RT = _7 or 0
local f0 = math.rad(_8 or 0)
local R0 = abs(_9 or 0)
local AS = (_10 or 0) / 100
AS = max(AS, -1)
AS = min(AS, 1)
local RS1 = (AS >= 0 and 1 or 1 + AS) * RS
local RS2 = (AS >= 0 and 1 - AS or 1) * RS
local CN = floor(_11 or 4)
CN = max(CN, 3)
CN = min(CN, 30)
local RE = floor(abs(_12 or 10))
RE = max(RE, 1)
RE = min(RE, 50)
local Ju = floor(abs(_13 or 0))
if Ju == 0 then
    if Lw < 4 then
        Ju = ({ 5, 3, 2 })[Lw]
    else
        Ju = 1
    end
end
local SD = abs(_14 or 0) + 1
local SR = floor(_15 or 0)
local CK = _0[0] == nil and obj.check0 or _0[0]
_0 = nil
_1 = nil
_2 = nil
_3 = nil
_4 = nil
_5 = nil
_6 = nil
_7 = nil
_8 = nil
_9 = nil
_10 = nil
_11 = nil
_12 = nil
_13 = nil
_14 = nil
_15 = nil
obj.load("figure", "円", CL, Lw * 2)
obj.effect("リサイズ", "拡大率", 50)
if RN == 0 then
    obj.alpha = 0
else
    local Asp = 0.6
    if CN == 3 then
        Asp = 0.44
    elseif CN == 4 then
        Asp = 0.55
    end
    local interpolationT
    if RS >= 0.1 then
        interpolationT = obj.interpolation
    else
        interpolationT = function(t, x0, y0, x1, y1, x2, y2, x3, y3)
            local x, y = obj.interpolation(t, x0, y0, x1, y1, x2, y2, x3, y3)
            local x21, y21 = x2 - x1, y2 - y1
            local dx1, dy1 = x2 - x0, y2 - y0
            local dx2, dy2 = x1 - x3, y1 - y3
            local D = dx2 * dy1 - dx1 * dy2
            local A = (-dy2 * x21 + dx2 * y21) / D * Asp
            local B = (-dy1 * x21 + dx1 * y21) / D * Asp
            A = min(A, 0.75)
            A = max(A, 0)
            B = min(B, 0.75)
            B = max(B, 0)
            local it = 1 - t
            local u1, v1 = x1 + A * dx1, y1 + A * dy1
            local u2, v2 = x2 + B * dx2, y2 + B * dy2
            local X1, Y1 = it * x1 + t * u1, it * y1 + t * v1
            local X2, Y2 = it * u1 + t * u2, it * v1 + t * v2
            local X3, Y3 = it * u2 + t * x2, it * v2 + t * y2
            X1, Y1 = it * X1 + t * X2, it * Y1 + t * Y2
            X2, Y2 = it * X2 + t * X3, it * Y2 + t * Y3
            X1, Y1 = it * X1 + t * X2, it * Y1 + t * Y2
            local s = RS / 0.1
            x, y = (1 - s) * X1 + s * x, (1 - s) * Y1 + s * y
            return x, y
        end
    end
    if SR > 0 then
        SD = SD + floor(obj.time * obj.framerate / SR)
    end
    CT[1] = CT[1] / CN
    CT[2] = CT[2] / CN
    local RNi = ceil(RN)
    local RNx = CN * RNi
    local Y = {}
    local X = {}
    for i = -1, RNx + 1 do
        local R = SZ * (1 + RS1 * obj.rand(-1000, 1000 * 0, -SD, 2 * i + 3) / 1000)
        local f = 2 * PI / CN * (i + RS2 * obj.rand(-1000, 1000, -SD, 2 * i + 4) / 1000) + f0
        local x = max(1 - i / RNx, 0)
        x = min(x, 1)
        R = R * (1 - AT * (1 - math.pow(x, AA))) + R0
        R = R > 0 and (R < SZ and R or SZ) or 0
        X[i] = R * sin(f)
        Y[i] = R * cos(f)
    end
    local RNx2 = RNx / 2
    local ocx = CT[1] * RNx2
    local ocy = CT[2] * RNx2
    local Ys = {}
    local Xs = {}
    for i = 0, RNx - 1 do
        local x0, y0, x1, y1, x2, y2, x3, y3 = X[i - 1], Y[i - 1], X[i], Y[i], X[i + 1], Y[i + 1], X[i + 2], Y[i + 2]
        for s = 0, RE - 1 do
            local k = RE * i + s
            local sRE = s / RE
            local x, y = interpolationT(sRE, x0, y0, x1, y1, x2, y2, x3, y3)
            Xs[k], Ys[k] = x + CT[1] * ((i + sRE) - RNx2), -HP * y + CT[2] * ((i + sRE) - RNx2)
        end
    end
    local x, y = X[RNx] + CT[1] * RNx2, -HP * Y[RNx] + CT[2] * RNx2
    local REx = RE * RNx
    Xs[REx] = x
    Ys[REx] = y
    local MaxMin = function(XX, screen, max_z)
        local Zmax = XX[0]
        local Zmin = XX[0]
        local N = #XX
        for i = 1, N do
            Zmax = Zmax < XX[i] and XX[i] or Zmax
        end
        for i = 1, N do
            Zmin = Zmin > XX[i] and XX[i] or Zmin
        end
        Zmax = max(abs(Zmax), abs(Zmin))
        Zmax = floor(Zmax + Lw / 2 + 5)
        Zmax = 2 * Zmax + screen % 2
        return min(Zmax, max_z)
    end
    local max_x, max_y = obj.getinfo("image_max")
    local XMAX = MaxMin(Xs, obj.screen_w, max_x)
    local YMAX = MaxMin(Ys, obj.screen_h, max_y)
    obj.setoption("drawtarget", "tempbuffer", XMAX, YMAX)
    RN = REx * RN / RNi
    RNx = floor(RN)
    local dN = RN - RNx
    local TLT = RNx
    if dN > 0 then
        RN = RNx + 1
        Xs[RN], Ys[RN], TLT =
            (1 - dN) * Xs[RNx] + dN * Xs[RN], (1 - dN) * Ys[RNx] + dN * Ys[RN], (1 - dN) * RNx + dN * RN
    end
    local U = {}
    local V = {}
    local W = {}
    local x0, y0, t0, dA, Nk = Xs[0], Ys[0], 0, 0, 0
    for i = 1, RN do
        local TT = i < RN and i or TLT
        local x1, y1, t1 = Xs[i], Ys[i], TT
        local dx, dy = (x1 - x0), (y1 - y0)
        local L = sqrt(dx * dx + dy * dy)
        if dA > L then
            dA = dA - L
        else
            dL = L - dA
            local n = floor(dL / DN)
            for k = 0, n do
                local t = dA / L
                Nk = Nk + 1
                U[Nk], V[Nk], W[Nk] = (1 - t) * x0 + t * x1, (1 - t) * y0 + t * y1, (1 - t) * t0 + t * t1
                dA = dA + DN
            end
            dA = dA - L
        end
        x0, y0, t0 = x1, y1, t1
    end
    local STi, EDi, SPi = 1, Nk, 1
    if CK then
        local t = obj.time / obj.totaltime
        if RT == 1 then
            local WW = W[Nk] * t
            for i = 1, Nk do
                if W[i] > WW then
                    break
                end
                EDi = i
            end
        elseif RT == 2 then
            STi, EDi, SPi = Nk, Nk - (Nk - 1) * t, -1
        elseif RT == 3 then
            local WW = W[Nk] * (1 - t)
            for i = Nk, 1, -1 do
                if W[i] < WW then
                    break
                end
                EDi = i
            end
            STi, SPi = Nk, -1
        else
            EDi = 1 + (Nk - 1) * t
        end
    end
    for i = STi, EDi, SPi do
        obj.draw(U[i], V[i])
    end
    obj.copybuffer("obj", "tmp")
    for i = 2, Ju do
        obj.draw()
        obj.copybuffer("obj", "tmp")
    end
    obj.cx = -ocx
    obj.cy = -ocy
end
