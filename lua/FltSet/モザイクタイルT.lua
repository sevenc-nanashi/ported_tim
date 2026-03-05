--label:tim2\T_Filter_Module.anm\モザイクタイルT
---$track:サイズ
---min=0
---max=2000
---step=0.1
local rename_me_track0 = 50

---$track:溝幅
---min=0
---max=1000
---step=0.1
local rename_me_track1 = 1

---$track:細かさ
---min=1
---max=100
---step=0.1
local rename_me_track2 = 10

---$track:変形量
---min=-500
---max=500
---step=0.1
local rename_me_track3 = 30

---$value:縦横比％
local asp = 100

---$value:溝明度
local BL = 70

---$value:凸エッジ幅
local tw = 2

---$value:凸エッジ高さ
local th = 1

---$value:凸エッジ角度
local tr = -45

---$value:がさつき
local gs = 50

---$value:変化速度
local nv = 0

---$value:乱数シード
local seed = 0

---$check:がさつき
local rename_me_check0 = true

local w, h = obj.getpixel()
asp = asp * 0.01
local Sw = rename_me_track0
local Sh = Sw * asp
local Bw = rename_me_track1
local Fr = rename_me_track2 * 0.1
local Rf = rename_me_track3
local w2, h2 = w + Sw, h + Sh

if rename_me_check0 then
    require("T_Filter_Module")
    local Vec = math.floor((tr + 45) / 45 - 0.5)
    Vec = Vec % 8
    obj.effect("領域拡張", "塗りつぶし", 1, "上", 1, "下", 1, "左", 1, "右", 1)
    local userdata, w, h = obj.getpixeldata()
    T_Filter_Module.Sharp(userdata, w, h, 0.5)
    obj.putpixeldata(userdata)
    userdata, w, h = obj.getpixeldata()
    T_Filter_Module.Emboss(userdata, w, h, gs * 0.01, Vec)
    obj.putpixeldata(userdata)
    obj.effect("クリッピング", "上", 1, "下", 1, "左", 1, "右", 1)
end

obj.copybuffer("cache:ori", "obj")
obj.effect("色調補正", "明るさ", BL)
obj.copybuffer("cache:D-ori", "obj")
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
obj.copybuffer("cache:Lat", "tmp")

obj.load("figure", "四角形", 0xffffff, 2 * math.max(w2, h2))
obj.effect("ノイズ", "mode", 1, "周期X", Fr, "周期Y", Fr, "seed", seed, "変化速度", nv)
local userdata, w0, h0 = obj.getpixeldata()
T_Filter_Module.FlatRGB(userdata, w0, h0, 1)
obj.putpixeldata(userdata)
obj.setoption("blend", 0)
obj.draw()
obj.load("figure", "四角形", 0xffffff, 2 * math.max(w2, h2))
obj.effect("ノイズ", "mode", 1, "周期X", Fr, "周期Y", Fr, "seed", seed + 100, "変化速度", nv)
userdata, w0, h0 = obj.getpixeldata()
T_Filter_Module.FlatRGB(userdata, w0, h0, 2)
obj.putpixeldata(userdata)
obj.setoption("blend", 5)
obj.draw()
obj.setoption("blend", 0)
obj.copybuffer("obj", "cache:Lat")
obj.effect(
    "ディスプレイスメントマップ",
    "type",
    0,
    "name",
    "*tempbuffer",
    "元のサイズに合わせる",
    1,
    "param0",
    Rf,
    "param1",
    Rf
)

obj.copybuffer("tmp", "cache:ori")
obj.setoption("blend", "alpha_sub")
obj.draw()
obj.copybuffer("obj", "tmp")
obj.effect("凸エッジ", "幅", tw, "高さ", th, "角度", tr)
obj.copybuffer("tmp", "cache:D-ori")
obj.setoption("blend", 0)
obj.draw()
obj.load("tempbuffer")
