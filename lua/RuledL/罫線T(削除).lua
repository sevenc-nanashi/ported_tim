--label:tim2\装飾\罫線T.anm
---$track:削除点数
---min=2
---max=16
---step=1
local track_delete_point = 2

---$value:削除アンカー
local delete_anchors = { -70, -60, 70, -60 }

RuledlineT = RuledlineT or {}
local anchor_count = track_delete_point
obj.setanchor("delete_anchors", anchor_count, "line")
RuledlineT.ACX = RuledlineT.ACX or {}
RuledlineT.ACY = RuledlineT.ACY or {}
local num = (#RuledlineT.ACX or 0) + 1
RuledlineT.ACX[num] = {}
RuledlineT.ACY[num] = {}
for k = 1, anchor_count do
    RuledlineT.ACX[num][k] = delete_anchors[2 * k - 1]
    RuledlineT.ACY[num][k] = delete_anchors[2 * k]
end
