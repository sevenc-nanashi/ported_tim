--label:${ROOT_CATEGORY}\アニメーション効果
local thickness, tooth_width_offset, step_adjustment, inner_thickness_percent, outer_radius, tooth_base_radius, inner_radius, inner_thickness, outer_half_thickness, inner_half_thickness, side_half_thickness, start_angle, tooth_angle, end_angle, y0, x0, y1, x1, y2, x2, y3, x3, y4, x4, y5, x5, y6, x6, y7, x7, center_v, center_u, v0, u0, v1, u1, v2, u2, v3, u3, v4, u4, v5, u5, v6, u6, v7, u7
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
local track_tooth_count = 20

---$track:内輪半径補正
---min=0
---max=200
---step=0.1
local track_inner_radius_adjust = 100

thickness = track_thickness
tooth_width_offset = track_width_ratio_adjust / 100
step_adjustment = track_adjust
inner_thickness_percent = track_adjust_2

outer_radius = obj.h / 2
tooth_base_radius = outer_radius * (1 - step_adjustment * math.pi / track_tooth_count / 200)
inner_radius = outer_radius * (1 - 2 * math.pi / track_tooth_count) * track_inner_radius_adjust / 100
inner_thickness = thickness * inner_thickness_percent / 100

if tooth_base_radius <= inner_radius then
    tooth_base_radius = inner_radius
end
if tooth_base_radius <= 0 then
    tooth_base_radius = 0
end
if inner_radius <= 0 then
    inner_radius = 0
end

obj.setoption("antialias", 1)

outer_half_thickness = thickness / 2
inner_half_thickness = inner_thickness / 2
if inner_thickness > thickness then
    side_half_thickness = inner_half_thickness
else
    side_half_thickness = outer_half_thickness
end

