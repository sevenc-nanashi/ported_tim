--label:tim2\輪郭追跡.anm\輪郭追跡拡張機能
--track0:破線周期,0,100,5,0.01
--track1:破線間隔,0,100,2.5,0.01
--track2:滑らかさ,0,1000,0,1
--track3:本体透明度,0,100,0
--value@fig:形状/fig,"円"
--value@td:進行方向/chk,0
--value@senp:先端表示/chk,0
--value@senz:先端図形/fig,"三角形"
--value@sens:先端サイズ,50

Trin_ehn = {}
Trin_ehn.ivf = obj.track0 * 0.01
Trin_ehn.ivl = obj.track1 * 0.01
Trin_ehn.sm = math.floor(obj.track2)
Trin_ehn.halp = 1 - obj.track3 * 0.01
Trin_ehn.fig = fig
Trin_ehn.td = td
Trin_ehn.senp = senp
Trin_ehn.senz = senz
Trin_ehn.sens = sens
