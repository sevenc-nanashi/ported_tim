--label:tim2\カスタムフレア.anm\ストリーク(複)
---$track:光芒長
---min=0
---max=2000
---step=0.1
local rename_me_track0 = 400

---$track:光芒高さ
---min=0
---max=2000
---step=0.1
local rename_me_track1 = 5

---$track:強度
---min=0
---max=100
---step=0.1
local rename_me_track2 = 100

---$track:回転
---min=-3600
---max=3600
---step=0.1
local rename_me_track3 = 0

---$check:ベースカラー
local basechk = 1

---$color:光芒色
local col = 0x9999ff

---$value:本数
local n = 3

---$value:位置％
local t = -100

---$value:位置オフセット％
local OFSET = { 0, 0, 0 }

---$value:拡大率
local exp = 50

---$value:間隔
local dh = 5

---$value:間隔ﾗﾝﾀﾞﾑ
local ddh = 5

---$value:横ﾗﾝﾀﾞﾑ
local dw = 10

---$value:点滅
local blink = 0.1

obj.copybuffer("cache:BKIMG", "obj") --背景をBKIMGに保存
if basechk == 1 then
    col = CustomFlareColor
end
local l = rename_me_track0 * 2
local r = rename_me_track1 * 0.5
local rot = rename_me_track3
exp = exp * 0.01
obj.load("figure", "円", col, r)
obj.effect("ぼかし", "範囲", r / 2.5)
obj.setoption("blend", 0)
obj.setoption("drawtarget", "tempbuffer", 2 * l, 8 * r)
local a = 1
local yr = r
for i = 1, 3 do
    obj.drawpoly(-l, -yr, 0, -l, yr, 0, l, yr, 0, l, -yr, 0, 0, 0, obj.w, 0, obj.w, obj.h, 0, obj.h)
    --a = a/2
    yr = yr * 2
end
obj.load("tempbuffer")
obj.copybuffer("tmp", "cache:BKIMG")
obj.setoption("blend", CustomFlareMode)
local dx = (t + OFSET[1]) * 0.01 * CustomFlaredX + CustomFlareCX
local dy = (t + OFSET[2]) * 0.01 * CustomFlaredY + CustomFlareCY
local dz = (t + OFSET[3]) * 0.01 * CustomFlaredZ + CustomFlareCZ
local cos = math.cos(rot * math.pi / 180)
local sin = math.sin(-rot * math.pi / 180)
local of = obj.time * obj.framerate
for i = 0, n - 1 do
    local alpha = obj.rand(0, 100, i, of) / 100 + (1 - blink)
    if alpha > 1 then
        alpha = 1
    end
    alpha = alpha * rename_me_track2 * 0.01
    local ox = obj.rand(-dw, dw, i, 1000) * 0.5
    local oy = (i - (n - 1) * 0.5) * dh + obj.rand(-ddh, ddh, i, 2000) * 0.5
    ox, oy = cos * ox + sin * oy, -sin * ox + cos * oy
    obj.draw(ox + dx, oy + dy, dz, exp, alpha, 0, 0, rot)
end
obj.load("tempbuffer")
obj.setoption("blend", 0)
