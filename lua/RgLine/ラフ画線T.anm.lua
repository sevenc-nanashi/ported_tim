--label:tim2
---$track:長さ
---min=0
---max=500
---step=1
local track_length = 10

---$track:強度上限
---min=0
---max=255
---step=1
local track_intensity_max = 128

---$track:強度下限
---min=0
---max=255
---step=1
local track_intensity_min = 0

---$track:しきい値
---min=0
---max=1000
---step=1
local track_threshold = 0

---$color:線色
local _1 = 0x0

---$color:背景−色
local _2 = 0xffffff

---$value:└元絵比率%
local _3 = 0

---$value:└透明度%
local _4 = 0

---$value:画線ガンマ
local _5 = 100

---$check:スクリーン合成
local _6 = 1

---$check:境界補正
local _7 = 0

---$color:└追加色
local _8 = 0xffffff

---$value:方向表示指定
local _9 = "11110000"

---$value:長さMAPﾚｲﾔｰ
local _10 = 0

---$value:抽出−サイズ
local _11 = 1

---$value:└強度
local _12 = 300

---$value:└しきい値
local _13 = 0

---$value:PI
local _0 = nil

---$check:画線のみ
local check0 = true

_0 = _0 or {}
local pw = _0[1] or track_length
local Lu = _0[2] or track_intensity_max
local Ld = _0[3] or track_intensity_min
local Ls = _0[4] or track_threshold
local Is = _0[0] == nil and check0 or _0[0]
local col1 = _1 or 0x0
local col2 = _2 or 0xffffff
local Oal = _3 or 0
local Bal = _4 or 0
local LG = _5 or 100
local SSy = _6 or 1
local OutC = _7 or 0
local col3 = _8 or 0xffffff
local Did = _9 or "11111111"
local Lay = _10 or 0
local BL = _11 or 1
local BS = _12 or 300
local BH = _13 or 0
_0 = nil
_1 = nil
_2 = nil
_3 = nil
_4 = nil
_5 = nil
_6 = nil
_7 = nil
_8 = nil
_9 = nil
_10 = nil
_11 = nil
_12 = nil
_13 = nil
if OutC == 1 then
    obj.effect("縁取り", "サイズ", pw, "color", col3, "ぼかし", 1)
end
require("T_RoughLine_Module")
local SeD = 0
local RoughLine = T_RoughLine_Module.LineExt
local t = 1
for i in string.gmatch(Did, "[0-1]") do
    SeD = SeD + i * t
    t = t * 2
end
Lay = Lay or 0
if Lay > 0 and Lay <= 100 then
    local Lck = obj.getvalue("layer" .. Lay .. ".x") and 1 or 0
    if Lck == 1 then
        local Pr =
            { obj.ox, obj.oy, obj.oz, obj.rx, obj.ry, obj.rz, obj.cx, obj.cy, obj.cz, obj.zoom, obj.alpha, obj.aspect }
        local w0, h0 = obj.getpixel()
        obj.copybuffer("tmp", "obj")
        obj.load("layer", Lay, true)
        if OutC == 1 then
            obj.effect("領域拡張", "上", pw, "下", pw, "左", pw, "右", pw, "塗りつぶし", 0)
        end
        obj.effect("リサイズ", "X", w0, "Y", h0, "ドット数でサイズ指定", 1)
        local userdata, w, h = obj.getpixeldata()
        T_RoughLine_Module.SetMapImage(userdata, w, h)
        obj.copybuffer("obj", "tmp")
        obj.ox, obj.oy, obj.oz, obj.rx, obj.ry, obj.rz, obj.cx, obj.cy, obj.cz, obj.zoom, obj.alpha, obj.aspect =
            unpack(Pr)
    end
end
local userdata, w, h = obj.getpixeldata()
T_RoughLine_Module.SetPublicImage(userdata, w, h)
obj.effect("ぼかし", "範囲", BL, "サイズ固定", 1)
userdata, w, h = obj.getpixeldata()
RoughLine(userdata, w, h, pw, Lu, Ld, Ls, BS, BH, Is, Oal, Bal, col1, col2, SSy, LG, SeD)
obj.putpixeldata(userdata)
