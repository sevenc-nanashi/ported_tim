--label:tim2
--track0:パターン,0,1000,0
--track1:展開度,0,100,50,0.01
--track2:サイズ,1,100,6
--track3:コア間隔,2,100,3

--value@pos:位置,{0,-150,0,150}
--value@c_col:コア色/col,0xffffff
--value@g_col:発光色/col,0x0000ff
--value@g_s:発光強さ,40
--value@g_k:発光拡散,300
--value@g_th:発光しきい値,0
--value@g_kv:発光拡散速度,10
--value@f_n:軌道フォーク数,8
--value@stl:軌道直進性,8
--value@gr:軌道設置範囲,30
--value@AS:領域サイズ,{-180,-180,180,180}
--value@chk:枠表示/chk,1

function Lightning(stx, sty, enx, eny, c_d, c_s)
    if c_d < 0.3 then
        return
    end

    local Lx, Ly = enx - stx, eny - sty
    local LL = Lx * Lx + Ly * Ly
    local L = math.sqrt(LL)
    local dLx = Lx * c_d / L
    local dLy = Ly * c_d / L

    obj.draw(stx, sty, 0, c_s / Ac_s)

    local ss = obj.rand(-75, 75, 0, 10 + frnd) * 0.01
    local sin = math.sin(ss)
    local cos = math.cos(ss)
    local dx, dy = cos * dLx + sin * dLy, -sin * dLx + cos * dLy
    local ox = 0
    local oy = 0
    local i = 0

    local bl = {}

    for j = 1, 3 do
        bl[j] = obj.rand(0, Ly * 0.5, i, j + frnd)
    end

    while oy * oy < Ly * Ly do
        i = i + 1
        local gen = math.exp(-at * oy / Ly)

        if gen < 0.005 then
            return
        end

        local dx, dy

        local ii = 0
        repeat
            ii = ii + 1
            local ss = obj.rand(-75, 75, i, 12 + frnd + 100 * ii) * 0.01
            local sin = math.sin(ss)
            local cos = math.cos(ss)
            dx, dy = (cos * dLx + sin * dLy) * gen, (-sin * dLx + cos * dLy) * gen
        until dy * dLy > 0

        local rn = math.log(obj.rand(2, 100, i, 11 + frnd)) / math.log(c_tf) / c_d

        for k = 0, stl * rn do
            obj.draw(stx + ox + k * dx, sty + oy + k * dy, 0, c_s / Ac_s * gen)
        end

        ox = ox + stl * rn * dx
        oy = oy + stl * rn * dy

        for j = 1, 3 do
            if bl[j] ~= nil and bl[j] * bl[j] < oy * oy and f_n > 1 then
                frnd = frnd + 1
                f_n = f_n - 1
                local gx = obj.rand(-gr, gr, i, 13 + frnd) * 0.01 * Ly
                Lightning(stx + ox, sty + oy, enx + gx, eny, c_d * 0.8 * gen, c_s * 0.8 * gen)
                bl[j] = nil
            end
        end
    end
end

function Szdrawpoly(x1, y1, x2, y2)
    obj.drawpoly(x1, y1, 0, x2, y1, 0, x2, y2, 0, x1, y2, 0, 0, 0, obj.w, 0, obj.w, obj.h, 0, obj.h)
end

frnd = math.floor(obj.track0)
at = 100 - obj.track1
at = (math.exp(0.10 * at) - 1) / 62

Ac_s = obj.track2

c_d = obj.track3

obj.setanchor("pos", 2, "line")
local stx, sty, enx, eny = unpack(pos)
obj.setanchor("AS", 2)
local ASx0, ASy0, ASx1, ASy1 = unpack(AS)
cx, cy = (ASx1 + ASx0) / 2, (ASy1 + ASy0) / 2

c_tf = 80 --軌道折れ確率[%]

if f_n > 25 then
    f_n = 25
end

stl = math.floor(stl)
if stl < 1 then
    stl = 1
end

obj.setoption("drawtarget", "tempbuffer", math.abs(ASx1 - ASx0), math.abs(ASy1 - ASy0))

obj.load("figure", "円", c_col, Ac_s)

Lightning(stx - cx, sty - cy, enx - cx, eny - cy, c_d, Ac_s)

if obj.getoption("gui") == true and obj.getinfo("saving") == false and chk == 1 then
    obj.load("figure", "四角形", 0xffffff, 100)
    ASx0 = ASx0 - cx
    ASx1 = ASx1 - cx
    ASy0 = ASy0 - cy
    ASy1 = ASy1 - cy
    Szdrawpoly(ASx0, ASy0 - 0.5, ASx1, ASy0 + 0.5)
    Szdrawpoly(ASx0, ASy1 - 0.5, ASx1, ASy1 + 0.5)
    Szdrawpoly(ASx0 - 0.5, ASy0, ASx0 + 0.5, ASy1)
    Szdrawpoly(ASx1 - 0.5, ASy0, ASx1 + 0.5, ASy1)
end

obj.load("tempbuffer")

obj.cx, obj.cy = obj.cx - cx, obj.cy - cy

obj.effect("色調補正", "明るさ", 200)
obj.effect(
    "発光",
    "強さ",
    g_s,
    "拡散",
    g_k,
    "しきい値",
    g_th,
    "拡散速度",
    g_kv,
    "color",
    c_col,
    "no_color",
    0,
    "サイズ固定",
    1
)
obj.effect(
    "発光",
    "強さ",
    g_s,
    "拡散",
    g_k,
    "しきい値",
    g_th,
    "拡散速度",
    g_kv,
    "color",
    g_col,
    "no_color",
    0,
    "サイズ固定",
    1
)
