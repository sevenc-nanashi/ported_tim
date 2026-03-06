--label:tim2\未分類
---$track:ズレX
---min=-20000
---max=20000
---step=0.1
local track_offset_x = 0

---$track:ズレY
---min=-20000
---max=20000
---step=0.1
local track_offset_y = 0

---$track:輝度
---min=0
---max=200
---step=0.1
local track_luminance = 100

---$track:縁補正
---min=0
---max=1000
---step=0.1
local track_adjust = 1

---$check:透明度エッジ
local Edchk = 0

---$check:ｵﾘｼﾞﾅﾙ表示
local orichk = 0

---$value:エッジ強さ
local pow = 100

---$value:エッジしきい値
local sh = 0

---$value:エッジぼかし
local blur = 2

local dx = track_offset_x
local dy = track_offset_y
local ld = track_luminance
local edc = track_adjust

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
