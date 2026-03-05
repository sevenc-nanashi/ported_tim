--label:tim2
---$track:振幅
---min=0
---max=1000
---step=0.1
local rename_me_track0 = 100

---$track:波数
---min=0
---max=5000
---step=0.1
local rename_me_track1 = 100

---$track:位相ｽﾞﾚX
---min=-5000
---max=5000
---step=0.1
local rename_me_track2 = -100

---$track:位相ｽﾞﾚY
---min=-5000
---max=5000
---step=0.1
local rename_me_track3 = 0

---$value:分割数
local N = 30

---$value:モード
local SW = 1

---$value:縦波数を別指定/chk
local Yck = 0

---$value:└縦波数
local HC = 100

N = N or 30
SW = (SW or 1) .. ""
local w, h = obj.w, obj.h
local w2, h2 = w / 2, h / 2
local wN, hN = w / N, h / N
local A = w / 30 * rename_me_track0 / 100
local WC = rename_me_track1
HC = (Yck == 1) and (HC or 100) or WC
WC = 2 * math.pi / w * WC / 100
HC = 2 * math.pi / w * HC / 100
local d1 = 2 * math.pi * rename_me_track2 / 100
local d2 = 2 * math.pi * rename_me_track3 / 100
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
