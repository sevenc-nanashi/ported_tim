--label:tim2\カメレオン効果.anm\カメレオン効果(適応)
--track0:適応率,0,100,70
--track1:明度補正,0,300,100
--track2:逆光強度,0,300,0
--track3:逆光拡散,0,500,15
--check0:ﾌﾚｰﾑﾊﾞｯﾌｧを背景,0;
--value@CkV:輝度補正/chk,1
--value@CkS:彩度補正/chk,1
--value@col:逆光色/col,""
--value@BLA:逆光自動調整/chk,0
--value@BLL:逆光強度補正,100
--value@reC:事前無彩色補正/chk,0
--value@reH:└強度,30

require("T_Familiar_Module")

local P = obj.track0 / 100
local L = obj.track1 / 100
local GL = obj.track2
local GD = obj.track3

BLL = (BLL or 100) / 100

if obj.check0 then
    local Pr =
        { obj.ox, obj.oy, obj.oz, obj.rx, obj.ry, obj.rz, obj.cx, obj.cy, obj.cz, obj.zoom, obj.alpha, obj.aspect }
    obj.copybuffer("cache:org", "obj")
    obj.load("framebuffer")
    local userdata, w, h = obj.getpixeldata()
    T_Familiar_Module.SetColor(userdata, w, h, 0, 0, w, h, false, 0, 0)
    obj.copybuffer("obj", "cache:org")
    obj.ox, obj.oy, obj.oz, obj.rx, obj.ry, obj.rz, obj.cx, obj.cy, obj.cz, obj.zoom, obj.alpha, obj.aspect = unpack(Pr)
end

if reC == 1 then
    reH = (reH or 30)
    local r, g, b = T_Familiar_Module.GetColor()
    local col = RGB(r, g, b)
    obj.effect("単色化", "強さ", reH, "color", col)
end

local userdata, w, h = obj.getpixeldata()
T_Familiar_Module.Familiar(userdata, w, h, P, L, CkS, CkV)
obj.putpixeldata(userdata)

if GL > 0 and GD > 0 then
    local r, g, b
    if col == "" then
        r, g, b = T_Familiar_Module.GetColor()
        if BLA == 1 then
            local mx = math.max(r, g, b)
            if mx == 0 then
                r, g, b = 0, 0, 0
            else
                r, g, b = 255 * r / mx, 255 * g / mx, 255 * b / mx
            end
        end
    else
        r, g, b = RGB(col)
    end

    r, g, b = r * BLL, g * BLL, b * BLL
    r = math.max(math.min(r, 255), 0)
    g = math.max(math.min(g, 255), 0)
    b = math.max(math.min(b, 255), 0)

    obj.effect("ライト", "強さ", obj.track2, "拡散", obj.track3, "逆光", 1, "color", RGB(r, g, b))
end
