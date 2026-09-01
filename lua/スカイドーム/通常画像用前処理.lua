--label:${ROOT_CATEGORY}\変形\@スカイドーム
---$check:水平と垂直をリンク
local check_use_separate_vertical_range = true

---$track:水平範囲
---min=0
---max=360
---step=0.1
local track_horizontal_range = 120

---$track:垂直範囲
---min=0
---max=180
---step=0.1
local track_vertical_range = 60

---$check:画像サイズ調整
local check_resize = 1

--hide@track_vertical_range:check_use_separate_vertical_range==1

if check_resize == 1 then
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

if check_use_separate_vertical_range then
    T_SKYDOME_HORIZONTAL_RATIO = track_horizontal_range / 360
    T_SKYDOME_VERTICAL_RATIO = T_SKYDOME_HORIZONTAL_RATIO
else
    T_SKYDOME_HORIZONTAL_RATIO = track_horizontal_range / 360
    T_SKYDOME_VERTICAL_RATIO = track_vertical_range / 180
end
