--label:tim2\モーフィング.anm
---$track:変化度
---min=0
---max=100
---step=0.1
local rename_me_track0 = 50

---$track:ﾎﾟｲﾝﾄｻｲｽﾞ
---min=0
---max=500
---step=1
local rename_me_track2 = 30

---$track:ﾌｫﾝﾄｻｲｽﾞ
---min=0
---max=500
---step=1
local rename_me_track3 = 30

---$check:ﾚｲﾔｰｽｸﾘﾌﾟﾄ1
local Lsc1 = 1

---$check:ﾚｲﾔｰｽｸﾘﾌﾟﾄ2
local Lsc2 = 1

---$check:ライン表示
local lchk = 1

---$color:線色
local Lcol = 0xffffff

---$value:線幅
local Lw = 3

---$check:ポイント表示
local pchk = 1

---$color:ポイント色
local pcol = 0xffffff

---$color:文字色
local fcol = 0x0

---$check:ガイド表示
local rename_me_check0 = true

(function()
    local Triangulation = function(Num)
        local RepJudge = function(p1, p2, p3, q) --外接円より内部（境界含まない）なら真
            if (p1.x == q.x and p1.y == q.y) or (p2.x == q.x and p2.y == q.y) or (p3.x == q.x and p3.y == q.y) then
                return false
            end

            local c = 2 * ((p2.x - p1.x) * (p3.y - p1.y) - (p2.y - p1.y) * (p3.x - p1.x))
            local cx = (
                (p3.y - p1.y) * (p2.x ^ 2 - p1.x ^ 2 + p2.y ^ 2 - p1.y ^ 2)
                + (p1.y - p2.y) * (p3.x ^ 2 - p1.x ^ 2 + p3.y ^ 2 - p1.y ^ 2)
            ) / c
            local cy = (
                (p1.x - p3.x) * (p2.x ^ 2 - p1.x ^ 2 + p2.y ^ 2 - p1.y ^ 2)
                + (p2.x - p1.x) * (p3.x ^ 2 - p1.x ^ 2 + p3.y ^ 2 - p1.y ^ 2)
            ) / c
            if (p1.x - cx) ^ 2 + (p1.y - cy) ^ 2 > (q.x - cx) ^ 2 + (q.y - cy) ^ 2 then
                return true
            else
                return false
            end
        end

        local function reTriangulation(MT, DMT, Ap)
            local pN = {}
            pN[1] = { DMT[1][1], DMT[1][2] }
            pN[2] = { DMT[1][2], DMT[1][3] }
            pN[3] = { DMT[1][3], DMT[1][1] }
            for i = 2, #DMT do
                local pp = { DMT[i][1], DMT[i][2], DMT[i][3], DMT[i][1] }
                for k = 1, 3 do
                    local hantei = 1
                    for j = 1, #pN do
                        if pN[j][1] == pp[k + 1] and pN[j][2] == pp[k] then
                            table.remove(pN, j)
                            hantei = 0
                            break
                        end
                    end
                    if hantei == 1 then
                        pN[#pN + 1] = { pp[k], pp[k + 1] }
                    end
                end
            end
            for i = 1, #pN do
                MT[#MT + 1] = { pN[i][1], pN[i][2], Ap }
            end
        end

        local MPos = Morphing_obj[1].pos

        local MT = {}
        MT[1] = { 1, 2, 4 }
        MT[2] = { 2, 3, 4 }

        for i = 5, Num do
            local DMT = {}
            local j = 1
            repeat --MTをMTとDMTに分離　DMTはiが外接円内部にある
                local p1, p2, p3 = unpack(MT[j])
                if RepJudge(MPos[p1], MPos[p2], MPos[p3], MPos[i]) then
                    DMT[#DMT + 1] = MT[j]
                    MT[j] = MT[#MT]
                    MT[#MT] = nil
                else
                    j = j + 1
                end
            until j > #MT
            reTriangulation(MT, DMT, i)
        end

        return MT
    end

    if Morphing_obj[1] == nil and Morphing_obj[2] == nil then
        Morphing_obj = nil
        return 0
    elseif Morphing_obj[1] == nil then
        Morphing_obj[1] = Morphing_obj[2]
    elseif Morphing_obj[2] == nil then
        Morphing_obj[2] = Morphing_obj[1]
    end

    local t = (Morphing_inport or rename_me_track0) * 0.01

    local Lscript = {}
    Lscript[1] = (Lsc1 == 1) and true
    Lscript[2] = (Lsc2 == 1) and true

    Morphing_obj[3] = {}
    local MO1 = Morphing_obj[1]
    local MO2 = Morphing_obj[2]
    local MO3 = Morphing_obj[3]

    local Num = math.min(#MO1.pos, #MO2.pos)
    local w = math.max(MO1.w, MO2.w)
    local h = math.max(MO1.h, MO2.h)

    local MT = Triangulation(Num)

    MO3.pos = {}
    for i = 1, Num do
        MO3.pos[i] = {}
        MO3.pos[i].x = MO1.pos[i].x * (1 - t) + MO2.pos[i].x * t
        MO3.pos[i].y = MO1.pos[i].y * (1 - t) + MO2.pos[i].y * t
    end

    for P = 1, 2 do
        local MO = Morphing_obj[P]
        obj.load("layer", MO.layer, Lscript[P])
        obj.setoption("drawtarget", "tempbuffer", w, h)
        obj.setoption("blend", "alpha_add")
        local Mw = MO.w * 0.5
        local Mh = MO.h * 0.5
        for i = 1, #MT do
            local x1 = MO3.pos[MT[i][1]].x
            local y1 = MO3.pos[MT[i][1]].y
            local x2 = MO3.pos[MT[i][2]].x
            local y2 = MO3.pos[MT[i][2]].y
            local x3 = MO3.pos[MT[i][3]].x
            local y3 = MO3.pos[MT[i][3]].y

            local u1 = MO.pos[MT[i][1]].x + Mw
            local v1 = MO.pos[MT[i][1]].y + Mh
            local u2 = MO.pos[MT[i][2]].x + Mw
            local v2 = MO.pos[MT[i][2]].y + Mh
            local u3 = MO.pos[MT[i][3]].x + Mw
            local v3 = MO.pos[MT[i][3]].y + Mh

            obj.drawpoly(x1, y1, 0, x1, y1, 0, x2, y2, 0, x3, y3, 0, u1, v1, u1, v1, u2, v2, u3, v3)
        end
        obj.copybuffer("cache:img" .. P, "tmp")
    end

    obj.setoption("drawtarget", "tempbuffer", w, h)
    obj.copybuffer("obj", "cache:img1")
    obj.setoption("blend", 0)
    obj.draw(0, 0, 0, 1, 1 - t)

    obj.copybuffer("obj", "cache:img2")
    obj.setoption("blend", "alpha_add")
    obj.draw(0, 0, 0, 1, t)

    obj.setoption("blend", 0)

    if lchk == 1 and rename_me_check0 then
        local d_line = function(x1, y1, x2, y2, wd)
            local dx = x2 - x1
            local dy = y2 - y1
            local r = math.sqrt(dx * dx + dy * dy)
            local sx = dy * wd * 0.5 / r
            local sy = -dx * wd * 0.5 / r
            obj.drawpoly(x2 - sx, y2 - sy, 0, x1 - sx, y1 - sy, 0, x1 + sx, y1 + sy, 0, x2 + sx, y2 + sy, 0)
        end
        obj.load("figure", "四角形", Lcol, 1) --math.min(w*0.5,h*0.5))
        for i = 1, #MT do
            local x1 = MO3.pos[MT[i][1]].x
            local y1 = MO3.pos[MT[i][1]].y
            local x2 = MO3.pos[MT[i][2]].x
            local y2 = MO3.pos[MT[i][2]].y
            local x3 = MO3.pos[MT[i][3]].x
            local y3 = MO3.pos[MT[i][3]].y
            d_line(x1, y1, x2, y2, Lw)
            d_line(x2, y2, x3, y3, Lw)
            d_line(x3, y3, x1, y1, Lw)
        end
    end

    if pchk == 1 and rename_me_check0 then
        obj.load("figure", "円", pcol, rename_me_track2)
        for i = 1, Num do
            obj.draw(MO3.pos[i].x, MO3.pos[i].y)
        end

        obj.setfont("", rename_me_track3, 0, fcol)
        for i = 1, Num do
            obj.load("text", i)
            obj.draw(MO3.pos[i].x, MO3.pos[i].y)
        end
    end

    obj.load("tempbuffer")
    Morphing_obj = nil
    Morphing_inport = nil
end)()
