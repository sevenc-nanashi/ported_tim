--label:${ROOT_CATEGORY}\色調整\@多色グラデーション
local active_color_count, gradient_center_x, gradient_center_y, cen_x, cen_y, gradient_colors, gradient_width, center_offset_x, center_offset_y, haba2
---$track:幅
---min=0
---max=5000
---step=0.1
local track_width = 100

---$track:中心X
---min=-20000
---max=20000
---step=0.1
local track_center_x = 0

---$track:中心Y
---min=-20000
---max=20000
---step=0.1
local track_center_y = 0

---$check:表示
local check_show_guide = 0

---$color:色1
local gradient_color_1 = 0x00ff00

---$color:色2
local gradient_color_2 = 0xffff00

---$color:色3
local gradient_color_3 = 0xff0000

---$color:色4
local gradient_color_4 = 0x0000ff

---$color:色5
local gradient_color_5 = nil

---$color:色6
local gradient_color_6 = nil

---$color:色7
local gradient_color_7 = nil

---$color:色8
local gradient_color_8 = nil

---$track:ガイド半径
---min=0
---max=1000
---step=1
local track_guide_radius = 100

---$color:ガイド色
local guide_color = 0xffffff

--hide@track_width:check_show_guide==1
--hide@track_center_x:check_show_guide==1
--hide@track_center_y:check_show_guide==1
--hide@gradient_color_1:check_show_guide==1
--hide@gradient_color_2:check_show_guide==1
--hide@gradient_color_3:check_show_guide==1
--hide@gradient_color_4:check_show_guide==1
--hide@gradient_color_5:check_show_guide==1
--hide@gradient_color_6:check_show_guide==1
--hide@gradient_color_7:check_show_guide==1
--hide@gradient_color_8:check_show_guide==1
--hide@track_guide_radius:check_show_guide==0
--hide@guide_color:check_show_guide==0

if check_show_guide == 1 then
    obj.load("figure", "円", guide_color, track_guide_radius)
    obj.effect("縁取り")

    active_color_count = obj.getoption("section_num") + 1
    if active_color_count > 8 then
        active_color_count = 8
    end
    for i = 1, active_color_count - 1 do
        gradient_center_x = obj.getvalue("x", 0, i - 1) - obj.getvalue("x")
        gradient_center_y = obj.getvalue("y", 0, i - 1) - obj.getvalue("y")
        obj.drawpoly(
            gradient_center_x - track_guide_radius / 2,
            gradient_center_y - track_guide_radius / 2,
            0,
            gradient_center_x + track_guide_radius / 2,
            gradient_center_y - track_guide_radius / 2,
            0,
            gradient_center_x + track_guide_radius / 2,
            gradient_center_y + track_guide_radius / 2,
            0,
            gradient_center_x - track_guide_radius / 2,
            gradient_center_y + track_guide_radius / 2,
            0,
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
    gradient_center_x = obj.getvalue("x", 0, -1) - obj.getvalue("x")
    gradient_center_y = obj.getvalue("y", 0, -1) - obj.getvalue("y")
    obj.drawpoly(
        gradient_center_x - track_guide_radius / 2,
        gradient_center_y - track_guide_radius / 2,
        0,
        gradient_center_x + track_guide_radius / 2,
        gradient_center_y - track_guide_radius / 2,
        0,
        gradient_center_x + track_guide_radius / 2,
        gradient_center_y + track_guide_radius / 2,
        0,
        gradient_center_x - track_guide_radius / 2,
        gradient_center_y + track_guide_radius / 2,
        0,
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
    obj.setoption("focus_mode", "fixed_size")
    cen_x = {}
    cen_y = {}
    gradient_colors = {
        gradient_color_1,
        gradient_color_2,
        gradient_color_3,
        gradient_color_4,
        gradient_color_5,
        gradient_color_6,
        gradient_color_7,
        gradient_color_8,
    }
    gradient_width = track_width
    center_offset_x = track_center_x
    center_offset_y = track_center_y
    active_color_count = obj.getoption("section_num") + 1
    if active_color_count > 8 then
        active_color_count = 8
    end
    for i = 1, active_color_count - 1 do
        cen_x[i] = obj.getvalue("x", 0, i - 1) + center_offset_x
        cen_y[i] = obj.getvalue("y", 0, i - 1) + center_offset_y
    end
    cen_x[active_color_count] = obj.getvalue("x", 0, -1) + center_offset_x
    cen_y[active_color_count] = obj.getvalue("y", 0, -1) + center_offset_y

    for i = 1, active_color_count do
        if T_GRADIENT_EXTENSION_ACTIVE == 1 then
            cen_x[i] = cen_x[i] + T_GRADIENT_OFFSET_X[i]
            cen_y[i] = cen_y[i] + T_GRADIENT_OFFSET_Y[i]
            haba2 = gradient_width + T_GRADIENT_WIDTH_OFFSETS[i]
        else
            haba2 = gradient_width
        end
        obj.effect(
            "グラデーション",
            "no_color2",
            1,
            "color",
            gradient_colors[i],
            "中心X",
            cen_x[i],
            "中心Y",
            cen_y[i],
            "幅",
            haba2,
            "type",
            1
        )
    end
    obj.ox = obj.ox - obj.getvalue("x") + center_offset_x
    obj.oy = obj.oy - obj.getvalue("y") + center_offset_y
    T_GRADIENT_EXTENSION_ACTIVE = 0
end
