--label:tim2\集中線T.obj\集中線T2
--track0:発生量,0,100,35
--track1:中心,0,100,60
--track2:分布,0,100,50,0.01
--track3:放射周期,0,100,0
--value@color:色/col,0xffffff
--value@Gr:明るさ,500
--value@yspd:放射速度,0
--value@spd:変化速度,0
--value@rv:回転速度,0
--value@Edd:渦巻,0
--value@TY:タイプ,1
--value@seed:シード,0
--value@w:幅,nil
--value@h:高さ,nil
local sh = 100 - obj.track0
local clipY = obj.track1
local fr1 = obj.track2
local yfr = obj.track3
local screen_w = w or obj.screen_w
local screen_h = h or obj.screen_h

fr1 = fr1 * fr1 * 0.01
yfr = yfr / 25
local size = (screen_w < screen_h) and screen_h or screen_w
clipY = 0.01 * (clipY - 50) * size
obj.load("figure", "四角形", 0xffffff, size)
obj.effect(
    "ノイズ",
    "変化速度",
    spd,
    "周期X",
    fr1,
    "周期Y",
    yfr,
    "速度Y",
    -yspd,
    "しきい値",
    sh,
    "seed",
    seed + 3000,
    "type",
    TY
)
obj.effect("斜めクリッピング", "角度", 180, "ぼかし", size, "中心Y", clipY)
obj.effect("極座標変換", "渦巻", Edd * 0.1, "回転", rv * obj.time)
obj.setoption("drawtarget", "tempbuffer", screen_w, screen_h)
obj.draw(0, 0, 0, 1.2)
obj.load("tempbuffer")
obj.effect("グロー", "強さ", Gr, "拡散", 1, "しきい値", 0, "ぼかし", 1)
obj.effect("単色化", "color", color, "輝度を保持する", 0)
