--label:tim2
--track0:配置,1,3,1,1
--track1:サイズ,0,5000,100
--track2:間隔(%),-1000,1000,10
--value@pPOS:事前回転位置,""
--value@pROT:事前回転方向,""
--value@POS:回転位置,"1251"
--value@ROT:回転方向,"0010"
--value@SHO:内部表示/chk,1

function p_rot(p1, p2, rs, rc)
    return p1 * rc + p2 * rs, -p1 * rs + p2 * rc
end

local SHO = SHO or 1
local POS = POS or "0"
local ROT = ROT or "0"
local pPOS = pPOS or ""
local pROT = pROT or ""

local sx0 = {}
local sy0 = {}
local sz0 = {}
local sx1 = {}
local sy1 = {}
local sz1 = {}
local sx2 = {}
local sy2 = {}
local sz2 = {}
local sx3 = {}
local sy3 = {}
local sz3 = {}
local mset = {}
local II = {}
local JJ = {}
local KK = {}
local u0 = {}
local u1 = {}
local u2 = {}
local u3 = {}
local v0 = {}
local v1 = {}
local v2 = {}
local v3 = {}

local qs = obj.track1
local dw = qs * (1 + obj.track2 / 100)

local DataL = math.min(string.len(POS), string.len(ROT))
for n = 1, DataL do
    mset[n] = tonumber(string.sub(POS, n, n))
    if tonumber(string.sub(ROT, n, n)) == 1 then
        mset[n] = -mset[n]
    end
end
local dN = (obj.totalframe + 1) / DataL
local NowN = math.floor(obj.frame / dN)
local bfN = 1

DataL = math.min(string.len(pPOS), string.len(pROT))
if DataL > 0 then
    for n = 1, DataL do
        mset[n - DataL] = tonumber(string.sub(pPOS, n, n))
        if tonumber(string.sub(pROT, n, n)) == 1 then
            mset[n - DataL] = -mset[n - DataL]
        end
    end
    bfN = 1 - DataL
end

w, h = obj.w, obj.h
local w3 = w / 3
local h3 = h / 3
local w9 = w / 9
local h6 = h / 6

for s = 0, 5 do
    u0[s], v0[s] = 0, 0
    u1[s], v1[s] = w, 0
    u2[s], v2[s] = w, h
    u3[s], v3[s] = 0, h
end

