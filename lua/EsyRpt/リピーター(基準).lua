--label:tim2\簡易リピーター.anm\リピーター(基準)
--track0:X,-5000,5000,300
--track1:Y,-5000,5000,0
--track2:回転,-3600,3600,0
--track3:拡大%,00,5000,100
obj.setanchor("track", 0, "line")
repeater_dx = obj.getvalue(0)
repeater_dy = obj.getvalue(1)
repeater_dr = obj.track2
repeater_dk = obj.track3 * 0.01
repeater_rep = 0
