--label:tim2
--track0:変形量,0,1000,20
--track1:周期,0,200,2,0.01
--track2:変化速度,0,50,0
--track3:形状,1,6,1,1
--value@seed:シード,0
--value@fry:Y周期(空白X＝Y),nil
--check0:周囲を少し残す,0;

local Rf = obj.track0
local frx = obj.track1
fry = fry or frx
local sp = obj.track2
local kata = obj.track3 - 1
local w, h = obj.getpixel()
obj.copybuffer("cache:ORI", "obj")

obj.setoption("drawtarget", "tempbuffer", w, h)
obj.load("四角形", 0xffffff, math.max(w, h))
obj.draw()
obj.copybuffer("obj", "tmp")
obj.effect("ノイズ", "周期X", frx, "周期Y", frx, "変化速度", sp, "type", kata, "seed", seed, "mode", 1)
obj.effect("グラデーション", "color", 0xff0000, "color2", 0xff0000, "blend", 3)
obj.draw()
obj.effect("単色化", "color", 0xffffff, "輝度を保持する", 0)
obj.effect(
    "ノイズ",
    "周期X",
    fry,
    "周期Y",
    fry,
    "変化速度",
    sp,
    "type",
    kata,
    "seed",
    seed + 1000,
    "mode",
    1
)
obj.effect("グラデーション", "color", 0x00ff00, "color2", 0x00ff00, "blend", 3)
obj.setoption("blend", 1)
obj.draw()

if not obj.check0 then
    obj.copybuffer("obj", "cache:ORI")
    obj.effect(
        "ディスプレイスメントマップ",
        "type",
        0,
        "name",
        "*tempbuffer",
        "元のサイズに合わせる",
        1,
        "param0",
        Rf,
        "param1",
        Rf
    )
    obj.effect("反転", "透明度反転", 1)
    obj.copybuffer("cache:MAP", "obj")
end

obj.copybuffer("obj", "cache:ORI")
obj.effect(
    "ディスプレイスメントマップ",
    "type",
    0,
    "name",
    "*tempbuffer",
    "元のサイズに合わせる",
    1,
    "param0",
    -Rf,
    "param1",
    -Rf
)
obj.effect("反転", "透明度反転", 1)

obj.copybuffer("tmp", "cache:ORI")
obj.setoption("blend", "alpha_sub")
obj.draw()

if not obj.check0 then
    obj.copybuffer("obj", "cache:MAP")
    obj.setoption("blend", "alpha_sub")
    obj.draw()
end

obj.load("tempbuffer")
obj.setoption("blend", 0)
