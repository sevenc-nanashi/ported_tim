--label:tim2
--track0:揺れ角,0,360,30
--track1:揺れ周期,0.01,100,2,0.01
--track2:揺れズレ,-360,360,90
--track3:センター,-180,180,0
--value@N:分割,10
--value@dL:上固定長％,10
--value@dL2:下固定長％,10
--value@UB:下を基準/chk,0
--value@rndF:ランダム揺れ量/chk,0
--value@seed:ランダム揺れﾊﾟﾀｰﾝ,0
--value@sft:時間ずれ,0.1
--value@rep:横に繰り返す/chk,0
--value@repN:繰り返し個数,3
--value@stepX:間隔,50
--value@Frd:破綻軽減/chk,0
--check0:アルファ補正,1;

local w, h = obj.getpixel()
local w2, h2 = w / 2, h / 2
local t = obj.time
if UB == 1 then
    dL, dL2 = dL2, dL
end
if dL < 0 then
    dL = 0
elseif dL > 100 then
    dL = 100
end
if dL2 < 0 then
    dL2 = 0
elseif dL2 > 100 - dL then
    dL2 = 100 - dL
end
dL = dL * 0.01 * h
dL2 = dL2 * 0.01 * h
local L = h - dL - dL2 --長さ
local F = math.pi * obj.track0 / 180 --揺れ幅
local dt = obj.track1
local c = 2 * math.pi / dt --揺れ速度
local d = 2 * obj.track2 * math.pi / 180 --揺れズレ
local CNT = obj.track3 * math.pi / 180 --センター
local alp = obj.check0 and 1 or 0
seed = 10 + math.abs(seed)

