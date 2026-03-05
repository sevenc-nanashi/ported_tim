--label:tim2\カスタムフレア.anm\スパーク
---$track:サイズ
---min=0
---max=5000
---step=0.1
local rename_me_track0 = 400

---$track:長さ
---min=0
---max=1000
---step=0.1
local rename_me_track1 = 60

---$track:強度
---min=0
---max=100
---step=0.1
local rename_me_track2 = 20

---$track:回転
---min=-3600
---max=3600
---step=0.1
local rename_me_track3 = 0

---$value:数
local n = 150

---$check:ベースカラー
local basechk = 1

---$color:光芒色
local col = 0x9999ff

---$value:幅比率％
local dH = 10

---$value:ぼかし
local blur = 5

---$value:放射ブラー
local rblur = 50

---$value:位置％
local t = -100

---$value:位置オフセット％
local OFSET = { 0, 0, 0 }

---$value:動径方向バラツキ％
local drh = 100

---$value:点滅
local blink = 0.2

---$value:乱数シード
local seed = 0

obj.copybuffer("cache:BKIMG", "obj") --背景をBKIMGに保存
if basechk == 1 then
    col = CustomFlareColor
end
local alpha = obj.rand(0, 100) / 100 + (1 - blink)
if alpha > 1 then
    alpha = 1
end
local size = rename_me_track0 * 0.5
local dL = rename_me_track1 * 0.5
alpha = alpha * rename_me_track2 * 0.01
local rot = rename_me_track3
dH = dL * dH * 0.01
local dx = (t + OFSET[1]) * 0.01 * CustomFlaredX + CustomFlareCX
local dy = (t + OFSET[2]) * 0.01 * CustomFlaredY + CustomFlareCY
local dz = (t + OFSET[3]) * 0.01 * CustomFlaredZ + CustomFlareCZ
obj.load("image", obj.getinfo("script_path") .. "CF-image\\leaf.png")
obj.effect("グラデーション", "color", col, "color2", col, "blend", 3)
obj.effect("ぼかし", "範囲", blur)
local w0, h0 = obj.getpixel()
local LS = dL
local LL = math.max(size * 0.5, dL)
dH = w0 * dH / 30
dL = h0 * dL / 100
drh = drh * 0.01
local wh = 2 * (dL + LL)
obj.setoption("drawtarget", "tempbuffer", wh, wh)
obj.setoption("blend", 6)
LS = drh * LS + (1 - drh) * LL
for i = 1, n do
    local rz = (obj.rand(-3600, 3600, i, seed) * 0.1 - rot) * math.pi / 180
    local r = obj.rand(LS, LL, i, 1000 + seed)
    local s = math.sin(rz)
    local c = math.cos(rz)
    local x0 = -dH
    local y0 = -dL + r
    local x1 = dH
    local y1 = -dL + r
    local x2 = dH
    local y2 = dL + r
    local x3 = -dH
    local y3 = dL + r
    x0, y0 = x0 * c + y0 * s, -x0 * s + y0 * c
    x1, y1 = x1 * c + y1 * s, -x1 * s + y1 * c
    x2, y2 = x2 * c + y2 * s, -x2 * s + y2 * c
    x3, y3 = x3 * c + y3 * s, -x3 * s + y3 * c
    obj.drawpoly(x0, y0, 0, x1, y1, 0, x2, y2, 0, x3, y3, 0, 0, 0, obj.w, 0, obj.w, obj.h, 0, obj.h, alpha)
end
obj.load("tempbuffer")
obj.effect("放射ブラー", "範囲", rblur)
obj.copybuffer("tmp", "cache:BKIMG")
obj.setoption("blend", CustomFlareMode)
obj.draw(dx, dy, dz)
obj.load("tempbuffer")
obj.setoption("blend", 0)
