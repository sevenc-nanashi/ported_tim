--label:tim2
---$track:粉砕度
---min=0
---max=5000
---step=0.1
local rename_me_track0 = 100

---$track:時間差
---min=0
---max=1000
---step=0.1
local rename_me_track1 = 100

---$track:半径
---min=10
---max=10000
---step=0.1
local rename_me_track2 = 300

---$track:限界距離
---min=0
---max=10000
---step=0.1
local rename_me_track3 = 150

---$value:厚さ
local dti = 20

---$value:破片サイズ
local size = 40

---$value:ランダム形状
local Rk = 100

---$value:中心
local AA = "0,0,0"

---$value:速度
local speed = 100

---$value:距離影響
local impact = 100

---$value:円周方向初速度
local vr = 0

---$value:重力
local grav = "0,100,0"

---$value:ランダム回転
local spin = 100

---$value:ランダム方向
local diff = 100

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

obj.effect()

mpi = math.pi
tm = rename_me_track0 / 1000
delay = rename_me_track1
Rm = rename_me_track3
RRq = rename_me_track2
delay = delay * 0.002
impact = impact * 0.2
spin = math.floor(spin * 10)
diff = diff / 80
size = size * obj.w / (RRq * 2 * mpi)
if size < 10 then
    size = 10
end
Rk = math.abs(Rk * 0.5)
if Rk >= 50 then
    Rk = 50
end
xl = obj.w
yl = obj.h
sp = speed * 0.05
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

n1, n2, gravx, gravy, gravz = string.find(grav, "(.*),(.*),(.*)")
gravx = gravx * 6
gravy = gravy * 6
gravz = gravz * 6
n1, n2, ax, ay, az = string.find(AA, "(.*),(.*),(.*)")

for y = 0, h do
    for x = 0, w do
        hxx[(w + 1) * y + x] = xl * x / w + obj.rand(-pw, pw, x, y)
        hyy[(w + 1) * y + x] = yl * y / h + obj.rand(-ph, ph, x, y + 1000)
    end
end
for y = 0, h do
    hxx[(w + 1) * y] = 0
    hxx[(w + 1) * y + w] = xl
    hyy[(w + 1) * y + w] = hyy[(w + 1) * y]
end
for x = 0, w do
    hyy[x] = 0
    hyy[(w + 1) * h + x] = yl
end

for y = 0, h - 1 do
    idy = size * y - yl / 2
    for x = 0, w - 1 do
        n0 = (w + 1) * y + x
        n1 = (w + 1) * (y + 1) + x

        rr = -RRq * math.sin(mpi * (size * y) / yl) * math.cos(2 * mpi * (size * x) / xl + mpi) + RRq
        ss = math.sqrt((size * x - xl / 2) ^ 2 + idy * idy)
        tt[(w + 1) * y + x] = tm - 2 * ss / l * delay
        han[(w + 1) * y + x] = 0
        if Rm >= 0 and rr >= Rm + size then
            han[(w + 1) * y + x] = 2
        elseif Rm >= 0 and rr >= Rm then
            han[(w + 1) * y + x] = 1
        end
    end
end

for y = 0, h - 1 do
    idy = size * y - yl / 2
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

        for i = 0, 3 do
            px[i] = RRq * math.sin(mpi * pv[i] / yl) * math.sin(2 * mpi * pu[i] / xl + mpi)
            py[i] = -RRq * math.cos(mpi * pv[i] / yl)
            pz[i] = -RRq * math.sin(mpi * pv[i] / yl) * math.cos(2 * mpi * pu[i] / xl + mpi)

            qx[i] = (RRq - dti) * math.sin(mpi * pv[i] / yl) * math.sin(2 * mpi * pu[i] / xl + mpi)
            qy[i] = -(RRq - dti) * math.cos(mpi * pv[i] / yl)
            qz[i] = -(RRq - dti) * math.sin(mpi * pv[i] / yl) * math.cos(2 * mpi * pu[i] / xl + mpi)
        end

        -- 基準の計算
        gx = (px[0] + px[1] + px[2] + px[3] + qx[0] + qx[1] + qx[2] + qx[3]) / 8
        gy = (py[0] + py[1] + py[2] + py[3] + qy[0] + qy[1] + qy[2] + qy[3]) / 8
        gz = (pz[0] + pz[1] + pz[2] + pz[3] + qz[0] + qz[1] + qz[2] + qz[3]) / 8

        vx = gx - ax
        vy = gy - ay
        vz = gz - az

        t = tt[(w + 1) * y + x]

        if (t < 0) or hh ~= 0 then
            t = 0
            obj.setoption("antialias", 0)
        else
            obj.setoption("antialias", 1)
        end

        gg = math.sqrt(gx * gx + gy * gy)
        idx = size * x - xl / 2
        rr = idx * idx + idy * idy
        v = 1 / (1 + 4 * rr / (l * l) * impact)
        vx = vx * v + obj.rand(-size, size, x, y + 4000) * diff + vr * gx / gg
        vy = vy * v + obj.rand(-size, size, x, y + 5000) * diff
        vz = vz * v + obj.rand(-size, size, x, y + 6000) * diff + vr * gy / gg
        cx = gx + t * vx * sp + t * t * gravx
        cy = gy + t * vy * sp + t * t * gravy
        cz = gz + t * vz * sp + t * t * gravz

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
            xx = px[i] - gx
            yy = py[i] - gy
            zz = pz[i] - gz
            px[i] = m00 * xx + m01 * yy + m02 * zz + cx
            py[i] = m10 * xx + m11 * yy + m12 * zz + cy
            pz[i] = m20 * xx + m21 * yy + m22 * zz + cz

            xx = qx[i] - gx
            yy = qy[i] - gy
            zz = qz[i] - gz
            qx[i] = m00 * xx + m01 * yy + m02 * zz + cx
            qy[i] = m10 * xx + m11 * yy + m12 * zz + cy
            qz[i] = m20 * xx + m21 * yy + m22 * zz + cz
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
            if
                (y == 0 and han[(w + 1) * (h - 1) + x] == 0 and tt[(w + 1) * (h - 1) + x] > 0)
                or (han[(w + 1) * (y - 1) + x] == 0 and tt[(w + 1) * (y - 1) + x] > 0)
            then
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
            if
                (x == w - 1 and han[(w + 1) * y] == 0 and tt[(w + 1) * y] > 0)
                or (han[(w + 1) * y + x + 1] == 0 and tt[(w + 1) * y + x + 1] > 0)
            then
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
            if
                (y == h - 1 and han[x] == 0 and tt[x] > 0)
                or (han[(w + 1) * (y + 1) + x] == 0 and tt[(w + 1) * (y + 1) + x] > 0)
            then
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
            if
                (x == 0 and han[(w + 1) * y + w - 1] == 0 and tt[(w + 1) * y + w - 1] > 0)
                or (han[(w + 1) * y + x - 1] == 0 and tt[(w + 1) * y + x - 1] > 0)
            then
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
        end
    end
end
