--label:tim2
---$track:縮小率
---min=0
---max=500
---step=0.1
local rename_me_track0 = 100

---$track:回転
---min=-3600
---max=3600
---step=0.1
local rename_me_track1 = 0

---$track:シフト
---min=-5000
---max=5000
---step=0.1
local rename_me_track2 = 0

---$track:元画像
---min=0
---max=100
---step=0.1
local rename_me_track3 = 0

---$check:円形配置
local chk = 0

---$check:反転
local rev = 0

---$check:繰返し
local rep = 0

---$value:合成モード[0-9]
local gmode = 0

---$value:混色度合
local S = 30

---$value:境界補正
local dc = 0.055

---$check:位置ズレ補正
local reC = 1

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
    rename_me_track0 * 0.01,
    math.rad(rename_me_track1),
    rev,
    chk,
    rename_me_track2,
    rep,
    dc
)

obj.putpixeldata(userdata)
obj.setoption("blend", math.floor(gmode))
obj.draw(0, 0, 0, 1, 1 - rename_me_track3 * 0.01)
obj.load("tempbuffer")
obj.setoption("blend", 0)

if reC == 1 then
    obj.ox = iox
    obj.oy = ioy
    obj.cx = icx
    obj.cy = icy
end
