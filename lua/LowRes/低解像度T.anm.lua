--label:tim2\未分類
---$track:強度
---min=-200
---max=200
---step=0.1
local track_intensity = 50

---$track:サイズ
---min=3
---max=500
---step=1
local track_size = 10

---$track:角度
---min=-3600
---max=3600
---step=0.1
local track_angle = 0

---$track:ぼかし%
---min=0
---max=500
---step=0.1
local track_percent = 100

---$color:色1
local col1 = 0xffffff

---$check:2色目指定
local ck = 0

---$color:└色2
local col2 = 0x0

---$check:直線
local Lc = 0

---$check:網表示
local Ap = 0

---$check:ブロック描画
local check0 = false

local L = track_intensity / 100
local S = math.floor(track_size)
local w0, h0 = obj.getpixel()
local D = track_angle
local N = track_percent / 100
local ty, tw
if Lc == 0 then
    ty, tw = 1, 100
else
    ty, tw = 3, 69
end
if ck == 0 then
    local r, g, b = RGB(col1)
    col2 = RGB(255 - r, 255 - g, 255 - b)
end
if D ~= 0 then
    local sin = math.abs(math.sin(D * math.pi / 180))
    local cos = math.abs(math.cos(D * math.pi / 180))
    local iw = w0 * cos + h0 * sin
    local ih = w0 * sin + h0 * cos
    obj.setoption("drawtarget", "tempbuffer", iw + S, ih + S)
    obj.effect("領域拡張", "上", S, "下", S, "左", S, "右", S, "塗りつぶし", 1)
    obj.draw(0, 0, 0, 1, 1, 0, 0, -D)
    obj.copybuffer("obj", "tmp")
end
w, h = obj.getpixel()
local nx2 = 2 * math.ceil(0.5 * w / S)
local ny2 = 2 * math.ceil(0.5 * h / S)
if check0 then
    local ws, hs = nx2 * S, ny2 * S
    local dx, dy = (ws - w) / 2, (hs - h) / 2
    obj.effect("領域拡張", "上", dy, "下", dy, "左", dx, "右", dx, "塗りつぶし", 1)
    obj.effect("リサイズ", "X", nx2, "Y", ny2, "ドット数でサイズ指定", 1)
    obj.effect("リサイズ", "X", ws, "Y", hs, "補間なし", 1, "ドット数でサイズ指定", 1)
    obj.effect("クリッピング", "上", dy, "下", dy, "左", dx, "右", dx)
else
    obj.effect("ぼかし", "範囲", S * N, "サイズ固定", 1)
end
if L ~= 0 or Ap == 1 then
    obj.copybuffer("cache:ORGL", "obj")
    obj.setoption("drawtarget", "tempbuffer", w, h)
    obj.load("figure", "四角形", col2, 100)
    obj.effect("グラデーション", "type", ty, "強さ", 75, "幅", tw, "color", col1, "color2", col2)
    if L < 0 then
        L = -L
        obj.effect("反転", "輝度反転", 1)
    end
    obj.effect("リサイズ", "X", S, "Y", S, "ドット数でサイズ指定", 1)

    if nx2 > 400 or ny2 > 400 then
        local nx1 = math.floor(math.sqrt(nx2))
        local ny1 = math.floor(math.sqrt(ny2))
        nx2 = math.ceil(nx2 / nx1)
        ny2 = math.ceil(ny2 / ny1)
        nx1 = nx1 + nx1 % 2
        ny1 = ny1 + ny1 % 2
        obj.effect("画像ループ", "横回数", nx1, "縦回数", ny1)
    end
    obj.effect("画像ループ", "横回数", nx2, "縦回数", ny2)
    obj.draw()
    obj.copybuffer("obj", "cache:ORGL")
    obj.effect("反転", "透明度反転", 1)
    obj.setoption("blend", "alpha_sub")
    obj.draw()
    obj.copybuffer("obj", "tmp")

    if Ap == 0 then
        obj.copybuffer("tmp", "cache:ORGL")
        obj.setoption("blend", 5)
        if L <= 1 then
            obj.draw(0, 0, 0, 1, L)
        else
            obj.draw(0, 0, 0, 1, 1)
            obj.draw(0, 0, 0, 1, L - 1)
        end
    end
    obj.copybuffer("obj", "tmp")
    obj.setoption("blend", 0)
end
if D ~= 0 then
    obj.setoption("drawtarget", "tempbuffer", w0, h0)
    obj.draw(0, 0, 0, 1, 1, 0, 0, D)
    obj.copybuffer("obj", "tmp")
end
