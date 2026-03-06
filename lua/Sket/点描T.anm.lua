--label:tim2
---$track:サイズ
---min=3
---max=300
---step=1
local track_size = 10

---$track:位置ｽﾞﾚ%
---min=0
---max=100
---step=0.1
local track_position_offset_percent = 50

---$track:ピッチ%
---min=50
---max=100
---step=0.1
local track_percent = 75

---$track:色幅
---min=0
---max=255
---step=1
local track_color_width = 32

---$check:背景に着色
local _1 = 0

---$color:└背景色
local _2 = 0xffffff

---$check:└背景を元絵に
local _3 = 0

---$check:3D的表示
local _4 = 0

---$value:└環境光
local _5 = 20

---$value:└拡散光
local _6 = 80

---$value:└鏡面光
local _7 = 60

---$value:　└光沢度
local _8 = 30

---$value:シード
local _9 = 0

---$value:└変化間隔
local _10 = 0

---$value: PI
local _0 = nil

---$check:色参照位置固定
local check0 = false

require("T_Sketch_Module")
_0 = _0 or {}
local Sz = _0[1] or track_size
local Dx = _0[2] or track_position_offset_percent
local Pt = _0[3] or track_percent
local Cw = _0[4] or track_color_width
local Oc = _0[0] == nil and check0 or _0[0]
_0 = nil
local ck1 = _1 or 0
local Bol = _2 or 0xffffff
local ck2 = _3 or 0
local ck3 = _4 or 0
local La = _5 or 20
local Ld = _6 or 80
local Ls = _7 or 60
local Ns = _8 or 30
local SD = _9 or 0
local sR = _10 or 0
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
if sR > 0 then
    SD = SD + math.floor(obj.time * obj.framerate / sR)
end
local userdata, w, h = obj.getpixeldata()
T_Sketch_Module.Sketch(userdata, w, h, Sz, Dx, Pt, Cw, ck1 + 2 * ck2, Bol, ck3, La, Ld, Ls, Ns, SD, Oc)
obj.putpixeldata(userdata)
