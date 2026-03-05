--label:tim2\簡易リピーター.anm
---$track:透過率%
---min=0
---max=100
---step=0.1
local rename_me_track0 = 0

---$track:個数
---min=2
---max=100
---step=1
local rename_me_track1 = 5

---$track:基準回転
---min=-3600
---max=3600
---step=0.1
local rename_me_track2 = 0

---$track:基準拡大
---min=0
---max=5000
---step=0.1
local rename_me_track3 = 100

---$check:重なり順
local AP = 0

---$check:色の上書き
local cop = 0

---$color:基準色
local colo1 = 0xff0000

---$color:最終色
local colo2 = 0x0000ff

---$value:合成モード
local adm = 0

---$check:位置ズレ補正
local reC = 1

local repch = function(pr, hen)
    if hen > 0 then
        return pr ^ (1 + 5 * hen)
    else
        return 1 - (1 - pr) ^ (1 - 5 * hen)
    end
end

local iox = obj.ox
local ioy = obj.oy
local icx = obj.cx
local icy = obj.cy
reC = reC or 0

local LAL = rename_me_track0 * 0.01
local N = math.floor(rename_me_track1)
local rz_ori = rename_me_track2
local zoom_ori = rename_me_track3 * 0.01

local col1 = { RGB(colo1) }
local col2 = { RGB(colo2) }

local dx = repeater_dx
local dy = repeater_dy
local dr = repeater_dr
local dk = repeater_dk
local rep = repeater_rep

local SS, dS, mrp, alf
if rep == 1 then
    SS = repeater_SS
    dS = repeater_dS
    mrp = repeater_mrp
    alf = repeater_alf

    repeater_SS = nil
    repeater_dS = nil
    repeater_mrp = nil
    repeater_alf = nil
end

local henx = repeater_henx or 0
local heny = repeater_heny or 0
local henzo = repeater_henzo or 0
local henrz = repeater_henrz or 0

repeater_dx = nil
repeater_dy = nil
repeater_dr = nil
repeater_dk = nil
repeater_rep = nil
repeater_henx = nil
repeater_heny = nil
repeater_henzo = nil
repeater_henrz = nil

local is, ie, di
if AP == 0 then
    is, ie, di = 0, N - 1, 1
else
    is, ie, di = N - 1, 0, -1
end

local ott
if rep == 1 then
    ott = obj.load("movie", file)
end

local w, h = obj.getpixel()

local xx = {}
local yy = {}
local zo = {}
local rz = {}
local max_x = 0
local max_y = 0
local min_x = 0
local min_y = 0

for i = 0, N - 1 do
    local pr = i / (N - 1)
    local prx = repch(pr, henx)
    local pry = repch(pr, heny)
    local przo = repch(pr, henzo)
    local prrz = repch(pr, henrz)
    xx[i] = dx * prx
    yy[i] = dy * pry
    zo[i] = (1 + (dk - 1) * przo) * zoom_ori
    rz[i] = rz_ori + dr * prrz

    local rz = math.rad(rz[i])
    local co = math.abs(math.cos(rz))
    local si = math.abs(math.sin(rz))
    local ww1 = (w * co + h * si) * zo[i] * 0.5
    local hh1 = (w * si + h * co) * zo[i] * 0.5
    max_x = math.max(ww1 + xx[i], max_x)
    max_y = math.max(hh1 + yy[i], max_y)
    min_x = math.min(-ww1 + xx[i], min_x)
    min_y = math.min(-hh1 + yy[i], min_y)
end

local cx = (max_x + min_x) * 0.5
local cy = (max_y + min_y) * 0.5

obj.setoption("drawtarget", "tempbuffer", max_x - min_x, max_y - min_y)

for i = is, ie, di do
    local pr = i / (N - 1)
    if rep == 1 then
        TT = SS + i * dS
        if mrp == 1 then
            TT = TT % ott
        end
        obj.load("movie", file, TT, alf)
    end
    if cop == 1 then
        local cc = RGB(
            math.floor((1 - pr) * col1[1] + pr * col2[1]),
            math.floor((1 - pr) * col1[2] + pr * col2[2]),
            math.floor((1 - pr) * col1[3] + pr * col2[3])
        )
        obj.effect("グラデーション", "color", cc, "color2", cc, "blend", adm)
    end
    obj.draw(xx[i] - cx, yy[i] - cy, 0, zo[i], 1 - pr * LAL, 0, 0, rz[i])
end
obj.load("tempbuffer")
if reC == 1 then
    obj.ox = iox
    obj.oy = ioy
    obj.cx = icx
    obj.cy = icy
end
obj.cx = obj.cx - cx
obj.cy = obj.cy - cy
