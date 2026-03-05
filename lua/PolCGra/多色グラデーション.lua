--label:tim2\多色グラデーション.anm\多色グラデーション
--track0:幅,0,5000,100
--track1:中心X,-20000,20000,0
--track2:中心Y,-20000,20000,0
--track3:表示,0,1,0
--value@col1:色1,"0x00ff00"
--value@col2: 色2,"0xffff00"
--value@col3: 色3,"0xff0000"
--value@col4: 色4,"0x0000ff"
--value@col5: 色5,""
--value@col6: 色6,""
--value@col7: 色7,""
--value@col8: 色8,""
--value@size: ガイド半径,100
--value@colG: ガイド色,"0xffffff"

if obj.track3 == 1 then
    obj.load("figure", "円", colG, size)
    obj.effect("縁取り")

    N = obj.getoption("section_num") + 1
    if N > 8 then
        N = 8
    end
    for i = 1, N - 1 do
        xx = obj.getvalue("x", 0, i - 1) - obj.getvalue("x")
        yy = obj.getvalue("y", 0, i - 1) - obj.getvalue("y")
        obj.drawpoly(
            xx - size / 2,
            yy - size / 2,
            0,
            xx + size / 2,
            yy - size / 2,
            0,
            xx + size / 2,
            yy + size / 2,
            0,
            xx - size / 2,
            yy + size / 2,
            0,
            0,
            0,
            obj.w,
            0,
            obj.w,
            obj.h,
            0,
            obj.h
        )
    end
    xx = obj.getvalue("x", 0, -1) - obj.getvalue("x")
    yy = obj.getvalue("y", 0, -1) - obj.getvalue("y")
    obj.drawpoly(
        xx - size / 2,
        yy - size / 2,
        0,
        xx + size / 2,
        yy - size / 2,
        0,
        xx + size / 2,
        yy + size / 2,
        0,
        xx - size / 2,
        yy + size / 2,
        0,
        0,
        0,
        obj.w,
        0,
        obj.w,
        obj.h,
        0,
        obj.h
    )
else
    obj.setoption("focus_mode", "fixed_size")
    cenX = {}
    cenY = {}
    cc = { col1, col2, col3, col4, col5, col6, col7, col8, col9, col10 }
    haba = obj.track0
    sox = obj.track1
    soy = obj.track2
    N = obj.getoption("section_num") + 1
    if N > 8 then
        N = 8
    end
    for i = 1, N - 1 do
        cenX[i] = obj.getvalue("x", 0, i - 1) + sox
        cenY[i] = obj.getvalue("y", 0, i - 1) + soy
    end
    cenX[N] = obj.getvalue("x", 0, -1) + sox
    cenY[N] = obj.getvalue("y", 0, -1) + soy

    for i = 1, N do
        if hantei == 1 then
            cenX[i] = cenX[i] + kaX[i]
            cenY[i] = cenY[i] + kaY[i]
            haba2 = haba + kaS[i]
        else
            haba2 = haba
        end
        obj.effect(
            "グラデーション",
            "no_color2",
            1,
            "color",
            cc[i],
            "中心X",
            cenX[i],
            "中心Y",
            cenY[i],
            "幅",
            haba2,
            "type",
            1
        )
    end
    obj.ox = obj.ox - obj.getvalue("x") + sox
    obj.oy = obj.oy - obj.getvalue("y") + soy
    hantei = 0
end
