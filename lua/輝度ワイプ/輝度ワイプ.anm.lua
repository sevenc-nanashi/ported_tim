--label:${ROOT_CATEGORY}\切り替え効果
---$track:ワイプ量
---min=0
---max=100
---step=0.1
local track_wipe_amount = 50

---$track:ぼかし
---min=0
---max=500
---step=0.1
local track_blur = 0

---$track:読込先
---min=0
---max=100
---step=1
---zero_label=自身
local track_load_target = 0

---$check:暗い所から透過
local check_transparent_from_dark = false

local wipe_amount = track_wipe_amount
local blur_amount = track_blur
local load_target = track_load_target
local image_width, image_height = obj.getpixel()

obj.setoption("drawtarget", "tempbuffer", image_width, image_height)
obj.draw()

if load_target > 0 then
    ---$embed
    local extbuffer = require("extbuffer")
    extbuffer.read(load_target)
end

obj.effect("色調補正", "ｺﾝﾄﾗｽﾄ", 100 + wipe_amount, "彩度", 100 - wipe_amount)
obj.effect("単色化", "color", 0xffffff, "輝度を保持する", 1)

if check_transparent_from_dark then
    obj.effect("反転", "輝度反転", 1)
end

if wipe_amount < 50 then
    obj.effect("単色化", "color", 0x000000, "輝度を保持する", 0, "強さ", 100 - 2 * wipe_amount)
else
    obj.effect("単色化", "color", 0xffffff, "輝度を保持する", 0, "強さ", 2 * wipe_amount - 100)
end

-- local userdata, w, h = obj.getpixeldata("object", "bgra")
-- tim2.color_shift_channels(userdata, w, h, 1, 1, 2, 3)
-- obj.putpixeldata("object", userdata, w, h, "bgra")
obj.effect("チャンネルシフト@T_Color_Module@tim.anm2", "アルファ", "赤")

obj.effect("ぼかし", "範囲", blur_amount, "サイズ固定", 1)
obj.setoption("blend", "alpha_sub")
obj.draw()
obj.copybuffer("object", "tempbuffer")
