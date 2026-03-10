--label:tim2\配置\TrackingラインEasy.anm
---$track:+頂点数
---min=2
---max=16
---step=1
local track_plus_vertex_count = 2

---$check:環状にする
local cy = 0

---$value:座標
local pos = { 0, 0, 100, 100 }

---$check:頂点追加を無効にする
local check0 = false

if not check0 then
    local num = track_plus_vertex_count
    obj.setanchor("pos", num, "line")
    local xnum = #Tracking.X + 1
    Tracking.cy[xnum] = cy or 0
    Tracking.X[xnum] = {}
    Tracking.Y[xnum] = {}
    for i = 1, num do
        Tracking.X[xnum][i] = pos[2 * i - 1]
        Tracking.Y[xnum][i] = pos[2 * i]
    end
end

if obj.getoption("script_name", 1) ~= "TrackingラインEasy(頂点追加)@tim.anm2" then
    Tracking.DoTrackingLineEasy(Tracking)
    Tracking = nil
end
