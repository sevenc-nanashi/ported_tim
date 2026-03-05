--label:tim2
--track0:基準X,-10000,10000,0
--track1:基準Y,-10000,10000,0
--track2:移動X,-10000,10000,100
--track3:移動Y,-10000,10000,100
--value@ATp:影響範囲,200
--value@DFp:被影響範囲,200
--value@POS:絶対/相対/chk,1
--value@M:分割数,30
--value@BS:境界固定/chk,0
--value@PSA:パス表示/chk,0
--value@mcol:移動色/col,0xff0000
--value@acol:影響範囲色/col,0x00ff00
--value@dcol:被影響範囲色/col,0x0000ff
--value@fcol:文字色/col,0xff00ff
--value@sz:表示サイズ,50
--value@lw:線幅,3
--check0:中心XY基準,0;

local TK = function(Z)
    if Z >= 1 then
        return 0
    else
        return (2 * Z + 1) * (Z - 1) ^ 2
    end
end

if SwarpT_N then
    SwarpT_N = SwarpT_N + 1
else
    SwarpT_N = 1
    SwarpT_X0 = {}
    SwarpT_Y0 = {}
    SwarpT_X1 = {}
    SwarpT_Y1 = {}
    SwarpT_AT = {}
    SwarpT_DF = {}
end

SwarpT_X0[SwarpT_N] = obj.track0
SwarpT_Y0[SwarpT_N] = obj.track1
SwarpT_X1[SwarpT_N] = obj.track2
SwarpT_Y1[SwarpT_N] = obj.track3
if POS == 1 then
    SwarpT_X1[SwarpT_N] = SwarpT_X1[SwarpT_N] + SwarpT_X0[SwarpT_N]
    SwarpT_Y1[SwarpT_N] = SwarpT_Y1[SwarpT_N] + SwarpT_Y0[SwarpT_N]
end
SwarpT_AT[SwarpT_N] = ATp
SwarpT_DF[SwarpT_N] = DFp

