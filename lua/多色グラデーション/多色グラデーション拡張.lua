--label:tim2\色調整\@多色グラデーション
---$track:番号
---min=1
---max=8
---step=1
local track_index = 1

---$track:幅
---min=-5000
---max=5000
---step=0.1
local track_width = 0

---$track:中心X
---min=-20000
---max=20000
---step=0.1
local track_center_x = 0

---$track:中心Y
---min=-20000
---max=20000
---step=0.1
local track_center_y = 0

if hantei == nil or hantei == 0 then
    kaX = { 0, 0, 0, 0, 0, 0, 0, 0 }
    kaY = { 0, 0, 0, 0, 0, 0, 0, 0 }
    kaS = { 0, 0, 0, 0, 0, 0, 0, 0 }
end
ban = math.floor(track_index)
kaS[ban] = track_width
kaX[ban] = track_center_x
kaY[ban] = track_center_y
hantei = 1
