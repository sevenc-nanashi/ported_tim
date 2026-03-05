--label:tim2\ライトバースト.anm\ライトバースト
--track0:輝度,0,200,100
--track1:ｺﾝﾄﾗｽﾄ,0,100,50
--track2:範囲,0,75,50
--track3:透明度,0,100,0
--value@col:発光色/col,0xffffff
--value@chk:オリジナル色発光/chk,0
--value@Cpos:発光中心,{0,0}
--value@Gmode:合成モード[1-9],1
--value@RC:追加合成数,0

local w, h = obj.getpixel()

if komorebikakutyou == 1 then
    w, h = w + dw, h + dh
end

obj.setoption("drawtarget", "tempbuffer", w, h)
obj.draw()

if komorebikakutyou == nil or komorebikakutyou == 0 then
    obj.setanchor("Cpos", 1)
    XX = Cpos[1]
    YY = Cpos[2]
else
    obj.load("tempbuffer")
    XX = Dpos[1]
    YY = Dpos[2]
end

if chk == 0 then
    obj.effect("単色化", "color", col)
end
obj.effect("色調補正", "輝度", obj.track0, "ｺﾝﾄﾗｽﾄ", 100 + obj.track1)
obj.effect("放射ブラー", "範囲", obj.track2, "X", XX, "Y", YY, "サイズ固定", 1)
obj.setoption("blend", Gmode)
for i = 0, RC do
    obj.draw(0, 0, 0, 1, 1 - obj.track3 / 100)
end
obj.load("tempbuffer")
obj.setoption("blend", 0)
komorebikakutyou = 0
