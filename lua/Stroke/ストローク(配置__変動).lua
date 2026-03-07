--label:tim2\装飾\ストロークT.anm
--track0:誤差X,0,10000,100
--track1:誤差Y,0,10000,100
--track2:誤差ｻｲｽﾞ,0,1000,80
--track3:誤差角度,0,3600,180
--dialog:誤差透明度,local GosaA=50;乱数シード,local seed=0;拡大率変動[%],local zoomt={100,100,100};角度変動,local rott={0,0,0};透明度変動[%],local alpt={0,0,0};

T_strokeTM_GosaX = obj.track0
T_strokeTM_GosaY = obj.track1
T_strokeTM_GosaS = obj.track2
T_strokeTM_GosaR = obj.track3
T_strokeTM_GosaA = GosaA
T_strokeTM_seed = seed
T_strokeTM_zoomt = zoomt
T_strokeTM_rott = rott
T_strokeTM_alpt = alpt
T_strokeTM_rnd = 1

if obj.getoption("script_name", 1, true):sub(-4, -1) ~= obj.getoption("script_name"):sub(-4, -1) then
	T_stroke_f()
	T_strokeTM_ancB = nil
	T_strokeTM_N = nil
end