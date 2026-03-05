--label:tim2\T_Color_Module.anm\パステル調
--track0:彩度,0,100,70
--track1:明度,0,100,70
--track2:しきい値,0,100,10
--track3:色付ｴｯｼﾞ,0,100,50
--value@shw:しきい値ぼかし,8
--value@edc:縁補正,1
--value@pow:エッジ強さ,100
--value@sh:エッジしきい値,0
--value@blur:エッジぼかし,1
require("T_Color_Module")
local Ces = obj.track3 / 100
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
T_Color_Module.Pastel(userdata, w, h, obj.track0, obj.track1, obj.track2, shw or 0)
obj.putpixeldata(userdata)
if Ces > 0 then
    obj.copybuffer("tmp", "obj")
    obj.copybuffer("obj", "cache:Edg")
    obj.draw(0, 0, 0, 1, Ces)
    obj.copybuffer("obj", "tmp")
end
