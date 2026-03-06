--label:tim2\変形\簡易ワープ.anm
---$track:基準X
---min=-10000
---max=10000
---step=0.1
local track_base_x = 0

---$track:基準Y
---min=-10000
---max=10000
---step=0.1
local track_base_y = 0

---$track:移動X
---min=-10000
---max=10000
---step=0.1
local track_move_x = 100

---$track:移動Y
---min=-10000
---max=10000
---step=0.1
local track_move_y = 100

---$value:影響範囲
local ATp = 200

---$value:被影響範囲
local DFp = 200

---$check:絶対/相対
local POS = 1

if N then
    N = N + 1
else
    N = 1
    X0 = {}
    Y0 = {}
    X1 = {}
    Y1 = {}
    AT = {}
    DF = {}
end

X0[N] = track_base_x
Y0[N] = track_base_y
X1[N] = track_move_x
Y1[N] = track_move_y
if POS == 1 then
    X1[N] = X1[N] + X0[N]
    Y1[N] = Y1[N] + Y0[N]
end
AT[N] = ATp
DF[N] = DFp
