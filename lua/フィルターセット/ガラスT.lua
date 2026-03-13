--label:tim2\加工\@T_Filter_Module
---$track:歪み量
---min=0
---max=500
---step=0.1
local track_distortion_amount = 50

---$track:滑らか
---min=0
---max=200
---step=1
local track_smooth = 5

---$track:周期/サイズ
---min=1
---max=100
---step=0.1
local track_period_size = 20

---$track:分断
---min=0
---max=100
---step=0.1
local track_divide = 0

---$select:形状
---ノイズ四角=1
---四角ガラス=2
---円ガラス=3
local fig = 1

---$track:変化速度
---min=-1000
---max=1000
---step=0.1
local track_change_speed = 0

---$track:乱数シード
---min=0
---max=100000
---step=1
local track_seed = 0

local T_Filter_Module = obj.module("tim2")
local size = track_distortion_amount
local per = track_period_size
local seed = track_seed
local nv = track_change_speed
fig = ((fig or 1) - 1) % 3 + 1
obj.effect("領域拡張", "塗りつぶし", 1, "上", size, "下", size, "左", size, "右", size)
obj.copybuffer("cache:ori", "object")
local w, h = obj.getpixel()

if fig == 1 then
    obj.setoption("drawtarget", "tempbuffer", w, h)
    obj.load("figure", "四角形", 0xffffff, math.max(w, h))
    obj.effect("ノイズ", "周期X", per, "周期Y", per, "type", 0, "mode", 1, "seed", seed, "変化速度", nv)
    local userdata, w0, h0 = obj.getpixeldata("object", "bgra")
    T_Filter_Module.filter_flat_rgb(userdata, w0, h0, 1)
    obj.putpixeldata("object", userdata, w0, h0, "bgra")
    obj.setoption("blend", 5)
    obj.draw()
    obj.load("figure", "四角形", 0xffffff, math.max(w, h))
    obj.effect(
        "ノイズ",
        "周期X",
        per,
        "周期Y",
        per,
        "ノイズの種類",
        "Type1",
        "合成モード",
        "明るさと乗算",
        "シード",
        seed + 100,
        "変化速度",
        nv
    )
    local userdata, w0, h0 = obj.getpixeldata("object", "bgra")
    T_Filter_Module.filter_flat_rgb(userdata, w0, h0, 2)
    obj.putpixeldata("object", userdata, w0, h0, "bgra")
    obj.setoption("blend", 5)
    obj.draw()
    obj.setoption("blend", 0)
elseif fig == 2 then
    local siz = per * 2.5
    obj.load("figure", "四角形", 0x808080, 50)
    local userdata, w0, h0 = obj.getpixeldata("object", "bgra")
    T_Filter_Module.filter_glass_sq(userdata, w0, h0)
    obj.putpixeldata("object", userdata, w0, h0, "bgra")
    obj.effect("ぼかし", "範囲", 2, "サイズ固定", 1)
    local pp = siz / 50 * 100
    obj.effect("リサイズ", "拡大率", pp)
    local nx = -math.floor(-w / siz)
    local ny = -math.floor(-h / siz)
    nx = 2 * math.floor((nx + 1) / 2)
    ny = 2 * math.floor((ny + 1) / 2)
    obj.effect("画像ループ", "横回数", nx, "縦回数", ny)
else
    local siz = per * 5
    obj.setoption("drawtarget", "tempbuffer", 100, 100)
    obj.load("figure", "四角形", 0x808080, 100)
    obj.draw()
    obj.load("figure", "四角形", 0xffffff, 100)
    obj.draw(0, 0, 0, 1, 0.2)
    obj.load("figure", "円", 0x808080, 70.71)
    obj.effect("グラデーション", "幅", 140, "blend", 5, "color", 0x80ff80, "color2", 0x800080)
    obj.effect("グラデーション", "幅", 140, "blend", 5, "color2", 0xff8080, "color", 0x008080, "角度", 90)
    obj.draw(50, 0, 0)
    obj.draw(-50, 0, 0)
    obj.draw(0, 50, 0)
    obj.draw(0, -50, 0)
    obj.load("tempbuffer")
    obj.effect("リサイズ", "拡大率", siz)
    local nx = -math.floor(-w / siz)
    local ny = -math.floor(-h / siz)
    nx = 2 * math.floor((nx + 1) / 2)
    ny = 2 * math.floor((ny + 1) / 2)
    obj.effect("画像ループ", "横回数", nx, "縦回数", ny)
    obj.effect("ぼかし", "範囲", siz * 0.02, "サイズ固定", 1)
end
obj.setoption("drawtarget", "tempbuffer", w, h)

local userdata, w, h = obj.getpixeldata("tempbuffer", "bgra")
T_Filter_Module.filter_flattening(userdata, w, h, track_divide * 0.01)
obj.putpixeldata("tempbuffer", userdata, w, h, "bgra")
obj.draw()

obj.copybuffer("obj", "cache:ori")
obj.effect(
    "ディスプレイスメントマップ",
    "type",
    0,
    "name",
    "*tempbuffer",
    "元のサイズに合わせる",
    1,
    "param0",
    size,
    "param1",
    size,
    "ぼかし",
    track_smooth
)
obj.effect("クリッピング", "上", size, "下", size, "左", size, "右", size)
