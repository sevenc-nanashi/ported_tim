--label:${ROOT_CATEGORY}\カスタムオブジェクト
---$track:光中心(X)
---min=-5000
---max=5000
---step=0.1
local track_light_center_x = -320

---$track:光中心(Y)
---min=-5000
---max=5000
---step=0.1
local track_light_center_y = -180

---$track:ずれ(X)
---min=-5000
---max=5000
---step=0.1
local track_offset_x = 640

---$track:ずれ(Y)
---min=-5000
---max=5000
---step=0.1
local track_offset_y = 360

---$track:ぼかし
---min=0
---max=1000
---step=0.1
local track_blur = 5

---$track:点滅幅
---min=0
---max=1
---step=0.01
local track_flicker = 0.1

local center_x = track_light_center_x
local center_y = track_light_center_y
local offset_x = track_offset_x
local offset_y = track_offset_y

local flicker_alpha = 1 - track_flicker + track_flicker * obj.rand(0, 100) / 100

local make_disc

local function make_light(x, y, flare_size, noise_speed)
    obj.load("figure", "四角形", 0xffffff, 8 * flare_size / 9)
    obj.effect("ノイズ", "周期X", 20, "周期Y", 0, "しきい値", 24, "変化速度", noise_speed)
    obj.effect("境界ぼかし", "範囲", flare_size / 3, "縦横比", -100)
    obj.effect("クリッピング", "上", flare_size / 3)
    obj.effect("極座標変換", "中心幅", flare_size / 25)
    obj.alpha = 0.5 * flicker_alpha
    obj.ox = x
    obj.oy = y
    obj.zoom = 2
    obj.draw()

    obj.load("figure", "円", 0xffffff, 4 * flare_size / 15)
    obj.effect("ぼかし", "範囲", flare_size / 10)
    obj.ox = x
    obj.oy = y
    obj.effect("ぼかし", "範囲", track_blur)
    obj.draw()
    make_disc(x, y, flare_size, 120, 70, 70, 1, 0.2)
end

make_disc = function(x, y, flare_size, r, g, b, outer_alpha, inner_alpha)
    obj.load("figure", "四角形", r * 256 ^ 2 + g * 256 + b, flare_size * 482 / 500)
    obj.alpha = outer_alpha * flicker_alpha
    obj.effect("クリッピング", "上", 0.9 * flare_size)
    obj.effect("境界ぼかし", "範囲", 0.23 * flare_size, "縦横比", -100)
    obj.effect("クリッピング", "下", 0.0395 * flare_size)
    obj.effect("極座標変換", "中心幅", 0.175 * flare_size)
    obj.ox = x
    obj.oy = y
    obj.effect("ぼかし", "範囲", track_blur)
    obj.draw()

    obj.load("figure", "円", r * 256 ^ 2 + g * 256 + b, 0.964 * flare_size)
    obj.alpha = inner_alpha * flicker_alpha
    obj.ox = x
    obj.oy = y
    obj.effect("ぼかし", "範囲", track_blur)
    obj.draw()
end

make_light(center_x, center_y, 450, 0)
make_disc(center_x + 0.60 * offset_x, center_y + 0.60 * offset_y, 200, 255, 255, 128, 0.4, 0.3) --middle yellow
make_disc(center_x + 0.85 * offset_x, center_y + 0.85 * offset_y, 250, 170, 255, 128, 0.4, 0.2) --middle green
make_disc(center_x + offset_x, center_y + offset_y, 500, 255, 255, 128, 0.3, 0.1) --big yellow
make_disc(center_x + 0.58 * offset_x, center_y + 0.58 * offset_y, 100, 255, 255, 128, 0.4, 0.3) --middle-small yellow
make_disc(center_x + 0.68 * offset_x, center_y + 0.68 * offset_y, 80, 170, 255, 128, 0.2, 0.1) --small green
make_disc(center_x + 0.62 * offset_x, center_y + 0.62 * offset_y, 50, 255, 255, 128, 0.4, 0.3) --small yellow
make_disc(center_x + 0.35 * offset_x, center_y + 0.35 * offset_y, 50, 255, 255, 128, 0.4, 0.3) --small yellow
make_disc(center_x - 0.23 * offset_x, center_y - 0.23 * offset_y, 350, 100, 100, 255, 0.2, 0.1) --big parple
make_disc(center_x + 0.41 * offset_x, center_y + 0.41 * offset_y, 10, 255, 255, 255, 0.5, 0.5) --small white
make_disc(center_x + 0.50 * offset_x, center_y + 0.50 * offset_y, 10, 255, 255, 255, 0.5, 0.5) --small white
make_disc(center_x - 0.13 * offset_x, center_y - 0.13 * offset_y, 75, 255, 255, 255, 0.2, 0.1) --middle white