for i = -1, 1 do
    for j = -1, 1 do
        for k = -1, 1 do
            if obj.track0 == 1 then
                u0[0], v0[0] = (i + 1) * w3, (j + 1) * h3
                u1[0], v1[0] = (i + 2) * w3, (j + 1) * h3
                u2[0], v2[0] = (i + 2) * w3, (j + 2) * h3
                u3[0], v3[0] = (i + 1) * w3, (j + 2) * h3

                u0[1], v0[1] = (k + 1) * w3, (j + 1) * h3
                u1[1], v1[1] = (k + 2) * w3, (j + 1) * h3
                u2[1], v2[1] = (k + 2) * w3, (j + 2) * h3
                u3[1], v3[1] = (k + 1) * w3, (j + 2) * h3

                u0[2], v0[2] = (1 - i) * w3, (j + 1) * h3
                u1[2], v1[2] = (2 - i) * w3, (j + 1) * h3
                u2[2], v2[2] = (2 - i) * w3, (j + 2) * h3
                u3[2], v3[2] = (1 - i) * w3, (j + 2) * h3

                u0[3], v0[3] = (1 - k) * w3, (j + 1) * h3
                u1[3], v1[3] = (2 - k) * w3, (j + 1) * h3
                u2[3], v2[3] = (2 - k) * w3, (j + 2) * h3
                u3[3], v3[3] = (1 - k) * w3, (j + 2) * h3

                u0[4], v0[4] = (i + 1) * w3, (1 - k) * h3
                u1[4], v1[4] = (i + 2) * w3, (1 - k) * h3
                u2[4], v2[4] = (i + 2) * w3, (2 - k) * h3
                u3[4], v3[4] = (i + 1) * w3, (2 - k) * h3

                u0[5], v0[5] = (i + 1) * w3, (k + 1) * h3
                u1[5], v1[5] = (i + 2) * w3, (k + 1) * h3
                u2[5], v2[5] = (i + 2) * w3, (k + 2) * h3
                u3[5], v3[5] = (i + 1) * w3, (k + 2) * h3
            elseif obj.track0 == 3 then
                u0[0], v0[0] = (i + 1) * w9, (j + 1) * h6
                u1[0], v1[0] = (i + 2) * w9, (j + 1) * h6
                u2[0], v2[0] = (i + 2) * w9, (j + 2) * h6
                u3[0], v3[0] = (i + 1) * w9, (j + 2) * h6

                u0[1], v0[1] = (3 + k + 1) * w9, (j + 1) * h6
                u1[1], v1[1] = (3 + k + 2) * w9, (j + 1) * h6
                u2[1], v2[1] = (3 + k + 2) * w9, (j + 2) * h6
                u3[1], v3[1] = (3 + k + 1) * w9, (j + 2) * h6

                u0[2], v0[2] = (1 - i) * w9, (j + 1 + 3) * h6
                u1[2], v1[2] = (2 - i) * w9, (j + 1 + 3) * h6
                u2[2], v2[2] = (2 - i) * w9, (j + 2 + 3) * h6
                u3[2], v3[2] = (1 - i) * w9, (j + 2 + 3) * h6

                u0[3], v0[3] = (3 + 1 - k) * w9, (j + 1 + 3) * h6
                u1[3], v1[3] = (3 + 2 - k) * w9, (j + 1 + 3) * h6
                u2[3], v2[3] = (3 + 2 - k) * w9, (j + 2 + 3) * h6
                u3[3], v3[3] = (3 + 1 - k) * w9, (j + 2 + 3) * h6

                u0[4], v0[4] = (6 + i + 1) * w9, (1 - k) * h6
                u1[4], v1[4] = (6 + i + 2) * w9, (1 - k) * h6
                u2[4], v2[4] = (6 + i + 2) * w9, (2 - k) * h6
                u3[4], v3[4] = (6 + i + 1) * w9, (2 - k) * h6

                u0[5], v0[5] = (6 + i + 1) * w9, (k + 1 + 3) * h6
                u1[5], v1[5] = (6 + i + 2) * w9, (k + 1 + 3) * h6
                u2[5], v2[5] = (6 + i + 2) * w9, (k + 2 + 3) * h6
                u3[5], v3[5] = (6 + i + 1) * w9, (k + 2 + 3) * h6
            end

            for si = -1, 1 do
                for sj = -1, 1 do
                    for sk = -1, 1 do
                        II[9 * (si + 1) + 3 * (sj + 1) + (sk + 1)] = si
                        JJ[9 * (si + 1) + 3 * (sj + 1) + (sk + 1)] = sj
                        KK[9 * (si + 1) + 3 * (sj + 1) + (sk + 1)] = sk
                    end -- sk
                end -- sj
            end -- si

            local dx1 = -qs / 2 + dw * i
            local dx2 = qs / 2 + dw * i
            local dy1 = -qs / 2 + dw * j
            local dy2 = qs / 2 + dw * j
            local dz1 = -qs / 2 + dw * k
            local dz2 = qs / 2 + dw * k

            sx0[0] = dx1
            sy0[0] = dy1
            sz0[0] = dz1
            sx1[0] = dx2
            sy1[0] = dy1
            sz1[0] = dz1
            sx2[0] = dx2
            sy2[0] = dy2
            sz2[0] = dz1
            sx3[0] = dx1
            sy3[0] = dy2
            sz3[0] = dz1
            sx0[1] = dx2
            sy0[1] = dy1
            sz0[1] = dz1
            sx1[1] = dx2
            sy1[1] = dy1
            sz1[1] = dz2
            sx2[1] = dx2
            sy2[1] = dy2
            sz2[1] = dz2
            sx3[1] = dx2
            sy3[1] = dy2
            sz3[1] = dz1
            sx0[2] = dx2
            sy0[2] = dy1
            sz0[2] = dz2
            sx1[2] = dx1
            sy1[2] = dy1
            sz1[2] = dz2
            sx2[2] = dx1
            sy2[2] = dy2
            sz2[2] = dz2
            sx3[2] = dx2
            sy3[2] = dy2
            sz3[2] = dz2
            sx0[3] = dx1
            sy0[3] = dy1
            sz0[3] = dz2
            sx1[3] = dx1
            sy1[3] = dy1
            sz1[3] = dz1
            sx2[3] = dx1
            sy2[3] = dy2
            sz2[3] = dz1
            sx3[3] = dx1
            sy3[3] = dy2
            sz3[3] = dz2
            sx0[4] = dx1
            sy0[4] = dy1
            sz0[4] = dz2
            sx1[4] = dx2
            sy1[4] = dy1
            sz1[4] = dz2
            sx2[4] = dx2
            sy2[4] = dy1
            sz2[4] = dz1
            sx3[4] = dx1
            sy3[4] = dy1
            sz3[4] = dz1
            sx0[5] = dx1
            sy0[5] = dy2
            sz0[5] = dz1
            sx1[5] = dx2
            sy1[5] = dy2
            sz1[5] = dz1
            sx2[5] = dx2
            sy2[5] = dy2
            sz2[5] = dz2
            sx3[5] = dx1
            sy3[5] = dy2
            sz3[5] = dz2

            for n = bfN, NowN + 1 do
                local Iact, sita, act, cos_s, sin_s, han

                if n <= NowN then
                    Iact = mset[n]
                    sita = math.pi / 2
                    act = math.floor(math.abs(Iact)) --0, 1,2,3, 4,5,6, 7,8,9
                    if Iact < 0 then
                        sita = -sita
                    end
                    cos_s = math.cos(sita)
                    sin_s = math.sin(-sita)
                else
                    Iact = mset[NowN + 1]
                    local sita = math.pi / 2 * (obj.frame - NowN * dN) / dN
                    act = math.floor(math.abs(Iact)) --0, 1,2,3, 4,5,6, 7,8,9
                    if Iact < 0 then
                        sita = -sita
                    end
                    cos_s = math.cos(sita)
                    sin_s = math.sin(-sita)
                end

                if Iact > 0 then
                    han = -1
                else
                    han = 1
                end

                if act == 1 or act == 2 or act == 3 then
                    if KK[9 * (i + 1) + 3 * (j + 1) + (k + 1)] == act - 2 then
                        for s = 0, 5 do
                            sx0[s], sy0[s] = p_rot(sx0[s], sy0[s], sin_s, cos_s)
                            sx1[s], sy1[s] = p_rot(sx1[s], sy1[s], sin_s, cos_s)
                            sx2[s], sy2[s] = p_rot(sx2[s], sy2[s], sin_s, cos_s)
                            sx3[s], sy3[s] = p_rot(sx3[s], sy3[s], sin_s, cos_s)
                        end
                        II[9 * (i + 1) + 3 * (j + 1) + (k + 1)], JJ[9 * (i + 1) + 3 * (j + 1) + (k + 1)] = p_rot(
                            II[9 * (i + 1) + 3 * (j + 1) + (k + 1)],
                            JJ[9 * (i + 1) + 3 * (j + 1) + (k + 1)],
                            han,
                            0
                        )
                    end
                end

                if act == 4 or act == 5 or act == 6 then
                    if II[9 * (i + 1) + 3 * (j + 1) + (k + 1)] == act - 5 then
                        for s = 0, 5 do
                            sy0[s], sz0[s] = p_rot(sy0[s], sz0[s], sin_s, cos_s)
                            sy1[s], sz1[s] = p_rot(sy1[s], sz1[s], sin_s, cos_s)
                            sy2[s], sz2[s] = p_rot(sy2[s], sz2[s], sin_s, cos_s)
                            sy3[s], sz3[s] = p_rot(sy3[s], sz3[s], sin_s, cos_s)
                        end
                        JJ[9 * (i + 1) + 3 * (j + 1) + (k + 1)], KK[9 * (i + 1) + 3 * (j + 1) + (k + 1)] = p_rot(
                            JJ[9 * (i + 1) + 3 * (j + 1) + (k + 1)],
                            KK[9 * (i + 1) + 3 * (j + 1) + (k + 1)],
                            han,
                            0
                        )
                    end
                end

                if act == 7 or act == 8 or act == 9 then
                    if JJ[9 * (i + 1) + 3 * (j + 1) + (k + 1)] == act - 8 then
                        for s = 0, 5 do
                            sz0[s], sx0[s] = p_rot(sz0[s], sx0[s], sin_s, cos_s)
                            sz1[s], sx1[s] = p_rot(sz1[s], sx1[s], sin_s, cos_s)
                            sz2[s], sx2[s] = p_rot(sz2[s], sx2[s], sin_s, cos_s)
                            sz3[s], sx3[s] = p_rot(sz3[s], sx3[s], sin_s, cos_s)
                        end
                        KK[9 * (i + 1) + 3 * (j + 1) + (k + 1)], II[9 * (i + 1) + 3 * (j + 1) + (k + 1)] = p_rot(
                            KK[9 * (i + 1) + 3 * (j + 1) + (k + 1)],
                            II[9 * (i + 1) + 3 * (j + 1) + (k + 1)],
                            han,
                            0
                        )
                    end
                end

                if n == NowN + 1 then
                    if SHO == 0 then
                        for s = 0, 5 do
                            if
                                (s == 0 and k == -1)
                                or (s == 2 and k == 1)
                                or (s == 1 and i == 1)
                                or (s == 3 and i == -1)
                                or (s == 4 and j == -1)
                                or (s == 5 and j == 1)
                            then
                                obj.drawpoly(
                                    sx0[s],
                                    sy0[s],
                                    sz0[s],
                                    sx1[s],
                                    sy1[s],
                                    sz1[s],
                                    sx2[s],
                                    sy2[s],
                                    sz2[s],
                                    sx3[s],
                                    sy3[s],
                                    sz3[s],
                                    u0[s],
                                    v0[s],
                                    u1[s],
                                    v1[s],
                                    u2[s],
                                    v2[s],
                                    u3[s],
                                    v3[s]
                                )
                            end
                        end -- s
                    else
                        for s = 0, 5 do
                            obj.drawpoly(
                                sx0[s],
                                sy0[s],
                                sz0[s],
                                sx1[s],
                                sy1[s],
                                sz1[s],
                                sx2[s],
                                sy2[s],
                                sz2[s],
                                sx3[s],
                                sy3[s],
                                sz3[s],
                                u0[s],
                                v0[s],
                                u1[s],
                                v1[s],
                                u2[s],
                                v2[s],
                                u3[s],
                                v3[s]
                            )
                        end -- s
                    end -- SHO
                end -- if n
            end -- n
        end -- k
    end -- j
end -- i
