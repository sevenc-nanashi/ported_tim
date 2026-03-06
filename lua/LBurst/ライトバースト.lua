--label:tim2\未分類\ライトバースト.anm
---$track:輝度
---min=0
---max=200
---step=0.1
local track_luminance = 100

---$track:ｺﾝﾄﾗｽﾄ
---min=0
---max=100
---step=0.1
local track_contrast = 50

---$track:範囲
---min=0
---max=75
---step=0.1
local track_range = 50

---$track:透明度
---min=0
---max=100
---step=0.1
local track_opacity = 0

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
obj.effect("色調補正", "輝度", track_luminance, "ｺﾝﾄﾗｽﾄ", 100 + track_contrast)
obj.effect("放射ブラー", "範囲", track_range, "X", XX, "Y", YY, "サイズ固定", 1)
obj.setoption("blend", Gmode)
for i = 0, RC do
    obj.draw(0, 0, 0, 1, 1 - track_opacity / 100)
end
obj.load("tempbuffer")
obj.setoption("blend", 0)
komorebikakutyou = 0
