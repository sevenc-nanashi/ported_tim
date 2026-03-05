--label:tim2\カスタムフレア.anm\リング(単)
---$track:サイズ
---min=0
---max=5000
---step=0.1
local rename_me_track0 = 200

---$track:幅
---min=0
---max=4000
---step=0.1
local rename_me_track1 = 10

---$track:強度
---min=0
---max=100
---step=0.1
local rename_me_track2 = 50

---$track:ぼかし
---min=0
---max=1000
---step=0.1
local rename_me_track3 = 10

---$check:ベースカラー
local basechk = 1

---$color:色
local col = 0xccccff

---$value:位置％
local dt = 0

---$value:位置オフセット
local OFSET = { 0, 0, 0 }

---$value:点滅
local blink = 0.2

obj.copybuffer("tmp", "obj")
obj.setoption("drawtarget", "tempbuffer")
obj.setoption("blend", CustomFlareMode)
if basechk == 1 then
    col = CustomFlareColor
end
local alpha = obj.rand(0, 100) / 100 + (1 - blink)
if alpha > 1 then
    alpha = 1
end
alpha = alpha * rename_me_track2 * 0.01
local size = rename_me_track0
local haba = rename_me_track1
local blur = rename_me_track3
dt = dt * 0.01
obj.load("figure", "円", col, size, haba)
obj.effect("ぼかし", "範囲", blur)
ox = CustomFlareCX + dt * CustomFlaredX + OFSET[1] * CustomFlaredX * 0.01
oy = CustomFlareCY + dt * CustomFlaredY + OFSET[2] * CustomFlaredY * 0.01
oz = CustomFlareCZ + dt * CustomFlaredZ + OFSET[3] * CustomFlaredZ * 0.01
obj.draw(ox, oy, oz, 1, alpha)
obj.load("tempbuffer")
obj.setoption("blend", 0)
