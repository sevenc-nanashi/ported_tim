--label:tim2
---$track:基準X
---min=-10000
---max=10000
---step=0.1
local track_base_x = 0

---$track:基準Y
---min=-10000
---max=10000
---step=0.1
local track_base_y = 0

---$track:移動X
---min=-10000
---max=10000
---step=0.1
local track_move_x = 100

---$track:移動Y
---min=-10000
---max=10000
---step=0.1
local track_move_y = 100

---$value:影響範囲
local ATp = 200

---$value:被影響範囲
local DFp = 200

---$check:絶対/相対
local POS = 1

---$value:分割数
local M = 30

---$check:境界固定
local BS = 0

---$check:パス表示
local PSA = 0

---$color:移動色
local mcol = 0xff0000

---$color:影響範囲色
local acol = 0x00ff00

---$color:被影響範囲色
local dcol = 0x0000ff

---$color:文字色
local fcol = 0xff00ff

---$value:表示サイズ
local sz = 50

---$value:線幅
local lw = 3

---$check:中心XY基準
local check0 = true

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

SwarpT_X0[SwarpT_N] = track_base_x
SwarpT_Y0[SwarpT_N] = track_base_y
SwarpT_X1[SwarpT_N] = track_move_x
SwarpT_Y1[SwarpT_N] = track_move_y
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

    if check0 then
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
