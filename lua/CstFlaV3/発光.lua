--label:tim2\カスタムフレア.anm\発光
--track0:大きさ,1,5000,80
--track1:ぼかし％,1,1000,10
--track2:強度,0,100,30
--track3:中心強度,0,100,100
--value@basechk:ベースカラー/chk,1
--value@col:色/col,0xccccff
--value@t:位置％,-100
--value@OFSET:位置オフセット％,{0,0,0}
--value@hs:発光中心サイズ％,80
--value@aubg:自動拡大/chk,0
--value@Rmax:基準距離,400
obj.copybuffer("tmp", "obj")
obj.setoption("drawtarget", "tempbuffer")
obj.setoption("blend", CustomFlareMode)
if basechk == 1 then
    col = CustomFlareColor
end
local size = obj.track0
local alp = obj.track2 * 0.01
hs = hs * 0.01
if aubg == 1 then
    size = size
        * (
            1
            - math.sqrt(
                    CustomFlaredX * CustomFlaredX + CustomFlaredY * CustomFlaredY + CustomFlaredZ * CustomFlaredZ
                )
                / Rmax
        )
    if size < 0 then
        size = 0
    end
end
local blur = size * obj.track1 * 0.01
local dx = (t + OFSET[1]) * 0.01 * CustomFlaredX + CustomFlareCX
local dy = (t + OFSET[2]) * 0.01 * CustomFlaredY + CustomFlareCY
local dz = (t + OFSET[3]) * 0.01 * CustomFlaredZ + CustomFlareCZ
obj.load("figure", "円", col, size)
obj.effect("ぼかし", "範囲", blur)
obj.draw(dx, dy, dz, 1, alp)
obj.load("figure", "円", 0xffffff, size * hs)
obj.effect("ぼかし", "範囲", blur * hs)
obj.draw(dx, dy, dz, 1, alp * obj.track3 * 0.01)
obj.load("tempbuffer")
obj.setoption("blend", 0)
