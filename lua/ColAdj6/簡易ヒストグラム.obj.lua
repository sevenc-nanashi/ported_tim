--label:tim2
--track0:レイヤー,1,100,1,1
--track1:幅,100,1000,256,1
--track2:高さ,100,1000,200,1
--track3:縦倍率%,1,1000,100
--value@efR:エフェクト読込/chk,1
--value@Rap:R表示/chk,1
--value@Gap:G表示/chk,1
--value@Bap:B表示/chk,1
--check0:輝度表示,1;
Lw = Lw or 3
local w = obj.track1
local h = obj.track2
efR = efR or 1
Rap = Rap or 1
Gap = Gap or 1
Bap = Bap or 1
require("T_Color_Module")
obj.load("layer", obj.track0, efR == 1)
local w0, h0 = obj.getpixel()
obj.effect("領域拡張", "右", 256 - w0, "下", h - h0)
local userdata, w1, h1 = obj.getpixeldata()
T_Color_Module.CreateHistogram(userdata, 256, h, w0, h0, w1, h1, obj.track3 / 100, obj.check0, Rap, Gap, Bap)
obj.putpixeldata(userdata)
obj.effect(
    "クリッピング",
    "中心の位置を変更",
    1,
    "右",
    math.max(0, w1 - 256),
    "下",
    math.max(0, h1 - h)
)
obj.effect("リサイズ", "ドット数でサイズ指定", 1, "X", w, "Y", h)
obj.effect("縁取り", "サイズ", 1, "ぼかし", 0, "color", 0x0)
obj.effect("縁取り", "サイズ", 2, "ぼかし", 0, "color", 0xffffff)