if obj.getoption("script_name") ~= obj.getoption("script_name", 1) then
    local w, h = obj.getpixel()
    local ox = obj.ox
    local oy = obj.oy
    local oz = obj.oz
    local cx = obj.cx
    local cy = obj.cy
    local cz = obj.cz

    local w2 = w / 2
    local h2 = h / 2

    if obj.check0 then
        for k = 1, SwarpT_N do
            SwarpT_X0[k] = SwarpT_X0[k] + cx
            SwarpT_Y0[k] = SwarpT_Y0[k] + cy
            SwarpT_X1[k] = SwarpT_X1[k] + cx
            SwarpT_Y1[k] = SwarpT_Y1[k] + cy
        end
    end

    obj.setoption("drawtarget", "tempbuffer", w, h)
    obj.setoption("blend", "alpha_add")

    local dw = w / M
    local dh = h / M

    local dx = {}
    local dy = {}
    for i = 0, M do
        dx[i] = {}
        dy[i] = {}
        for j = 0, M do
            dx[i][j] = 0
            dy[i][j] = 0
        end
    end

    -- ｽﾞﾚ量を計算
    for i = 0, M do
        local XX = i * dw - w2
        for j = 0, M do
            local rsumx = 0
            local rsumy = 0

            local YY = j * dh - h2
            for s = 1, SwarpT_N do
                local RR = ((XX - SwarpT_X0[s]) ^ 2 + (YY - SwarpT_Y0[s]) ^ 2) ^ 0.5

                local A = TK(RR / SwarpT_AT[s])
                if BS == 1 then -- 境界補正
                    if XX < SwarpT_X0[s] then
                        A = A * TK((SwarpT_X0[s] - XX) / (SwarpT_X0[s] + w2))
                    else
                        A = A * TK((SwarpT_X0[s] - XX) / (SwarpT_X0[s] - w2))
                    end
                    if YY < SwarpT_Y0[s] then
                        A = A * TK((SwarpT_Y0[s] - YY) / (SwarpT_Y0[s] + h2))
                    else
                        A = A * TK((SwarpT_Y0[s] - YY) / (SwarpT_Y0[s] - h2))
                    end
                end

                local B = 1
                for k = 1, SwarpT_N do
                    if k ~= s then
                        local RR2 = ((XX - SwarpT_X0[k]) ^ 2 + (YY - SwarpT_Y0[k]) ^ 2) ^ 0.5
                        B = B * (1 - TK(RR2 / SwarpT_DF[k]))
                    end
                end

                if RR > 0 then
                    rsumx = rsumx + A * (SwarpT_X1[s] - SwarpT_X0[s]) * B
                    rsumy = rsumy + A * (SwarpT_Y1[s] - SwarpT_Y0[s]) * B
                else
                    rsumx = SwarpT_X1[s] - SwarpT_X0[s]
                    rsumy = SwarpT_Y1[s] - SwarpT_Y0[s]
                end
                if RR == 0 then
                    break
                end
            end --s
            dx[i][j] = rsumx
            dy[i][j] = rsumy
        end
    end

    -- 表示
    for i = 0, M - 1 do
        local u0 = i * dw
        local u1 = (i + 1) * dw
        for j = 0, M - 1 do
            local v0 = j * dh
            local v1 = (j + 1) * dh

            local px0 = u0 + dx[i][j] - w2
            local px1 = u1 + dx[i + 1][j] - w2
            local px2 = u1 + dx[i + 1][j + 1] - w2
            local px3 = u0 + dx[i][j + 1] - w2

            local py0 = v0 + dy[i][j] - h2
            local py1 = v0 + dy[i + 1][j] - h2
            local py2 = v1 + dy[i + 1][j + 1] - h2
            local py3 = v1 + dy[i][j + 1] - h2

            obj.drawpoly(px0, py0, 0, px1, py1, 0, px2, py2, 0, px3, py3, 0, u0, v0, u1, v0, u1, v1, u0, v1)
        end
    end

    -- 枠表示
    if PSA == 1 and obj.getinfo("saving") == false then
        for i = 1, SwarpT_N do
            obj.load("figure", "円", mcol, sz)
            obj.draw(SwarpT_X1[i], SwarpT_Y1[i], 0)

            local sr = ((SwarpT_X0[i] - SwarpT_X1[i]) ^ 2 + (SwarpT_Y0[i] - SwarpT_Y1[i]) ^ 2) ^ 0.5
            local u1 = sz / 2 * (SwarpT_Y0[i] - SwarpT_Y1[i]) / sr + SwarpT_X0[i]
            local v1 = sz / 2 * (SwarpT_X1[i] - SwarpT_X0[i]) / sr + SwarpT_Y0[i]
            local u2 = -sz / 2 * (SwarpT_Y0[i] - SwarpT_Y1[i]) / sr + SwarpT_X0[i]
            local v2 = -sz / 2 * (SwarpT_X1[i] - SwarpT_X0[i]) / sr + SwarpT_Y0[i]

            obj.load("figure", "四角形", mcol, 100)
            obj.drawpoly(
                u1,
                v1,
                0,
                SwarpT_X1[i],
                SwarpT_Y1[i],
                0,
                SwarpT_X1[i],
                SwarpT_Y1[i],
                0,
                u2,
                v2,
                0,
                0,
                0,
                w,
                0,
                w,
                h,
                0,
                h
            )

            obj.setfont("", sz * 2, 1, fcol, 0x0)
            obj.load("text", i)
            obj.draw(SwarpT_X0[i], SwarpT_Y0[i], 0)

            obj.load("figure", "円", acol, 2 * SwarpT_AT[i], lw)
            obj.draw(SwarpT_X0[i], SwarpT_Y0[i], 0)

            obj.load("figure", "円", dcol, 2 * SwarpT_DF[i], lw)
            obj.draw(SwarpT_X0[i], SwarpT_Y0[i], 0)
        end
    end

    SwarpT_N = 0
    obj.load("tempbuffer")
    obj.ox = ox
    obj.oy = oy
    obj.oz = oz
    obj.cx = cx
    obj.cy = cy
    obj.cz = cz
end
