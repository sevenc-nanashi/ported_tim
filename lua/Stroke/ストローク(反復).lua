--label:tim2\装飾\ストロークT.anm
---$track:進捗度
---min=0
---max=100
---step=0.01
local track_progress = 50

---$track:左端残し
---min=0
---max=2000
---step=1
local track_keep_left_edge = 0

---$track:右端残し
---min=0
---max=2000
---step=1
local track_keep_right_edge = 0

---$select:繰返モード
---根本固定=1
---先端固定=2
---ランダム=3
local track_mode = 1

---$track:軌道精度
---min=1
---max=1000
---step=1
local smN = 30

---$check:環状軌道
local CirObt = 0

---$select:軌道
---曲線=0
---円=1
local richk = 1

---$check:先頭調整
local topadj = 0

---$value:幅変動[%]
local fat = { 100, 100, 100 }

---$value:z軸方向
local posZ = { 0, 0, 0 }

---$track:最大ランダム長[%]
---min=5
---max=100
---step=1
local RnD = 50

---$track:乱数シード
---min=0
---max=100000
---step=1
local seed = 0

---$check:フレームバッファ表示
local fbapp = 0

local sp1 = track_keep_left_edge
local sp2 = track_keep_right_edge
local t = track_progress * 0.01
local AP = track_mode --1は根本固定、2は先端固定、3はランダム
topadj = topadj or 2 --互換用

