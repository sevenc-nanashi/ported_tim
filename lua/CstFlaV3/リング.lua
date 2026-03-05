--label:tim2\カスタムフレア.anm\リング
--track0:サイズ,0,5000,200
--track1:幅,0,4000,10
--track2:数,1,100,3,1
--track3:強度,0,100,50
--value@dsize:サイズ幅％,50
--value@biger:順次拡大/chk,0
--value@dalp:強度幅％,5
--value@basechk:ベースカラー/chk,1
--value@col:色/col,0xccccff
--value@dcol:色幅％,5
--value@PP:位置％,{0,5}
--value@OFSET:位置オフセット,{0,0,0}
--value@SIG:散らばり％,{100,25}
--value@blur:ぼかし,10
--value@blink:点滅,0.2
--value@seed:乱数シード,0
obj.copybuffer("tmp", "obj")
obj.setoption("drawtarget", "tempbuffer")
obj.setoption("blend", CustomFlareMode)
if basechk == 1 then
    col = CustomFlareColor
end
local size = obj.track0
local haba = obj.track1
local count = obj.track2
local alp = obj.track3 * 0.01
local t = PP[1]
local dt = PP[2]
local sp = SIG[1] * 0.01
local dsp = SIG[2]
OFSET[1] = OFSET[1] * 0.01
OFSET[2] = OFSET[2] * 0.01
OFSET[3] = OFSET[3] * 0.01
obj.load("figure", "円", col, size, haba)
obj.effect("ぼかし", "範囲", blur)
local OF = math.floor(obj.time * obj.framerate)
for i = 1, count do
    if dcol > 0 then
        local h, s, v = HSV(col)
        h = math.floor(h + 3.6 * obj.rand(0, dcol, i, seed)) % 360
        col = HSV(h, s, v)
        obj.load("figure", "円", col, size, haba)
        obj.effect("ぼかし", "範囲", blur)
    end
    local hi = ((i - 0.5) / count - 0.5) * (1 + obj.rand(-dsp, dsp, i, 1000 + seed) * 0.01)
    hi = t + hi * sp
    local ox = CustomFlaredX * (hi + obj.rand(-dt, dt, i, 2000 + seed) * 0.005 + OFSET[1])
    local oy = CustomFlaredY * (hi + obj.rand(-dt, dt, i, 3000 + seed) * 0.005 + OFSET[2])
    local oz = CustomFlaredZ * (hi + obj.rand(-dt, dt, i, 4000 + seed) * 0.005 + OFSET[3])
    local zoom = CustomFlaredX * CustomFlaredX + CustomFlaredY * CustomFlaredY + CustomFlaredZ * CustomFlaredZ
    if zoom == 0 or biger == 0 then
        zoom = 1
    else
        zoom = math.sqrt(
            (
                (CustomFlaredX + ox) * (CustomFlaredX + ox)
                + (CustomFlaredY + oy) * (CustomFlaredY + oy)
                + (CustomFlaredZ + oz) * (CustomFlaredZ + oz)
            )
                / zoom
                * 0.25
        )
    end
    ox = CustomFlareCX + ox
    oy = CustomFlareCY + oy
    oz = CustomFlareCZ + oz
    zoom = zoom * (1 - obj.rand(0, dsize, i, 5000 + seed) * 0.01)
    local alpha = obj.rand(0, 100, i, OF + seed) / 100 + (1 - blink)
    if alpha > 1 then
        alpha = 1
    end
    alpha = alp * alpha * obj.rand(100 - dalp * 0.5, 100 + dalp * 0.5, i, 6000 + seed) * 0.01
    obj.draw(ox, oy, oz, zoom, alpha)
end
obj.load("tempbuffer")
obj.setoption("blend", 0)
