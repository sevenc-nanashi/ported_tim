--label:tim2\変形\簡易ワープ.anm
---$track:分割数
---min=1
---max=200
---step=0.1
local track_split_count = 30

---$track:境界固定
---min=0
---max=1
---step=0.1
local track_boundary_fixed = 0

---$value:パス表示
local PSA = 0

---$value:基準色
local kcol = 0xffffff

---$value:移動色
local mcol = 0xff0000

---$value:影響範囲色
local acol = 0x00ff00

---$value:被影響範囲色
local dcol = 0x0000ff

---$value:文字色
local fcol = 0xff00ff

---$value:表示サイズ
local sz = 50

---$value:線幅
local lw = 3

function TK(Z)
    if Z >= 1 then
        return 0
    else
        return (2 * Z + 1) * (Z - 1) ^ 2
    end
end

M = math.floor(track_split_count)
BS = math.floor(track_boundary_fixed)

dw = obj.w / M
dh = obj.h / M

dx = {}
dy = {}
for i = 0, M do
    for j = 0, M do
        dx[(M + 1) * i + j] = 0
        dy[(M + 1) * i + j] = 0
    end
end

-- ｽﾞﾚ量を計算
for i = 0, M do
    XX = i * dw - obj.w / 2
    for j = 0, M do
        rsumx = 0
        rsumy = 0

        YY = j * dh - obj.h / 2
        for s = 1, N do
            RR = ((XX - X0[s]) ^ 2 + (YY - Y0[s]) ^ 2) ^ 0.5

            A = TK(RR / AT[s])
            if BS == 1 then -- 境界補正
                if XX < X0[s] then
                    A = A * TK((X0[s] - XX) / (X0[s] + obj.w / 2))
                else
                    A = A * TK((X0[s] - XX) / (X0[s] - obj.w / 2))
                end
                if YY < Y0[s] then
                    A = A * TK((Y0[s] - YY) / (Y0[s] + obj.h / 2))
                else
                    A = A * TK((Y0[s] - YY) / (Y0[s] - obj.h / 2))
                end
            end

            B = 1
            for k = 1, N do
                if k ~= s then
                    RR2 = ((XX - X0[k]) ^ 2 + (YY - Y0[k]) ^ 2) ^ 0.5
                    B = B * (1 - TK(RR2 / DF[k]))
                end
            end -- k

            if RR > 0 then
                rsumx = rsumx + A * (X1[s] - X0[s]) * B
                rsumy = rsumy + A * (Y1[s] - Y0[s]) * B
            else
                rsumx = X1[s] - X0[s]
                rsumy = Y1[s] - Y0[s]
            end
            if RR == 0 then
                break
            end
        end --s
        dx[(M + 1) * i + j] = rsumx
        dy[(M + 1) * i + j] = rsumy
    end
end

for i = 0, M - 1 do
    u0 = i * dw
    u1 = (i + 1) * dw
    for j = 0, M - 1 do
        v0 = j * dh
        v1 = (j + 1) * dh

        px0 = u0 + dx[(M + 1) * i + j] - obj.w / 2
        px1 = u1 + dx[(M + 1) * (i + 1) + j] - obj.w / 2
        px2 = u1 + dx[(M + 1) * (i + 1) + j + 1] - obj.w / 2
        px3 = u0 + dx[(M + 1) * i + j + 1] - obj.w / 2

        py0 = v0 + dy[(M + 1) * i + j] - obj.h / 2
        py1 = v0 + dy[(M + 1) * (i + 1) + j] - obj.h / 2
        py2 = v1 + dy[(M + 1) * (i + 1) + j + 1] - obj.h / 2
        py3 = v1 + dy[(M + 1) * i + j + 1] - obj.h / 2

        obj.drawpoly(px0, py0, 0, px1, py1, 0, px2, py2, 0, px3, py3, 0, u0, v0, u1, v0, u1, v1, u0, v1)
    end
end

if PSA == 1 then
    for i = 1, N do
        obj.load("figure", "円", kcol, sz)
        obj.ox = X0[i]
        obj.oy = Y0[i]
        obj.draw()

        obj.load("figure", "円", mcol, sz)
        obj.ox = X1[i]
        obj.oy = Y1[i]
        obj.draw()

        sr = ((X0[i] - X1[i]) ^ 2 + (Y0[i] - Y1[i]) ^ 2) ^ 0.5
        u1 = sz / 2 * (Y0[i] - Y1[i]) / sr + X0[i]
        v1 = sz / 2 * (X1[i] - X0[i]) / sr + Y0[i]
        u2 = -sz / 2 * (Y0[i] - Y1[i]) / sr + X0[i]
        v2 = -sz / 2 * (X1[i] - X0[i]) / sr + Y0[i]
        obj.load("figure", "四角形", mcol, 100)
        obj.drawpoly(u1, v1, 0, X1[i], Y1[i], 0, X1[i], Y1[i], 0, u2, v2, 0, 0, 0, obj.w, 0, obj.w, obj.h, 0, obj.h)
        obj.setfont("", sz * 2, 1, fcol, 0x0)
        obj.load("text", i)
        obj.ox = X0[i]
        obj.oy = Y0[i]
        obj.draw()

        obj.load("figure", "四角形", acol, 2 * AT[i], lw)
        obj.ox = X0[i]
        obj.oy = Y0[i]
        obj.draw()

        obj.load("figure", "四角形", dcol, 2 * DF[i], lw)
        obj.ox = X0[i]
        obj.oy = Y0[i]
        obj.draw()
    end
end
N = 0 -- 最後に初期化
