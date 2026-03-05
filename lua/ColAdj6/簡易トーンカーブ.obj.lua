--label:tim2
--track0:サイズX,50,1000,600
--track1:サイズY,50,1000,200
--track2:赤凹凸,-30,30,0,0.01
--track3:表示方式,-1,2,0,1
--value@g3:緑凹凸,0
--value@b3:青凹凸,0
--value@Rset:Rのみ設定/chk,0
--value@Gset:Gのみ設定/chk,0
--value@Bset:Bのみ設定/chk,0
--value@pos:カーブ,{-280,80,-200,0,-120,-80,-80,80,0,0,80,-80,120,80,200,0,280,-80}
--value@spN:表示精度,20
--check0:カーブ表示,1;
require("T_Color_Module")
local drawtoneC = function(Cty, k, sw, sh, dx, dy, col, flg, a, TC, spN)
    local swh = sw
    local shh = sh
    local swq = sw * 0.5
    local shq = sh * 0.5
    local swg = sw * 0.4
    local shg = sh * 0.4
    local swg2 = sw * 0.8
    local shg2 = sh * 0.8
    local sqs = sw < sh and sh or sw
    if flg then
        obj.load("figure", "四角形", 0xffffff, 1)
        obj.drawpoly(
            -swq + dx - 1,
            -shq + dy,
            0,
            swq + dx + 1,
            -shq + dy,
            0,
            swq + dx + 1,
            shq + dy,
            0,
            -swq + dx - 1,
            shq + dy,
            0
        )
    end
    if TC >= 0 then
        local dxswg = dx - swg
        local dyshg = dy - shg
        local x0, y0 = (pos[k] - dxswg) / swg2, (pos[k + 1] - dyshg) / shg2
        local x1, y1 = (pos[k + 2] - dxswg) / swg2, (pos[k + 3] - dyshg) / shg2
        local x2, y2 = (pos[k + 4] - dxswg) / swg2, (pos[k + 5] - dyshg) / shg2
        if x0 > x1 then
            x0, x1 = x1, x0
            y0, y1 = y1, y0
        end
        if x1 > x2 then
            x1, x2 = x2, x1
            y1, y2 = y2, y1
            if x0 > x2 then
                x0, x2 = x2, x0
                y0, y2 = y2, y0
            end
        end
        local TRA
        if TC == 0 then
            y0 = y0 + a * x0 * x0 * x0
            y1 = y1 + a * x1 * x1 * x1
            y2 = y2 + a * x2 * x2 * x2
            local dr10 = (y1 - y0) / (x1 - x0)
            local dr20 = (y2 - y0) / (x2 - x0)
            local b = (dr10 - dr20) / (x1 - x2)
            local c = dr10 - b * (x1 + x0)
            local d = y0 - b * x0 * x0 - c * x0
            TRA = { TC, a, -b, -c, 1 - d, 0, 0, 0 }
        elseif TC == 1 then
            a1 = (y1 - y0) / (x1 - x0)
            b1 = y0 - a1 * x0 - a / 20
            a2 = (y2 - y1) / (x2 - x1)
            b2 = y1 - a2 * x1 + a / 20
            TRA = { TC, -a1, 1 - b1, -a2, 1 - b2, x1, 0, 0 }
        elseif TC == 2 then
            local dx10, dx20, dx21 = x1 - x0, x2 - x0, x2 - x1
            local dr10, dr20, dr21 = (y1 - y0) / dx10, (y2 - y0) / dx20, (y2 - y1) / dx21
            if a ~= 0 then
                local at2 = a / 10 + math.atan2(y2 - y0, dx20)
                dr20 = math.tan(at2)
            end
            local a1 = (dr20 - dr10) / dx10
            local b1 = dr20 - 2 * x1 * a1
            local c1 = y1 - (a1 * x1 + b1) * x1
            local a2 = -(dr20 - dr21) / dx21
            local b2 = dr20 - 2 * x1 * a2
            local c2 = y1 - (a2 * x1 + b2) * x1
            TRA = { TC, -a1, -b1, 1 - c1, -a2, -b2, 1 - c2, x1 }
        end
        T_Color_Module.SetToneCurve(Cty, unpack(TRA))
    end
    if flg then
        obj.load("figure", "四角形", col, 1)
        obj.effect("リサイズ", "ドット数でサイズ指定", 1, "X", 256, "Y", 2 * shg2)
        local userdata, w, h = obj.getpixeldata()
        T_Color_Module.DrawToneCurve(userdata, w, h, Cty, col)
        obj.putpixeldata(userdata)
        obj.effect("リサイズ", "ドット数でサイズ指定", 1, "X", swg2, "Y", shg2)
        obj.draw(dx, dy)
    end
end
local sw, sh = obj.track0, obj.track1
local ar = obj.track2
local ag = g3 or 0
local ab = b3 or 0
local TC_Type = obj.track3
spN = spN or 20
Rset = Rset or 0
Gset = Gset or 0
Bset = Bset or 0
if Rset == 1 or Gset == 1 or Bset == 1 then
    if obj.check0 then
        obj.setanchor("pos", 3)
    end
    obj.setoption("drawtarget", "tempbuffer", sw / 3, sh)
    if Rset == 1 then
        drawtoneC(0, 1, sw / 3, sh, 0, 0, 0xff0000, obj.check0, ar, TC_Type, spN)
        T_ToneCurve_R = 1
    elseif Gset == 1 then
        drawtoneC(1, 1, sw / 3, sh, 0, 0, 0x00ff00, obj.check0, ar, TC_Type, spN)
        T_ToneCurve_G = 1
    else
        drawtoneC(2, 1, sw / 3, sh, 0, 0, 0x0000ff, obj.check0, ar, TC_Type, spN)
        T_ToneCurve_B = 1
    end
else
    T_ToneCurve_R = 1
    T_ToneCurve_G = 1
    T_ToneCurve_B = 1
    if obj.check0 then
        obj.setanchor("pos", 9)
    end
    obj.setoption("drawtarget", "tempbuffer", sw, sh)
    drawtoneC(0, 1, sw / 3, sh, -sw / 3, 0, 0xff0000, obj.check0, ar, TC_Type, spN)
    drawtoneC(1, 7, sw / 3, sh, 0, 0, 0x00ff00, obj.check0, ag, TC_Type, spN)
    drawtoneC(2, 13, sw / 3, sh, sw / 3, 0, 0x0000ff, obj.check0, ab, TC_Type, spN)
end
obj.load("tempbuffer")
