--label:${ROOT_CATEGORY}\配置\@モーションパスA
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

T_MP_SECTION_COUNT = T_MP_SECTION_COUNT + 1
T_MP_X_POSITIONS[T_MP_SECTION_COUNT] = track_x_coord
T_MP_Y_POSITIONS[T_MP_SECTION_COUNT] = track_y_coord
T_MP_Z_POSITIONS[T_MP_SECTION_COUNT] = track_z_coord
T_MP_TWISTS[T_MP_SECTION_COUNT] = track_twist
