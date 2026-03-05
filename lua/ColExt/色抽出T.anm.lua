--label:tim2
--track0:輝度範囲,0,4096,300,1
--track1:色差範囲,0,4096,300,1
--track2:境界補正,0,5,0,1
--value@col:抽出色/col,""
--check0:簡易処理,1;

(function()
    local TrHex = function(A)
        local H = { "0", "1", "2", "3", "4", "5", "6", "7", "8", "9", "a", "b", "c", "d", "e", "f" }
        A = (A < 0 and 0x10000 + A) or A
        local A1 = 1 + SHIFT(AND(A, 0xf000), -12)
        local A2 = 1 + SHIFT(AND(A, 0x0f00), -8)
        local A3 = 1 + SHIFT(AND(A, 0x00f0), -4)
        local A4 = 1 + AND(A, 0x000f)
        return H[A3] .. H[A4] .. H[A1] .. H[A2]
    end
    if col == nil then
        return
    end
    obj.effect("領域拡張", "上", 10, "下", 10, "右", 10, "左", 10, "塗りつぶし", 1)
    obj.copybuffer("cache:ori", "obj")
    obj.setoption("drawtarget", "tempbuffer")
    if not obj.check0 then
        obj.copybuffer("tmp", "obj")
        obj.effect("反転", "透明度反転", 1)
        obj.setoption("blend", "alpha_add")
        obj.draw()
        obj.copybuffer("obj", "tmp")
    end
    local r, g, b = RGB(col)
    local Y = SHIFT((4918 * r + 354), -10) + SHIFT((9655 * g + 585), -10) + SHIFT((1875 * b + 523), -10)
    local Cb = SHIFT((-2775 * r + 240), -10) + SHIFT((-5449 * g + 515), -10) + SHIFT((8224 * b + 256), -10)
    local Cr = SHIFT((8224 * r + 256), -10) + SHIFT((-6887 * g + 110), -10) + SHIFT((-1337 * b + 646), -10)
    Y = TrHex(Y) .. TrHex(Cb) .. TrHex(Cr)
    obj.effect(
        "カラーキー",
        "輝度範囲",
        obj.track0,
        "色差範囲",
        obj.track1,
        "境界補正",
        obj.track2,
        "color_yc",
        Y,
        "status",
        1
    )
    obj.copybuffer("tmp", "cache:ori")
    obj.setoption("blend", "alpha_sub")
    obj.draw()
    obj.load("tempbuffer")
    obj.effect("クリッピング", "上", 10, "下", 10, "右", 10, "左", 10)
end)(col)
