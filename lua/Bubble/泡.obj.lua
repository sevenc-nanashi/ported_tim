--label:tim2\カスタムオブジェクト
---$track:個数
---min=0
---max=1000
---step=0.1
local track_count = 200

---$track:速度
---min=-50
---max=50
---step=0.1
local track_speed = -8

---$track:方向
---min=-50
---max=50
---step=0.1
local track_direction = 0

---$track:形状補正
---min=0
---max=100
---step=0.1
local track_adjust = 50

---$value:サイズ
local size = 100

---$color:色
local col = 0xffffff

---$value:ゆらぎ幅
local fw = 2

---$value:ゆらぎ速度
local f_speed = 2

---$value:奥行き
local depth = 15

---$value:事後エフェクト
local af = 0

---$value:表示領域補正
local er = 1

obj.load("figure", "円", col, size)
obj.effect("ぼかし", "範囲", size)
obj.effect("クリッピング", "右", size * 1.4 * track_adjust / 100)
obj.effect("クリッピング", "左", size * 1.4 * track_adjust / 100)
obj.effect("斜めクリッピング")
obj.effect("極座標変換")

w = obj.screen_w * er / 2 + obj.w
h = obj.screen_h * er / 2 + obj.h
if af == 0 then
    obj.effect()
else
    obj.setoption("dst", "tmp", obj.screen_w * er, obj.screen_h * er)
end
s = track_speed / 10
sp = track_direction * obj.w
s = s * obj.time
fs = f_speed * obj.time * math.pi * 2 / 10
n = track_count
fw = fw * obj.w
xs = -w
xe = w
if sp < 0 then
    xe = xe - sp
else
    xs = xs - sp
end
for i = 1, n do
    sc = 1 / (1 + depth * i / n)
    t = s * sc + obj.rand(0, 1000, i, 1000) / 1000
    p = math.floor(t)
    t = t - p
    r = fs + math.pi * 2 * obj.rand(0, 1000, i, 1001) / 1000
    x = obj.rand(xs, xe, i, p) + (math.sin(r) * fw + t * sp) * sc
    y = t * h * 2 - h
    obj.draw(x, y, 0, sc)
end

if af ~= 0 then
    obj.load("tempbuffer")
end