T_stroke_f = function()
    local interpolationT
    if richk == 0 then
        interpolationT = function(t, x0, y0, x1, y1, x2, y2, x3, y3)
            if t <= 0.5 then
                s = t + 0.5
                return ((1 - s) * (1 - s) * x0 + (1 + 2 * s - 2 * s * s) * x1 + s * s * x2) / 2,
                    ((1 - s) * (1 - s) * y0 + (1 + 2 * s - 2 * s * s) * y1 + s * s * y2) / 2
            else
                s = t - 0.5
                return ((1 - s) * (1 - s) * x1 + (1 + 2 * s - 2 * s * s) * x2 + s * s * x3) / 2,
                    ((1 - s) * (1 - s) * y1 + (1 + 2 * s - 2 * s * s) * y2 + s * s * y3) / 2
            end
        end
    elseif richk == 1 then
        interpolationT = function(t, x0, y0, x1, y1, x2, y2, x3, y3) --正方形配置で円になるように特殊な計算
            local s, Ax, Ay, Cx, Cy, Dx, Dy, Ex, Ey, Fx, Fy
            if t <= 0.5 then
                t = t + 0.5
                Ex, Ey = (x0 + x1) * 0.5, (y0 + y1) * 0.5
                Dx, Dy = x1, y1
                Fx, Fy = (x1 + x2) * 0.5, (y1 + y2) * 0.5
            else
                t = t - 0.5
                Ex, Ey = (x1 + x2) * 0.5, (y1 + y2) * 0.5
                Dx, Dy = x2, y2
                Fx, Fy = (x2 + x3) * 0.5, (y2 + y3) * 0.5
            end
            t = math.tan(math.pi * 0.5 * t * 0.5)
            Ax, Ay = (1 - t) * Ex + t * Dx, (1 - t) * Ey + t * Dy
            s = 2 * t / (1 + t)
            Cx, Cy = (1 - s) * Dx + s * Fx, (1 - s) * Dy + s * Fy
            s = t * (1 + t) / (1 + t * t)
            return (1 - s) * Ax + s * Cx, (1 - s) * Ay + s * Cy
        end
    else
        interpolationT = function(t, x0, y0, x1, y1, x2, y2, x3, y3)
            return (1 - t) * x1 + t * x2, (1 - t) * y1 + t * y2
        end
    end

    local DistanceCor = function(PX, PY, N)
        local Long = {}
        local iPX = {}
        local iPY = {}
        iPX[0], iPY[0] = PX[0], PY[0]
        iPX[N], iPY[N] = PX[N], PY[N]
        Long[0] = 0
        for i = 1, N do
            Long[i] = Long[i - 1] + math.sqrt((PX[i] - PX[i - 1]) ^ 2 + (PY[i] - PY[i - 1]) ^ 2)
        end
        local CON = Long[N] / N
        local M = 1
        for i = 1, N - 1 do
            local DIS = i * CON
            while DIS > Long[M] do
                M = M + 1
            end
            local rate = (DIS - Long[M - 1]) / (Long[M] - Long[M - 1])
            iPX[i] = PX[M - 1] + rate * (PX[M] - PX[M - 1])
            iPY[i] = PY[M - 1] + rate * (PY[M] - PY[M - 1])
        end
        return iPX, iPY, math.floor(Long[N])
    end

    local CalArray = function(t, Arr) --倍率用
        local N = #Arr
        if N == 1 then
            return Arr[1]
        end
        local s = 1 + t * (N - 1)
        local Q1 = math.floor(s)
        local Q0 = math.max(1, Q1 - 1)
        local Q2 = math.min(N, Q1 + 1)
        local Q3 = math.min(N, Q1 + 2)
        s = s - Q1
        return obj.interpolation(s, Arr[Q0], Arr[Q1], Arr[Q2], Arr[Q3])
    end

    local CalArray2 = function(t, Arr) --Z座標用
        local N = #Arr
        if N == 1 then
            return Arr[1]
        end
        local s = 1 + t * (N - 1)
        local Q1 = math.floor(s)
        local Q0 = Q1 - 1
        local Q2 = Q1 + 1
        local Q3 = Q1 + 2
        s = s - Q1
        if Q0 < 1 then
            Q0 = 2 * Arr[1] - Arr[2]
        else
            Q0 = Arr[Q0]
        end
        Q1 = Arr[Q1]
        if Q2 > N then
            Q2 = 2 * Arr[N] - Arr[N - 1]
        else
            Q2 = Arr[Q2]
        end
        if Q3 > N + 1 then
            Q3 = 3 * Arr[N] - 2 * Arr[N - 1]
        elseif Q3 > N then
            Q3 = 2 * Arr[N] - Arr[N - 1]
        else
            Q3 = Arr[Q3]
        end
        return obj.interpolation(s, Q0, Q1, Q2, Q3)
    end

    local RVEC = function(x1, x2, y1, y2, h)
        local dx = x1 - x2
        local dy = y1 - y2
        local dr = math.sqrt(dx * dx + dy * dy)
        return 0.5 * dx * h / dr, 0.5 * dy * h / dr
    end

    local acN = T_strokeTM_N
    local anc = T_strokeTM_ancB

    if CirObt == 1 then
        acN = acN + 1
        anc[2 * acN - 1], anc[2 * acN] = anc[1], anc[2]
    end

    local w0, h0 = obj.getpixel() --オリジナルサイズ
    RnD = math.min(1, math.max(0.05, RnD * 0.01))
    smN = math.min(1000, math.max(1, math.floor(smN)))
    sp1 = math.floor(math.min(sp1, w0 - 2))
    sp2 = math.floor(math.min(sp2, w0 - sp1 - 1))
    obj.copybuffer("cache:ori", "obj") --オリジナルを保存

    obj.effect("クリッピング", "左", sp1, "右", sp2) --両端をカット
    local w, h = w0 - (sp1 + sp2), h0 --両端カットサイズ
    obj.copybuffer("cache:moyou", "obj") --両端カットを保存

    for i = 1, #fat do
        fat[i] = fat[i] * 0.01
    end

    --座標データ作成

    local ancX = {}
    local ancY = {}

    for i = 1, acN do
        ancX[i] = anc[2 * i - 1]
        ancY[i] = anc[2 * i]
    end

    if CirObt == 1 then
        ancX[0] = ancX[acN - 1]
        ancY[0] = ancY[acN - 1]
        ancX[acN + 1] = ancX[2]
        ancY[acN + 1] = ancY[2]
    else
        ancX[0] = 2 * ancX[1] - ancX[2]
        ancY[0] = 2 * ancY[1] - ancY[2]
        ancX[acN + 1] = 2 * ancX[acN] - ancX[acN - 1]
        ancY[acN + 1] = 2 * ancY[acN] - ancY[acN - 1]
    end

    --距離、座標設定
    local posX = {}
    local posY = {}
    local Long = {}
    for i = 1, acN - 1 do
        posX[i] = {}
        posY[i] = {}
        for k = 0, smN do
            posX[i][k], posY[i][k] = interpolationT(
                k / smN,
                ancX[i - 1],
                ancY[i - 1],
                ancX[i],
                ancY[i],
                ancX[i + 1],
                ancY[i + 1],
                ancX[i + 2],
                ancY[i + 2]
            )
        end
        posX[i], posY[i], Long[i] = DistanceCor(posX[i], posY[i], smN)
    end

    --距離再計算
    local LongS = {}
    LongS[0] = 0
    for i = 1, acN - 1 do
        LongS[i] = LongS[i - 1] + Long[i]
    end
    local AllLong = LongS[acN - 1]

    --輪郭計算用
    for i = 2, acN - 1 do
        posX[i][-1] = posX[i - 1][smN - 1]
        posY[i][-1] = posY[i - 1][smN - 1]
    end
    for i = 1, acN - 2 do
        posX[i][smN + 1] = posX[i + 1][1]
        posY[i][smN + 1] = posY[i + 1][1]
    end
    if CirObt == 1 then
        posX[1][-1] = posX[acN - 1][smN - 1]
        posY[1][-1] = posY[acN - 1][smN - 1]
        posX[acN - 1][smN + 1] = posX[1][1]
        posY[acN - 1][smN + 1] = posY[1][1]
    else
        posX[1][-1] = 2 * posX[1][0] - posX[1][1]
        posY[1][-1] = 2 * posY[1][0] - posY[1][1]
        posX[acN - 1][smN + 1] = 2 * posX[acN - 1][smN] - posX[acN - 1][smN - 1]
        posY[acN - 1][smN + 1] = 2 * posY[acN - 1][smN] - posY[acN - 1][smN - 1]
    end

    --幅調整
    local HH = {}
    for i = 1, acN - 1 do
        HH[i] = {}
        for k = 0, smN do
            local t = (k * Long[i] / smN + LongS[i - 1]) / AllLong
            HH[i][k] = h * CalArray(t, fat)
        end
    end

    --輪郭作成
    local posTX = {}
    local posTY = {}
    local posBX = {}
    local posBY = {}
    for i = 1, acN - 1 do
        posTX[i] = {}
        posTY[i] = {}
        posBX[i] = {}
        posBY[i] = {}
        for k = 0, smN do
            local dx, dy = RVEC(posX[i][k - 1], posX[i][k + 1], posY[i][k - 1], posY[i][k + 1], HH[i][k])
            posTX[i][k] = posX[i][k] + dy
            posTY[i][k] = posY[i][k] - dx
            posBX[i][k] = posX[i][k] - dy
            posBY[i][k] = posY[i][k] + dx
        end
    end

    --ブロック最大値を計算
    local acmax = 1
    local acmaxb = 1
    if t < 1 then
        while LongS[acmaxb] < t * (AllLong - sp1 - sp2) + sp1 do
            acmaxb = acmaxb + 1
        end
        acmax = acmaxb
        while LongS[acmax] < t * (AllLong - sp1 - sp2) + sp1 + sp2 do
            acmax = acmax + 1
        end
    else
        acmax = acN - 1
        acmaxb = acmax
    end

    --ブロック単位で画像作成
    local xlong = t * (AllLong - sp1 - sp2)
    local sft = 0

    if AP < 3 then
        if AP == 1 then
            sft = sp1 - w
        else
            sft = (sp1 + xlong) % w - w
        end

        for i = 1, acmax do
            obj.setoption("drawtarget", "tempbuffer", Long[i], h)
            obj.setoption("blend", "alpha_add2")
            local nw = math.floor((Long[i] - sft) / w) + 1
            local longh = Long[i] * 0.5

            if AP == 1 or (AP == 2 and i ~= acmax and (i ~= acmaxb or acmax == acmaxb)) then
                for j = 0, nw do
                    obj.draw(-longh + sft + w * (j + 0.5))
                end
            elseif (i == acmax and acmax == acmaxb) or (i == acmaxb and acmax ~= acmaxb) then
                for j = 0, nw do
                    obj.draw(-longh + xlong + sp1 - LongS[i - 1] - w * (j + 0.5))
                end
            end

            sft = -((Long[i] - sft) % w)
            obj.copybuffer("cache:line" .. i, "tmp")
        end
    else
        local y1 = h * 0.5
        local y0 = -y1
        local RnDw = RnD * w

        local a = {}
        a[-2] = 0
        a[-1] = w
        a[0] = 0
        local dL = -2 * w + sp1
        local RL = sp1
        for i = 1, acmax do
            obj.setoption("drawtarget", "tempbuffer", Long[i], h)
            obj.setoption("blend", "alpha_add2")
            local n = 0

            repeat
                a[n + 1] = obj.rand(a[n], a[n] + RnDw, i, n + 1000 + seed)
                n = n + 1
                if a[n] > w then
                    a[n] = w
                end
                a[n + 1] = obj.rand(a[n] - RnDw, a[n], i, n + 1000 + seed)
                n = n + 1
                if a[n] < 0 then
                    a[n] = 0
                end
                RL = RL + (2 * a[n - 1] - a[n - 2] - a[n])
            until RL >= Long[i]

            local sht = -Long[i] * 0.5 + dL
            for i = 0, n, 2 do
                local u0, u1, x0, x1, du

                u0 = a[i - 2]
                u1 = a[i - 1]
                du = u1 - u0
                x0 = sht
                x1 = sht + du
                obj.drawpoly(x0, y0, 0, x1, y0, 0, x1, y1, 0, x0, y1, 0, u0, 0, u1, 0, u1, h, u0, h)
                sht = sht + du

                u0 = a[i]
                u1 = a[i - 1]
                du = u1 - u0
                x0 = sht + du
                x1 = sht
                obj.drawpoly(x0, y0, 0, x1, y0, 0, x1, y1, 0, x0, y1, 0, u0, 0, u1, 0, u1, h, u0, h)
                sht = sht + du
            end
            obj.copybuffer("cache:line" .. i, "tmp")

            a[-2] = a[n - 2]
            a[-1] = a[n - 1]
            a[0] = a[n]
            RL = RL - Long[i]
            dL = RL - (2 * a[n - 1] - a[n - 2] - a[n])
        end
    end

    obj.copybuffer("obj", "cache:line1")
    obj.effect("クリッピング", "左", sp1)
    obj.effect("領域拡張", "左", sp1)
    obj.copybuffer("tmp", "obj")
    obj.copybuffer("obj", "cache:ori")
    obj.effect("クリッピング", "右", w + sp2)
    obj.draw((-Long[1] + sp1) * 0.5, 0)
    obj.copybuffer("cache:line1", "tmp")

    for i = acmaxb, acmax do
        local X = xlong + sp1 - LongS[i - 1] - Long[i] * 0.5
        obj.copybuffer("obj", "cache:line" .. i)
        obj.effect("斜めクリッピング", "角度", -90, "中心X", X, "ぼかし", 0)
        obj.copybuffer("tmp", "obj")
        obj.copybuffer("obj", "cache:ori")
        obj.effect("クリッピング", "左", w + sp1)
        obj.draw(X + sp2 * 0.5 - topadj * 0.5, 0)
        obj.copybuffer("cache:line" .. i, "tmp")
    end

    if fbapp == 0 then
        --最大最小検出
        local maxX = posTX[1][0]
        local minX = posTX[1][0]
        local maxY = posTY[1][0]
        local minY = posTY[1][0]
        for i = 1, acmax do
            for k = 0, smN do
                maxX = math.max(posTX[i][k], posBX[i][k], maxX)
                minX = math.min(posTX[i][k], posBX[i][k], minX)
                maxY = math.max(posTY[i][k], posBY[i][k], maxY)
                minY = math.min(posTY[i][k], posBY[i][k], minY)
            end
        end

        local ww = maxX - minX
        local hh = maxY - minY
        local cw = (maxX + minX) * 0.5
        local ch = (maxY + minY) * 0.5

        obj.setoption("drawtarget", "tempbuffer", ww, hh)
        obj.setoption("blend", "alpha_add2")
        for i = 1, acmax do
            obj.copybuffer("obj", "cache:line" .. i)
            for k = 0, smN - 1 do
                local x0, y0 = posTX[i][k] - cw, posTY[i][k] - ch
                local x1, y1 = posTX[i][k + 1] - cw, posTY[i][k + 1] - ch
                local x2, y2 = posBX[i][k + 1] - cw, posBY[i][k + 1] - ch
                local x3, y3 = posBX[i][k] - cw, posBY[i][k] - ch
                local u0 = Long[i] * k / smN
                local u1 = Long[i] * (k + 1) / smN
                obj.drawpoly(x0, y0, 0, x1, y1, 0, x2, y2, 0, x3, y3, 0, u0, 0, u1, 0, u1, h, u0, h)
            end
        end
        obj.load("tempbuffer")
        obj.setoption("blend", 0)
        obj.cx = -cw
        obj.cy = -ch
    else
        local zz = {}
        for i = 1, acmax do
            zz[i] = {}
            for k = 0, smN do
                local t = (k * Long[i] / smN + LongS[i - 1]) / AllLong
                zz[i][k] = CalArray2(t, posZ)
            end
        end
        obj.setoption("drawtarget", "framebuffer")
        for i = 1, acmax do
            obj.copybuffer("obj", "cache:line" .. i)
            obj.cx = 0
            obj.cy = 0
            for k = 0, smN - 1 do
                local x0, y0 = posTX[i][k], posTY[i][k]
                local x1, y1 = posTX[i][k + 1], posTY[i][k + 1]
                local x2, y2 = posBX[i][k + 1], posBY[i][k + 1]
                local x3, y3 = posBX[i][k], posBY[i][k]
                local u0 = Long[i] * k / smN
                local u1 = Long[i] * (k + 1) / smN
                obj.drawpoly(
                    x1,
                    y1,
                    zz[i][k + 1],
                    x0,
                    y0,
                    zz[i][k],
                    x3,
                    y3,
                    zz[i][k],
                    x2,
                    y2,
                    zz[i][k + 1],
                    u1,
                    0,
                    u0,
                    0,
                    u0,
                    h,
                    u1,
                    h
                )
            end
        end
        obj.setoption("blend", 0)
    end
end

if obj.getoption("script_name", 1, true):sub(-4, -1) ~= obj.getoption("script_name"):sub(-4, -1) then
    T_stroke_f()
    T_strokeTM_ancB = nil
    T_strokeTM_N = nil
end
