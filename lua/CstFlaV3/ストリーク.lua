--label:tim2\カスタムフレア.anm
---$track:光芒長
---min=0
---max=2000
---step=0.1
local track_ray_length = 400

---$track:光芒高さ
---min=0
---max=2000
---step=0.1
local track_ray_height = 20

---$track:強度
---min=0
---max=100
---step=0.1
local track_intensity = 50

---$track:回転
---min=-3600
---max=3600
---step=0.1
local track_rotation = 0

---$check:ベースカラー
local basechk = 1

---$color:光芒色
local col = 0x9999ff

---$value:位置％
local t = -100

---$value:位置オフセット％
local OFSET = { 0, 0, 0 }

---$check:ｱﾝｶｰに合わせる
local acr = 0

---$value:点滅
local blink = 0.1

obj.copybuffer("tmp", "obj")
obj.setoption("drawtarget", "tempbuffer")
obj.setoption("blend", CustomFlareMode)
if basechk == 1 then
    col = CustomFlareColor
end
local alpha = obj.rand(0, 100) / 100 + (1 - blink)
if alpha > 1 then
    alpha = 1
end
alpha = alpha * track_intensity * 0.01
local l = track_ray_length * 2
local r = track_ray_height * 0.5
local rot = -track_rotation / 180 * math.pi
if acr == 1 then
    rot = rot - math.atan2(CustomFlaredY, CustomFlaredX)
end
obj.load("figure", "円", col, r)
obj.effect("ぼかし", "範囲", r / 2.5)
local dx = (t + OFSET[1]) * 0.01 * CustomFlaredX + CustomFlareCX
local dy = (t + OFSET[2]) * 0.01 * CustomFlaredY + CustomFlareCY
local dz = (t + OFSET[3]) * 0.01 * CustomFlaredZ + CustomFlareCZ
local a = alpha
local yr = r
local c = math.cos(rot)
local s = math.sin(rot)
for i = 1, 3 do
    local x0, y0 = -l * c - yr * s + dx, l * s - yr * c + dy
    local x1, y1 = -l * c + yr * s + dx, l * s + yr * c + dy
    local x2, y2 = l * c + yr * s + dx, -l * s + yr * c + dy
    local x3, y3 = l * c - yr * s + dx, -l * s - yr * c + dy
    obj.drawpoly(x0, y0, dz, x1, y1, dz, x2, y2, dz, x3, y3, dz, 0, 0, obj.w, 0, obj.w, obj.h, 0, obj.h, a)
    a = a / 2
    yr = yr * 2
end
obj.load("tempbuffer")
obj.setoption("blend", 0)
