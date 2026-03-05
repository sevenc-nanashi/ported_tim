--label:tim2\多色グラデーション.anm\多色グラデーション拡張
--track0:番号,1,8,1
--track1:幅,-5000,5000,0
--track2:中心X,-20000,20000,0
--track3:中心Y,-20000,20000,0

if hantei == nil or hantei == 0 then
    kaX = { 0, 0, 0, 0, 0, 0, 0, 0 }
    kaY = { 0, 0, 0, 0, 0, 0, 0, 0 }
    kaS = { 0, 0, 0, 0, 0, 0, 0, 0 }
end
ban = math.floor(obj.track0)
kaS[ban] = obj.track1
kaX[ban] = obj.track2
kaY[ban] = obj.track3
hantei = 1
