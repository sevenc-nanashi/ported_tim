--label:モーションパスB.anm\MP-B2(複数可)
---$track:R座標
---min=0
---max=10000
---step=0.1
local track_r_coord_2 = 100

---$track:θ座標
---min=-1800
---max=1800
---step=0.1
local track_theta_coord_2 = 0

---$track:φ座標
---min=-3600
---max=3600
---step=0.1
local track_phi_coord_2 = 0

---$track:ねじれ
---min=-3600
---max=3600
---step=0.1
local track_twist_2 = 0

--value@STW:初期ねじれ,0
XX = {}
YY = {}
ZZ = {}
TW = {}
XX[0] = 0
YY[0] = 0
ZZ[0] = 0
TW[0] = STW
XX[1] = track_r_coord_2
YY[1] = track_theta_coord_2
ZZ[1] = track_phi_coord_2
TW[1] = track_twist_2
NN = 1

---$track:R座標
---min=0
---max=10000
---step=0.1
local track_r_coord_2 = 100

---$track:θ座標
---min=-1800
---max=1800
---step=0.1
local track_theta_coord_2 = 0

---$track:φ座標
---min=-3600
---max=3600
---step=0.1
local track_phi_coord_2 = 0

---$track:ねじれ
---min=-3600
---max=3600
---step=0.1
local track_twist_2 = 0

NN = NN + 1
XX[NN] = track_r_coord_2
YY[NN] = track_theta_coord_2
ZZ[NN] = track_phi_coord_2
TW[NN] = track_twist_2
