--label:tim2\未分類
---$track:蓋角度
---min=-90
---max=270
---step=0.1
local track_angle = 0

---$track:側面角度
---min=-90
---max=270
---step=0.1
local track_angle_2 = 0

---$track:サイズ
---min=0
---max=5000
---step=0.1
local track_size = 100

---$track:奥行き(%)
---min=0
---max=5000
---step=0.1
local track_depth_percent = 100

---$value:高さ(%)
local Hr = 100

---$value:配置
local POS = 0

---$value:表裏反転
local REV = 0

---$value:アンチエイリアス
local ANT = 0

local sx0 = {}
local sy0 = {}
local sz0 = {}
local sx1 = {}
local sy1 = {}
local sz1 = {}
local sx2 = {}
local sy2 = {}
local sz2 = {}
local sx3 = {}
local sy3 = {}
local sz3 = {}

local u0 = {}
local u1 = {}
local u2 = {}
local u3 = {}
local v0 = {}
local v1 = {}
local v2 = {}
local v3 = {}

local sita1 = track_angle
local sita2 = track_angle_2

local POS = POS
local REV = REV

local ANT = ANT or 0
local Hr = Hr or 100

obj.setoption("antialias", ANT)
Hr = Hr * 0.01

if POS == 0 then
    ww = track_size
    hh = ww * obj.h / obj.w
    ll = ww * track_depth_percent / 100
else
    ww = track_size
    hh = ww * (obj.h / 2) / (obj.w / 3)
    ll = ww * track_depth_percent / 100
end

ww2 = ww / 2
hh2 = hh / 2
ll2 = ll / 2

if POS == 0 then
    for s = 0, 5 do
        u0[s], v0[s] = 0, 0
        u1[s], v1[s] = obj.w, 0
        u2[s], v2[s] = obj.w, obj.h
        u3[s], v3[s] = 0, obj.h
    end
else
    u0[0], v0[0] = 0, 0
    u1[0], v1[0] = obj.w / 3, 0
    u2[0], v2[0] = obj.w / 3, obj.h / 2
    u3[0], v3[0] = 0, obj.h / 2

    u0[1], v0[1] = obj.w / 3, 0
    u1[1], v1[1] = 2 * obj.w / 3, 0
    u2[1], v2[1] = 2 * obj.w / 3, obj.h / 2
    u3[1], v3[1] = obj.w / 3, obj.h / 2

    u0[2], v0[2] = 0, obj.h / 2
    u1[2], v1[2] = obj.w / 3, obj.h / 2
    u2[2], v2[2] = obj.w / 3, obj.h
    u3[2], v3[2] = 0, obj.h

    u0[3], v0[3] = obj.w / 3, obj.h / 2
    u1[3], v1[3] = 2 * obj.w / 3, obj.h / 2
    u2[3], v2[3] = 2 * obj.w / 3, obj.h
    u3[3], v3[3] = obj.w / 3, obj.h

    u0[4], v0[4] = 2 * obj.w / 3, 0
    u1[4], v1[4] = obj.w, 0
    u2[4], v2[4] = obj.w, obj.h / 2
    u3[4], v3[4] = 2 * obj.w / 3, obj.h / 2

    u0[5], v0[5] = 2 * obj.w / 3, obj.h / 2
    u1[5], v1[5] = obj.w, obj.h / 2
    u2[5], v2[5] = obj.w, obj.h
    u3[5], v3[5] = 2 * obj.w / 3, obj.h
end

sx0[0] = -ww2
sy0[0] = hh2 * Hr - hh * math.cos(sita2 / 180 * math.pi) * Hr
sz0[0] = -ll2 - hh * math.sin(sita2 / 180 * math.pi) * Hr
sx1[0] = ww2
sy1[0] = sy0[0]
sz1[0] = sz0[0]
sx2[0] = ww2
sy2[0] = hh2 * Hr
sz2[0] = -ll2
sx3[0] = -ww2
sy3[0] = hh2 * Hr
sz3[0] = -ll2

sx0[1] = ww2 + hh * math.sin(sita2 / 180 * math.pi) * Hr
sy0[1] = hh2 * Hr - hh * math.cos(sita2 / 180 * math.pi) * Hr
sz0[1] = -ll2
sx1[1] = sx0[1]
sy1[1] = sy0[1]
sz1[1] = ll2
sx2[1] = ww2
sy2[1] = hh2 * Hr
sz2[1] = ll2
sx3[1] = ww2
sy3[1] = hh2 * Hr
sz3[1] = -ll2

sx0[2] = ww2
sy0[2] = hh2 * Hr - hh * math.cos(sita2 / 180 * math.pi) * Hr
sz0[2] = ll2 + hh * math.sin(sita2 / 180 * math.pi) * Hr
sx1[2] = -ww2
sy1[2] = sy0[2]
sz1[2] = sz0[2]
sx2[2] = -ww2
sy2[2] = hh2 * Hr
sz2[2] = ll2
sx3[2] = ww2
sy3[2] = hh2 * Hr
sz3[2] = ll2

sx0[3] = -ww2 - hh * math.sin(sita2 / 180 * math.pi) * Hr
sy0[3] = hh2 * Hr - hh * math.cos(sita2 / 180 * math.pi) * Hr
sz0[3] = ll2
sx1[3] = sx0[3]
sy1[3] = sy0[3]
sz1[3] = -ll2
sx2[3] = -ww2
sy2[3] = hh2 * Hr
sz2[3] = -ll2
sx3[3] = -ww2
sy3[3] = hh2 * Hr
sz3[3] = ll2

sx0[4] = sx1[2]
sy0[4] = sy1[2]
sz0[4] = sz1[2]
sx1[4] = sx0[2]
sy1[4] = sy0[2]
sz1[4] = sz0[2]
sx2[4] = sx1[4]
sy2[4] = sy1[4] - ll * math.sin((sita1 + sita2) / 180 * math.pi)
sz2[4] = sz1[4] - ll * math.cos((sita1 + sita2) / 180 * math.pi)
sx3[4] = sx0[4]
sy3[4] = sy0[4] - ll * math.sin((sita1 + sita2) / 180 * math.pi)
sz3[4] = sz0[4] - ll * math.cos((sita1 + sita2) / 180 * math.pi)

sx0[5] = -ww2
sy0[5] = hh2 * Hr
sz0[5] = -ll2
sx1[5] = ww2
sy1[5] = hh2 * Hr
sz1[5] = -ll2
sx2[5] = ww2
sy2[5] = hh2 * Hr
sz2[5] = ll2
sx3[5] = -ww2
sy3[5] = hh2 * Hr
sz3[5] = ll2

if REV == 1 then
    for s = 0, 5 do
        sx0[s], sx1[s] = sx1[s], sx0[s]
        sy0[s], sy1[s] = sy1[s], sy0[s]
        sz0[s], sz1[s] = sz1[s], sz0[s]

        sx2[s], sx3[s] = sx3[s], sx2[s]
        sy2[s], sy3[s] = sy3[s], sy2[s]
        sz2[s], sz3[s] = sz3[s], sz2[s]
    end
end

for s = 0, 5 do
    obj.drawpoly(
        sx0[s],
        sy0[s],
        sz0[s],
        sx1[s],
        sy1[s],
        sz1[s],
        sx2[s],
        sy2[s],
        sz2[s],
        sx3[s],
        sy3[s],
        sz3[s],
        u0[s],
        v0[s],
        u1[s],
        v1[s],
        u2[s],
        v2[s],
        u3[s],
        v3[s]
    )
end -- s
