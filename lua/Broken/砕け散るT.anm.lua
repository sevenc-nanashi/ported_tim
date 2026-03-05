--label:tim2
---$track:粉砕度
---min=0
---max=5000
---step=0.1
local track_shatter_amount = 100

---$track:時間差
---min=0
---max=1000
---step=0.1
local track_time_offset = 100

---$track:限界半径
---min=-10000
---max=10000
---step=0.1
local track_radius = 300

---$track:厚さ
---min=0
---max=1000
---step=0.1
local track_thickness = 20

---$value:破片サイズ
local size = 50

---$value:ランダム形状
local Rk = 100

---$value:中心X
local ax = 0

---$value:中心Y
local ay = 0

---$value:中心Z
local az = 0

---$value:速度
local speed = 100

---$value:重力
local grav = 100

---$value:距離影響
local impact = 100

---$value:ランダム回転
local spin = 100

---$value:ランダム方向
local diff = 100

---$value:再生速度
local step = 1.0

local hxx = {}
local hyy = {}
local px = {}
local py = {}
local pz = {}
local qx = {}
local qy = {}
local qz = {}
local pu = {}
local pv = {}
local han = {}
local tt = {}

tm = step * track_shatter_amount / 1000
delay = track_time_offset
Rm = track_radius
dti = track_thickness
obj.effect()
grav = grav * 6
delay = delay * 0.002
impact = impact * 0.2
spin = math.floor(spin * 10)
diff = diff / 80
if size < 10 then
    size = 10
end
Rk = math.abs(Rk)
if Rk >= 100 then
    Rk = 100
end
xl = obj.w
yl = obj.h
sp = speed * 0.01 * math.sqrt(impact)
w = math.floor(xl / size)
h = math.floor(yl / size)
l = math.sqrt(xl * xl + yl * yl)
if w < 2 then
    w = 2
elseif w > xl then
    w = xl
end
if h < 2 then
    h = 2
elseif h > yl then
    h = yl
end
pw = xl / w * 0.43 * Rk / 100
ph = yl / h * 0.43 * Rk / 100

for y = 0, h do
    for x = 0, w do
        hxx[(w + 1) * y + x] = xl * x / w + obj.rand(-pw, pw, x, y)
        hyy[(w + 1) * y + x] = yl * y / h + obj.rand(-ph, ph, x, y + 1000)
    end
end
for y = 0, h do
    hxx[(w + 1) * y] = 0
    hxx[(w + 1) * y + w] = xl
end
for x = 0, w do
    hyy[x] = 0
    hyy[(w + 1) * h + x] = yl
end

for y = 0, h - 1 do
    idy = yl * (y + 0.5) / h - ay - yl / 2
    for x = 0, w - 1 do
        n0 = (w + 1) * y + x
        n1 = (w + 1) * (y + 1) + x

        gx = (hxx[n0] + hxx[n0 + 1] + hxx[n1 + 1] + hxx[n1]) / 4
        gy = (hyy[n0] + hyy[n0 + 1] + hyy[n1 + 1] + hyy[n1]) / 4

        cx = gx - xl / 2
        cy = gy - yl / 2

        vx = cx - ax
        vy = cy - ay
        vz = -az
        v = math.sqrt(vx * vx + vy * vy + vz * vz)

        tt[(w + 1) * y + x] = tm - v / l * delay

        rr = math.sqrt((xl * (x + 0.5) / w - ax - xl / 2) ^ 2 + idy * idy + az * az)
        han[(w + 1) * y + x] = 0
        if (Rm >= 0 and rr >= Rm + size) or (Rm < 0 and rr < -Rm - size) then
            han[(w + 1) * y + x] = 2
        elseif (Rm >= 0 and rr >= Rm) or (Rm < 0 and rr < -Rm) then
            han[(w + 1) * y + x] = 1
        end
    end
end

