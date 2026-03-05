--label:tim2\T_Filter_Module.anm
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

---$track:周期/ｻｲｽﾞ
---min=1
---max=100
---step=0.1
local track_period_size = 20

---$track:分断
---min=0
---max=100
---step=0.1
local track_divide = 0

---$value:形状[1..3]
local fig = 1

---$value:変化速度
local nv = 0

---$value:乱数シード
local seed = 0

require("T_Filter_Module")
local size = track_distortion_amount
local per = track_period_size
fig = ((fig or 1) - 1) % 3 + 1
obj.effect("領域拡張", "塗りつぶし", 1, "上", size, "下", size, "左", size, "右", size)
obj.copybuffer("cache:ori", "obj")
local w, h = obj.getpixel()

if fig == 1 then
    obj.setoption("drawtarget", "tempbuffer", w, h)
    obj.load("figure", "四角形", 0xffffff, math.max(w, h))
    obj.effect("ノイズ", "周期X", per, "周期Y", per, "type", 0, "mode", 1, "seed", seed, "変化速度", nv)
    local userdata, w0, h0 = obj.getpixeldata()
    T_Filter_Module.FlatRGB(userdata, w0, h0, 1)
    obj.putpixeldata(userdata)
    obj.setoption("blend", 5)
    obj.draw()
    obj.load("figure", "四角形", 0xffffff, math.max(w, h))
    obj.effect(
        "ノイズ",
        "周期X",
        per,
        "周期Y",
        per,
        "type",
        0,
        "mode",
        1,
        "seed",
        seed + 100,
        "変化速度",
        nv
    )
    local userdata, w0, h0 = obj.getpixeldata()
    T_Filter_Module.FlatRGB(userdata, w0, h0, 2)
    obj.putpixeldata(userdata)
    obj.setoption("blend", 5)
    obj.draw()
    obj.setoption("blend", 0)
elseif fig == 2 then
    local siz = per * 2.5
    obj.load("figure", "四角形", 0x808080, 50)
    local userdata, w0, h0 = obj.getpixeldata()
    T_Filter_Module.GlassSQ(userdata, w0, h0)
    obj.putpixeldata(userdata)
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

local userdata, w, h = obj.getpixeldata()
T_Filter_Module.Flattening(userdata, w, h, track_divide * 0.01)
obj.putpixeldata(userdata)
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
