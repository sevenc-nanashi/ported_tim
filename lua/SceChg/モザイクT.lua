--label:tim2\シーンチェンジ\@シーンチェンジセットT.scn
---$track:サイズ
---min=1
---max=1000
---step=0.1
local rename_me_track0 = 50

---$check:タイル風
local te = 0

---$check:タイル補正
local ho = 1

---$check:滑らか
local rename_me_check0 = false

local t = obj.getvalue("scenechange")
if rename_me_check0 then
    t = t * t * (3 - 2 * t)
end
local a = 4 * t - 1.5
if a < 0 then
    a = 0
elseif a > 1 then
    a = 1
end
local s = (rename_me_track0 - 1) * (1 - math.abs(2 * t - 1)) + 1
if te == 1 and ho == 1 and s < 10 then
    obj.copybuffer("cache:bf", "obj")
end
obj.copybuffer("tmp", "frm")
obj.copybuffer("cache:af", "tmp")

obj.effect("モザイク", "サイズ", s, "タイル風", te)
obj.draw()
obj.copybuffer("obj", "cache:af")
obj.effect("モザイク", "サイズ", s, "タイル風", te)
obj.draw(0, 0, 0, 1, a)

if te == 1 and ho == 1 and s < 10 then
    local w, h = obj.getpixel()
    obj.setoption("drawtarget", "tempbuffer", w, h)
    obj.copybuffer("obj", "cache:bf")
    obj.effect("モザイク", "サイズ", s)
    obj.draw()
    obj.copybuffer("obj", "cache:af")
    obj.effect("モザイク", "サイズ", s)
    obj.draw(0, 0, 0, 1, a)
    obj.load("tempbuffer")
    obj.setoption("drawtarget", "framebuffer")
    obj.draw(0, 0, 0, 1, (10 - s) / 9)
end