for y = 0, h - 1 do
    for x = 0, w - 1 do
        hh = han[(w + 1) * y + x]
        n0 = (w + 1) * y + x
        n1 = (w + 1) * (y + 1) + x
        pu[0] = hxx[n0]
        pu[1] = hxx[n0 + 1]
        pu[2] = hxx[n1 + 1]
        pu[3] = hxx[n1]
        pv[0] = hyy[n0]
        pv[1] = hyy[n0 + 1]
        pv[2] = hyy[n1 + 1]
        pv[3] = hyy[n1]
        -- 基準の計算
        gx = (pu[0] + pu[1] + pu[2] + pu[3]) / 4
        gy = (pv[0] + pv[1] + pv[2] + pv[3]) / 4

        cx = gx - xl / 2
        cy = gy - yl / 2

        vx = cx - ax
        vy = cy - ay
        vz = -az
        v = math.sqrt(vx * vx + vy * vy + vz * vz)

        t = tt[(w + 1) * y + x]

        if (t < 0) or hh ~= 0 then
            t = 0
            obj.setoption("antialias", 0)
        else
            obj.setoption("antialias", 1)
        end

        v = 1 / (1 + v * v / (l * l) * impact)
        vx = vx * v + obj.rand(-size, size, x, y + 4000) * diff
        vy = vy * v + obj.rand(-size, size, x, y + 5000) * diff
        vz = vz * v + obj.rand(-size, size, x, y + 6000) * diff
        cx = cx + t * vx * sp
        cy = cy + t * vy * sp + t * t * grav
        cz = t * vz * sp

        -- 回転を計算
        xx = t * obj.rand(-spin, spin, x, y + 2000) / 100
        yy = t * obj.rand(-spin, spin, x, y + 3000) / 100
        zz = t * obj.rand(-spin, spin, x, y + 4000) / 100
        sin_x = math.sin(xx)
        cos_x = math.cos(xx)
        sin_y = math.sin(yy)
        cos_y = math.cos(yy)
        sin_z = math.sin(zz)
        cos_z = math.cos(zz)
        m00 = cos_y * cos_z
        m01 = -cos_y * sin_z
        m02 = -sin_y
        m10 = cos_x * sin_z - sin_x * sin_y * cos_z
        m11 = cos_x * cos_z + sin_x * sin_y * sin_z
        m12 = -sin_x * cos_y
        m20 = sin_x * sin_z + cos_x * sin_y * cos_z
        m21 = sin_x * cos_z - cos_x * sin_y * sin_z
        m22 = cos_x * cos_y

        for i = 0, 3 do
            xx = pu[i] - gx
            yy = pv[i] - gy
            px[i] = m00 * xx + m01 * yy
            py[i] = m10 * xx + m11 * yy
            pz[i] = m20 * xx + m21 * yy
        end

        for i = 0, 3 do
            px[i] = px[i] + cx
            py[i] = py[i] + cy
            pz[i] = pz[i] + cz
            qx[i] = px[i] + m02 * dti
            qy[i] = py[i] + m12 * dti
            qz[i] = pz[i] + m22 * dti
        end
        obj.drawpoly(
            px[0],
            py[0],
            pz[0],
            px[1],
            py[1],
            pz[1],
            px[2],
            py[2],
            pz[2],
            px[3],
            py[3],
            pz[3],
            pu[0],
            pv[0],
            pu[1],
            pv[1],
            pu[2],
            pv[2],
            pu[3],
            pv[3]
        )
        obj.drawpoly(
            qx[0],
            qy[0],
            qz[0],
            qx[1],
            qy[1],
            qz[1],
            qx[2],
            qy[2],
            qz[2],
            qx[3],
            qy[3],
            qz[3],
            pu[0],
            pv[0],
            pu[1],
            pv[1],
            pu[2],
            pv[2],
            pu[3],
            pv[3]
        )
        if hh == 0 and t > 0 then
            obj.drawpoly(
                px[0],
                py[0],
                pz[0],
                px[1],
                py[1],
                pz[1],
                qx[1],
                qy[1],
                qz[1],
                qx[0],
                qy[0],
                qz[0],
                pu[0],
                pv[0],
                pu[1],
                pv[1],
                pu[1],
                pv[1],
                pu[0],
                pv[0]
            )
            obj.drawpoly(
                px[1],
                py[1],
                pz[1],
                px[2],
                py[2],
                pz[2],
                qx[2],
                qy[2],
                qz[2],
                qx[1],
                qy[1],
                qz[1],
                pu[1],
                pv[1],
                pu[2],
                pv[2],
                pu[2],
                pv[2],
                pu[1],
                pv[1]
            )
            obj.drawpoly(
                px[2],
                py[2],
                pz[2],
                px[3],
                py[3],
                pz[3],
                qx[3],
                qy[3],
                qz[3],
                qx[2],
                qy[2],
                qz[2],
                pu[2],
                pv[2],
                pu[3],
                pv[3],
                pu[3],
                pv[3],
                pu[2],
                pv[2]
            )
            obj.drawpoly(
                px[3],
                py[3],
                pz[3],
                px[0],
                py[0],
                pz[0],
                qx[0],
                qy[0],
                qz[0],
                qx[3],
                qy[3],
                qz[3],
                pu[3],
                pv[3],
                pu[0],
                pv[0],
                pu[0],
                pv[0],
                pu[3],
                pv[3]
            )
        elseif hh == 1 then
            if y == 0 or (han[(w + 1) * (y - 1) + x] == 0 and tt[(w + 1) * (y - 1) + x] > 0) then
                obj.drawpoly(
                    px[0],
                    py[0],
                    pz[0],
                    px[1],
                    py[1],
                    pz[1],
                    qx[1],
                    qy[1],
                    qz[1],
                    qx[0],
                    qy[0],
                    qz[0],
                    pu[0],
                    pv[0],
                    pu[1],
                    pv[1],
                    pu[1],
                    pv[1],
                    pu[0],
                    pv[0]
                )
            end
            if x == w - 1 or (han[(w + 1) * y + x + 1] == 0 and tt[(w + 1) * y + x + 1] > 0) then
                obj.drawpoly(
                    px[1],
                    py[1],
                    pz[1],
                    px[2],
                    py[2],
                    pz[2],
                    qx[2],
                    qy[2],
                    qz[2],
                    qx[1],
                    qy[1],
                    qz[1],
                    pu[1],
                    pv[1],
                    pu[2],
                    pv[2],
                    pu[2],
                    pv[2],
                    pu[1],
                    pv[1]
                )
            end
            if y == h - 1 or (han[(w + 1) * (y + 1) + x] == 0 and tt[(w + 1) * (y + 1) + x] > 0) then
                obj.drawpoly(
                    px[2],
                    py[2],
                    pz[2],
                    px[3],
                    py[3],
                    pz[3],
                    qx[3],
                    qy[3],
                    qz[3],
                    qx[2],
                    qy[2],
                    qz[2],
                    pu[2],
                    pv[2],
                    pu[3],
                    pv[3],
                    pu[3],
                    pv[3],
                    pu[2],
                    pv[2]
                )
            end
            if x == 0 or (han[(w + 1) * y + x - 1] == 0 and tt[(w + 1) * y + x - 1] > 0) then
                obj.drawpoly(
                    px[3],
                    py[3],
                    pz[3],
                    px[0],
                    py[0],
                    pz[0],
                    qx[0],
                    qy[0],
                    qz[0],
                    qx[3],
                    qy[3],
                    qz[3],
                    pu[3],
                    pv[3],
                    pu[0],
                    pv[0],
                    pu[0],
                    pv[0],
                    pu[3],
                    pv[3]
                )
            end
        elseif (Rm >= 0 and hh == 2) or (Rm < 0 and hh == 0 and t == 0) then
            if x == 0 then
                obj.drawpoly(
                    px[3],
                    py[3],
                    pz[3],
                    px[0],
                    py[0],
                    pz[0],
                    qx[0],
                    qy[0],
                    qz[0],
                    qx[3],
                    qy[3],
                    qz[3],
                    pu[3],
                    pv[3],
                    pu[0],
                    pv[0],
                    pu[0],
                    pv[0],
                    pu[3],
                    pv[3]
                )
            elseif x == w - 1 then
                obj.drawpoly(
                    px[1],
                    py[1],
                    pz[1],
                    px[2],
                    py[2],
                    pz[2],
                    qx[2],
                    qy[2],
                    qz[2],
                    qx[1],
                    qy[1],
                    qz[1],
                    pu[1],
                    pv[1],
                    pu[2],
                    pv[2],
                    pu[2],
                    pv[2],
                    pu[1],
                    pv[1]
                )
            end
            if y == 0 then
                obj.drawpoly(
                    px[0],
                    py[0],
                    pz[0],
                    px[1],
                    py[1],
                    pz[1],
                    qx[1],
                    qy[1],
                    qz[1],
                    qx[0],
                    qy[0],
                    qz[0],
                    pu[0],
                    pv[0],
                    pu[1],
                    pv[1],
                    pu[1],
                    pv[1],
                    pu[0],
                    pv[0]
                )
            elseif y == h - 1 then
                obj.drawpoly(
                    px[2],
                    py[2],
                    pz[2],
                    px[3],
                    py[3],
                    pz[3],
                    qx[3],
                    qy[3],
                    qz[3],
                    qx[2],
                    qy[2],
                    qz[2],
                    pu[2],
                    pv[2],
                    pu[3],
                    pv[3],
                    pu[3],
                    pv[3],
                    pu[2],
                    pv[2]
                )
            end
        end
    end
end
