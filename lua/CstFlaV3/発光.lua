--label:tim2\光効果\カスタムフレア.anm
---$track:大きさ
---min=1
---max=5000
---step=0.1
local track_size = 80

---$track:ぼかし％
---min=1
---max=1000
---step=0.1
local track_percent = 10

---$track:強度
---min=0
---max=100
---step=0.1
local track_intensity = 30

---$track:中心強度
---min=0
---max=100
---step=0.1
local track_center_intensity = 100

---$check:ベースカラー
local basechk = 1

---$color:色
local col = 0xccccff

---$track:位置％
---min=-5000
---max=5000
---step=0.1
local t = -100

---$value:位置オフセット％
local OFSET = { 0, 0, 0 }

---$track:発光中心サイズ％
---min=0
---max=100
---step=0.1
local hs = 80

---$check:自動拡大
local aubg = 0

---$track:基準距離
---min=0
---max=5000
---step=0.1
local Rmax = 400

obj.copybuffer("tmp", "obj")
obj.setoption("drawtarget", "tempbuffer")
obj.setoption("blend", CustomFlareMode)
if basechk == 1 then
    col = CustomFlareColor
end
local size = track_size
local alp = track_intensity * 0.01
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
local blur = size * track_percent * 0.01
local dx = (t + OFSET[1]) * 0.01 * CustomFlaredX + CustomFlareCX
local dy = (t + OFSET[2]) * 0.01 * CustomFlaredY + CustomFlareCY
local dz = (t + OFSET[3]) * 0.01 * CustomFlaredZ + CustomFlareCZ
obj.load("figure", "円", col, size)
obj.effect("ぼかし", "範囲", blur)
obj.draw(dx, dy, dz, 1, alp)
obj.load("figure", "円", 0xffffff, size * hs)
obj.effect("ぼかし", "範囲", blur * hs)
obj.draw(dx, dy, dz, 1, alp * track_center_intensity * 0.01)
obj.load("tempbuffer")
obj.setoption("blend", 0)
