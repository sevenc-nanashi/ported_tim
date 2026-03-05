--label:tim2\輪郭追跡.anm\輪郭追跡(表示)
---$track:描画度
---min=0
---max=100
---step=0.1
local rename_me_track0 = 100

---$track:線幅
---min=0
---max=1000
---step=0.1
local rename_me_track1 = 10

---$track:開始点
---min=0
---max=100
---step=0.1
local rename_me_track2 = 0

---$track:閾値
---min=0
---max=255
---step=1
local rename_me_track3 = 128

---$color:色
local col = 0xffffff

---$check:逆回転
local rev = 0

---$check:輪郭のみ
local rin = 0

---$check:輪郭を下に
local Rover = 0

---$check:中心補正
local reC = 1

---$value:ｽｷｬﾝ粗さ
local Scsp = 1

local icx = obj.cx
local icy = obj.cy
reC = reC or 0

local fig, ivf, ivl, td, sm, halp, senp, senz, sens

if Trin_ehn == nil then
    fig = "円"
    ivf = 1
    ivl = 0
    td = 0
    sm = 0
    halp = 1
    senp = 0
    senz = nil
    sens = nil
else
    fig = Trin_ehn.fig
    ivf = Trin_ehn.ivf
    ivl = Trin_ehn.ivl
    td = Trin_ehn.td
    sm = Trin_ehn.sm
    halp = Trin_ehn.halp
    senp = Trin_ehn.senp
    senz = Trin_ehn.senz
    sens = Trin_ehn.sens
end

local r2 = math.sqrt(2)
local hp = rename_me_track0 * 0.01
local lw = rename_me_track1
local zure = rename_me_track2 * 0.01
local T = rename_me_track3
local dpx = { -1, 0, 1, 1, 1, 0, -1, -1 }
local dpy = { 1, 1, 1, 0, -1, -1, -1, 0 }
local dky = { r2, 1, r2, 1, r2, 1, r2, 1 }
local w, h = obj.getpixel()

local nn = 0
local vold = 0
local ni = {}
local nj = {}
local ky = {}
local r, g, b, a
Scsp = math.floor(Scsp or 1)
Scsp = (Scsp < 1 and 1) or Scsp

for j = 0, h - 1, Scsp do
    for i = 0, w - 1 do
        r, g, b, a = obj.getpixel(i, j, "rgb")
        if a > T then
            ni[0] = i
            nj[0] = j
            break
        end
    end
    if a > T then
        break
    end
end

local res
local vnew
local ti
local tj

repeat
    res = 0
    for i = 0, 7 do
        vnew = (vold + 6 + i) % 8
        ti = ni[nn] + dpx[vnew + 1]
        tj = nj[nn] + dpy[vnew + 1]
        if ti >= 0 and ti < w and tj >= 0 and tj < h then
            r, g, b, a = obj.getpixel(ti, tj, "rgb")
            if a > T then
                nn = nn + 1
                ni[nn] = ti
                nj[nn] = tj
                ky[nn] = dky[vnew + 1]
                vold = vnew
                if nn == 1 then
                    v0 = vnew
                end
                res = 1
                break
            end
        end
    end
until (ni[nn - 1] == ni[0] and nj[nn - 1] == nj[0] and v0 == vnew and nn > 1) or res == 0

nn = nn - 1

local ii = math.floor(nn * zure)
local ALL = 0
for i = 1, nn do
    ALL = ALL + ky[i]
end

if sm > 0 then
    local ttx = {}
    local tty = {}

    for i = 1, nn do
        ttx[i] = 0
        tty[i] = 0
        for s = 1, sm do
            ii = (nn + i + s - 2) % nn + 1
            ttx[i] = ttx[i] + ni[ii]
            tty[i] = tty[i] + nj[ii]
        end
        ttx[i] = ttx[i] / sm
        tty[i] = tty[i] / sm
    end
    for i = 1, nn do
        ni[i] = ttx[i]
        nj[i] = tty[i]
    end
end

obj.setoption("drawtarget", "tempbuffer", w + lw, h + lw)

if rin == 0 and Rover ~= 1 then
    obj.draw(0, 0, 0, 1, halp)
else
    obj.copybuffer("cache:IMG", "obj")
end

obj.load("figure", fig, col, lw)

local ALP = ALL * hp
local AL = 0
local i = 0
local oz

if ALP > 0 then
    repeat
        i = i + 1
        ii = (i + math.floor(nn * zure)) % nn
        if rev == 0 then
            ii = nn - ii - 1
        end
        ii = ii + 1
        AL = AL + ky[ii]

        local hanl = AL / ALL
        local count = math.floor(hanl / ivf)

        if count * ivf < hanl and hanl <= (count + 1) * ivf - ivl then
            if td == 1 then
                oz = math.deg(math.atan2(nj[ii] - nj[ii - 1], ni[ii] - ni[ii - 1]))
            else
                oz = 0
            end
            obj.draw(ni[ii] - w / 2, nj[ii] - h / 2, 0, 1, 1, 0, 0, oz)
        end
    until AL >= ALP

    if senp == 1 then
        obj.load("figure", senz, col, sens)
        obj.draw(ni[ii] - w / 2, nj[ii] - h / 2, 0, 1, 1, 0, 0, oz - 90)
    end
end

if rin == 0 and Rover == 1 then
    obj.copybuffer("obj", "cache:IMG")
    obj.draw(0, 0, 0, 1, halp)
end

obj.load("tempbuffer")

if reC == 1 then
    obj.cx = icx
    obj.cy = icy
end

Trin_ehn = nil
