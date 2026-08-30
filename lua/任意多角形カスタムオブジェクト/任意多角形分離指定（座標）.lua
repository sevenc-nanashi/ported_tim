--label:${ROOT_CATEGORY}\カスタムオブジェクト\@任意多角形
---$track:ガイドサイズ
---min=0
---max=1000
---step=0.1
local track_guide_size = 50

---$color:ガイド色
local guide_color = 0xff0000

---$figure:図形
local guide_figure = "円"

obj.load("figure", guide_figure, guide_color, track_guide_size)
T_POLYGON_SPLIT_COUNT = obj.getoption("section_num") + 1
T_POLYGON_SPLIT_POSITIONS = {}
for i = 1, T_POLYGON_SPLIT_COUNT - 1 do
    T_POLYGON_SPLIT_POSITIONS[i] = {}
    T_POLYGON_SPLIT_POSITIONS[i].x = obj.getvalue("x", 0, i - 1)
    T_POLYGON_SPLIT_POSITIONS[i].y = obj.getvalue("y", 0, i - 1)
end
T_POLYGON_SPLIT_POSITIONS[T_POLYGON_SPLIT_COUNT] = {}
T_POLYGON_SPLIT_POSITIONS[T_POLYGON_SPLIT_COUNT].x = obj.getvalue("x", 0, -1)
T_POLYGON_SPLIT_POSITIONS[T_POLYGON_SPLIT_COUNT].y = obj.getvalue("y", 0, -1)
T_POLYGON_SPLIT_POSITIONS[0] = {}
T_POLYGON_SPLIT_POSITIONS[0] = T_POLYGON_SPLIT_POSITIONS[T_POLYGON_SPLIT_COUNT]
T_POLYGON_SPLIT_POSITIONS[T_POLYGON_SPLIT_COUNT + 1] = {}
T_POLYGON_SPLIT_POSITIONS[T_POLYGON_SPLIT_COUNT + 1] = T_POLYGON_SPLIT_POSITIONS[1]

for i = 1, T_POLYGON_SPLIT_COUNT do
    obj.draw(T_POLYGON_SPLIT_POSITIONS[i].x - obj.getvalue("x"), T_POLYGON_SPLIT_POSITIONS[i].y - obj.getvalue("y"))
end
