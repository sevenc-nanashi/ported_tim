--label:tim2\色調整
---$track:サイズX
---min=50
---max=1000
---step=0.1
local track_size_x = 600

---$track:サイズY
---min=50
---max=1000
---step=0.1
local track_size_y = 200

---$track:表示方式
---min=-1
---max=2
---step=1
local track_display_mode = 0

---$track:赤凹凸
---min=-30
---max=30
---step=0.01
local track_red_bump = 0

---$track:緑凹凸
---min=-30
---max=30
---step=0.01
local track_green_bump = 0

---$track:青凹凸
---min=-30
---max=30
---step=0.01
local track_blue_bump = 0

---$check:Rのみ設定
local Rset = 0

---$check:Gのみ設定
local Gset = 0

---$check:Bのみ設定
local Bset = 0

---$value:カーブ
local pos = { -280, 80, -200, 0, -120, -80, -80, 80, 0, 0, 80, -80, 120, 80, 200, 0, 280, -80 }

---$track:表示精度
---min=1
---max=100
---step=1
local track_display_precision = 20

---$check:カーブ表示
local check0 = true

-- require("T_Color_Module")
local T_Color_Module = obj.module("tim2")
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
        T_Color_Module.color_set_tone_curve(Cty, unpack(TRA))
    end
    if flg then
        obj.load("figure", "四角形", col, 1)
        obj.effect("リサイズ", "ドット数でサイズ指定", 1, "X", 256, "Y", 2 * shg2)
        local userdata, w, h = obj.getpixeldata("object", "bgra")
        T_Color_Module.color_draw_tone_curve(userdata, w, h, Cty, col)
        obj.putpixeldata("object", userdata, w, h, "bgra")
        obj.effect("リサイズ", "ドット数でサイズ指定", 1, "X", swg2, "Y", shg2)
        obj.draw(dx, dy)
    end
end
local sw, sh = track_size_x, track_size_y
local ar = track_red_bump
local ag = track_green_bump or 0
local ab = track_blue_bump or 0
local TC_Type = track_display_mode
local spN = track_display_precision or 20
Rset = Rset or 0
Gset = Gset or 0
Bset = Bset or 0
if Rset == 1 or Gset == 1 or Bset == 1 then
    if check0 then
        obj.setanchor("pos", 3)
    end
    obj.setoption("drawtarget", "tempbuffer", sw / 3, sh)
    if Rset == 1 then
        drawtoneC(0, 1, sw / 3, sh, 0, 0, 0xff0000, check0, ar, TC_Type, spN)
        T_ToneCurve_R = 1
    elseif Gset == 1 then
        drawtoneC(1, 1, sw / 3, sh, 0, 0, 0x00ff00, check0, ar, TC_Type, spN)
        T_ToneCurve_G = 1
    else
        drawtoneC(2, 1, sw / 3, sh, 0, 0, 0x0000ff, check0, ar, TC_Type, spN)
        T_ToneCurve_B = 1
    end
else
    T_ToneCurve_R = 1
    T_ToneCurve_G = 1
    T_ToneCurve_B = 1
    if check0 then
        obj.setanchor("pos", 9)
    end
    obj.setoption("drawtarget", "tempbuffer", sw, sh)
    drawtoneC(0, 1, sw / 3, sh, -sw / 3, 0, 0xff0000, check0, ar, TC_Type, spN)
    drawtoneC(1, 7, sw / 3, sh, 0, 0, 0x00ff00, check0, ag, TC_Type, spN)
    drawtoneC(2, 13, sw / 3, sh, sw / 3, 0, 0x0000ff, check0, ab, TC_Type, spN)
end
obj.load("tempbuffer")
