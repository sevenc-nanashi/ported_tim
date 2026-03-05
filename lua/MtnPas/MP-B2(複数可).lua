--label:モーションパスB.anm\MP-B2(複数可)
--track0:R座標,0,10000,100
--track1:θ座標,-1800,1800,0
--track2:φ座標,-3600,3600,0
--track3:ねじれ,-3600,3600,0
--value@STW:初期ねじれ,0
XX = {}
YY = {}
ZZ = {}
TW = {}
XX[0] = 0
YY[0] = 0
ZZ[0] = 0
TW[0] = STW
XX[1] = obj.track0
YY[1] = obj.track1
ZZ[1] = obj.track2
TW[1] = obj.track3
NN = 1

--track0:R座標,0,10000,100
--track1:θ座標,-1800,1800,0
--track2:φ座標,-3600,3600,0
--track3:ねじれ,-3600,3600,0
NN = NN + 1
XX[NN] = obj.track0
YY[NN] = obj.track1
ZZ[NN] = obj.track2
TW[NN] = obj.track3
