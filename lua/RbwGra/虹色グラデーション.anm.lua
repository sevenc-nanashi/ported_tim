--label:tim2
--track0:縮小率,0,500,100
--track1:回転,-3600,3600,0
--track2:シフト,-5000,5000,0
--track3:元画像,0,100,0
--value@chk:円形配置/chk,0
--value@rev:反転/chk,0
--value@rep:繰返し/chk,0
--value@gmode:合成モード[0-9],0
--value@S:混色度合,30
--value@dc:境界補正,0.055
--value@reC:位置ズレ補正/chk,1

local iox = obj.ox
local ioy = obj.oy
local icx = obj.cx
local icy = obj.cy
reC = reC or 0

require("T_R_gradation")
local userdata, w, h = obj.getpixeldata()
obj.setoption("drawtarget", "tempbuffer", w, h)
obj.draw()

T_R_gradation.T_R_gradationLine(
    userdata,
    w,
    h,
    S,
    obj.track0 * 0.01,
    math.rad(obj.track1),
    rev,
    chk,
    obj.track2,
    rep,
    dc
)

obj.putpixeldata(userdata)
obj.setoption("blend", math.floor(gmode))
obj.draw(0, 0, 0, 1, 1 - obj.track3 * 0.01)
obj.load("tempbuffer")
obj.setoption("blend", 0)

if reC == 1 then
    obj.ox = iox
    obj.oy = ioy
    obj.cx = icx
    obj.cy = icy
end
