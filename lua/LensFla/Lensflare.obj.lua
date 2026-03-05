--label:tim2
--track0:光中心(X),-5000,5000,-320
--track1:光中心(Y),-5000,5000,-180
--track2:ずれ(X),-5000,5000,640
--track3:ずれ(Y),-5000,5000,360
--param:bb=5;fh=0.1

Cx = obj.track0
Cy = obj.track1
dx = obj.track2
dy = obj.track3

YR = 1 - fh + fh * obj.rand(0, 100) / 100

function MkLt(X, Y, fsize, CHS)
    obj.load("figure", "四角形", 0xffffff, 8 * fsize / 9)
    obj.effect("ノイズ", "周期X", 20, "周期Y", 0, "しきい値", 24, "変化速度", CHS)
    obj.effect("境界ぼかし", "範囲", fsize / 3, "縦横比", -100)
    obj.effect("クリッピング", "上", fsize / 3)
    obj.effect("極座標変換", "中心幅", fsize / 25)
    obj.alpha = 0.5 * YR
    obj.ox = X
    obj.oy = Y
    obj.zoom = 2
    obj.draw()

    obj.load("figure", "円", 0xffffff, 4 * fsize / 15)
    obj.effect("ぼかし", "範囲", fsize / 10)
    obj.ox = X
    obj.oy = Y
    obj.effect("ぼかし", "範囲", bb)
    obj.draw()
    MkDC(X, Y, fsize, 120, 70, 70, 1, 0.2)
end

function MkDC(X, Y, fsize, R, G, B, ALP1, ALP2)
    obj.load("figure", "四角形", R * 256 ^ 2 + G * 256 + B, fsize * 482 / 500)
    obj.alpha = ALP1 * YR
    obj.effect("クリッピング", "上", 0.9 * fsize)
    obj.effect("境界ぼかし", "範囲", 0.23 * fsize, "縦横比", -100)
    obj.effect("クリッピング", "下", 0.0395 * fsize)
    obj.effect("極座標変換", "中心幅", 0.175 * fsize)
    obj.ox = X
    obj.oy = Y
    obj.effect("ぼかし", "範囲", bb)
    obj.draw()

    obj.load("figure", "円", R * 256 ^ 2 + G * 256 + B, 0.964 * fsize)
    obj.alpha = ALP2 * YR
    obj.ox = X
    obj.oy = Y
    obj.effect("ぼかし", "範囲", bb)
    obj.draw()
end

MkLt(Cx, Cy, 450, 0)
MkDC(Cx + 0.60 * dx, Cy + 0.60 * dy, 200, 255, 255, 128, 0.4, 0.3) --middle yellow
MkDC(Cx + 0.85 * dx, Cy + 0.85 * dy, 250, 170, 255, 128, 0.4, 0.2) --middle green
MkDC(Cx + dx, Cy + dy, 500, 255, 255, 128, 0.3, 0.1) --big yellow
MkDC(Cx + 0.58 * dx, Cy + 0.58 * dy, 100, 255, 255, 128, 0.4, 0.3) --middle-small yellow
MkDC(Cx + 0.68 * dx, Cy + 0.68 * dy, 80, 170, 255, 128, 0.2, 0.1) --small green
MkDC(Cx + 0.62 * dx, Cy + 0.62 * dy, 50, 255, 255, 128, 0.4, 0.3) --small yellow
MkDC(Cx + 0.35 * dx, Cy + 0.35 * dy, 50, 255, 255, 128, 0.4, 0.3) --small yellow
MkDC(Cx - 0.23 * dx, Cy - 0.23 * dy, 350, 100, 100, 255, 0.2, 0.1) --big parple
MkDC(Cx + 0.41 * dx, Cy + 0.41 * dy, 10, 255, 255, 255, 0.5, 0.5) --small white
MkDC(Cx + 0.50 * dx, Cy + 0.50 * dy, 10, 255, 255, 255, 0.5, 0.5) --small white
MkDC(Cx - 0.13 * dx, Cy - 0.13 * dy, 75, 255, 255, 255, 0.2, 0.1) --middle white
