--label:tim2\未分類\モーションパスD.anm
---$track:R座標
---min=0
---max=10000
---step=0.1
local track_r_coord = 100

---$track:θ座標
---min=-1800
---max=1800
---step=0.1
local track_theta_coord = 0

---$track:φ座標
---min=-3600
---max=3600
---step=0.1
local track_phi_coord = 0

---$track:ねじれ
---min=-3600
---max=3600
---step=0.1
local track_twist = 0

---$value:分割数
local BN = 20

---$value:描画方法(0-4)
local CHA = 0

---$value:相対/絶対(0/1)
local TY = 0

---$value:パス描画(0/1)
local APP = 0

---$value:パス描画色1
local PCOL = 0xff0000

---$value:パス描画色2
local QCOL = 0x0000ff

---$value:フォーカス
local foc = 1

---$value:文字サイズ補正
local FS = 0.5

---$value:先頭表示
local TOPA = 0

---$value:内部
local SEC = 0

-- 関数共通

function PassXYZ(s) -- s<=1
    Ns = NN * s
    Ns1 = math.floor(Ns)
    Ns2 = (Ns - Ns1) / 2

    if Ns1 <= 0 then
        nx = Ax[1] * Ns2 * Ns2 + Bx[1] * Ns2 + Cx[1]
        ny = Ay[1] * Ns2 * Ns2 + By[1] * Ns2 + Cy[1]
        nz = Az[1] * Ns2 * Ns2 + Bz[1] * Ns2 + Cz[1]
        nt = At[1] * Ns2 * Ns2 + Bt[1] * Ns2 + Ct[1]
    elseif Ns1 == NN - 1 then
        SS1 = Ns2 + 0.5
        nx = Ax[Ns1] * SS1 * SS1 + Bx[Ns1] * SS1 + Cx[Ns1]
        ny = Ay[Ns1] * SS1 * SS1 + By[Ns1] * SS1 + Cy[Ns1]
        nz = Az[Ns1] * SS1 * SS1 + Bz[Ns1] * SS1 + Cz[Ns1]
        nt = At[Ns1] * SS1 * SS1 + Bt[Ns1] * SS1 + Ct[Ns1]
    elseif s == 1 then
        nx = XX[NN]
        ny = YY[NN]
        nz = ZZ[NN]
        nt = TW[NN]
    else
        SS1 = Ns2 + 0.5
        SS2 = Ns2
        RS = 2 * Ns2
        nx = (Ax[Ns1] * SS1 * SS1 + Bx[Ns1] * SS1 + Cx[Ns1]) * (1 - RS)
            + RS * (Ax[Ns1 + 1] * SS2 * SS2 + Bx[Ns1 + 1] * SS2 + Cx[Ns1 + 1])
        ny = (Ay[Ns1] * SS1 * SS1 + By[Ns1] * SS1 + Cy[Ns1]) * (1 - RS)
            + RS * (Ay[Ns1 + 1] * SS2 * SS2 + By[Ns1 + 1] * SS2 + Cy[Ns1 + 1])
        nz = (Az[Ns1] * SS1 * SS1 + Bz[Ns1] * SS1 + Cz[Ns1]) * (1 - RS)
            + RS * (Az[Ns1 + 1] * SS2 * SS2 + Bz[Ns1 + 1] * SS2 + Cz[Ns1 + 1])
        nt = (At[Ns1] * SS1 * SS1 + Bt[Ns1] * SS1 + Ct[Ns1]) * (1 - RS)
            + RS * (At[Ns1 + 1] * SS2 * SS2 + Bt[Ns1 + 1] * SS2 + Ct[Ns1 + 1])
    end
    return nx, ny, nz, nt
end

function ShiftR(iax, iay, iaz, ir)
    abs = (iax * iax + iay * iay) ^ 0.5
    ibx, iby = iay / abs, -iax / abs
    icx, icy, icz = iax * iaz, iay * iaz, -iax * iax - iay * iay
    abs = (icx * icx + icy * icy + icz * icz) ^ 0.5
    icx, icy, icz = icx / abs, icy / abs, icz / abs
    mc = math.cos(ir / 180 * math.pi)
    ms = math.sin(ir / 180 * math.pi)
    return obj.w * (ibx * mc + icx * ms) / 2, obj.w * (iby * mc + icy * ms) / 2, obj.w * (icz * ms) / 2
end

obj.setoption("antialias", 1)

XX = {}
YY = {}
ZZ = {}
TW = {}

NN = obj.getoption("section_num")

for i = 0, NN - 1 do
    XX[i] = obj.getvalue("track.track_r_coord", 0, i)
    YY[i] = obj.getvalue("track.track_theta_coord", 0, i)
    ZZ[i] = obj.getvalue("track.track_phi_coord", 0, i)
    TW[i] = obj.getvalue("track.track_twist", 0, i)
