--label:tim2\カスタムフレア.anm\2色リング(単)
---$track:サイズ
---min=0
---max=5000
---step=0.1
local rename_me_track0 = 200

---$track:幅
---min=0
---max=4000
---step=0.1
local rename_me_track1 = 20

---$track:強度
---min=0
---max=100
---step=0.1
local rename_me_track2 = 80

---$track:回転
---min=-3600
---max=3600
---step=0.1
local rename_me_track3 = 0

---$value:ベースカラー/chk
local basechk = 0

---$value:色1/col
local col1 = 0xff0000

---$value:色2/col
local col2 = 0x22ff22

---$value:グラデ幅
local grh = 40

---$value:ぼかし
local blur = 5

---$value:開口量％
local ew = 40

---$value:開口ぼかし％
local bw = 20

---$value:位置％
local t = 25

---$value:位置オフセット
local OFSET = { 0, 0, 0 }

---$value:自動消去/chk
local auba = 0

---$value:基準距離
local Rmax = 400

---$value:点滅
local blink = 0.2

obj.copybuffer("tmp", "obj")
obj.setoption("drawtarget", "tempbuffer")
obj.setoption("blend", CustomFlareMode)
local alpha = obj.rand(0, 100) / 100 + (1 - blink)
if alpha > 1 then
    alpha = 1
end
alpha = alpha * rename_me_track2 * 0.01
if auba == 1 then
    alpha = alpha
        * math.sqrt(CustomFlaredX * CustomFlaredX + CustomFlaredY * CustomFlaredY + CustomFlaredZ * CustomFlaredZ)
        / Rmax
end
local l = rename_me_track0 * math.pi / 4
local cy = (l - rename_me_track1 * math.pi) * 0.5
local rot = rename_me_track3 + math.deg(math.atan2(CustomFlaredY, CustomFlaredX)) - 90
t = t * 0.01
obj.load("figure", "四角形", CustomFlareColor, l)
obj.effect("斜めクリッピング", "角度", -180, "中心Y", cy)
if basechk == 0 then
    obj.effect("グラデーション", "color", col1, "color2", col2, "中心Y", cy / 2 + l / 4, "幅", grh)
end
if ew > 0 then
    obj.effect("斜めクリッピング", "角度", 90, "幅", l * (100 - ew) * 0.01, "ぼかし", l * bw * 0.01)
end
obj.effect("極座標変換")
obj.effect("ぼかし", "範囲", blur)
ox = CustomFlareCX + t * CustomFlaredX + OFSET[1] * CustomFlaredX * 0.01
oy = CustomFlareCY + t * CustomFlaredY + OFSET[2] * CustomFlaredY * 0.01
oz = CustomFlareCZ + t * CustomFlaredZ + OFSET[3] * CustomFlaredZ * 0.01
obj.draw(ox, oy, oz, 1, alpha, 0, 0, rot)
obj.load("tempbuffer")
obj.setoption("blend", 0)
