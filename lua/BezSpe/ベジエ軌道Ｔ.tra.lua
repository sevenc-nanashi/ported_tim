--label:tim2\トラックバー制御
--param:1
--[[
軌道調整Ｔ.objの軌道番号と
設定の[]の中の数字を揃える
--]]

local index, ratio = math.modf(obj.getpoint("index"))
local s = obj.getpoint(index)
local e = obj.getpoint(index + 1)
local n = obj.getpoint("param")
local L = obj.getpoint("link")

local q1x, q1y, q2x, q2y, obt

if n > 0 then
    q1x = OrbitNumber[n][1]
    q1y = OrbitNumber[n][2]
    q2x = OrbitNumber[n][3]
    q2y = OrbitNumber[n][4]
    obt = OrbitNumber[n][5]
else
    n = -n
    obt = math.floor(n / 100000000)
    n = n - obt * 100000000
    q1x = math.floor(n / 1000000)
    n = n - q1x * 1000000
    q1y = math.floor(n / 10000)
    n = n - q1y * 10000
    q2x = math.floor(n / 100)
    n = n - q2x * 100
    q2y = n
    q1x, q1y, q2x, q2y = q1x / 50, q1y / 50, q2x / 50, q2y / 50
end

local t1 = 0
local t2 = 1
for i = 1, 10 do
    local tm = (t1 + t2) * 0.5
    local ss = 1 - tm
    local xm = (3 * ss * ss * q1x + (3 * ss * q2x + tm) * tm) * tm
    if ratio < xm then
        t2 = tm
    else
        t1 = tm
    end
end
local tm = (t1 + t2) * 0.5
local ss = 1 - tm
ratio = (3 * ss * ss * q1y + (3 * ss * q2y + tm) * tm) * tm

if obt == 0 then
    return s + (e - s) * ratio
else
    if obt == L + 1 then
        return s + (e - s) * ratio
    else
        return obj.getpoint("default")
    end
end
