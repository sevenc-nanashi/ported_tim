--label:tim2\カスタムフレア.anm
---$track:形状
---min=1
---max=14
---step=1
local track_shape = 1

---$track:サイズ％
---min=0
---max=5000
---step=0.1
local track_size_percent = 30

---$track:強度
---min=0
---max=100
---step=0.1
local track_intensity = 50

---$track:ぼかし
---min=0
---max=1000
---step=0.1
local track_blur = 5

---$check:ベースカラー
local basechk = 1

---$color:色
local col = 0xccccff

---$value:位置％
local t = 0

---$value:位置ズレ％
local OFSET = { 0, 0, 0 }

---$value:回転
local rot = 0

---$check:ｱﾝｶｰに合わせる
local acr = 0

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
alpha = alpha * track_intensity * 0.01
local fig = track_shape
local size = track_size_percent * 0.01
local blur = track_blur
t = t * 0.01
obj.load("image", obj.getinfo("script_path") .. "CF-image\\I" .. fig .. ".png")
obj.effect("グラデーション", "color", col, "color2", col, "blend", 5)
obj.effect("ぼかし", "範囲", blur)
ox = CustomFlareCX + t * CustomFlaredX + OFSET[1] * CustomFlaredX * 0.01
oy = CustomFlareCY + t * CustomFlaredY + OFSET[2] * CustomFlaredY * 0.01
oz = CustomFlareCZ + t * CustomFlaredZ + OFSET[3] * CustomFlaredZ * 0.01
if acr == 1 then
    rot = rot + math.deg(math.atan2(CustomFlaredY, CustomFlaredX))
end
obj.draw(ox, oy, oz, size, alpha, 0, 0, rot)
obj.load("tempbuffer")
obj.setoption("blend", 0)
