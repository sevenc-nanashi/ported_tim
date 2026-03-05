--label:tim2\カメレオン効果.anm\カメレオン効果(適応)
---$track:適応率
---min=0
---max=100
---step=0.1
local rename_me_track0 = 70

---$track:明度補正
---min=0
---max=300
---step=0.1
local rename_me_track1 = 100

---$track:逆光強度
---min=0
---max=300
---step=0.1
local rename_me_track2 = 0

---$track:逆光拡散
---min=0
---max=500
---step=0.1
local rename_me_track3 = 15

---$check:ﾌﾚｰﾑﾊﾞｯﾌｧを背景
local rename_me_check0 = true

---$value:輝度補正/chk
local CkV = 1

---$value:彩度補正/chk
local CkS = 1

---$value:逆光色/col
local col = ""

---$value:逆光自動調整/chk
local BLA = 0

---$value:逆光強度補正
local BLL = 100

---$value:事前無彩色補正/chk
local reC = 0

---$value:└強度
local reH = 30

require("T_Familiar_Module")

local P = rename_me_track0 / 100
local L = rename_me_track1 / 100
local GL = rename_me_track2
local GD = rename_me_track3

BLL = (BLL or 100) / 100

if rename_me_check0 then
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

    obj.effect("ライト", "強さ", rename_me_track2, "拡散", rename_me_track3, "逆光", 1, "color", RGB(r, g, b))
end
