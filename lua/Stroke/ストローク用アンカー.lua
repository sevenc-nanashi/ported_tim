--label:tim2\ストロークT.anm\ストローク用アンカー
--track0:ｱﾝｶｰ数,1,12,3,1
--value@anc:追加座標,{-100,0,0,0,100,0}
--追加削除対策で#は使わない
local k = obj.track0
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
