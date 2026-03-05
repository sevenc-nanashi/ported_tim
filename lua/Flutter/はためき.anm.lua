--label:tim2
--track0:振幅,0,1000,100
--track1:波数,0,5000,100
--track2:位相ｽﾞﾚX,-5000,5000,-100
--track3:位相ｽﾞﾚY,-5000,5000,0
--value@N:分割数,30
--value@SW:モード,1
--value@Yck:縦波数を別指定/chk,0
--value@HC:└縦波数,100
N = N or 30
SW = (SW or 1) .. ""
local w, h = obj.w, obj.h
local w2, h2 = w / 2, h / 2
local wN, hN = w / N, h / N
local A = w / 30 * obj.track0 / 100
local WC = obj.track1
HC = (Yck == 1) and (HC or 100) or WC
WC = 2 * math.pi / w * WC / 100
HC = 2 * math.pi / w * HC / 100
local d1 = 2 * math.pi * obj.track2 / 100
local d2 = 2 * math.pi * obj.track3 / 100
obj.setoption("antialias", 1)
for i = 0, N - 1 do
    local u1 = i * wN
    local u2 = (i + 1) * wN
    local x1 = u1 - w2
    local x2 = u2 - w2
    local SN1 = math.sin(x1 * WC + d1)
    local SN2 = math.sin(x2 * WC + d1)
    local iN1 = i / N
    local iN2 = (i + 1) / N
    for j = 0, N - 1 do
        local v1 = j * hN
        local v2 = (j + 1) * hN
        local y1 = v1 - h2
        local y2 = v2 - h2
        local z1 = A * (SN1 + math.sin(y1 * HC + d2))
        local z2 = A * (SN2 + math.sin(y1 * HC + d2))
        local z3 = A * (SN2 + math.sin(y2 * HC + d2))
        local z4 = A * (SN1 + math.sin(y2 * HC + d2))
        local jN1 = j / N
        local jN2 = (j + 1) / N
        if string.find(SW, "1") then
            z1, z2, z3, z4 = z1 * iN1, z2 * iN2, z3 * iN2, z4 * iN1
        end
        if string.find(SW, "2") then
            z1, z2, z3, z4 = z1 * jN1, z2 * jN1, z3 * jN2, z4 * jN2
        end
        if string.find(SW, "3") then
            z1, z2, z3, z4 = z1 * (1 - iN1), z2 * (1 - iN2), z3 * (1 - iN2), z4 * (1 - iN1)
        end
        if string.find(SW, "4") then
            z1, z2, z3, z4 = z1 * (1 - jN1), z2 * (1 - jN1), z3 * (1 - jN2), z4 * (1 - jN2)
        end
        obj.drawpoly(x1, y1, z1, x2, y1, z2, x2, y2, z3, x1, y2, z4, u1, v1, u2, v1, u2, v2, u1, v2)
    end
end
