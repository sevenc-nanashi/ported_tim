--label:tim2\カスタムフレア.anm
---$track:大きさ
---min=1
---max=5000
---step=0.1
local rename_me_track0 = 80

---$track:ぼかし％
---min=1
---max=1000
---step=0.1
local rename_me_track1 = 10

---$track:強度
---min=0
---max=100
---step=0.1
local rename_me_track2 = 30

---$track:中心強度
---min=0
---max=100
---step=0.1
local rename_me_track3 = 100

---$check:ベースカラー
local basechk = 1

---$color:色
local col = 0xccccff

---$value:位置％
local t = -100

---$value:位置オフセット％
local OFSET = { 0, 0, 0 }

---$value:発光中心サイズ％
local hs = 80

---$check:自動拡大
local aubg = 0

---$value:基準距離
local Rmax = 400

obj.copybuffer("tmp", "obj")
obj.setoption("drawtarget", "tempbuffer")
obj.setoption("blend", CustomFlareMode)
if basechk == 1 then
    col = CustomFlareColor
end
local size = rename_me_track0
local alp = rename_me_track2 * 0.01
hs = hs * 0.01
if aubg == 1 then
    size = size
        * (
            1
            - math.sqrt(
                    CustomFlaredX * CustomFlaredX + CustomFlaredY * CustomFlaredY + CustomFlaredZ * CustomFlaredZ
                )
                / Rmax
        )
    if size < 0 then
        size = 0
    end
end
local blur = size * rename_me_track1 * 0.01
local dx = (t + OFSET[1]) * 0.01 * CustomFlaredX + CustomFlareCX
local dy = (t + OFSET[2]) * 0.01 * CustomFlaredY + CustomFlareCY
local dz = (t + OFSET[3]) * 0.01 * CustomFlaredZ + CustomFlareCZ
obj.load("figure", "円", col, size)
obj.effect("ぼかし", "範囲", blur)
obj.draw(dx, dy, dz, 1, alp)
obj.load("figure", "円", 0xffffff, size * hs)
obj.effect("ぼかし", "範囲", blur * hs)
obj.draw(dx, dy, dz, 1, alp * rename_me_track3 * 0.01)
obj.load("tempbuffer")
obj.setoption("blend", 0)