end

XX[NN] = obj.getvalue("track.track_r_coord", 0, -1)
YY[NN] = obj.getvalue("track.track_theta_coord", 0, -1)
ZZ[NN] = obj.getvalue("track.track_phi_coord", 0, -1)
TW[NN] = obj.getvalue("track.track_twist", 0, -1)

for i = 0, NN do
    s1 = YY[i] * math.pi / 180
    s2 = (ZZ[i] + 90) * math.pi / 180
    XX[i], YY[i], ZZ[i] =
        XX[i] * math.sin(s1) * math.sin(s2), -XX[i] * math.cos(s1), -XX[i] * math.sin(s1) * math.cos(s2)
end

if SEC == 1 and CHA < 3 then
    for i = 0, NN do
        XX[i], YY[i], ZZ[i] = ZZ[i], XX[i], YY[i]
        TW[i] = TW[i] + 90
    end
elseif SEC == 2 and CHA < 3 then
    for i = 0, NN do
        XX[i], ZZ[i] = ZZ[i], XX[i]
        TW[i] = TW[i] + 90
    end
end

-- --------以降共通

obj.effect()

if TY == 0 then
    for i = 1, NN do
        XX[i] = XX[i - 1] + XX[i]
        YY[i] = YY[i - 1] + YY[i]
        ZZ[i] = ZZ[i - 1] + ZZ[i]
    end
end

OFH = (1 + obj.frame) / (1 + obj.totalframe)

Ax = {}
Bx = {}
Cx = {}
Ay = {}
By = {}
Cy = {}
Az = {}
Bz = {}
Cz = {}
At = {}
Bt = {}
Ct = {}

for M = 1, NN - 1 do
    Ax[M] = 2 * XX[M - 1] - 4 * XX[M] + 2 * XX[M + 1]
    Bx[M] = -3 * XX[M - 1] + 4 * XX[M] - XX[M + 1]
    Cx[M] = XX[M - 1]
    Ay[M] = 2 * YY[M - 1] - 4 * YY[M] + 2 * YY[M + 1]
    By[M] = -3 * YY[M - 1] + 4 * YY[M] - YY[M + 1]
    Cy[M] = YY[M - 1]
    Az[M] = 2 * ZZ[M - 1] - 4 * ZZ[M] + 2 * ZZ[M + 1]
    Bz[M] = -3 * ZZ[M - 1] + 4 * ZZ[M] - ZZ[M + 1]
    Cz[M] = ZZ[M - 1]
    At[M] = 2 * TW[M - 1] - 4 * TW[M] + 2 * TW[M + 1]
    Bt[M] = -3 * TW[M - 1] + 4 * TW[M] - TW[M + 1]
    Ct[M] = TW[M - 1]
end

if CHA == 0 then
    Nmax = NN * BN
    Nv = Nmax
    Ama = 0
elseif CHA == 1 then
    Nmax = math.floor(NN * BN * OFH)
    Nv = NN * BN
    Ama = NN * BN * OFH - Nmax
elseif CHA == 2 then
    Nmax = math.floor(NN * BN * OFH)
    Nv = Nmax
    Ama = NN * BN * OFH - Nmax
elseif CHA == 3 then
    Nmax = math.floor(NN * BN * OFH)
else
    Nmax = NN * BN
end

