--label:${ROOT_CATEGORY}\装飾\@ストロークT
---$track:アンカー数
---min=1
---max=12
---step=1
local track_count = 3

---$value:追加座標
local anchors = { -100, 0, 0, 0, 100, 0 }

--追加削除対策で#は使わない
local anchor_count = track_count
obj.setanchor("anchors", anchor_count, "line")
if T_STROKE_ANCHORS == nil then
    T_STROKE_ANCHORS = {}
    T_STROKE_ANCHOR_COUNT = 0
end
for i = 1, 2 * anchor_count do
    T_STROKE_ANCHORS[2 * T_STROKE_ANCHOR_COUNT + i] = anchors[i]
end
T_STROKE_ANCHOR_COUNT = T_STROKE_ANCHOR_COUNT + anchor_count

---$embed
local common = require("common")
if common.is_last_chain() then
    T_STROKE_DRAW()
    T_STROKE_ANCHORS = nil
    T_STROKE_ANCHOR_COUNT = nil
end
