--label:tim2\罫線T.anm\罫線T(削除)
---$track:削除点
---min=2
---max=16
---step=1
local rename_me_track0 = 2

---$value:アンカー
local posDL = { -70, -60, 70, -60 }

RuledlineT = RuledlineT or {}
local apnum = rename_me_track0
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
