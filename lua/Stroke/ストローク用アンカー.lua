--label:tim2\装飾\ストロークT.anm
---$track:アンカー数
---min=1
---max=12
---step=1
local track_count = 3

---$value:追加座標
local anc = { -100, 0, 0, 0, 100, 0 }

--追加削除対策で#は使わない
local k = track_count
obj.setanchor("anc", k, "line")
if T_strokeTM_ancB == nil then
    T_strokeTM_ancB = {}
    T_strokeTM_N = 0
end
for i = 1, 2 * k do
    T_strokeTM_ancB[2 * T_strokeTM_N + i] = anc[i]
end
T_strokeTM_N = T_strokeTM_N + k

if obj.getoption("script_name", 1, true):sub(-4, -1) ~= obj.getoption("script_name"):sub(-4, -1) then
    T_stroke_f()
    T_strokeTM_ancB = nil
    T_strokeTM_N = nil
end