for i = 0, track_tooth_count - 1 do
    start_angle = 2 * i * math.pi / track_tooth_count
    tooth_angle = (2 * i + 1 + tooth_width_offset) * math.pi / track_tooth_count
    end_angle = (2 * i + 2) * math.pi / track_tooth_count

    x0, y0 = outer_radius * math.cos(start_angle), outer_radius * math.sin(start_angle)
    x1, y1 = outer_radius * math.cos(tooth_angle), outer_radius * math.sin(tooth_angle)
    x2, y2 = inner_radius * math.cos(tooth_angle), inner_radius * math.sin(tooth_angle)
    x3, y3 = inner_radius * math.cos(start_angle), inner_radius * math.sin(start_angle)
    x4, y4 = tooth_base_radius * math.cos(tooth_angle), tooth_base_radius * math.sin(tooth_angle)
    x5, y5 = tooth_base_radius * math.cos(end_angle), tooth_base_radius * math.sin(end_angle)
    x6, y6 = inner_radius * math.cos(end_angle), inner_radius * math.sin(end_angle)
    x7, y7 = tooth_base_radius * math.cos(start_angle), tooth_base_radius * math.sin(start_angle)

    center_u, center_v = obj.w / 2, obj.h / 2
    u0, v0 = obj.w * (x0 + outer_radius) / (2 * outer_radius), obj.h * (y0 + outer_radius) / (2 * outer_radius)
    u1, v1 = obj.w * (x1 + outer_radius) / (2 * outer_radius), obj.h * (y1 + outer_radius) / (2 * outer_radius)
    u2, v2 = obj.w * (x2 + outer_radius) / (2 * outer_radius), obj.h * (y2 + outer_radius) / (2 * outer_radius)
    u3, v3 = obj.w * (x3 + outer_radius) / (2 * outer_radius), obj.h * (y3 + outer_radius) / (2 * outer_radius)
    u4, v4 = obj.w * (x4 + outer_radius) / (2 * outer_radius), obj.h * (y4 + outer_radius) / (2 * outer_radius)
    u5, v5 = obj.w * (x5 + outer_radius) / (2 * outer_radius), obj.h * (y5 + outer_radius) / (2 * outer_radius)
    u6, v6 = obj.w * (x6 + outer_radius) / (2 * outer_radius), obj.h * (y6 + outer_radius) / (2 * outer_radius)
    u7, v7 = obj.w * (x7 + outer_radius) / (2 * outer_radius), obj.h * (y7 + outer_radius) / (2 * outer_radius)

    -- 車輪外側
    obj.drawpoly(
        x0,
        y0,
        outer_half_thickness,
        x1,
        y1,
        outer_half_thickness,
        x2,
        y2,
        outer_half_thickness,
        x3,
        y3,
        outer_half_thickness,
        u0,
        v0,
        u1,
        v1,
        u2,
        v2,
        u3,
        v3
    )
    obj.drawpoly(
        x4,
        y4,
        outer_half_thickness,
        x5,
        y5,
        outer_half_thickness,
        x6,
        y6,
        outer_half_thickness,
        x2,
        y2,
        outer_half_thickness,
        u4,
        v4,
        u5,
        v5,
        u6,
        v6,
        u2,
        v2
    )
    obj.drawpoly(
        x0,
        y0,
        -outer_half_thickness,
        x1,
        y1,
        -outer_half_thickness,
        x2,
        y2,
        -outer_half_thickness,
        x3,
        y3,
        -outer_half_thickness,
        u0,
        v0,
        u1,
        v1,
        u2,
        v2,
        u3,
        v3
    )
    obj.drawpoly(
        x4,
        y4,
        -outer_half_thickness,
        x5,
        y5,
        -outer_half_thickness,
        x6,
        y6,
        -outer_half_thickness,
        x2,
        y2,
        -outer_half_thickness,
        u4,
        v4,
        u5,
        v5,
        u6,
        v6,
        u2,
        v2
    )

    -- 車輪内側
    obj.drawpoly(
        x3,
        y3,
        inner_half_thickness,
        x2,
        y2,
        inner_half_thickness,
        0,
        0,
        inner_half_thickness,
        0,
        0,
        inner_half_thickness,
        u3,
        v3,
        u2,
        v2,
        center_u,
        center_v,
        center_u,
        center_v
    )
    obj.drawpoly(
        x2,
        y2,
        inner_half_thickness,
        x6,
        y6,
        inner_half_thickness,
        0,
        0,
        inner_half_thickness,
        0,
        0,
        inner_half_thickness,
        u2,
        v2,
        u6,
        v6,
        center_u,
        center_v,
        center_u,
        center_v
    )
    obj.drawpoly(
        x3,
        y3,
        -inner_half_thickness,
        x2,
        y2,
        -inner_half_thickness,
        0,
        0,
        -inner_half_thickness,
        0,
        0,
        -inner_half_thickness,
        u3,
        v3,
        u2,
        v2,
        center_u,
        center_v,
        center_u,
        center_v
    )
    obj.drawpoly(
        x2,
        y2,
        -inner_half_thickness,
        x6,
        y6,
        -inner_half_thickness,
        0,
        0,
        -inner_half_thickness,
        0,
        0,
        -inner_half_thickness,
        u2,
        v2,
        u6,
        v6,
        center_u,
        center_v,
        center_u,
        center_v
    )

    -- 車輪外側面
    obj.drawpoly(
        x7,
        y7,
        outer_half_thickness,
        x0,
        y0,
        outer_half_thickness,
        x0,
        y0,
        -outer_half_thickness,
        x7,
        y7,
        -outer_half_thickness,
        u7,
        v7,
        u0,
        v0,
        u0,
        v0,
        u7,
        v7
    )
    obj.drawpoly(
        x0,
        y0,
        outer_half_thickness,
        x1,
        y1,
        outer_half_thickness,
        x1,
        y1,
        -outer_half_thickness,
        x0,
        y0,
        -outer_half_thickness,
        u0,
        v0,
        u1,
        v1,
        u1,
        v1,
        u0,
        v0
    )
    obj.drawpoly(
        x1,
        y1,
        outer_half_thickness,
        x4,
        y4,
        outer_half_thickness,
        x4,
        y4,
        -outer_half_thickness,
        x1,
        y1,
        -outer_half_thickness,
        u1,
        v1,
        u4,
        v4,
        u4,
        v4,
        u1,
        v1
    )
    obj.drawpoly(
        x4,
        y4,
        outer_half_thickness,
        x5,
        y5,
        outer_half_thickness,
        x5,
        y5,
        -outer_half_thickness,
        x4,
        y4,
        -outer_half_thickness,
        u4,
        v4,
        u5,
        v5,
        u5,
        v5,
        u4,
        v4
    )

    -- 車輪内側面
    obj.drawpoly(
        x2,
        y2,
        side_half_thickness,
        x3,
        y3,
        side_half_thickness,
        x3,
        y3,
        -side_half_thickness,
        x2,
        y2,
        -side_half_thickness,
        u2,
        v2,
        u3,
        v3,
        u3,
        v3,
        u2,
        v2
    )
    obj.drawpoly(
        x6,
        y6,
        side_half_thickness,
        x2,
        y2,
        side_half_thickness,
        x2,
        y2,
        -side_half_thickness,
        x6,
        y6,
        -side_half_thickness,
        u6,
        v6,
        u2,
        v2,
        u2,
        v2,
        u6,
        v6
    )
end
