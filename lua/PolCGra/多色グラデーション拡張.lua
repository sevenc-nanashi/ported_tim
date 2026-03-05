--label:tim2\多色グラデーション.anm\多色グラデーション拡張
---$track:番号
---min=1
---max=8
---step=0.1
local rename_me_track0 = 1

---$track:幅
---min=-5000
---max=5000
---step=0.1
local rename_me_track1 = 0

---$track:中心X
---min=-20000
---max=20000
---step=0.1
local rename_me_track2 = 0

---$track:中心Y
---min=-20000
---max=20000
---step=0.1
local rename_me_track3 = 0

if hantei == nil or hantei == 0 then
    kaX = { 0, 0, 0, 0, 0, 0, 0, 0 }
    kaY = { 0, 0, 0, 0, 0, 0, 0, 0 }
    kaS = { 0, 0, 0, 0, 0, 0, 0, 0 }
end
ban = math.floor(rename_me_track0)
kaS[ban] = rename_me_track1
kaX[ban] = rename_me_track2
kaY[ban] = rename_me_track3
hantei = 1
