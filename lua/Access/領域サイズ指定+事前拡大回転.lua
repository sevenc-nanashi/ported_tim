--label:tim2\サイズ修正T.anm\領域サイズ指定+事前拡大回転
--track0:幅,0,5000,300
--track1:高さ,0,5000,300
--track2:回転角,-3600,3600,0
--track3:拡大率,0,5000,100

obj.setoption("drawtarget", "tempbuffer", obj.track0, obj.track1)
obj.draw(0, 0, 0, obj.track3 * 0.01, 1, 0, 0, obj.track2)
obj.load("tempbuffer")
