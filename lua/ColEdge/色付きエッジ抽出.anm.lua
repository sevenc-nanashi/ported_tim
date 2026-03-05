--label:tim2
--track0:ズレX,-20000,20000,0
--track1:ズレY,-20000,20000,0
--track2:輝度,0,200,100
--track3:縁補正,0,1000,1

--value@Edchk:透明度エッジ/chk,0
--value@orichk:ｵﾘｼﾞﾅﾙ表示/chk,0
--value@pow:エッジ強さ,100
--value@sh:エッジしきい値,0
--value@blur:エッジぼかし,2

local dx = obj.track0
local dy = obj.track1
local ld = obj.track2
local edc = obj.track3

local w, h = obj.getpixel()

obj.setoption("drawtarget", "tempbuffer", w, h)

obj.copybuffer("cache:ori", "obj")

obj.effect("色調補正", "輝度", ld)
obj.draw()

obj.copybuffer("obj", "cache:ori")

if Edchk == 0 then
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
else
    obj.effect(
        "エッジ抽出",
        "強さ",
        pow,
        "しきい値",
        sh,
        "輝度エッジを抽出",
        0,
        "透明度エッジを抽出",
        1
    )
end

obj.effect("縁取り", "サイズ", edc, "ぼかし", blur, "color", 0xffffff)

obj.effect("反転", "透明度反転", 1)

obj.setoption("blend", "alpha_sub")
obj.draw()

obj.copybuffer("obj", "tmp")
obj.setoption("blend", 0)

if orichk == 1 then
    obj.copybuffer("tmp", "cache:ori")
else
    obj.setoption("drawtarget", "tempbuffer", w, h)
end

obj.draw(dx, dy)
obj.load("tempbuffer")
