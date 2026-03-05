--label:tim2
---$track:サイズ
---min=0
---max=500
---step=0.1
local track_size = 50

---$track:境界ﾎﾞｶｼ
---min=0.1
---max=500
---step=0.1
local track_boundary_blur = 2

---$track:α基準
---min=0
---max=254
---step=1
local track_alpha_base = 128

---$track:合成量
---min=-100
---max=100
---step=0.1
local track_blend_amount = 100

---$check:高精度
local check0 = false

---$color:色1
local col1 = 0xffffff

---$color:色2
local col2 = 0x0

---$check:距離グラデ
local Lgr = 0

---$check:錯覚補正
local Mis = 0

---$value:└色ぼかし量%
local MiV = 25

---$value:└αぼかし量%
local MiA = 25

---$value:ﾓｰﾄﾞ[0〜2]
local mode = 0

local Sz = track_size
local bl = track_boundary_blur
local sh = track_alpha_base
local Gal = track_blend_amount / 100
local col1 = col1 or 0xffffff
local col2 = col2 or 0x0
local Lgr = Lgr or 0
local iSz = -math.floor(-Sz)
MiV = Sz * (MiV or 0) / 100
MiA = bl * (MiA or 0) / 100
mode = mode or 0

obj.copybuffer("cache:Org", "obj")
if mode == 0 then
    obj.effect("領域拡張", "上", iSz, "下", iSz, "右", iSz, "左", iSz)
elseif mode == 1 then
    obj.effect("領域拡張", "上", iSz, "下", iSz, "右", iSz, "左", iSz)
    obj.effect("エッジ抽出", "透明度エッジを抽出", 1, "輝度エッジを抽出", 0)
else
    obj.effect("反転", "透明度反転", 1)
end

require("T_Framing_Module")
local userdata, w, h = obj.getpixeldata()

if check0 then
    T_Framing_Module.FramingHi(userdata, w, h, Sz, bl, sh, col1, col2, Lgr)
else
    T_Framing_Module.Framing(userdata, w, h, Sz, bl, sh, col1, col2, Lgr)
end
obj.putpixeldata(userdata)

if Mis == 1 then
    if MiV > 0 then
        local userdata, w, h = obj.getpixeldata()
        T_Framing_Module.ReAlpha(userdata, w, h)
        obj.putpixeldata(userdata)
        obj.effect("ぼかし", "範囲", MiV, "サイズ固定", 1)
        userdata, w, h = obj.getpixeldata()
        T_Framing_Module.SetAlpha(userdata, w, h)
        obj.putpixeldata(userdata)
    end
    if MiA > 0 then
        local userdata, w, h = obj.getpixeldata()
        T_Framing_Module.SetImage(userdata, w, h)
        obj.effect("ぼかし", "範囲", MiA, "サイズ固定", 1)
        userdata, w, h = obj.getpixeldata()
        T_Framing_Module.SetColor(userdata, w, h)
        obj.putpixeldata(userdata)
    end
end

obj.setoption("drawtarget", "tempbuffer", w, h)
if mode == 0 then
    if Gal ~= 0 then
        obj.copybuffer("tmp", "obj")
        obj.copybuffer("obj", "cache:Org")
        if Gal < 0 then
            obj.setoption("blend", "alpha_sub")
            Gal = -Gal
        end
        obj.draw(0, 0, 0, 1, Gal)
        obj.copybuffer("obj", "tmp")
    end
elseif mode == 1 then
    if Gal > 0 then
        obj.copybuffer("cache:Frm", "obj")
        obj.copybuffer("obj", "cache:Org")
        obj.draw(0, 0, 0, 1, Gal)
        obj.copybuffer("obj", "cache:Frm")
        obj.draw()
        obj.copybuffer("obj", "tmp")
    end
else
    if Gal < 1 then
        obj.copybuffer("cache:Frm", "obj")
        obj.copybuffer("obj", "cache:Org")
        obj.draw(0, 0, 0, 1, Gal)
        obj.copybuffer("obj", "cache:Frm")
    else
        obj.copybuffer("tmp", "cache:Org")
    end
    obj.draw()
    obj.copybuffer("obj", "cache:Org")
    obj.effect("反転", "透明度反転", 1)
    obj.setoption("blend", "alpha_sub")
    obj.draw()
    obj.copybuffer("obj", "tmp")
end
obj.setoption("blend", 0)
