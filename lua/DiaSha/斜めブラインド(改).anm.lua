--label:tim2
---$track:割合
---min=0
---max=100
---step=0.1
local track_ratio = 30

---$track:幅
---min=5
---max=2000
---step=0.1
local track_width = 100

---$track:角度
---min=-3600
---max=3600
---step=0.1
local track_angle = 60

---$track:基準
---min=-100
---max=100
---step=0.1
local track_base = 0

---$value:時間差[%]
local TS = 0

---$check:透明度反転
local chk = 0

local t = 100 - track_ratio
TS = TS * 0.01
local ATS = math.abs(TS)

if t > 0 then
    t = t * 0.01
    local spw = track_width
    local deg = track_angle
    local rad = math.rad(deg)
    local bas = track_base * 0.005

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
