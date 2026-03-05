--label:tim2
--track0:個数,0,1000,200
--track1:速度,-50,50,-8
--track2:方向,-50,50,0
--track3:形状補正,0,100,50
--value@size:サイズ,100
--value@col:色/col,0xffffff
--value@fw:ゆらぎ幅,2
--value@f_speed:ゆらぎ速度,2
--value@depth:奥行き,15
--value@af:事後エフェクト,0
--value@er:表示領域補正,1

obj.load("figure", "円", col, size)
obj.effect("ぼかし", "範囲", size)
obj.effect("クリッピング", "右", size * 1.4 * obj.track3 / 100)
obj.effect("クリッピング", "左", size * 1.4 * obj.track3 / 100)
obj.effect("斜めクリッピング")
obj.effect("極座標変換")

w = obj.screen_w * er / 2 + obj.w
h = obj.screen_h * er / 2 + obj.h
if af == 0 then
    obj.effect()
else
    obj.setoption("dst", "tmp", obj.screen_w * er, obj.screen_h * er)
end
s = obj.track1 / 10
sp = obj.track2 * obj.w
s = s * obj.time
fs = f_speed * obj.time * math.pi * 2 / 10
n = obj.track0
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
