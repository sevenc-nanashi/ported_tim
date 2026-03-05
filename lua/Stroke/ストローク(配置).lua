--label:tim2\ストロークT.anm
---$track:進捗度1
---min=0
---max=100
---step=0.01
local rename_me_track0 = 100

---$track:進捗度2
---min=0
---max=100
---step=0.01
local rename_me_track1 = 0

---$track:区間個数
---min=1
---max=5000
---step=1
local rename_me_track2 = 10

---$track:ﾗﾝﾀﾞﾑ性
---min=0
---max=100
---step=0.1
local rename_me_track3 = 0

---$check:重なり反転
local apchk = 0

---$check:環状軌道
local CirObt = 0

---$value:軌道[0_2]
local richk = 1

---$check:進行方向
local vecchk = 0

---$check:先頭表示
local topOnly = 0

---$value:位置ランダム性
local Gosa = 200

---$value:領域拡大
local dScr = 0

---$value:精度
local smN = 20

local t1 = rename_me_track0 * 0.01
local t2 = rename_me_track1 * 0.01
if t2 < t1 then
    t1, t2 = t2, t1
end
local posN = rename_me_track2
local rnd = rename_me_track3 * 0.01

T_stroke_f = function()
    local t_To_D = function(Datat, posN)
        local DataD = {}
        local fN = #Datat
        Datat[0] = Datat[1]
        Datat[fN + 1] = Datat[fN]
        Datat[fN + 2] = Datat[fN]
        for i = 0, posN do
            local x = i * (fN - 1) / posN + 1
            local xn = math.floor(x)
            local dx = x - xn
            DataD[i] = obj.interpolation(dx, Datat[xn - 1], Datat[xn], Datat[xn + 1], Datat[xn + 2])
        end
        return DataD
    end

    local interpolationT = (function(k)
        if k == 0 then
            return function(t, x0, y0, x1, y1, x2, y2, x3, y3)
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
        elseif k == 1 then
            return function(t, x0, y0, x1, y1, x2, y2, x3, y3) --正方形配置で円になるように特殊な計算
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
            return function(t, x0, y0, x1, y1, x2, y2, x3, y3)
                return (1 - t) * x1 + t * x2, (1 - t) * y1 + t * y2
            end
        end
    end)(richk)

    local GosaX, GosaY, GosaS, GosaR, GosaA, seed
    local zoomt, rott, alpt

    if T_strokeTM_rnd then
        GosaX = T_strokeTM_GosaX
        GosaY = T_strokeTM_GosaY
        GosaS = T_strokeTM_GosaS
        GosaR = T_strokeTM_GosaR
        GosaA = T_strokeTM_GosaA
        seed = T_strokeTM_seed
        zoomt = T_strokeTM_zoomt
        rott = T_strokeTM_rott
        alpt = T_strokeTM_alpt
    else
        GosaX = Gosa
        GosaY = Gosa
        GosaS = 60
        GosaR = 40
        GosaA = 0
        seed = 0
        zoomt = { 100 }
        rott = { 0 }
        alpt = { 0 }
    end
    T_strokeTM_rnd = nil

    local anc = T_strokeTM_ancB
    local acN = T_strokeTM_N

    if CirObt == 1 then
        acN = acN + 1
        anc[2 * acN - 1] = anc[1]
        anc[2 * acN] = anc[2]
    end

    local ancX = {}
    local ancY = {}
    for i = 1, acN do
        ancX[i] = anc[2 * i - 1]
        ancY[i] = anc[2 * i]
    end

    if CirObt == 0 then
        ancX[0] = 2 * ancX[1] - ancX[2]
        ancY[0] = 2 * ancY[1] - ancY[2]
        ancX[acN + 1] = 2 * ancX[acN] - ancX[acN - 1]
        ancY[acN + 1] = 2 * ancY[acN] - ancY[acN - 1]
    else
        ancX[0] = ancX[acN - 1]
        ancY[0] = ancY[acN - 1]
        ancX[acN + 1] = ancX[2]
        ancY[acN + 1] = ancY[2]
    end

    local iposX = {}
    local iposY = {}
    local inum = 1
    local x0, y0 = ancX[0], ancY[0]
    local x1, y1 = ancX[1], ancY[1]
    local x2, y2 = ancX[2], ancY[2]
    for i = 1, acN - 1 do
        local x3, y3 = ancX[i + 2], ancY[i + 2]
        for j = 0, smN - 1 do
            local time = j / smN
            iposX[inum], iposY[inum] = interpolationT(time, x0, y0, x1, y1, x2, y2, x3, y3)
            inum = inum + 1
        end
        x0, y0 = x1, y1
        x1, y1 = x2, y2
        x2, y2 = x3, y3
    end
    if CirObt == 0 then
        iposX[inum], iposY[inum] = ancX[acN], ancY[acN]
    else
        iposX[inum], iposY[inum] = iposX[1], iposY[1]
    end
    local ALL = {}
    ALL[0] = 0
    for i = 1, inum - 1 do
        ALL[i] = ALL[i - 1] + math.sqrt((iposX[i + 1] - iposX[i]) ^ 2 + (iposY[i + 1] - iposY[i]) ^ 2)
    end
    --posN
    local posX = {}
    local posY = {}

    local step = ALL[inum - 1] / (posN - 1)

    local k = 1
    local i = 1
    posX[1], posY[1] = iposX[1], iposY[1]

    repeat
        if ALL[i] > k * step then
            local y = (k * step - ALL[i - 1]) / (ALL[i] - ALL[i - 1])
            k = k + 1
            posX[k] = (1 - y) * iposX[i] + y * iposX[i + 1]
            posY[k] = (1 - y) * iposY[i] + y * iposY[i + 1]
        else
            i = i + 1
        end
    until i > inum - 1

    if CirObt == 0 then
        posX[posN], posY[posN] = iposX[inum], iposY[inum]
        posX[0], posY[0] = posX[1], posY[1]
        posX[posN + 1], posY[posN + 1] = posX[posN], posY[posN]
    else
        posX[posN], posY[posN] = posX[1], posY[1]
        posX[0], posY[0] = posX[posN - 1], posY[posN - 1]
        posX[posN + 1], posY[posN + 1] = posX[2], posY[2]
        posN = posN - 1
    end
    local i1, i2, sti
    if apchk == 0 then
        i1 = math.floor(1 + (posN - 1) * t1)
        i2 = math.floor(1 + (posN - 1) * t2)
        sti = 1
    else
        i2 = math.floor(1 + (posN - 1) * t1)
        i1 = math.floor(1 + (posN - 1) * t2)
        sti = -1
    end
    if topOnly == 1 then
        i1 = math.ceil(i2)
    end

    --変動率率作成
    local xD = {}
    local yD = {}
    local zoomD = {}
    local rotD = {}
    local alpD = {}

    zoomD = t_To_D(zoomt, posN)
    rotD = t_To_D(rott, posN)
    alpD = t_To_D(alpt, posN)

    --自動角度
    dR = {}
    if vecchk == 1 then
        for i = 1, posN do
            dR[i] = math.deg(math.atan2(posY[i + 1] - posY[i - 1], posX[i + 1] - posX[i - 1]))
        end
    else
        for i = 1, posN do
            dR[i] = 0
        end
    end

    for i = 1, posN do
        posX[i] = posX[i] + obj.rand(-GosaX * 0.5, GosaX * 0.5, i, 1000 + seed) * rnd
        posY[i] = posY[i] + obj.rand(-GosaY * 0.5, GosaY * 0.5, i, 2000 + seed) * rnd
    end

    --最大最小検出
    local maxX = posX[1]
    local minX = posX[1]
    local maxY = posY[1]
    local minY = posY[1]
    for i = 2, posN do
        maxX = math.max(posX[i], maxX)
        minX = math.min(posX[i], minX)
        maxY = math.max(posY[i], maxY)
        minY = math.min(posY[i], minY)
    end

    local w, h = obj.getpixel()
    local dw = math.max(w, h)

    local ww = maxX - minX + dw + dScr
    local hh = maxY - minY + dw + dScr
    local cw = (maxX + minX) * 0.5
    local ch = (maxY + minY) * 0.5

    obj.setoption("drawtarget", "tempbuffer", ww, hh)

    for i = i1, i2, sti do
        local zoom = zoomD[i] * (1 + obj.rand(-GosaS * 0.5, GosaS * 0.5, i, 3000 + seed) * rnd * 0.01) * 0.01
        local alpha = (100 - alpD[i]) * (1 + obj.rand(-GosaA * 0.5, GosaA * 0.5, i, 4000 + seed) * rnd * 0.01)
        local rz = obj.rand(-GosaR * 0.5, GosaR * 0.5, i, 5000 + seed) * rnd + dR[i] + rotD[i]
        alpha = math.min(1, math.max(0, alpha * 0.01))
        obj.draw(posX[i] - cw, posY[i] - ch, 0, zoom, alpha, 0, 0, rz)
    end

    obj.load("tempbuffer")
    obj.cx = obj.cx - cw
    obj.cy = obj.cy - ch
end

if obj.getoption("script_name", 1, true):sub(-4, -1) ~= obj.getoption("script_name"):sub(-4, -1) then
    T_stroke_f()
    T_strokeTM_ancB = nil
    T_strokeTM_N = nil
end