WindShakeT = function(n)
    local t = t - n * sft
    local F = F
    if rndF == 1 then
        local s = t / dt
        local n1 = math.floor(s)
        local n0 = n1 - 1
        local n2 = n1 + 1
        local n3 = n1 + 2
        local m0 = n0 + 1
        local m1 = n1 + 1
        local m2 = n2 + 1
        local m3 = n3 + 1

        if n0 < 0 then
            m0 = 10000 - n0
        end
        if n1 < 0 then
            m1 = 10000 - n1
        end
        if n2 < 0 then
            m2 = 10000 - n2
        end
        if n3 < 0 then
            m3 = 10000 - n3
        end

        s = s - n1
        local f0 = obj.rand(0, 1000, -seed, m0) * F * 0.001
        local f1 = obj.rand(0, 1000, -seed, m1) * F * 0.001
        local f2 = obj.rand(0, 1000, -seed, m2) * F * 0.001
        local f3 = obj.rand(0, 1000, -seed, m3) * F * 0.001
        F = obj.interpolation(s, f0, f1, f2, f3)
    end
    local X = {}
    local Y = {}
    local V = {}
    X[0] = 0
    Y[0] = 0
    for i = 1, N do
        local Si = (F * math.sin((c * t - i * d / N)) + CNT) * (1 - (1 - i / N) ^ 4)
        X[i] = X[i - 1] + math.sin(Si)
        Y[i] = Y[i - 1] + math.cos(Si)
    end
    local a = L / N
    for i = 0, N do
        X[i] = X[i] * a
        Y[i] = Y[i] * a + dL - h2
        V[i] = a * i + dL
    end
    X[-1] = 0
    Y[-1] = -h2
    V[-1] = 0
    local X1 = {}
    local X2 = {}
    local Y1 = {}
    local Y2 = {}
    X1[-1] = -w2
    X2[-1] = w2
    Y1[-1] = -h2
    Y2[-1] = -h2

    for i = 0, N do
        local dx = X[i] - X[i - 1]
        local dy = Y[i] - Y[i - 1]
        dx, dy = -dy, dx
        local dr = math.sqrt(dx * dx + dy * dy)
        if dr ~= 0 then
            dx, dy = dx / dr * w2, dy / dr * w2
            X1[i] = X[i] + dx
            X2[i] = X[i] - dx
            Y1[i] = Y[i] + dy
            Y2[i] = Y[i] - dy
        else
            X1[i] = X1[i - 1]
            X2[i] = X2[i - 1]
            Y1[i] = Y1[i - 1]
            Y2[i] = Y2[i - 1]
        end
    end

    if dL2 > 0 then
        local dx = X[N] - X[N - 1]
        local dy = Y[N] - Y[N - 1]
        local dr = math.sqrt(dx * dx + dy * dy)
        dx, dy = dx / dr * dL2, dy / dr * dL2
        X1[N + 1] = X1[N] + dx
        X2[N + 1] = X2[N] + dx
        Y1[N + 1] = Y1[N] + dy
        Y2[N + 1] = Y2[N] + dy
        V[N + 1] = h
        N = N + 1
    end

    local minX = -w2
    local maxX = w2
    local minY = -h2
    local maxY = -h2
    for i = 0, N do
        if minX > X1[i] then
            minX = X1[i]
        elseif maxX < X1[i] then
            maxX = X1[i]
        end
        if minX > X2[i] then
            minX = X2[i]
        elseif maxX < X2[i] then
            maxX = X2[i]
        end
        if minY > Y1[i] then
            minY = Y1[i]
        elseif maxY < Y1[i] then
            maxY = Y1[i]
        end
        if minY > Y2[i] then
            minY = Y2[i]
        elseif maxY < Y2[i] then
            maxY = Y2[i]
        end
    end
    local WW = maxX - minX
    local HH = maxY - minY
    local CX = (maxX + minX) * 0.5
    local CY = (maxY + minY) * 0.5
    for i = -1, N do
        X1[i] = X1[i] - CX
        X2[i] = X2[i] - CX
        Y1[i] = Y1[i] - CY
        Y2[i] = Y2[i] - CY
    end
    obj.setoption("drawtarget", "tempbuffer", WW, HH)
    obj.setoption("blend", "alpha_add2")
    local drawpolyT = (function()
        if Frd == 1 then
            return function(x0, y0, x1, y1, x2, y2, x3, y3, v0, v1)
                local xc, yc = (x0 + x1 + x2 + x3) / 4, (y0 + y1 + y2 + y3) / 4
                local vc = (v0 + v1) / 2
                obj.drawpoly(x0, y0, 0, x1, y1, 0, xc, yc, 0, xc, yc, 0, 0, v0, w, v0, w2, vc, w2, vc)
                obj.drawpoly(x1, y1, 0, x2, y2, 0, xc, yc, 0, xc, yc, 0, w, v0, w, v1, w2, vc, w2, vc)
                obj.drawpoly(x3, y3, 0, x0, y0, 0, xc, yc, 0, xc, yc, 0, 0, v1, 0, v0, w2, vc, w2, vc)
                obj.drawpoly(x2, y2, 0, x3, y3, 0, xc, yc, 0, xc, yc, 0, w, v1, 0, v1, w2, vc, w2, vc)
            end
        else
            return function(x0, y0, x1, y1, x2, y2, x3, y3, v0, v1)
                obj.drawpoly(x0, y0, 0, x1, y1, 0, x2, y2, 0, x3, y3, 0, 0, v0, w, v0, w, v1, 0, v1)
            end
        end
    end)()
    for i = 0, N do
        drawpolyT(X1[i - 1], Y1[i - 1], X2[i - 1], Y2[i - 1], X2[i], Y2[i], X1[i], Y1[i], V[i - 1], V[i])
    end
    if alp == 1 then
        obj.copybuffer("cache:col", "tmp")
        obj.load("figure", "四角形", 0x0, 1)
        obj.effect("リサイズ", "X", w, "Y", h, "ドット数でサイズ指定", 1)
        obj.copybuffer("tmp", "obj")
        obj.copybuffer("obj", "cache:org")
        obj.effect("単色化", "輝度を保持する", 0)
        obj.setoption("blend", 0)
        obj.draw()
        obj.copybuffer("obj", "tmp")
        obj.setoption("drawtarget", "tempbuffer", WW, HH)
        obj.setoption("blend", "alpha_add2")
        for i = 0, N do
            --obj.drawpoly(X1[i-1],Y1[i-1],0, X2[i-1],Y2[i-1],0, X2[i],Y2[i],0, X1[i],Y1[i],0, 0,V[i-1], w,V[i-1], w,V[i], 0,V[i])
            drawpolyT(X1[i - 1], Y1[i - 1], X2[i - 1], Y2[i - 1], X2[i], Y2[i], X1[i], Y1[i], V[i - 1], V[i])
        end
        obj.copybuffer("obj", "tmp")
        obj.effect("ルミナンスキー", "基準輝度", 0, "ぼかし", 4096, "type", 1)
        obj.copybuffer("tmp", "cache:col")
        obj.setoption("blend", "alpha_sub")
        obj.draw()
        obj.setoption("blend", 0)
    end
    return WW, HH, CX, CY
end

if UB == 1 then
    obj.effect("反転", "上下反転", 1)
end
if alp == 1 then
    obj.setoption("drawtarget", "tempbuffer")
    obj.copybuffer("cache:org", "obj")
    obj.copybuffer("tmp", "obj")
    obj.effect("反転", "透明度反転", 1)
    obj.setoption("blend", "alpha_add2")
    obj.draw()
    obj.copybuffer("obj", "tmp")
end
if rep == 0 then
    local WW, HH, CX, CY = WindShakeT(1)
    obj.load("tempbuffer")
    obj.cx = -CX
    if UB == 1 then
        obj.effect("反転", "上下反転", 1)
        obj.cy = CY
    else
        obj.cy = -CY
    end
else
    obj.copybuffer("cache:orgI", "obj")
    for i = 1, repN do
        obj.copybuffer("obj", "cache:orgI")
        local WW, HH, CX, CY = WindShakeT(i)
        CX = (i - (repN + 1) / 2) * stepX + CX
        obj.load("tempbuffer")
        obj.setoption("drawtarget", "framebuffer")

        if UB == 1 then
            obj.effect("反転", "上下反転", 1)
            obj.draw(CX, -CY)
        else
            obj.draw(CX, CY)
        end
    end
end
