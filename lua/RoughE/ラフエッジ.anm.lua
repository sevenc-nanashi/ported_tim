--label:tim2
---$track:変形量
---min=0
---max=1000
---step=0.1
local rename_me_track0 = 20

---$track:周期
---min=0
---max=200
---step=0.01
local rename_me_track1 = 2

---$track:変化速度
---min=0
---max=50
---step=0.1
local rename_me_track2 = 0

---$track:形状
---min=1
---max=6
---step=1
local rename_me_track3 = 1

---$value:シード
local seed = 0

---$value:Y周期(空白X＝Y)
local fry = nil

---$check:周囲を少し残す
local rename_me_check0 = true

local Rf = rename_me_track0
local frx = rename_me_track1
fry = fry or frx
local sp = rename_me_track2
local kata = rename_me_track3 - 1
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

if not rename_me_check0 then
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

if not rename_me_check0 then
    obj.copybuffer("obj", "cache:MAP")
    obj.setoption("blend", "alpha_sub")
    obj.draw()
end

obj.load("tempbuffer")
obj.setoption("blend", 0)
