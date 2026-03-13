--label:tim2\アニメーション効果

---$track:開始位置％
---min=0
---max=5000
---step=0.1
local track_open_position_percent = 200

---$track:オーバー量％
---min=0
---max=100
---step=0.1
local track_over_percent = 10

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

---$select:基準軸
---縦=0
---横=1
local select_base_axis = 0

---$check:開始位置角度自動調整
local chk_auto_adjust_start_angle = false

---$track:開始オーバー補正％
---min=0
---max=500
---step=0.1
local track_start_over_correction_percent = 100

---$track:終了オーバー補正％
---min=0
---max=500
---step=0.1
local track_end_over_correction_percent = 100

---$track:開始オーバー時間％
---min=0
---max=100
---step=0.1
local track_start_over_time_percent = 10

---$track:終了オーバー時間％
---min=0
---max=100
---step=0.1
local track_end_over_time_percent = 10

---$track:オフセット％
---min=-5000
---max=5000
---step=0.1
local track_offset_percent = 0

---$track:時間範囲開始％
---min=0
---max=100
---step=0.1
local track_time_range_start_percent = 0

---$track:時間範囲終了％
---min=0
---max=100
---step=0.1
local track_time_range_end_percent = 100

local norm_pos = function(t)
    return t * t * (3 - 2 * t)
end
local norm_spd = function(t)
    return 6 * t * (1 - t)
end

local w, h = obj.getpixel()
local t = obj.time / obj.totaltime

local y0 = track_open_position_percent * 0.01
local dy = track_over_percent * 0.01
local deg = track_direction
local bl = track_blur * 0.01

local cos = math.cos(deg * math.pi / 180)
local sin = math.sin(-deg * math.pi / 180)
local bs = (select_base_axis == 1) and w or h

if chk_auto_adjust_start_angle then
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

local dy1 = dy * track_start_over_correction_percent * 0.01
local dy2 = dy * track_end_over_correction_percent * 0.01

local dt1 = track_start_over_time_percent * 0.01
local dt2 = track_end_over_time_percent * 0.01

local tm1 = math.max(0, math.min(1, track_time_range_start_percent * 0.01))
local tm2 = math.max(0, math.min(1, track_time_range_end_percent * 0.01))
t = tm1 * (1 - t) + t * tm2

local ofs = track_offset_percent * 0.01

bl = bl * (tm2 - tm1) / (obj.totaltime * obj.framerate)

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
