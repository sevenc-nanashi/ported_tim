--label:tim2\カスタムフレア.anm\ゆらめき
---$track:サイズ
---min=10
---max=1000
---step=0.1
local rename_me_track0 = 250

---$track:光芒量
---min=0
---max=100
---step=0.1
local rename_me_track1 = 55

---$track:強度
---min=0
---max=200
---step=0.1
local rename_me_track2 = 60

---$track:回転
---min=-3600
---max=3600
---step=0.1
local rename_me_track3 = 0

---$check:ベースカラー
local basechk = 1

---$color:光芒色
local col = 0x9999ff

---$value:位置％
local t = -100

---$value:位置オフセット％
local OFSET = { 0, 0, 0 }

---$value:先端ぼかし％
local rnd = 100

---$value:光芒変化速度
local speed = 0.2

---$value:形状[1-8]
local fig = 5

---$value:ｸﾘｯﾌﾟ位置幅ﾎﾞｶｼ
local clp = { 0, 0, 0 }

---$check:ｸﾘｯﾌﾟ向き
local aub = 0

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
local w = rename_me_track0
local c_num = rename_me_track1
local c_alp = rename_me_track2 * 0.01
fig = math.floor(fig)
if fig > 8 then
    fig = 8
end
if fig < 1 then
    fig = 1
end
local dx = (t + OFSET[1]) * 0.01 * CustomFlaredX + CustomFlareCX
local dy = (t + OFSET[2]) * 0.01 * CustomFlaredY + CustomFlareCY
local dz = (t + OFSET[3]) * 0.01 * CustomFlaredZ + CustomFlareCZ
local r = 2 * w
obj.load("figure", "四角形", col, r)
if fig <= 4 then
    obj.effect("ノイズ", "type", fig, "周期X", 1, "周期Y", 0, "しきい値", 100 - c_num, "速度Y", -speed)
else
    fig = fig - 4
    obj.effect("ノイズ", "type", fig, "周期X", c_num * 0.05, "周期Y", 0, "しきい値", 0, "速度Y", -speed)
end
obj.effect("境界ぼかし", "範囲", r * rnd * 0.01, "縦横比", -100)
clp[1] = -r * (clp[1] / 360 % 1)
clp[2] = r * (clp[2] / 360 % 1)
if aub == 1 then
    clp[1] = -r * (math.atan2(CustomFlaredY, CustomFlaredX) * 0.5 + math.pi / 4) / math.pi
end
if clp[2] > 0 then
    obj.effect("斜めクリッピング", "角度", 90, "中心X", clp[1] - r, "幅", -clp[2], "ぼかし", clp[3])
    obj.effect("斜めクリッピング", "角度", 90, "中心X", clp[1], "幅", -clp[2], "ぼかし", clp[3])
    obj.effect("斜めクリッピング", "角度", 90, "中心X", clp[1] + r, "幅", -clp[2], "ぼかし", clp[3])
end
r = r / 2.5
obj.effect("クリッピング", "上", r)
obj.effect("極座標変換", "回転", rename_me_track3)
local x0 = -r + dx
local y0 = -r + dy
local x1 = r + dx
local y1 = -r + dy
local x2 = r + dx
local y2 = r + dy
local x3 = -r + dx
local y3 = r + dy
alpha = alpha * c_alp
if alpha <= 1 then
    obj.drawpoly(x0, y0, dz, x1, y1, dz, x2, y2, dz, x3, y3, dz, 0, 0, obj.w, 0, obj.w, obj.h, 0, obj.h, alpha)
else
    obj.drawpoly(x0, y0, dz, x1, y1, dz, x2, y2, dz, x3, y3, dz, 0, 0, obj.w, 0, obj.w, obj.h, 0, obj.h, 1)
    obj.drawpoly(x0, y0, dz, x1, y1, dz, x2, y2, dz, x3, y3, dz, 0, 0, obj.w, 0, obj.w, obj.h, 0, obj.h, alpha - 1)
end
obj.load("tempbuffer")
obj.setoption("blend", 0)
