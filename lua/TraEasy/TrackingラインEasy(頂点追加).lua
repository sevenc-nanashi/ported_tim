--label:tim2\TrackingラインEasy.anm\TrackingラインEasy(頂点追加)
--track0:+頂点数,2,16,2,1
--value@cy:環状にする/chk,0
--value@pos:座標,{0,0,100,100}
--check0:頂点追加を無効にする,0;

if not obj.check0 then
    local num = obj.track0
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

if obj.getoption("script_name", 1) ~= "TrackingラインEasy(頂点追加)@TrackingラインEasy" then
    Tracking.DoTrackingLineEasy(Tracking)
    Tracking = nil
end
