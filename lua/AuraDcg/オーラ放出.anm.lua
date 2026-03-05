--label:tim2
---$track:範囲
---min=1
---max=500
---step=0.1
local rename_me_track0 = 50

---$track:サイクル
---min=1
---max=20
---step=1
local rename_me_track1 = 2

---$track:速度
---min=-1000
---max=1000
---step=0.1
local rename_me_track2 = 100

---$track:オフセット
---min=0
---max=1000
---step=0.1
local rename_me_track3 = 0

---$check:ミッドトーン無視
local egm = 0

---$color:ハイライト
local col1 = 0xffffff

---$color: ミッドトーン
local col2 = 0x0080ff

---$color: シャドウ
local col3 = 0x0080ff

---$value:ぼかし
local bl = 1

---$check:ｵﾘｼﾞﾅﾙ表示
local rename_me_check0 = true

require("T_Color_Module")

local ox, oy, oz = obj.ox, obj.oy, obj.oz
local cx, cy, cz = obj.cx, obj.cy, obj.cz
obj.copybuffer("cache:ori", "obj")

local sz = rename_me_track0

local repN = math.floor(rename_me_track1)
local sft = ((obj.time * rename_me_track2 + rename_me_track3) % 100) * 0.01

local r1, g1, b1 = RGB(col1)
local r3, g3, b3 = RGB(col3)
local r2, g2, b2
if egm == 0 then
    r2, g2, b2 = RGB(col2)
else
    r2, g2, b2 = math.floor((r1 + r3) * 0.5), math.floor((g1 + g3) * 0.5), math.floor((b1 + b3) * 0.5)
end

obj.effect("単色化", "color", 0xffffff, "輝度を保持する", 0)
obj.effect("縁取り", "サイズ", sz * 0.5, "ぼかし", 0, "color", 0xffffff)
obj.effect("縁取り", "サイズ", sz * 0.5, "ぼかし", 0, "color", 0x0)
obj.effect("ぼかし", "範囲", sz)

local userdata, w, h = obj.getpixeldata()
T_Color_Module.Colorama(userdata, w, h, sft, repN, 2, 255, 255, 255, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0, 0)
obj.putpixeldata(userdata)

obj.copybuffer("cache:wave", "obj")

obj.load("figure", "四角形", 0x0, (w < h and h or w))
obj.setoption("drawtarget", "tempbuffer", w, h)
obj.draw()
obj.copybuffer("obj", "cache:wave")
obj.draw()
obj.copybuffer("obj", "tmp")

local userdata, w, h = obj.getpixeldata()
T_Color_Module.ShiftChannels(userdata, w, h, 1, 1, 1, 1)
obj.putpixeldata(userdata)

local userdata, w, h = obj.getpixeldata()
T_Color_Module.TritoneV2(userdata, w, h, r1, g1, b1, r2, g2, b2, r3, g3, b3, 255, 128, 0)
obj.putpixeldata(userdata)
obj.effect("ぼかし", "範囲", bl)

if rename_me_check0 then
    obj.copybuffer("tmp", "obj")
    obj.copybuffer("obj", "cache:ori")
    obj.draw()
    obj.copybuffer("obj", "tmp")
end

obj.ox, obj.oy, obj.oz = ox, oy, oz
obj.cx, obj.cy, obj.cz = cx, cy, cz
