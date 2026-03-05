--label:tim2\カスタムフレア.anm\レンズ軌道
--track0:密度,1,100,10
--track1:サイズ％,0,50,15
--track2:強度,0,100,15
--track3:減衰率,0,100,40
--value@fig:形状/fig,"円"
--value@dsize:サイズ幅％,10
--value@dalp:強度幅％,0
--value@basechk:ベースカラー/chk,1
--value@col:色/col,0xccccff
--value@dcol:色幅％,0
--value@rot:回転,0
--value@drot:回転幅,0
--value@blur:ぼかし,0
--value@seed:乱数シード,0
obj.copybuffer("tmp", "obj")
obj.setoption("drawtarget", "tempbuffer")
obj.setoption("blend", CustomFlareMode)
if basechk == 1 then
    col = CustomFlareColor
end
local size = CustomFlareW * obj.track1 * 0.01
local alp = obj.track2 * 0.01
local gen = obj.track3 * 0.01
obj.load("figure", fig, col, size)
obj.effect("ぼかし", "範囲", blur)
local countx = math.floor(CustomFlareW / 600 * obj.track0)
local county = math.floor(CustomFlareH / 600 * obj.track0)
gen = -200 * gen / (CustomFlareW * CustomFlareW)
local st = CustomFlareW / countx
local dw = st * 0.5
for i = 0, countx do
    for j = 0, county do
        if dcol > 0 then
            local h, s, v = HSV(col)
            h = math.floor(h + math.floor(3.6 * obj.rand(0, dcol, i, j + seed))) % 360
            col = HSV(h, s, v)
            obj.load("figure", fig, col, size)
            obj.effect("ぼかし", "範囲", blur)
        end
        local zoom = 1 - obj.rand(0, dsize, i, j + 4000 + seed) * 0.01
        local alpha = alp * obj.rand(100 - dalp, 100, i, j + 6000 + seed) * 0.01
        local ox = i * st - CustomFlareW * 0.5 + obj.rand(-dw, dw, i, j + 1000 + seed)
        local oy = j * st - CustomFlareH * 0.5 + obj.rand(-dw, dw, i, j + 2000 + seed)
        local rr = (ox - CustomFlareXX) * (ox - CustomFlareXX) + (oy - CustomFlareYY) * (oy - CustomFlareYY)
        alpha = alpha * math.exp(gen * rr)
        local rz = rot + obj.rand(-drot, drot, i, j + 7000 + seed)
        obj.draw(ox, oy, 0, zoom, alpha, 0, 0, rz)
    end
end
obj.load("tempbuffer")
obj.setoption("blend", 0)
