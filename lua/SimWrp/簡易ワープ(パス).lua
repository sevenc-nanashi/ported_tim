--label:tim2\簡易ワープ.anm\簡易ワープ(パス)
--track0:基準X,-10000,10000,0
--track1:基準Y,-10000,10000,0
--track2:移動X,-10000,10000,100
--track3:移動Y,-10000,10000,100
--value@ATp:影響範囲,200
--value@DFp:被影響範囲,200
--value@POS:絶対/相対/chk,1

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

X0[N] = obj.track0
Y0[N] = obj.track1
X1[N] = obj.track2
Y1[N] = obj.track3
if POS == 1 then
    X1[N] = X1[N] + X0[N]
    Y1[N] = Y1[N] + Y0[N]
end
AT[N] = ATp
DF[N] = DFp
