--label:tim2\未分類
---$track:サイズ
---min=5
---max=1000
---step=0.1
local track_size = 10

---$track:トーン小
---min=0
---max=500
---step=0.1
local track_tone_small = 0

---$track:トーン大
---min=0
---max=500
---step=0.1
local track_tone_large = 100

---$track:回転
---min=-3600
---max=3600
---step=0.1
local track_rotation = 0

---$color:シャドウ色
local col2 = "0x0"

---$color:ハイライト色
local col1 = "0xffffff"

---$figure:トーン形状
local fig = "円"

---$check:段違い
local fzs = 1

---$check:背景色非表示
local bkap = 0

---$check:トーン反転
local tnrep = 0

---$check:自分自身で型抜き
local check0 = true

obj.copybuffer("cache:ori_img", "obj")
local si_x = track_size
local tsi1 = track_tone_small * 0.01
local tsi2 = track_tone_large * 0.01 - tsi1
local rz = track_rotation
local w, h = obj.getpixel()
local si_y = si_x
local figsz = si_x
gm = gm or 0
ogchk = ogchk or 1
if fzs == 1 then
    si_x = math.sqrt(2) * si_x
    si_y = si_x * 0.5
end
local nx = math.floor(w / (2 * si_x)) + 1
local ny = math.floor(h / (2 * si_y))

if tnrep == 1 then
    obj.effect("反転", "輝度反転", 1)
    col1, col2 = col2, col1
end

obj.pixeloption("type", "yc")
local con = {}
local al = {}
local posx = {}
local posy = {}
for i = -nx, nx do
    con[i] = {}
    al[i] = {}
    posx[i] = {}
    posy[i] = {}
    for j = -ny, ny do
        local dx = 0
        if fzs == 1 then
            dx = si_y * (j % 2)
        end
        posx[i][j] = i * si_x + dx
        posy[i][j] = j * si_y
        local y, cb, cr, a = obj.getpixel(posx[i][j] + w * 0.5, posy[i][j] + h * 0.5, "yc")
        local t = math.sqrt(1 - y / 4096)
        t = tsi1 + t * tsi2
        con[i][j] = t * 0.5
        al[i][j] = a / 4095
    end
end
obj.setoption("drawtarget", "tempbuffer", w, h)
if bkap == 0 then
    obj.effect("単色化", "color", col1, "輝度を保持する", 0)
    obj.draw()
end
obj.load("figure", fig, col2, 2 * figsz)
for i = -nx, nx do
    for j = -ny, ny do
        obj.draw(posx[i][j], posy[i][j], 0, con[i][j], al[i][j], 0, 0, rz)
    end
end
if check0 then
    obj.copybuffer("obj", "cache:ori_img")
    obj.effect("反転", "透明度反転", 1)
    obj.setoption("blend", "alpha_sub")
    obj.draw()
end
obj.load("tempbuffer")
obj.setoption("blend", 0)
