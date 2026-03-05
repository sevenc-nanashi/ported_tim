--label:tim2\多色グラデーション.anm
---$track:幅
---min=0
---max=5000
---step=0.1
local rename_me_track0 = 100

---$track:中心X
---min=-20000
---max=20000
---step=0.1
local rename_me_track1 = 0

---$track:中心Y
---min=-20000
---max=20000
---step=0.1
local rename_me_track2 = 0

---$track:表示
---min=0
---max=1
---step=0.1
local rename_me_track3 = 0

---$value:色1
local col1 = "0x00ff00"

---$value: 色2
local col2 = "0xffff00"

---$value: 色3
local col3 = "0xff0000"

---$value: 色4
local col4 = "0x0000ff"

---$value: 色5
local col5 = ""

---$value: 色6
local col6 = ""

---$value: 色7
local col7 = ""

---$value: 色8
local col8 = ""

---$value: ガイド半径
local size = 100

---$value: ガイド色
local colG = "0xffffff"

if rename_me_track3 == 1 then
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
    haba = rename_me_track0
    sox = rename_me_track1
    soy = rename_me_track2
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
