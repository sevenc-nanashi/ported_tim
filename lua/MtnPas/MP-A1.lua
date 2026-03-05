--label:モーションパスA.anm\MP-A1
---$track:X座標
---min=-10000
---max=10000
---step=0.1
local rename_me_track0 = 0

---$track:Y座標
---min=-10000
---max=10000
---step=0.1
local rename_me_track1 = -100

---$track:Z座標
---min=-10000
---max=10000
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
