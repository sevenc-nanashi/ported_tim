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

---$track:サイズ
---min=0
---max=1000
---step=0.1
local track_size = 100

---$color:色
local col = 0xffffff

---$track:ゆらぎ幅
---min=0
---max=10
---step=0.1
local track_fluctuation_width = 2

---$track:ゆらぎ速度
---min=-50
---max=50
---step=0.1
local track_fluctuation_speed = 2

---$track:奥行き
---min=0
---max=100
---step=0.1
local track_depth = 15

---$check:事後エフェクト
local check_after_effect = false

---$track:表示領域補正
---min=0.1
---max=10
---step=0.1
local track_display_area_correction = 1

obj.load("figure", "円", col, track_size)
obj.effect("ぼかし", "範囲", track_size)
obj.effect("クリッピング", "右", track_size * 1.4 * track_adjust / 100)
obj.effect("クリッピング", "左", track_size * 1.4 * track_adjust / 100)
obj.effect("斜めクリッピング")
obj.effect("極座標変換")

w = obj.screen_w * track_display_area_correction / 2 + obj.w
h = obj.screen_h * track_display_area_correction / 2 + obj.h
if not check_after_effect then
    obj.effect()
else
    obj.setoption(
        "dst",
        "tmp",
        obj.screen_w * track_display_area_correction,
        obj.screen_h * track_display_area_correction
    )
end
s = track_speed / 10
sp = track_direction * obj.w
s = s * obj.time
fluctuation_speed = track_fluctuation_speed * obj.time * math.pi * 2 / 10
n = track_count
fluctuation_width = track_fluctuation_width * obj.w
xs = -w
xe = w
if sp < 0 then
    xe = xe - sp
else
    xs = xs - sp
end
for i = 1, n do
    sc = 1 / (1 + track_depth * i / n)
    t = s * sc + obj.rand(0, 1000, i, 1000) / 1000
    p = math.floor(t)
    t = t - p
    r = fluctuation_speed + math.pi * 2 * obj.rand(0, 1000, i, 1001) / 1000
    x = obj.rand(xs, xe, i, p) + (math.sin(r) * fluctuation_width + t * sp) * sc
    y = t * h * 2 - h
    obj.draw(x, y, 0, sc)
end

if check_after_effect then
    obj.load("tempbuffer")
end
