--label:tim2\任意多角形カット.anm\任意多角形カットB(追加アンカー)
--track0:頂点数,1,16,4,1
--value@are:領域,{-100,-100,100,-100,100,100,-100,100}

if han == nil or han == 0 then
    pos = {}
    N = 0
    han = 1
end
NN = obj.track0
obj.setanchor("are", NN, "line")
for i = 1, NN do
    pos[N + i] = {}
    pos[N + i].x = are[2 * i - 1]
    pos[N + i].y = are[2 * i]
end
N = N + NN
