--label:tim2
--track0:割合,0,100,30
--track1:幅,5,2000,100
--track2:角度,-3600,3600,60
--track3:基準,-100,100,0
--value@TS:時間差[%],0
--value@chk:透明度反転/chk,0

local t = 100 - obj.track0
TS = TS * 0.01
local ATS = math.abs(TS)

if t > 0 then
    t = t * 0.01
    local spw = obj.track1
    local deg = obj.track2
    local rad = math.rad(deg)
    local bas = obj.track3 * 0.005

    local w, h = obj.getpixel()
    local L = math.sqrt(w * w + h * h)
    local N = math.ceil(L * 0.5 / spw)

    local sin = math.sin(rad)
    local cos = -math.cos(rad)

    for i = -N, N do
        local t0 = t * (2 * N * ATS + 1) - N * ATS
        t0 = t0 - i * TS
        if t0 > 1 then
            t0 = 1
        end

        local haba = math.floor((spw + 1) * t0)

        local sf = i * spw + haba * bas
        if t0 > 0 and haba > 0 then
            obj.effect(
                "斜めクリッピング",
                "中心X",
                sf * sin,
                "中心Y",
                sf * cos,
                "角度",
                deg,
                "ぼかし",
                0,
                "幅",
                -haba
            )
        end
    end
    obj.effect("反転", "透明度反転", chk)
end
