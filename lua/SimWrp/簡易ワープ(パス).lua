--label:tim2\簡易ワープ.anm
---$track:基準X
---min=-10000
---max=10000
---step=0.1
local rename_me_track0 = 0

---$track:基準Y
---min=-10000
---max=10000
---step=0.1
local rename_me_track1 = 0

---$track:移動X
---min=-10000
---max=10000
---step=0.1
local rename_me_track2 = 100

---$track:移動Y
---min=-10000
---max=10000
---step=0.1
local rename_me_track3 = 100

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

X0[N] = rename_me_track0
Y0[N] = rename_me_track1
X1[N] = rename_me_track2
Y1[N] = rename_me_track3
if POS == 1 then
    X1[N] = X1[N] + X0[N]
    Y1[N] = Y1[N] + Y0[N]
end
AT[N] = ATp
DF[N] = DFp
