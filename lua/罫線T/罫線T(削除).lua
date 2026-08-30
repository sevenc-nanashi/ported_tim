--label:${ROOT_CATEGORY}\装飾\@罫線T
---$track:削除点数
---min=2
---max=16
---step=1
local track_delete_point = 2

---$value:削除アンカー
local delete_anchors = { -70, -60, 70, -60 }

T_RULED_LINE_STATE = T_RULED_LINE_STATE or {}
T_RULED_LINE_STATE.definition = T_RULED_LINE_STATE.definition or {}
local ruled_line = T_RULED_LINE_STATE.definition
local anchor_count = track_delete_point
obj.setanchor("delete_anchors", anchor_count, "line")
ruled_line.deletion_anchor_x_groups = ruled_line.deletion_anchor_x_groups or {}
ruled_line.deletion_anchor_y_groups = ruled_line.deletion_anchor_y_groups or {}
local group_index = (#ruled_line.deletion_anchor_x_groups or 0) + 1
ruled_line.deletion_anchor_x_groups[group_index] = {}
ruled_line.deletion_anchor_y_groups[group_index] = {}
for anchor_index = 1, anchor_count do
    ruled_line.deletion_anchor_x_groups[group_index][anchor_index] = delete_anchors[2 * anchor_index - 1]
    ruled_line.deletion_anchor_y_groups[group_index][anchor_index] = delete_anchors[2 * anchor_index]
end
