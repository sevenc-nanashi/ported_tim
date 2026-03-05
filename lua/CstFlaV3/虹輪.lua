--label:tim2\カスタムフレア.anm\虹輪
--track0:大きさ,1,5000,250
--track1:長さ％,1,100,20
--track2:強度％,1,100,50
--track3:回転,-3600,3600,0
--value@t:位置％,50
--value@ds:虹輪開％,20
--value@spt:裁ち落とし％,0
--value@OFSET:位置オフセット％,{0,0,0}
--value@aubg:自動拡大/chk,0
--value@Rmax:基準距離,400
--value@asp:偏平率％,100
--value@blur:ぼかし,1
--value@fig:パターン[1-4],1
--value@ovchk:色上書き/chk,0
--value@ovcol:上書き色/col,0xccccff
--value@blink:点滅,0.2
--value@lt:発光,{0,250,80,0}
local figmax = 4
obj.copybuffer("cache:BKIMG", "obj") --背景をBKIMGに保存
local n = 10
local r = obj.track0 * 0.5
if aubg == 1 then
    r = r
        * math.sqrt(CustomFlaredX * CustomFlaredX + CustomFlaredY * CustomFlaredY + CustomFlaredZ * CustomFlaredZ)
        / Rmax
end
local dr = r * obj.track1 * 0.01
local wh = 2 * (r + dr)
obj.setoption("drawtarget", "tempbuffer", wh, wh)
obj.setoption("blend", 0)
local pi = math.pi
local cos = math.cos
local sin = math.sin
local alpha = obj.track2 * 0.01
local rot = obj.track3 / 180 * pi
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
obj.load("image", obj.getinfo("script_path") .. "CF-image\\hoop" .. fig .. ".png")
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
