--label:tim2
--track0:開位置％,0,5000,200
--track1:ｵｰﾊﾞｰ量％,0,100,10
--track2:方向,-360,360,-180
--track3:ブラー,0,1000,100
--value@sdy1:開ｵｰﾊﾞｰ補正％,100
--value@sdy2:終ｵｰﾊﾞｰ補正％,100
--value@dt1:開始ｵｰﾊﾞｰﾀｲﾑ％,10
--value@dt2:終了ｵｰﾊﾞｰﾀｲﾑ％,10
--value@ofs:オフセット％,0
--value@TM:時間範囲％,{0,100}
--value@baseChk:横基準/chk,0
--check0:開始位置角度自動調整,0;

local norm_pos = function(t)
    return t * t * (3 - 2 * t)
end
local norm_spd = function(t)
    return 6 * t * (1 - t)
end

local w, h = obj.getpixel()
local t = obj.time / obj.totaltime

local y0 = obj.track0 * 0.01
local dy = obj.track1 * 0.01
local deg = obj.track2
local bl = obj.track3 * 0.01

local cos = math.cos(deg * math.pi / 180)
local sin = math.sin(-deg * math.pi / 180)
local bs = (baseChk == 1) and w or h

if obj.check0 then
    local x = bs * y0 * sin
    local y = bs * y0 * cos
    x = w * math.floor((x + w * 0.5) / w)
    y = h * math.floor((y + h * 0.5) / h)
    local r = math.sqrt(x * x + y * y)
    y0 = r / bs
    deg = math.atan2(x, y)
    cos = math.cos(deg)
    sin = math.sin(deg)
    deg = 180 - deg * 180 / math.pi
end

local dy1 = dy * sdy1 * 0.01
local dy2 = dy * sdy2 * 0.01

dt1 = dt1 * 0.01
dt2 = dt2 * 0.01
TM = TM or { 0, 100 }
local TM1 = TM[1] * 0.01
local TM2 = TM[2] * 0.01
if TM1 < 0 then
    TM1 = 0
elseif TM1 > 1 then
    TM1 = 1
end
if TM2 < 0 then
    TM2 = 0
elseif TM2 > 1 then
    TM2 = 1
end
t = TM1 * (1 - t) + t * TM2

ofs = ofs * 0.01

bl = bl * (TM2 - TM1) / (obj.totaltime * obj.framerate)

local pos
if t < dt1 and dt1 ~= 0 then
    t = t / dt1
    pos = y0 + dy1 * norm_pos(t) + ofs
    bl = bl * dy1 * norm_spd(t) / dt1
elseif t > 1 - dt2 and dt2 ~= 0 then
    t = (t - 1 + dt2) / dt2
    pos = -dy2 * (1 - norm_pos(t)) + ofs
    bl = bl * dy2 * norm_spd(t) / dt2
else
    t = (t - dt1) / (1 - dt1 - dt2)
    pos = y0 + dy1 - (y0 + dy1 + dy2) * norm_pos(t) + ofs
    bl = bl * (y0 + dy1 + dy2) * norm_spd(t) / (1 - dt1 - dt2)
end
bl = math.abs(bl / 2)

obj.setoption("drawtarget", "tempbuffer", w, h)

local posy = bs * pos * cos
local posx = bs * pos * sin
posx = (posx % w)
posy = (posy % h)

obj.draw(posx, posy)
obj.draw(posx, posy - h)
obj.draw(posx - w, posy)
obj.draw(posx - w, posy - h)
obj.load("tempbuffer")
obj.effect("方向ブラー", "角度", deg, "範囲", bl * bs, "サイズ固定", 1)