if CHA < 3 then
    if TOPA == 0 then
        xf, yf, zf, tf = PassXYZ(0)
        ix, iy, iz, it = PassXYZ(0.5 / (NN * BN))
        dx, dy, dz = ShiftR(ix - xf, iy - yf, iz - zf, TW[0])
        x1, y1, z1 = xf + dx, yf + dy, zf + dz
        x0, y0, z0 = xf - dx, yf - dy, zf - dz

        for i = 1, Nmax do
            ix, iy, iz, it = PassXYZ(i / (NN * BN))
            dx, dy, dz = ShiftR(ix - xf, iy - yf, iz - zf, it)
            x2, y2, z2 = ix + dx, iy + dy, iz + dz
            x3, y3, z3 = ix - dx, iy - dy, iz - dz
            v1 = obj.h * (1 - i / (Nv + Ama))
            v2 = obj.h * (1 - (i - 1) / (Nv + Ama))

            if SEC == 1 then
                obj.drawpoly(y0, z0, x0, y1, z1, x1, y2, z2, x2, y3, z3, x3, 0, v2, obj.w, v2, obj.w, v1, 0, v1)
            elseif SEC == 2 then
                obj.drawpoly(z0, y0, x0, z1, y1, x1, z2, y2, x2, z3, y3, x3, 0, v2, obj.w, v2, obj.w, v1, 0, v1)
            else
                obj.drawpoly(x0, y0, z0, x1, y1, z1, x2, y2, z2, x3, y3, z3, 0, v2, obj.w, v2, obj.w, v1, 0, v1)
            end
            x0, y0, z0 = x3, y3, z3
            x1, y1, z1 = x2, y2, z2
            xf, yf, zf = ix, iy, iz
        end -- i

        if Ama > 0 then
            ix, iy, iz, it = PassXYZ((Nmax + Ama) / (NN * BN))
            dx, dy, dz = ShiftR(ix - xf, iy - yf, iz - zf, it)
            x2, y2, z2 = ix + dx, iy + dy, iz + dz
            x3, y3, z3 = ix - dx, iy - dy, iz - dz
            v1 = obj.h * (1 - (Nmax + Ama) / (Nv + Ama))
            v2 = obj.h * (1 - Nmax / (Nv + Ama))
            if SEC == 1 then
                obj.drawpoly(y0, z0, x0, y1, z1, x1, y2, z2, x2, y3, z3, x3, 0, v2, obj.w, v2, obj.w, v1, 0, v1)
            elseif SEC == 2 then
                obj.drawpoly(z0, y0, x0, z1, y1, x1, z2, y2, x2, z3, y3, x3, 0, v2, obj.w, v2, obj.w, v1, 0, v1)
            else
                obj.drawpoly(x0, y0, z0, x1, y1, z1, x2, y2, z2, x3, y3, z3, 0, v2, obj.w, v2, obj.w, v1, 0, v1)
            end
        end
    else
        if NN * BN * OFH <= 1 / 2 then
            inm = 1 / 2
        else
            inm = NN * BN * OFH
        end

        if CHA == 0 then
            inm = NN * BN
        end

        xf, yf, zf, tf = PassXYZ((inm - 1 / 2) / (NN * BN))
        ix, iy, iz, it = PassXYZ(inm / (NN * BN))

        dx, dy, dz = ix - xf, iy - yf, iz - zf
        kika = obj.h / (dx * dx + dy * dy + dz * dz) ^ 0.5 / 2
        dx, dy, dz = dx * kika, dy * kika, dz * kika

        xf, yf, zf = ix - dx, iy - dy, iz - dz
        ix, iy, iz = ix + dx, iy + dy, iz + dz
        dx, dy, dz = ShiftR(dx, dy, dz, it)

        x3, y3, z3 = xf - dx, yf - dy, zf - dz
        x2, y2, z2 = xf + dx, yf + dy, zf + dz
        x1, y1, z1 = ix + dx, iy + dy, iz + dz
        x0, y0, z0 = ix - dx, iy - dy, iz - dz
        if SEC == 1 then
            obj.drawpoly(y0, z0, x0, y1, z1, x1, y2, z2, x2, y3, z3, x3, 0, 0, obj.w, 0, obj.w, obj.h, 0, obj.h)
        elseif SEC == 2 then
            obj.drawpoly(z0, y0, x0, z1, y1, x1, z2, y2, x2, z3, y3, x3, 0, 0, obj.w, 0, obj.w, obj.h, 0, obj.h)
        else
            obj.drawpoly(x0, y0, z0, x1, y1, z1, x2, y2, z2, x3, y3, z3, 0, 0, obj.w, 0, obj.w, obj.h, 0, obj.h)
        end
    end
else
    for i = 0, Nmax do
        obj.ox, obj.oy, obj.oz, NL = PassXYZ(i / (NN * BN))
        obj.draw()
    end
end

-- ---------ここから違う

