--label:tim2\スカイドーム.anm
---$track:H範囲
---min=0
---max=360
---step=0.1
local track_h_range = 120

---$track:V範囲
---min=0
---max=180
---step=0.1
local track_v_range = 60

---$check:領域調整
local resize = 1

---$check:HとVをリンク
local check0 = true

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

if check0 then
    T_skydoom_H = track_h_range / 360
    T_skydoom_V = T_skydoom_H
else
    T_skydoom_H = track_h_range / 360
    T_skydoom_V = track_v_range / 180
end
