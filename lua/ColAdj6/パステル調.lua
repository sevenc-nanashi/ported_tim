--label:tim2\T_Color_Module.anm\パステル調
---$track:彩度
---min=0
---max=100
---step=0.1
local rename_me_track0 = 70

---$track:明度
---min=0
---max=100
---step=0.1
local rename_me_track1 = 70

---$track:しきい値
---min=0
---max=100
---step=0.1
local rename_me_track2 = 10

---$track:色付ｴｯｼﾞ
---min=0
---max=100
---step=0.1
local rename_me_track3 = 50

---$value:しきい値ぼかし
local shw = 8

---$value:縁補正
local edc = 1

---$value:エッジ強さ
local pow = 100

---$value:エッジしきい値
local sh = 0

---$value:エッジぼかし
local blur = 1

require("T_Color_Module")
local Ces = rename_me_track3 / 100
if Ces > 0 then
    obj.setoption("drawtarget", "tempbuffer")
    obj.copybuffer("cache:org", "obj")
    obj.copybuffer("tmp", "obj")
    obj.effect(
        "エッジ抽出",
        "強さ",
        pow,
        "しきい値",
        sh,
        "輝度エッジを抽出",
        1,
        "透明度エッジを抽出",
        0
    )
    obj.effect("縁取り", "サイズ", edc, "ぼかし", blur, "color", 0xffffff)
    obj.effect("反転", "透明度反転", 1)
    obj.setoption("blend", "alpha_sub")
    obj.draw()
    obj.setoption("blend", 0)
    obj.copybuffer("cache:Edg", "tmp")
    obj.copybuffer("obj", "cache:org")
end
local userdata, w, h = obj.getpixeldata()
T_Color_Module.Pastel(userdata, w, h, rename_me_track0, rename_me_track1, rename_me_track2, shw or 0)
obj.putpixeldata(userdata)
if Ces > 0 then
    obj.copybuffer("tmp", "obj")
    obj.copybuffer("obj", "cache:Edg")
    obj.draw(0, 0, 0, 1, Ces)
    obj.copybuffer("obj", "tmp")
end
