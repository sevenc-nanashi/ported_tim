--label:tim2\スカイドーム.anm\通常画像用前処理
--track0:H範囲,0,360,120
--track1:V範囲,0,180,60
--value@resize:領域調整/chk,1
--check0:HとVをリンク,1;

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

if obj.check0 then
    T_skydoom_H = obj.track0 / 360
    T_skydoom_V = T_skydoom_H
else
    T_skydoom_H = obj.track0 / 360
    T_skydoom_V = obj.track1 / 180
end
