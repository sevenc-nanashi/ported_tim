--label:tim2\罫線T.anm\罫線T(削除)
--track0:削除点,2,16,2,1
--value@posDL:アンカー,{-70,-60,70,-60}
RuledlineT = RuledlineT or {}
local apnum = obj.track0
obj.setanchor("posDL", apnum, "line")
RuledlineT.ACX = RuledlineT.ACX or {}
RuledlineT.ACY = RuledlineT.ACY or {}
local num = (#RuledlineT.ACX or 0) + 1
RuledlineT.ACX[num] = {}
RuledlineT.ACY[num] = {}
for k = 1, apnum do
    RuledlineT.ACX[num][k] = posDL[2 * k - 1]
    RuledlineT.ACY[num][k] = posDL[2 * k]
end
