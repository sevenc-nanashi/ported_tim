--label:tim2\ライトバースト.anm
---$track:輝度
---min=0
---max=200
---step=0.1
local rename_me_track0 = 100

---$track:ｺﾝﾄﾗｽﾄ
---min=0
---max=100
---step=0.1
local rename_me_track1 = 50

---$track:範囲
---min=0
---max=75
---step=0.1
local rename_me_track2 = 50

---$track:透明度
---min=0
---max=100
---step=0.1
local rename_me_track3 = 0

---$color:発光色
local col = 0xffffff

---$check:オリジナル色発光
local chk = 0

---$value:発光中心
local Cpos = { 0, 0 }

---$value:合成モード[1-9]
local Gmode = 1

---$value:追加合成数
local RC = 0

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
obj.effect("色調補正", "輝度", rename_me_track0, "ｺﾝﾄﾗｽﾄ", 100 + rename_me_track1)
obj.effect("放射ブラー", "範囲", rename_me_track2, "X", XX, "Y", YY, "サイズ固定", 1)
obj.setoption("blend", Gmode)
for i = 0, RC do
    obj.draw(0, 0, 0, 1, 1 - rename_me_track3 / 100)
end
obj.load("tempbuffer")
obj.setoption("blend", 0)
komorebikakutyou = 0
