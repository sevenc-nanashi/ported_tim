--label:モーションパスA.anm\MP-A1
---$track:X座標
---min=-10000
---max=10000
---step=0.1
local track_x_coord = 0

---$track:Y座標
---min=-10000
---max=10000
---step=0.1
local track_y_coord = -100

---$track:Z座標
---min=-10000
---max=10000
---step=0.1
local track_z_coord = 0

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
XX[1] = track_x_coord
YY[1] = track_y_coord
ZZ[1] = track_z_coord
TW[1] = track_twist
NN = 1
