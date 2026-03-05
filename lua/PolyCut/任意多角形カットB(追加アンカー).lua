--label:tim2\任意多角形カット.anm
---$track:頂点数
---min=1
---max=16
---step=1
local rename_me_track0 = 4

---$value:領域
local are = { -100, -100, 100, -100, 100, 100, -100, 100 }

if han == nil or han == 0 then
    pos = {}
    N = 0
    han = 1
end
NN = rename_me_track0
obj.setanchor("are", NN, "line")
for i = 1, NN do
    pos[N + i] = {}
    pos[N + i].x = are[2 * i - 1]
    pos[N + i].y = are[2 * i]
end
N = N + NN
