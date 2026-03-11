--label:tim2\光効果\@カスタムフレア.anm
---$track:大きさ
---min=1
---max=5000
---step=0.1
local track_size = 250

---$track:長さ％
---min=1
---max=100
---step=0.1
local track_length_percent = 20

---$track:強度％
---min=1
---max=100
---step=0.1
local track_intensity_percent = 50

---$track:回転
---min=-3600
---max=3600
---step=0.1
local track_rotation = 0

---$track:位置％
---min=-5000
---max=5000
---step=0.1
local t = 50

---$track:虹輪開％
---min=0
---max=100
---step=0.1
local ds = 20

---$track:裁ち落とし％
---min=0
---max=100
---step=0.1
local spt = 0

---$value:位置オフセット％
local OFSET = { 0, 0, 0 }

---$check:自動拡大
local aubg = 0

---$track:基準距離
---min=0
---max=5000
---step=0.1
local Rmax = 400

---$track:偏平率％
---min=0
---max=200
---step=0.1
local asp = 100

---$track:ぼかし
---min=0
---max=1000
---step=0.1
local blur = 1

---$select:パターン
---1=1
---2=2
---3=3
---4=4
local fig = 1

---$check:色上書き
local ovchk = 0

---$color:上書き色
local ovcol = 0xccccff

---$track:点滅
---min=0
---max=1
---step=0.01
local blink = 0.2

---$value:発光
local lt = { 0, 250, 80, 0 }

local figmax = 4
obj.copybuffer("cache:BKIMG", "obj") --背景をBKIMGに保存
local n = 10
local r = track_size * 0.5
if aubg == 1 then
    r = r
        * math.sqrt(CustomFlaredX * CustomFlaredX + CustomFlaredY * CustomFlaredY + CustomFlaredZ * CustomFlaredZ)
        / Rmax
end
local dr = r * track_length_percent * 0.01
local wh = 2 * (r + dr)
obj.setoption("drawtarget", "tempbuffer", wh, wh)
obj.setoption("blend", 0)
local pi = math.pi
local cos = math.cos
local sin = math.sin
local alpha = track_intensity_percent * 0.01
local rot = track_rotation / 180 * pi
ds = ds * 0.01
spt = spt * 0.01
asp = asp * 0.01
fig = math.floor(fig)
if fig > figmax then
    fig = figmax
end
if fig < 1 then
    fig = 1
end

-- obj.load("image", obj.getinfo("script_path") .. "CF-image\\hoop" .. fig .. ".png")
local tim2_images = obj.module("tim2")
local data, w, h = tim2_images.custom_flare_load_image("hoop" .. fig)
obj.putpixeldata("object", data, w, h)
tim2_images.custom_flare_free_image(data)
obj.setoption("antialias", 1)

local ox = CustomFlaredX * (t + OFSET[1]) * 0.01 + CustomFlareCX
local oy = CustomFlaredY * (t + OFSET[2]) * 0.01 + CustomFlareCY
local oz = CustomFlaredZ * (t + OFSET[3]) * 0.01 + CustomFlareCZ
rot = rot + math.atan2(CustomFlaredY, CustomFlaredX)
local kmax = 20 * n
local k0 = -1
for i = 0, n - 1 do
    for j = 0, 19 do
        k0 = k0 + 1
        local k1 = k0 + 1
        if spt * 0.5 * kmax < k0 and k1 < (1 - spt * 0.5) * kmax then
            local t0 = (2 * k0 / kmax - 1) * pi
            local t1 = (2 * k1 / kmax - 1) * pi
            if t0 > 0 then
                t0 = t0 * 0.99
            else
                t0 = t0 * 1.01
            end
            if t1 < 0 then
                t1 = t1 * 0.99
            else
                t1 = t1 * 1.01
            end
            local s0 = t0
            local s1 = t1
            local t0 = t0 / (1 - ds)
            local t1 = t1 / (1 - ds)
            if t0 < -pi then
                t0 = -pi
            end
            if t1 < -pi then
                t1 = -pi
            end
            if t0 > pi then
                t0 = pi
            end
            if t1 > pi then
                t1 = pi
            end
            local r01 = r + dr * (cos(t0) + 1) / 2
            local r02 = r - dr * (cos(t0) + 1) / 2
            local r11 = r + dr * (cos(t1) + 1) / 2
            local r12 = r - dr * (cos(t1) + 1) / 2
            local x0 = r01 * cos(s0)
            local y0 = r01 * sin(s0)
            local x1 = r11 * cos(s1)
            local y1 = r11 * sin(s1)
            local x2 = r12 * cos(s1)
            local y2 = r12 * sin(s1)
            local x3 = r02 * cos(s0)
            local y3 = r02 * sin(s0)
            local u0 = j * obj.w * 0.05
            local u1 = (j + 1) * obj.w * 0.05
            local v2 = obj.h
            obj.drawpoly(x0, y0, 0, x1, y1, 0, x2, y2, 0, x3, y3, 0, u0, 0, u1, 0, u1, v2, u0, v2, 1)
        end
    end
end
obj.load("tempbuffer")
obj.copybuffer("tmp", "cache:BKIMG")
obj.setoption("blend", CustomFlareMode)
local alpi = obj.rand(0, 100) / 100 + (1 - blink)
if alpi > 1 then
    alpi = 1
end
alpha = alpi * alpha
if ovchk == 1 then
    obj.effect("グラデーション", "color", ovcol, "color2", ovcol, "blend", 3)
end
obj.effect("ぼかし", "範囲", blur)
obj.effect(
    "発光",
    "強さ",
    lt[1],
    "拡散",
    lt[2],
    "しきい値",
    lt[3],
    "拡散速度",
    lt[4],
    "サイズ固定",
    1
)
local w, h = obj.getpixel()
w = w * 0.5
h = h * 0.5
local wc = w * cos(rot)
local ws = -w * sin(rot)
local hc = h * cos(rot)
local hs = -h * sin(rot)
local x0 = -wc - hs + ox
local y0 = (ws - hc) * asp + oy
local x1 = wc - hs + ox
local y1 = (-ws - hc) * asp + oy
local x2 = wc + hs + ox
local y2 = (-ws + hc) * asp + oy
local x3 = -wc + hs + ox
local y3 = (ws + hc) * asp + oy
obj.drawpoly(x0, y0, oz, x1, y1, oz, x2, y2, oz, x3, y3, oz, 0, 0, obj.w, 0, obj.w, obj.h, 0, obj.h, alpha)
obj.load("tempbuffer")
obj.setoption("blend", 0)
