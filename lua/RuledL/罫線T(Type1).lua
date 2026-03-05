--label:tim2\罫線T.anm\罫線T(Type1)
--track0:サイズ,0,500,100,1
--track1:横数,1,100,4,1
--track2:縦数,1,100,4,1
--track3:縦横比%,-100,100,-38.2
RuledlineT = RuledlineT or {}
RuledlineT.typ = 1
RuledlineT.dw = obj.track0
RuledlineT.nx = math.floor(obj.track1)
RuledlineT.ny = math.floor(obj.track2)
RuledlineT.asp = obj.track3 * 0.01
RuledlineT.LPX = {}
RuledlineT.LPY = {}
RuledlineT.cx = 0
RuledlineT.cy = 0
