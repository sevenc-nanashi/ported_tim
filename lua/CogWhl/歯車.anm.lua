--label:tim2\アニメーション効果
---$track:厚さ
---min=0
---max=1000
---step=0.1
local track_thickness = 100

---$track:幅比補正
---min=-100
---max=100
---step=0.1
local track_width_ratio_adjust = 0

---$track:段差補正
---min=0
---max=500
---step=0.1
local track_adjust = 100

---$track:厚さ補正
---min=0
---max=500
---step=0.1
local track_adjust_2 = 50

---$track:歯数
---min=3
---max=200
---step=1
local N = 20

---$track:内輪半径補正
---min=0
---max=200
---step=0.1
local R_ER = 100

Lou = track_thickness
ds = track_width_ratio_adjust / 100
D_ER = track_adjust
L_ER = track_adjust_2

R1 = obj.h / 2
R2 = R1 * (1 - D_ER * math.pi / N / 200)
R3 = R1 * (1 - 2 * math.pi / N) * R_ER / 100
Lin = Lou * L_ER / 100

if R2 <= R3 then
    R2 = R3
end
if R2 <= 0 then
    R2 = 0
end
if R3 <= 0 then
    R3 = 0
end

obj.setoption("antialias", 1)

zz = Lou / 2
zz3 = Lin / 2
if Lin > Lou then
    zz2 = zz3
else
    zz2 = zz
end

for i = 0, N - 1 do
    sita1 = 2 * i * math.pi / N
    sita2 = (2 * i + 1 + ds) * math.pi / N
    sita3 = (2 * i + 2) * math.pi / N

    x0, y0 = R1 * math.cos(sita1), R1 * math.sin(sita1)
    x1, y1 = R1 * math.cos(sita2), R1 * math.sin(sita2)
    x2, y2 = R3 * math.cos(sita2), R3 * math.sin(sita2)
    x3, y3 = R3 * math.cos(sita1), R3 * math.sin(sita1)
    x4, y4 = R2 * math.cos(sita2), R2 * math.sin(sita2)
    x5, y5 = R2 * math.cos(sita3), R2 * math.sin(sita3)
    x6, y6 = R3 * math.cos(sita3), R3 * math.sin(sita3)
    x7, y7 = R2 * math.cos(sita1), R2 * math.sin(sita1)

    uz, vz = obj.w / 2, obj.h / 2
    u0, v0 = obj.w * (x0 + R1) / (2 * R1), obj.h * (y0 + R1) / (2 * R1)
    u1, v1 = obj.w * (x1 + R1) / (2 * R1), obj.h * (y1 + R1) / (2 * R1)
    u2, v2 = obj.w * (x2 + R1) / (2 * R1), obj.h * (y2 + R1) / (2 * R1)
    u3, v3 = obj.w * (x3 + R1) / (2 * R1), obj.h * (y3 + R1) / (2 * R1)
    u4, v4 = obj.w * (x4 + R1) / (2 * R1), obj.h * (y4 + R1) / (2 * R1)
    u5, v5 = obj.w * (x5 + R1) / (2 * R1), obj.h * (y5 + R1) / (2 * R1)
    u6, v6 = obj.w * (x6 + R1) / (2 * R1), obj.h * (y6 + R1) / (2 * R1)
    u7, v7 = obj.w * (x7 + R1) / (2 * R1), obj.h * (y7 + R1) / (2 * R1)

    -- 車輪外側
    obj.drawpoly(x0, y0, zz, x1, y1, zz, x2, y2, zz, x3, y3, zz, u0, v0, u1, v1, u2, v2, u3, v3)
    obj.drawpoly(x4, y4, zz, x5, y5, zz, x6, y6, zz, x2, y2, zz, u4, v4, u5, v5, u6, v6, u2, v2)
    obj.drawpoly(x0, y0, -zz, x1, y1, -zz, x2, y2, -zz, x3, y3, -zz, u0, v0, u1, v1, u2, v2, u3, v3)
    obj.drawpoly(x4, y4, -zz, x5, y5, -zz, x6, y6, -zz, x2, y2, -zz, u4, v4, u5, v5, u6, v6, u2, v2)

    -- 車輪内側
    obj.drawpoly(x3, y3, zz3, x2, y2, zz3, 0, 0, zz3, 0, 0, zz3, u3, v3, u2, v2, uz, vz, uz, vz)
    obj.drawpoly(x2, y2, zz3, x6, y6, zz3, 0, 0, zz3, 0, 0, zz3, u2, v2, u6, v6, uz, vz, uz, vz)
    obj.drawpoly(x3, y3, -zz3, x2, y2, -zz3, 0, 0, -zz3, 0, 0, -zz3, u3, v3, u2, v2, uz, vz, uz, vz)
    obj.drawpoly(x2, y2, -zz3, x6, y6, -zz3, 0, 0, -zz3, 0, 0, -zz3, u2, v2, u6, v6, uz, vz, uz, vz)

    -- 車輪外側面
    obj.drawpoly(x7, y7, zz, x0, y0, zz, x0, y0, -zz, x7, y7, -zz, u7, v7, u0, v0, u0, v0, u7, v7)
    obj.drawpoly(x0, y0, zz, x1, y1, zz, x1, y1, -zz, x0, y0, -zz, u0, v0, u1, v1, u1, v1, u0, v0)
    obj.drawpoly(x1, y1, zz, x4, y4, zz, x4, y4, -zz, x1, y1, -zz, u1, v1, u4, v4, u4, v4, u1, v1)
    obj.drawpoly(x4, y4, zz, x5, y5, zz, x5, y5, -zz, x4, y4, -zz, u4, v4, u5, v5, u5, v5, u4, v4)

    -- 車輪内側面
    obj.drawpoly(x2, y2, zz2, x3, y3, zz2, x3, y3, -zz2, x2, y2, -zz2, u2, v2, u3, v3, u3, v3, u2, v2)
    obj.drawpoly(x6, y6, zz2, x2, y2, zz2, x2, y2, -zz2, x6, y6, -zz2, u6, v6, u2, v2, u2, v2, u6, v6)
end
