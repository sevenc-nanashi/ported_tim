--label:tim2\配置\@モーションパスB.anm
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

NN = NN + 1
XX[NN] = track_r_coord
YY[NN] = track_theta_coord
ZZ[NN] = track_phi_coord
TW[NN] = track_twist
