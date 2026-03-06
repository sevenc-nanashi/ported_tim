--label:tim2\未分類
---$track:開位置％
---min=0
---max=5000
---step=0.1
local track_open_position_percent = 200

---$track:ｵｰﾊﾞｰ量％
---min=0
---max=100
---step=0.1
local track_percent = 10

---$track:方向
---min=-360
---max=360
---step=0.1
local track_direction = -180

---$track:ブラー
---min=0
---max=1000
---step=0.1
local track_blur = 100

---$value:開ｵｰﾊﾞｰ補正％
local sdy1 = 100

---$value:終ｵｰﾊﾞｰ補正％
local sdy2 = 100

---$value:開始ｵｰﾊﾞｰﾀｲﾑ％
local dt1 = 10

---$value:終了ｵｰﾊﾞｰﾀｲﾑ％
local dt2 = 10

---$value:オフセット％
local ofs = 0

---$value:時間範囲％
local TM = { 0, 100 }

---$check:横基準
local baseChk = 0

---$check:開始位置角度自動調整
local check0 = false

local norm_pos = function(t)
    return t * t * (3 - 2 * t)
end
local norm_spd = function(t)
    return 6 * t * (1 - t)
end

local w, h = obj.getpixel()
local t = obj.time / obj.totaltime

local y0 = track_open_position_percent * 0.01
local dy = track_percent * 0.01
local deg = track_direction
local bl = track_blur * 0.01

local cos = math.cos(deg * math.pi / 180)
local sin = math.sin(-deg * math.pi / 180)
local bs = (baseChk == 1) and w or h

if check0 then
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
