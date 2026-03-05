--label:tim2\任意多角形.obj\任意多角形分離指定（座標)
--track0:ｶﾞｲﾄﾞｻｲｽﾞ,0,1000,50
--value@colG:ガイド色/col,0xff0000
--value@fig:図形/fig,"円"

obj.load("figure", fig, colG, obj.track0)
NTBS_N = obj.getoption("section_num") + 1
NTBS_pos = {}
for i = 1, NTBS_N - 1 do
    NTBS_pos[i] = {}
    NTBS_pos[i].x = obj.getvalue("x", 0, i - 1)
    NTBS_pos[i].y = obj.getvalue("y", 0, i - 1)
end
NTBS_pos[NTBS_N] = {}
NTBS_pos[NTBS_N].x = obj.getvalue("x", 0, -1)
NTBS_pos[NTBS_N].y = obj.getvalue("y", 0, -1)
NTBS_pos[0] = {}
NTBS_pos[0] = NTBS_pos[NTBS_N]
NTBS_pos[NTBS_N + 1] = {}
NTBS_pos[NTBS_N + 1] = NTBS_pos[1]

for i = 1, NTBS_N do
    obj.draw(NTBS_pos[i].x - obj.getvalue("x"), NTBS_pos[i].y - obj.getvalue("y"))
end
