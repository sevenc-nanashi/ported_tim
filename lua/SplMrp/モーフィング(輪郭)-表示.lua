--label:tim2\モーフィング.anm\モーフィング(輪郭)-表示
---$track:変化度
---min=0
---max=100
---step=0.1
local rename_me_track0 = 50

---$track:サイズ
---min=0
---max=1000
---step=0.1
local rename_me_track1 = 10

---$track:点数
---min=0
---max=20000
---step=1
local rename_me_track2 = 120

---$track:ｵﾌｾｯﾄ
---min=-2000
---max=2000
---step=0.1
local rename_me_track3 = 0

---$value:変形前画像ﾚｲﾔｰ
local inum = 0

---$value:ｴﾌｪｸﾄ取得/chk
local GE = 1

---$value:形状/fig
local fig = "円"

---$value:ドット色/col
local col = 0xffffff

---$value:自動方向/chk
local td = 0

---$value:一時保存EXT/chk
local IE = 0

Outlinemorphing_T = function(OT)
    local makeOutline = function(ni, nj, ky, T, w, h, SF)
        local r2 = math.sqrt(2)
        local dpx = { -1, 0, 1, 1, 1, 0, -1, -1 }
        local dpy = { 1, 1, 1, 0, -1, -1, -1, 0 }
        local dky = { r2, 1, r2, 1, r2, 1, r2, 1 }
        local w2, h2 = w * 0.5, h * 0.5
        local nn = 0
        local vold = 0
        local r, g, b, a
        for j = 0, h - 1 do
            for i = 0, w - 1 do
                r, g, b, a = obj.getpixel(i, j, "rgb")
                if a > T then
                    ni[0] = i
                    nj[0] = j
                    break
                end
            end
            if a > T then
                break
            end
        end
        ky[0] = 0
        local res
        local vnew
        local ti
        local tj
        repeat
            res = 0
            for i = 0, 7 do
                vnew = (vold + 6 + i) % 8
                ti = ni[nn] + dpx[vnew + 1]
                tj = nj[nn] + dpy[vnew + 1]
                if ti >= 0 and ti < w and tj >= 0 and tj < h then
                    r, g, b, a = obj.getpixel(ti, tj, "rgb")
                    if a > T then
                        nn = nn + 1
                        ni[nn] = ti
                        nj[nn] = tj
                        ky[nn] = dky[vnew + 1]
                        vold = vnew
                        if nn == 1 then
                            v0 = vnew
                        end
                        res = 1
                        break
                    end
                end
            end
        until (ni[nn - 1] == ni[0] and nj[nn - 1] == nj[0] and v0 == vnew and nn > 1) or res == 0
        nn = nn - 1
        local ALL = 0
        ky[-1] = 0

        if SF ~= 0 then
            SF = math.floor(SF * (nn - 1))
            local ini = {}
            local inj = {}
            for i = 0, nn do
                ini[i], inj[i] = ni[i], nj[i]
            end

            for i = 0, nn do
                local ii = (i + SF) % nn
                ni[i], nj[i] = ini[ii], inj[ii]
            end
        end

        for i = 0, nn do
            ni[i], nj[i] = ni[i] - w2, nj[i] - h2
            ALL = ALL + ky[i]
            ky[i] = ky[i] + ky[i - 1]
        end
        for i = 1, nn do
            ky[i] = ky[i] / ALL
        end
        return nn
    end

    local Adjus = function(px, py, ky, nn, XX, YY, N, OF)
        OF = OF % 1
        OF = OF % (1 / N)
        local k = 0
        for i = 0, nn do
            if k / N + OF <= ky[i] then
                XX[k] = px[i]
                YY[k] = py[i]
                k = k + 1
            end
        end
    end

    local S = OT.S or 50
    local Cw = OT.Cw or 10
    local N = OT.N or 120
    local OF = OT.OF or 0
    local T = OT.T or 128
    local inum = OT.inum or 1
    local fig = OT.fig or "円"
    local col = OT.col or 0xffffff
    local col2 = OT.col2 or 0xffffff
    local td = OT.td or 0
    local Deg = OT.Deg or 0
    local Lw = OT.Lw or 0
    local SF = (OT.SF or 0) * 0.01

    local w1, h1 = obj.getpixel()
    local px1 = {}
    local py1 = {}
    local ky1 = {}
    local nn1 = makeOutline(px1, py1, ky1, T, w1, h1, 0)

    if IE == 0 then
        GE = GE == 1 and true or false
        obj.load("layer", inum, GE)
    else
        require("extbuffer")
        extbuffer.read(inum)
    end

    local w2, h2 = obj.getpixel()
    local px2 = {}
    local py2 = {}
    local ky2 = {}
    local nn2 = makeOutline(px2, py2, ky2, T, w2, h2, SF)

    N = (N > nn1 * 0.5 and nn1 * 0.5) or N
    N = (N > nn2 * 0.5 and nn2 * 0.5) or N
    N = math.floor(N)

    local XX1 = {}
    local YY1 = {}
    Adjus(px1, py1, ky1, nn1, XX1, YY1, N, OF)

    local XX2 = {}
    local YY2 = {}
    Adjus(px2, py2, ky2, nn2, XX2, YY2, N, OF)

    obj.setoption("drawtarget", "tempbuffer", math.max(w1, w2) + 2 * Cw, math.max(h1, h2) + 2 * Cw)

    for i = 0, N - 1 do
        XX1[i] = XX1[i] * S + XX2[i] * (1 - S)
        YY1[i] = YY1[i] * S + YY2[i] * (1 - S)
    end
    XX1[N] = XX1[0]
    YY1[N] = YY1[0]
    XX1[-1] = XX1[N - 1]
    YY1[-1] = YY1[N - 1]
    if Lw > 0 then
        local Lw2 = Lw * 0.5
        obj.load("figure", "四角形", col2, 1) --  math.min(w1,w2,h1,h2))
        local x1, y1 = XX1[0], YY1[0]
        for i = 0, N - 1 do
            local x2, y2 = XX1[i + 1], YY1[i + 1]
            local dx, dy = x2 - x1, y2 - y1
            local dr = math.sqrt(dx * dx + dy * dy)
            if dr > 0 then
                dx, dy = Lw2 * dy / dr, -Lw2 * dx / dr
                obj.drawpoly(x1 - dx, y1 - dy, 0, x2 - dx, y2 - dy, 0, x2 + dx, y2 + dy, 0, x1 + dx, y1 + dy, 0)
            end
            x1, y1 = x2, y2
        end
    end
    obj.load("figure", fig, col, Cw)
    if td == 0 then
        for i = 0, N - 1 do
            obj.draw(XX1[i], YY1[i], 0, 1, 1, 0, 0, Deg)
        end
    else
        for i = 0, N - 1 do
            local R = math.atan2(XX1[i + 1] - XX1[i - 1], YY1[i + 1] - YY1[i - 1])
            obj.draw(XX1[i], YY1[i], 0, 1, 1, 0, 0, Deg - R * 180 / math.pi - 90)
        end
    end
    obj.load("tempbuffer")
end

Out_morph_T = Out_morph_T or {}
Out_morph_T.S = rename_me_track0 * 0.01
Out_morph_T.Cw = rename_me_track1
Out_morph_T.N = rename_me_track2
Out_morph_T.OF = -rename_me_track3 * 0.01

Out_morph_T.inum = inum or 1
Out_morph_T.fig = fig
Out_morph_T.col = col
Out_morph_T.td = td

if obj.getoption("script_name", 1, true) ~= "モーフィング(輪郭)-オプション@モーフィング" then
    Outlinemorphing_T(Out_morph_T)
    Outlinemorphing_T = nil
    Out_morph_T = nil
end
