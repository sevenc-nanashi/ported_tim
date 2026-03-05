--label:モーションパスB.anm\MP-B1
---$track:R座標
---min=0
---max=10000
---step=0.1
local track_r_coord = 100

---$track:θ座標
---min=-1800
---max=1800
---step=0.1
local track_theta_coord = 0

---$track:φ座標
---min=-3600
---max=3600
---step=0.1
local track_phi_coord = 0

---$track:ねじれ
---min=-3600
---max=3600
---step=0.1
local track_twist = 0

--value@STW:初期ねじれ,0
XX = {}
YY = {}
ZZ = {}
TW = {}
XX[0] = 0
YY[0] = 0
ZZ[0] = 0
TW[0] = STW
XX[1] = track_r_coord
YY[1] = track_theta_coord
ZZ[1] = track_phi_coord
TW[1] = track_twist
NN = 1
