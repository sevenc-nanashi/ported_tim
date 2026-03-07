--label:tim2\カスタムオブジェクト
---$track:サイズ
---min=1
---max=2000
---step=1
local track_size = 200

---$track:誤差％
---min=0
---max=100
---step=0.1
local track_percent = 30

---$track:線幅
---min=1
---max=200
---step=1
local track_line_width = 6

---$track:巻き数
---min=0
---max=200
---step=0.01
local track_count = 5

---$check:時間展開
local check0 = false

---$color:色
local param_color = 0xff0000

---$track:間隔
---min=0
---max=600
---step=0.1
local param_spacing = 0

---$track:中心ずれX
---min=-1000
---max=1000
---step=0.1
local param_center_offset_x = 0

---$track:中心ずれY
---min=-1000
---max=1000
---step=0.1
local param_center_offset_y = 0

local param_center_offset = { param_center_offset_x, param_center_offset_y }

---$track:減衰速度％
---min=-100
---max=100
---step=0.1
local param_attenuation_pct = 0

---$track:減衰形状
---min=0
---max=20
---step=0.1
local param_attenuation_shape = 0

---$track:円状
---min=0
---max=100
---step=0.1
local param_circle_ratio = 100

---$track:開始角度
---min=-360
---max=360
---step=0.1
local param_start_angle = 0

---$track:半径ｵﾌｾｯﾄ
---min=-1000
---max=1000
---step=0.1
local param_radius_offset = 0

---$track:誤差比
---min=-100
---max=100
---step=0.1
local param_error_balance = 0

---$select:時間展開法
---等速度=0
---等角速度=1
---反転等速度=2
---反転等角速度=3
local param_time_expand_mode = 0

---$track:周分割
---min=3
---max=30
---step=1
local param_circumference_divisions = 4

---$track:分解能
---min=1
---max=50
---step=1
local param_resolution = 40

---$track:重ね描き
---min=0
---max=20
---step=1
local param_overdraw_count = 0

---$track:シード
---min=0
---max=1000000
---step=1
local param_seed = 0

---$track:└変化間隔
---min=0
---max=10000
---step=1
local param_seed_step = 0

---$value:PI
local param_override = {}

local PI = math.pi
local sin = math.sin
local cos = math.cos
local max = math.max
local min = math.min
local abs = math.abs
local sqrt = math.sqrt
local floor = math.floor
local ceil = math.ceil
param_override = param_override or {}
local SZ = (param_override[1] or track_size) / 2
local RS = (param_override[2] or track_percent) / 100
local Lw = floor(param_override[3] or track_line_width)
local RN = param_override[4] or track_count
local CL = param_color or 0xffffff
local DN = abs(param_spacing or 2)
if DN < 1 then
    DN = math.log(Lw)
    DN = (0.5126 * DN + 0.4641) * DN
    DN = math.max(DN, 1)
end
local CT = param_center_offset or { 0, 0 }
CT[1] = (CT[1] or 0) / RN
CT[2] = abs(CT[2] or 0) / RN
local AT = abs(param_attenuation_pct or 0) / 100
local AA = abs(param_attenuation_shape or 0) + 1
local HP = (param_circle_ratio or 100) / 100
HP = max(HP, 0)
HP = min(HP, 1)
local RT = param_time_expand_mode or 0
local f0 = math.rad(param_start_angle or 0)
local R0 = abs(param_radius_offset or 0)
local AS = (param_error_balance or 0) / 100
AS = max(AS, -1)
AS = min(AS, 1)
local RS1 = (AS >= 0 and 1 or 1 + AS) * RS
local RS2 = (AS >= 0 and 1 - AS or 1) * RS
local CN = floor(param_circumference_divisions or 4)
CN = max(CN, 3)
CN = min(CN, 30)
local RE = floor(abs(param_resolution or 10))
RE = max(RE, 1)
RE = min(RE, 50)
local Ju = floor(abs(param_overdraw_count or 0))
if Ju == 0 then
    if Lw < 4 then
        Ju = ({ 5, 3, 2 })[Lw]
    else
        Ju = 1
    end
end
local SD = abs(param_seed or 0) + 1
local SR = floor(param_seed_step or 0)
local CK = param_override[0] == nil and check0 or param_override[0]
-- param_override = nil
-- param_color = nil
-- param_spacing = nil
-- param_center_offset = nil
-- param_attenuation_pct = nil
-- param_attenuation_shape = nil
-- param_circle_ratio = nil
-- param_time_expand_mode = nil
-- param_start_angle = nil
-- param_radius_offset = nil
-- param_error_balance = nil
-- param_circumference_divisions = nil
-- param_resolution = nil
-- param_overdraw_count = nil
-- param_seed = nil
-- param_seed_step = nil
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
        interpolationT = function(t, prev_x, prev_y, cur_x, cur_y, next_x, next_y, next2_x, next2_y)
            local x, y = obj.interpolation(t, prev_x, prev_y, cur_x, cur_y, next_x, next_y, next2_x, next2_y)
            local x21, y21 = next_x - cur_x, next_y - cur_y
            local dx1, dy1 = next_x - prev_x, next_y - prev_y
            local dx2, dy2 = cur_x - next2_x, cur_y - next2_y
            local D = dx2 * dy1 - dx1 * dy2
            local A = (-dy2 * x21 + dx2 * y21) / D * Asp
            local B = (-dy1 * x21 + dx1 * y21) / D * Asp
            A = min(A, 0.75)
            A = max(A, 0)
            B = min(B, 0.75)
            B = max(B, 0)
            local it = 1 - t
            local u1, v1 = cur_x + A * dx1, cur_y + A * dy1
            local u2, v2 = next_x + B * dx2, next_y + B * dy2
            local X1, Y1 = it * cur_x + t * u1, it * cur_y + t * v1
            local X2, Y2 = it * u1 + t * u2, it * v1 + t * v2
            local X3, Y3 = it * u2 + t * next_x, it * v2 + t * next_y
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
    local calc_max_dimension = function(values, screen_size, max_limit)
        local max_value = values[0]
        local min_value = values[0]
        local N = #values
        for i = 1, N do
            max_value = max_value < values[i] and values[i] or max_value
        end
        for i = 1, N do
            min_value = min_value > values[i] and values[i] or min_value
        end
        max_value = max(abs(max_value), abs(min_value))
        max_value = floor(max_value + Lw / 2 + 5)
        max_value = 2 * max_value + screen_size % 2
        return min(max_value, max_limit)
    end
    local max_x, max_y = obj.getinfo("image_max")
    local XMAX = calc_max_dimension(Xs, obj.screen_w, max_x)
    local YMAX = calc_max_dimension(Ys, obj.screen_h, max_y)
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
