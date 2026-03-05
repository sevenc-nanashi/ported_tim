--label:tim2\TrackingラインEasy.anm
---$track:開始/ｼﾌﾄ
---min=0
---max=100
---step=0.01
local rename_me_track0 = 50

---$track:終了/全長
---min=0
---max=100
---step=0.01
local rename_me_track1 = 0

---$track:頂点数
---min=2
---max=16
---step=1
local rename_me_track2 = 2

---$track:間隔
---min=0.1
---max=500
---step=0.1
local rename_me_track3 = 5

---$value:描画方法[0-2]
local dm = 1

---$value:定数(方法2のみ)
local C = 35

---$check:等速度_等間隔
local ec = 0

---$value:精度
local Ac = 20

---$check:環状にする
local cy = 0

---$check:同時に出現
local ST = 0

---$check:全長指定表示
local sp = 0

---$value:線幅
local Lw = { 100, 100, 100 }

---$color:変化色
local col = ""

---$value:領域拡張
local dSI = { 0, 0 }

---$value:座標
local pos = { 0, 0, 100, 100 }

---$check:頂点群を分離
local rename_me_check0 = true

Tracking = {}

Tracking.DoTrackingLineEasy = function(Trk)
    local Tracking_st = Trk.st
    local Tracking_ed = Trk.ed

    local myinterpolation
    if Trk.dm == 1 then
        myinterpolation = function(t, x0, y0, x1, y1, x2, y2, x3, y3)
            return obj.interpolation(t, x0, y0, x1, y1, x2, y2, x3, y3)
        end
    elseif Trk.dm == 2 then
        myinterpolation = function(t, x0, y0, x1, y1, x2, y2, x3, y3)
            local x10 = x1 - x0
            local x21 = x2 - x1
            local x32 = x3 - x2
            local y10 = y1 - y0
            local y21 = y2 - y1
            local y32 = y3 - y2

            local l0 = math.sqrt(x10 * x10 + y10 * y10)
            local l1 = math.sqrt(x21 * x21 + y21 * y21)
            local l2 = math.sqrt(x32 * x32 + y32 * y32)

            if l1 > 0 then
                x0 = x1 + Trk.C * (x21 * l0 + x10 * l1) / (l1 + l0)
                x3 = x2 - Trk.C * (x21 * l2 + x32 * l1) / (l1 + l2)
                y0 = y1 + Trk.C * (y21 * l0 + y10 * l1) / (l1 + l0)
                y3 = y2 - Trk.C * (y21 * l2 + y32 * l1) / (l1 + l2)
                s = 1 - t
                x1 = s * s * s * x1 + 3 * s * s * t * x0 + 3 * s * t * t * x3 + t * t * t * x2
                y1 = s * s * s * y1 + 3 * s * s * t * y0 + 3 * s * t * t * y3 + t * t * t * y2
            end
            return x1, y1
        end
    else
        myinterpolation = function(t, x0, y0, x1, y1, x2, y2, x3, y3)
            return x1 + t * (x2 - x1), y1 + t * (y2 - y1)
        end
    end

    if Trk.sp == 1 then
        local st = Tracking_st
        local ed = Tracking_ed
        Tracking_ed = st * (ed + 1) - ed
        Tracking_st = Tracking_ed + ed
    else
        if Tracking_st < Tracking_ed then
            Tracking_st, Tracking_ed = Tracking_ed, Tracking_st
        end
    end

    local alp = 0

    if not Trk.ck then
        for i = 2, #Trk.X do
            for j = 1, #Trk.X[i] do
                table.insert(Trk.X[1], Trk.X[i][j])
                table.insert(Trk.Y[1], Trk.Y[i][j])
            end
            Trk.X[i] = nil
        end
    end

    local TN = {}
    for i = 1, #Trk.X do
        TN[i] = #Trk.X[i]
        if Trk.cy[i] == 1 then --円の場合
            Trk.X[i][0] = Trk.X[i][TN[i]]
            Trk.Y[i][0] = Trk.Y[i][TN[i]]
            Trk.X[i][TN[i] + 1] = Trk.X[i][1]
            Trk.Y[i][TN[i] + 1] = Trk.Y[i][1]
            Trk.X[i][TN[i] + 2] = Trk.X[i][2]
            Trk.Y[i][TN[i] + 2] = Trk.Y[i][2]
            TN[i] = TN[i] + 1
        else --その他
            Trk.X[i][0] = Trk.X[i][1]
            Trk.Y[i][0] = Trk.Y[i][1]
            Trk.X[i][TN[i] + 1] = Trk.X[i][TN[i]]
            Trk.Y[i][TN[i] + 1] = Trk.Y[i][TN[i]]
        end
    end

    local Sum = {}
    local SumS = {}
    Sum[0] = 0
    if Trk.ec == 0 then
        for i = 1, #Trk.X do
            Sum[i] = Sum[i - 1] + TN[i] - 1
        end
    else
        for i = 1, #Trk.X do
            SumS[i] = {}
            SumS[i][0] = 0
            for j = 1, TN[i] - 1 do
                SumS[i][j] = 0
                local x0 = Trk.X[i][j - 1]
                local x1 = Trk.X[i][j]
                local x2 = Trk.X[i][j + 1]
                local x3 = Trk.X[i][j + 2]

                local y0 = Trk.Y[i][j - 1]
                local y1 = Trk.Y[i][j]
                local y2 = Trk.Y[i][j + 1]
                local y3 = Trk.Y[i][j + 2]

                local xx = {}
                local yy = {}

                local iTA = math.ceil(Trk.Ac * 0.5)
                for k = 0, iTA do
                    local t = k / iTA
                    xx[k], yy[k] = myinterpolation(t, x0, y0, x1, y1, x2, y2, x3, y3)
                end
                for k = 0, iTA - 1 do
                    SumS[i][j] = SumS[i][j] + math.sqrt((xx[k + 1] - xx[k]) ^ 2 + (yy[k + 1] - yy[k]) ^ 2)
                end
                SumS[i][j] = SumS[i][j] + SumS[i][j - 1]
            end
            Sum[i] = SumS[i][TN[i] - 1] + Sum[i - 1]
            for j = 1, TN[i] - 1 do
                SumS[i][j] = SumS[i][j] / SumS[i][TN[i] - 1]
            end
        end
    end

    local maxX = math.max(unpack(Trk.X[1]))
    local maxY = math.max(unpack(Trk.Y[1]))
    local minX = math.min(unpack(Trk.X[1]))
    local minY = math.min(unpack(Trk.Y[1]))
    for i = 2, #Trk.X do
        maxX = math.max(maxX, unpack(Trk.X[i]))
        maxY = math.max(maxY, unpack(Trk.Y[i]))
        minX = math.min(minX, unpack(Trk.X[i]))
        minY = math.min(minY, unpack(Trk.Y[i]))
    end

    local Sww = (maxX - minX) * 1.2 + 2 * Trk.SI + Trk.dSI[1]
    local Shh = (maxY - minY) * 1.2 + 2 * Trk.SI + Trk.dSI[2]
    local SCx = (maxX + minX) * 0.5
    local SCy = (maxY + minY) * 0.5

    obj.setoption("drawtarget", "tempbuffer", Sww, Shh)

    local stn = Sum[#Trk.X]
    for i = 1, #Trk.X do
        Sum[i] = Sum[i] / stn
    end

    local t = Tracking_st
    local t0 = t * stn
    for i = 0, #Trk.X - 1 do
        if Sum[i] <= t and t < Sum[i + 1] then
            t0 = (i + (t - Sum[i]) / (Sum[i + 1] - Sum[i]))
            break
        end
    end
    Tracking_st = t0

    t = Tracking_ed
    t0 = t * stn
    for i = 0, #Trk.X - 1 do
        if Sum[i] <= t and t < Sum[i + 1] then
            t0 = (i + (t - Sum[i]) / (Sum[i + 1] - Sum[i]))
            break
        end
    end
    Tracking_ed = t0

    local maxsum = 0
    if Trk.ST == 1 then
        for i = 1, #Trk.X do
            maxsum = math.max(maxsum, Sum[i] - Sum[i - 1])
        end
    end

    for i = 1, #Trk.X do
        local Tracking_st = Tracking_st
        local Tracking_ed = Tracking_ed

        if Trk.ST == 0 then
            Tracking_st = Tracking_st - i + 1
            Tracking_ed = Tracking_ed - i + 1
        else
            Tracking_st = Tracking_st / #Trk.X
            Tracking_ed = Tracking_ed / #Trk.X
            if Trk.ec == 1 then
                Tracking_st = Tracking_st * maxsum / (Sum[i] - Sum[i - 1])
                Tracking_ed = Tracking_ed * maxsum / (Sum[i] - Sum[i - 1])
            end
        end

        if not (Tracking_st < 0 or Tracking_ed > 1) then
            if Tracking_st > 1 then
                Tracking_st = 1
            end
            if Tracking_ed < 0 then
                Tracking_ed = 0
            end

            if Trk.ec == 1 then
                local tq1 = Tracking_st
                local t0 = tq1
                for j = 0, TN[i] - 2 do
                    if SumS[i][j] <= tq1 and tq1 < SumS[i][j + 1] then
                        t0 = (j + (tq1 - SumS[i][j]) / (SumS[i][j + 1] - SumS[i][j])) / (TN[i] - 1)
                        break
                    end
                end
                Tracking_st = t0

                local tq2 = Tracking_ed
                t0 = tq2
                for j = 0, TN[i] - 2 do
                    if SumS[i][j] <= tq2 and tq2 < SumS[i][j + 1] then
                        t0 = (j + (tq2 - SumS[i][j]) / (SumS[i][j + 1] - SumS[i][j])) / (TN[i] - 1)
                        break
                    end
                end
                Tracking_ed = t0
            end
            local dotN = 0
            local poxX = {}
            local poxY = {}
            for j = 1, TN[i] - 1 do
                if j == TN[i] - 1 and Trk.cy[i] == 0 then
                    hugo = 1
                else
                    hugo = -1
                end

                local x0 = Trk.X[i][j - 1]
                local x1 = Trk.X[i][j]
                local x2 = Trk.X[i][j + 1]
                local x3 = Trk.X[i][j + 2]

                local y0 = Trk.Y[i][j - 1]
                local y1 = Trk.Y[i][j]
                local y2 = Trk.Y[i][j + 1]
                local y3 = Trk.Y[i][j + 2]

                local r
                local Sum2 = {}

                if Trk.ec == 1 then
                    local xx = {}
                    local yy = {}
                    for k = 0, Trk.Ac do
                        local t = k / Trk.Ac
                        xx[k], yy[k] = myinterpolation(t, x0, y0, x1, y1, x2, y2, x3, y3)
                    end
                    Sum2[0] = 0
                    for k = 1, Trk.Ac do
                        Sum2[k] = Sum2[k - 1] + math.sqrt((xx[k] - xx[k - 1]) ^ 2 + (yy[k] - yy[k - 1]) ^ 2)
                    end

                    r = Sum2[Trk.Ac]

                    for k = 1, Trk.Ac do
                        Sum2[k] = Sum2[k] / Sum2[Trk.Ac]
                    end
                else
                    r = math.sqrt((x2 - x1) ^ 2 + (y2 - y1) ^ 2)
                end

                local step = 1 / math.ceil(r / Trk.iv)

                local Tracking_st = (TN[i] - 1) * Tracking_st - (j - 1)
                local Tracking_ed = (TN[i] - 1) * Tracking_ed - (j - 1)

                if not (Tracking_st < 0 or Tracking_ed > 1) then
                    if Tracking_st > 1 then
                        Tracking_st = 1
                    end
                    if Tracking_ed < 0 then
                        Tracking_ed = 0
                    end
                    Tracking_ed = step * math.ceil(Tracking_ed / step)

                    if Trk.ec == 0 then
                        for t = Tracking_ed, Tracking_st + hugo * step * 0.01, step do
                            local x, y = myinterpolation(t, x0, y0, x1, y1, x2, y2, x3, y3)
                            dotN = dotN + 1
                            poxX[dotN], poxY[dotN] = x - SCx, y - SCy
                            alp = 1
                        end
                    else
                        for t = Tracking_ed, Tracking_st + hugo * step * 0.01, step do
                            local t0 = t
                            for k = 0, Trk.Ac - 1 do
                                if Sum2[k] <= t and t < Sum2[k + 1] then
                                    t0 = (k + (t - Sum2[k]) / (Sum2[k + 1] - Sum2[k])) / Trk.Ac
                                    break
                                end
                            end

                            local x, y = myinterpolation(t0, x0, y0, x1, y1, x2, y2, x3, y3)
                            dotN = dotN + 1
                            poxX[dotN], poxY[dotN] = x - SCx, y - SCy
                            alp = 1
                        end
                    end
                end
            end

            if Trk.col == "" then
                for k = 1, dotN do
                    local s = (k - 1) / (dotN - 1)
                    s = s * Trk.Lw[3] + (2 * s * (2 * Trk.Lw[2] - Trk.Lw[1] - Trk.Lw[3]) + Trk.Lw[1]) * (1 - s)
                    obj.draw(poxX[k], poxY[k], 0, s * 0.01)
                end
            else
                obj.copybuffer("cache:img", "obj")
                for k = 1, dotN do
                    local s = (k - 1) / (dotN - 1)
                    local s2 = s * Trk.Lw[3] + (2 * s * (2 * Trk.Lw[2] - Trk.Lw[1] - Trk.Lw[3]) + Trk.Lw[1]) * (1 - s)
                    obj.copybuffer("obj", "cache:img")
                    obj.effect("単色化", "color", Trk.col, "輝度を保持する", 0, "強さ", 100 * (1 - s))
                    obj.draw(poxX[k], poxY[k], 0, s2 * 0.01)
                end
            end
        end
    end
    obj.alpha = alp
    obj.load("tempbuffer")
    obj.cx = obj.cx - SCx
    obj.cy = obj.cy - SCy
end

Tracking.SI = math.max(obj.getpixel())
Tracking.dm = dm or 1
Tracking.C = (C or 35) * 0.01
Tracking.ec = ec or 0
Tracking.Ac = Ac or 10
Tracking.sp = sp or 0
Tracking.ST = ST or 0
Tracking.Lw = Lw or { 100, 100, 100 }
Tracking.col = col or ""
Tracking.dSI = dSI or { 0, 0 }

Tracking.st = rename_me_track0 * 0.01
Tracking.ed = rename_me_track1 * 0.01
local num = rename_me_track2
Tracking.iv = rename_me_track3
Tracking.ck = rename_me_check0

obj.setanchor("pos", num, "line")

Tracking.cy = {}
Tracking.cy[1] = cy or 0
Tracking.X = {}
Tracking.Y = {}
Tracking.X[1] = {}
Tracking.Y[1] = {}
for i = 1, num do
    Tracking.X[1][i] = pos[2 * i - 1]
    Tracking.Y[1][i] = pos[2 * i]
end
if obj.getoption("script_name", 1) ~= "TrackingラインEasy(頂点追加)@TrackingラインEasy" then
    Tracking.DoTrackingLineEasy(Tracking)
    Tracking = nil
end
