--label:tim2\スカイドーム.anm\通常画像用前処理
---$track:H範囲
---min=0
---max=360
---step=0.1
local rename_me_track0 = 120

---$track:V範囲
---min=0
---max=180
---step=0.1
local rename_me_track1 = 60

---$value:領域調整/chk
local resize = 1

---$check:HとVをリンク
local rename_me_check0 = true

if resize == 1 then
    local w, h = obj.getpixel()
    if 2 * h > w then
        obj.setoption("drawtarget", "tempbuffer", 2 * h, h)
        obj.draw()
        obj.load("tempbuffer")
    else
        obj.setoption("drawtarget", "tempbuffer", w, w * 0.5)
        obj.draw()
        obj.load("tempbuffer")
    end
end

if rename_me_check0 then
    T_skydoom_H = rename_me_track0 / 360
    T_skydoom_V = T_skydoom_H
else
    T_skydoom_H = rename_me_track0 / 360
    T_skydoom_V = rename_me_track1 / 180
end
