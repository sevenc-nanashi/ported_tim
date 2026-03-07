--label:tim2\加工\T_Filter_Module.anm
---$track:サイズ
---min=0
---max=2000
---step=0.1
local track_size = 50

---$track:溝幅
---min=0
---max=1000
---step=0.1
local track_width = 1

---$track:細かさ
---min=1
---max=100
---step=0.1
local track_detail = 10

---$track:変形量
---min=-500
---max=500
---step=0.1
local track_deform_amount = 30

---$track:縦横比%
---min=1
---max=400
---step=0.1
local asp = 100

---$track:溝明度
---min=-255
---max=255
---step=1
local BL = 70

---$track:凸エッジ幅
---min=0
---max=50
---step=0.1
local tw = 2

---$track:凸エッジ高さ
---min=-20
---max=20
---step=0.1
local th = 1

---$select:凸エッジ角度
---左=-180
---左上=-135
---上=-90
---右上=-45
---右=0
---右下=45
---下=90
---左下=135
local edge_angle = -45

---$track:がさつき
---min=0
---max=200
---step=0.1
local gs = 50

---$track:変化速度
---min=-100
---max=100
---step=0.1
local nv = 0

---$track:乱数シード
---min=0
---max=9999
---step=1
local seed = 0

---$check:がさつきを有効化
local check0 = true

local w, h = obj.getpixel()
asp = asp * 0.01
local Sw = track_size
local Sh = Sw * asp
local Bw = track_width
local Fr = track_detail * 0.1
local Rf = track_deform_amount
local w2, h2 = w + Sw, h + Sh
local T_Filter_Module = obj.module("tim2")

if check0 then
    local Vec = math.floor((edge_angle + 45) / 45 - 0.5)
    Vec = Vec % 8
    obj.effect("領域拡張", "塗りつぶし", 1, "上", 1, "下", 1, "左", 1, "右", 1)
    local userdata, w, h = obj.getpixeldata("object", "bgra")
    T_Filter_Module.filter_sharp(userdata, w, h, 0.5)
    obj.putpixeldata("object", userdata, w, h, "bgra")
    userdata, w, h = obj.getpixeldata("object", "bgra")
    T_Filter_Module.filter_emboss(userdata, w, h, gs * 0.01, Vec)
    obj.putpixeldata("object", userdata, w, h, "bgra")
    obj.effect("クリッピング", "上", 1, "下", 1, "左", 1, "右", 1)
end

obj.copybuffer("cache:ori", "object")
obj.effect("色調補正", "明るさ", BL)
obj.copybuffer("cache:D-ori", "object")
obj.setoption("drawtarget", "tempbuffer", w2, h2)
obj.load("figure", "四角形", 0xffffff, math.max(Sw, Sh))
w2, h2 = w2 * 0.5, h2 * 0.5
local nx = math.ceil(w2 / Sw)
local ny = math.ceil(h2 / Sh)
local Bw1 = -math.floor(Bw * 0.5)
local Bw2 = Bw1 + Bw
for i = -nx, nx do
    local x = i * Sw
    obj.drawpoly(x + Bw1, -h2, 0, x + Bw2, -h2, 0, x + Bw2, h2, 0, x + Bw1, h2, 0)
end
for j = -ny, ny do
    local y = j * Sh
    obj.drawpoly(-w2, y + Bw1, 0, w2, y + Bw1, 0, w2, y + Bw2, 0, -w2, y + Bw2, 0)
end
obj.copybuffer("cache:Lat", "tempbuffer")

obj.load("figure", "四角形", 0xffffff, 2 * math.max(w2, h2))
obj.effect("ノイズ", "mode", 1, "周期X", Fr, "周期Y", Fr, "seed", seed, "変化速度", nv)
local userdata, w0, h0 = obj.getpixeldata("object", "bgra")
T_Filter_Module.filter_flat_rgb(userdata, w0, h0, 1)
obj.putpixeldata("object", userdata, w0, h0, "bgra")
obj.setoption("blend", "none")
obj.draw()
obj.load("figure", "四角形", 0xffffff, 2 * math.max(w2, h2))
obj.effect("ノイズ", "mode", 1, "周期X", Fr, "周期Y", Fr, "seed", seed + 100, "変化速度", nv)
userdata, w0, h0 = obj.getpixeldata("object", "bgra")
T_Filter_Module.filter_flat_rgb(userdata, w0, h0, 2)
obj.putpixeldata("object", userdata, w0, h0, "bgra")
obj.setoption("blend", "overlay")
obj.draw()
obj.setoption("blend", "none")
obj.copybuffer("object", "cache:Lat")
obj.effect(
    "ディスプレイスメントマップ",
    "変形方法",
    "移動変形",
    "マップの種類",
    "*tempbuffer",
    "元のサイズに合わせる",
    1,
    "変形X",
    Rf,
    "変形Y",
    Rf
)

obj.copybuffer("tempbuffer", "cache:ori")
obj.setoption("blend", "alpha_sub")
obj.draw()
obj.copybuffer("object", "tempbuffer")
obj.effect("凸エッジ", "幅", tw, "高さ", th, "角度", edge_angle)
obj.copybuffer("tempbuffer", "cache:D-ori")
obj.setoption("blend", "none")
obj.draw()
obj.load("tempbuffer")
