--label:モーションパスB.anm\MP-B2(複数可)
---$track:R座標
---min=0
---max=10000
---step=0.1
local rename_me_track0 = 100

---$track:θ座標
---min=-1800
---max=1800
---step=0.1
local rename_me_track1 = 0

---$track:φ座標
---min=-3600
---max=3600
---step=0.1
local rename_me_track2 = 0

---$track:ねじれ
---min=-3600
---max=3600
---step=0.1
local rename_me_track3 = 0

--value@STW:初期ねじれ,0
XX = {}
YY = {}
ZZ = {}
TW = {}
XX[0] = 0
YY[0] = 0
ZZ[0] = 0
TW[0] = STW
XX[1] = rename_me_track0
YY[1] = rename_me_track1
ZZ[1] = rename_me_track2
TW[1] = rename_me_track3
NN = 1

---$track:R座標
---min=0
---max=10000
---step=0.1
local rename_me_track0 = 100

---$track:θ座標
---min=-1800
---max=1800
---step=0.1
local rename_me_track1 = 0

---$track:φ座標
---min=-3600
---max=3600
---step=0.1
local rename_me_track2 = 0

---$track:ねじれ
---min=-3600
---max=3600
---step=0.1
local rename_me_track3 = 0

NN = NN + 1
XX[NN] = rename_me_track0
YY[NN] = rename_me_track1
ZZ[NN] = rename_me_track2
TW[NN] = rename_me_track3
