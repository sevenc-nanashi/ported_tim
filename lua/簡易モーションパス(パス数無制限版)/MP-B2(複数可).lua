--label:${ROOT_CATEGORY}\配置\@モーションパスB
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

T_MP_SECTION_COUNT = T_MP_SECTION_COUNT + 1
T_MP_X_POSITIONS[T_MP_SECTION_COUNT] = track_r_coord
T_MP_Y_POSITIONS[T_MP_SECTION_COUNT] = track_theta_coord
T_MP_Z_POSITIONS[T_MP_SECTION_COUNT] = track_phi_coord
T_MP_TWISTS[T_MP_SECTION_COUNT] = track_twist