if APP == 1 then
    cw = obj.screen_w / 80
    for i = 0, NN do
        if i == foc - 1 then
            obj.load("figure", "円", QCOL, 100)
        else
            obj.load("figure", "円", PCOL, 100)
        end
        ix, iy, iz, it = PassXYZ(i / NN)

        if SEC == 1 then
            obj.drawpoly(
                iy + cw,
                iz,
                ix + cw,
                iy + cw,
                iz,
                ix - cw,
                iy - cw,
                iz,
                ix - cw,
                iy - cw,
                iz,
                ix + cw,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
            obj.drawpoly(
                iy,
                iz + cw,
                ix + cw,
                iy,
                iz + cw,
                ix - cw,
                iy,
                iz - cw,
                ix - cw,
                iy,
                iz - cw,
                ix + cw,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
            obj.drawpoly(
                iy + cw,
                iz + cw,
                ix,
                iy - cw,
                iz + cw,
                ix,
                iy - cw,
                iz - cw,
                ix,
                iy + cw,
                iz - cw,
                ix,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
        elseif SEC == 2 then
            obj.drawpoly(
                iz,
                iy + cw,
                ix + cw,
                iz,
                iy + cw,
                ix - cw,
                iz,
                iy - cw,
                ix - cw,
                iz,
                iy - cw,
                ix + cw,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
            obj.drawpoly(
                iz + cw,
                iy,
                ix + cw,
                iz + cw,
                iy,
                ix - cw,
                iz - cw,
                iy,
                ix - cw,
                iz - cw,
                iy,
                ix + cw,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
            obj.drawpoly(
                iz + cw,
                iy + cw,
                ix,
                iz + cw,
                iy - cw,
                ix,
                iz - cw,
                iy - cw,
                ix,
                iz - cw,
                iy + cw,
                ix,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
        else
            obj.drawpoly(
                ix + cw,
                iy + cw,
                iz,
                ix - cw,
                iy + cw,
                iz,
                ix - cw,
                iy - cw,
                iz,
                ix + cw,
                iy - cw,
                iz,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
            obj.drawpoly(
                ix + cw,
                iy,
                iz + cw,
                ix - cw,
                iy,
                iz + cw,
                ix - cw,
                iy,
                iz - cw,
                ix + cw,
                iy,
                iz - cw,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
            obj.drawpoly(
                ix,
                iy + cw,
                iz + cw,
                ix,
                iy - cw,
                iz + cw,
                ix,
                iy - cw,
                iz - cw,
                ix,
                iy + cw,
                iz - cw,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
        end
    end -- i

    for i = 1, NN do
        if i == foc then
            obj.load("figure", "四角形", QCOL, 100)
        else
            obj.load("figure", "四角形", PCOL, 100)
        end
        ix0, iy0, iz0, it = PassXYZ((i - 1) / NN)
        ix1, iy1, iz1, it = PassXYZ(i / NN)

        if SEC == 1 then
            obj.drawpoly(
                iy0,
                iz0,
                ix0 + 1,
                iy0,
                iz0,
                ix0 - 1,
                iy1,
                iz1,
                ix1 - 1,
                iy1,
                iz1,
                ix1 + 1,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
            obj.drawpoly(
                iy0 + 1,
                iz0,
                ix0,
                iy0 - 1,
                iz0,
                ix0,
                iy1 - 1,
                iz1,
                ix1,
                iy1 + 1,
                iz1,
                ix1,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
            obj.drawpoly(
                iy0,
                iz0 + 1,
                ix0,
                iy0,
                iz0 - 1,
                ix0,
                iy1,
                iz1 - 1,
                ix1,
                iy1,
                iz1 + 1,
                ix1,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
        elseif SEC == 2 then
            obj.drawpoly(
                iz0,
                iy0,
                ix0 + 1,
                iz0,
                iy0,
                ix0 - 1,
                iz1,
                iy1,
                ix1 - 1,
                iz1,
                iy1,
                ix1 + 1,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
            obj.drawpoly(
                iz0,
                iy0 + 1,
                ix0,
                iz0,
                iy0 - 1,
                ix0,
                iz1,
                iy1 - 1,
                ix1,
                iz1,
                iy1 + 1,
                ix1,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
            obj.drawpoly(
                iz0 + 1,
                iy0,
                ix0,
                iz0 - 1,
                iy0,
                ix0,
                iz1 - 1,
                iy1,
                ix1,
                iz1 + 1,
                iy1,
                ix1,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
        else
            obj.drawpoly(
                ix0 + 1,
                iy0,
                iz0,
                ix0 - 1,
                iy0,
                iz0,
                ix1 - 1,
                iy1,
                iz1,
                ix1 + 1,
                iy1,
                iz1,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
            obj.drawpoly(
                ix0,
                iy0 + 1,
                iz0,
                ix0,
                iy0 - 1,
                iz0,
                ix1,
                iy1 - 1,
                iz1,
                ix1,
                iy1 + 1,
                iz1,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
            obj.drawpoly(
                ix0,
                iy0,
                iz0 + 1,
                ix0,
                iy0,
                iz0 - 1,
                ix1,
                iy1,
                iz1 - 1,
                ix1,
                iy1,
                iz1 + 1,
                0,
                0,
                obj.w,
                0,
                obj.w,
                obj.h,
                0,
                obj.h
            )
        end

        obj.setfont("Georgia", 70 * obj.screen_w / 128 * FS, 1, 0xffffff, 0x000000)
        obj.load("text", i)

        if SEC == 1 then
            obj.ox, obj.oy, obj.oz = (iy1 + iy0) / 2, (iz1 + iz0) / 2, (ix1 + ix0) / 2
        elseif SEC == 2 then
            obj.ox, obj.oy, obj.oz = (iz1 + iz0) / 2, (iy1 + iy0) / 2, (ix1 + ix0) / 2
        else
            obj.ox, obj.oy, obj.oz = (ix1 + ix0) / 2, (iy1 + iy0) / 2, (iz1 + iz0) / 2
        end
        obj.draw()
    end -- i
end
