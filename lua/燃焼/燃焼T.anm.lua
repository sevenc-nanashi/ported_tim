--label:${ROOT_CATEGORY}\アニメーション効果

--NOTE: AviUtl2の内部フォーマットの変更（YUY2 -> RGBA(f16)）に伴い、処理の再現が困難なため、
--ある程度パラメーターを変えています。まぁまぁそれっぽくはなっているはず...

--filter

---$track:展開
---min=0
---max=100
---step=0.1
local track_unfold = 50

---$track:強度
---min=0
---max=200
---step=0.1
local track_intensity = 100

---$track:しきい値
---min=0
---max=200
---step=0.1
local track_threshold = 100

---$track:周期/燃幅
---min=10
---max=200
---step=0.1
local track_period_width = 100

---$color:燃焼色1
local burn_color_1 = 0xff4747

---$color:燃焼色2
local burn_color_2 = 0xffce5b

---$check:画像表示
local track_source_opacity = 1

---$check:炎表示
local track_flame_opacity = 1

---$track:シード
---min=0
---max=1000000
---step=1
local track_seed = 0

---$select:合成モード
---通常=0
---加算=1
---減算=2
---乗算=3
---スクリーン=4
---オーバーレイ=5
---比較(明)=6
---比較(暗)=7
---輝度=8
---陰影=9
local select_blend_mode = 1

---$track:レイヤー指定
---min=0
---max=1000
---step=1
---zero_label=なし
local track_layer_index = 0

---$check:エフェクト取得
local check_include_effects = 1

---$check:一時保存EXT
local check_use_temp_save_extension = 0

---$check:展開を調整
local check_adjust_unfold = false

--hide@check_include_effects:track_layer_index==0
--hide@check_include_effects:check_use_temp_save_extension==1
--hide@check_use_temp_save_extension:track_layer_index==0

--[[pixelshader@saturate_brightness
---$include "./shaders/saturate_brightness.hlsl"
]]
--[[pixelshader@extended_contrast
---$include "./shaders/extended_contrast.hlsl"
]]
--[[pixelshader@tritone
---$include "./shaders/tritone.hlsl"
]]
--[[pixelshader@shift_and_reverse_channels
---$include "./shaders/shift_and_reverse_channels.hlsl"
]]

if track_source_opacity == 1 or track_flame_opacity == 1 then
    local contrast_offset = (track_unfold * 0.02 - 1) * 128
    local noise_period_scale = track_period_width * 0.01
    local glow_strength, edge_threshold_scale

    local random_seed = track_seed or 0
    local map_layer_index = track_layer_index or 0
    local blend_mode = select_blend_mode or 1

    if check_adjust_unfold then
        glow_strength = 60
        if noise_period_scale < 1 then
            glow_strength = 60 / noise_period_scale
        end
        edge_threshold_scale = 30 * noise_period_scale + 30
        glow_strength = (glow_strength + 2 * track_intensity - 200) * 0.01
        edge_threshold_scale = edge_threshold_scale * track_threshold * 0.01 * 0.01
    else
        glow_strength = track_intensity * 0.006
        edge_threshold_scale = track_threshold * 0.006
    end

    obj.copybuffer("cache:ori", "object")

    obj.effect("単色化", "色", 0xffffff, "輝度を保持する", 0)
    local source_width, source_height = obj.getpixel()

    local contrast_width
    if map_layer_index == 0 then
        obj.effect("リサイズ", "拡大率", (source_width + 100) / source_width * 100)
        obj.effect(
            "ノイズ",
            "周期X",
            noise_period_scale,
            "周期Y",
            noise_period_scale,
            "type",
            0,
            "blend_mode",
            1,
            "random_seed",
            random_seed
        )
        contrast_width = 180
    else
        if check_use_temp_save_extension == 0 then
            obj.load("layer", map_layer_index, check_include_effects == 1)
        else
            ---$embed
            local extbuffer = require("extbuffer")
            extbuffer.read(map_layer_index)
        end
        local map_width, map_height = obj.getpixel()
        obj.effect("リサイズ", "X", source_width / map_width * 100, "Y", source_height / map_height * 100)
        obj.effect("領域拡張", "上", 100, "下", 100, "右", 100, "左", 100, "塗りつぶし", 1)
        contrast_width = 200 - noise_period_scale * 20
    end

    if check_adjust_unfold then
        local contrast_tangent = math.tan(math.pi * contrast_width * 0.0025)
        contrast_offset = (1 + 1 / contrast_tangent) * contrast_offset
    end

    obj.pixelshader("extended_contrast", "object", "object", { contrast_offset, contrast_width })
    obj.copybuffer("cache:dst", "object")

    obj.effect("グロー", "強さ", 4, "拡散", 15, "しきい値", 0, "ぼかし", 1, "形状", "通常")
    obj.copybuffer("cache:alp", "object")

    obj.setoption("drawtarget", "tempbuffer", obj.getpixel())

    if track_source_opacity == 1 then
        obj.copybuffer("tempbuffer", "cache:ori")
        obj.pixelshader("shift_and_reverse_channels", "object", "object")
        obj.setoption("blend", "alpha_sub")
        obj.draw()
        obj.draw()
    end

    if track_flame_opacity == 1 then
        obj.copybuffer("object", "cache:alp")
        -- NOTE: AviUtl1の内部フォーマット（YUY2）っぽく輝度を飽和させる
        obj.pixelshader("saturate_brightness", "object", "object")
        obj.effect(
            "エッジ抽出",
            "輝度エッジを抽出",
            1,
            "しきい値",
            73 * edge_threshold_scale,
            "強さ",
            100
        )
        obj.copybuffer("cache:test", "object")

        local col1_r, col1_g, col1_b = RGB(burn_color_1)
        local col2_r, col2_g, col2_b = RGB(burn_color_2)
        obj.pixelshader(
            "tritone",
            "object",
            "object",
            { col1_r / 255, col1_g / 255, col1_b / 255, col2_r / 255, col2_g / 255, col2_b / 255 }
        )
        obj.effect(
            "グロー",
            "強さ",
            2 * glow_strength,
            "拡散",
            30,
            "しきい値",
            40,
            "ぼかし",
            3,
            "形状",
            "通常"
        )
        obj.effect(
            "グロー",
            "強さ",
            1 * glow_strength,
            "拡散",
            3,
            "しきい値",
            60,
            "ぼかし",
            3,
            "形状",
            "通常"
        )
        obj.effect("斜めクリッピング", "幅", source_height)
        obj.effect("斜めクリッピング", "幅", source_width, "角度", 90)
        obj.setoption("blend", blend_mode)
        obj.draw()

        obj.copybuffer("object", "cache:dst")
        obj.effect(
            "エッジ抽出",
            "輝度エッジを抽出",
            1,
            "しきい値",
            38 * edge_threshold_scale,
            "強さ",
            330
        )
        obj.pixelshader(
            "tritone",
            "object",
            "object",
            { col1_r / 255, col1_g / 255, col1_b / 255, col2_r / 255, col2_g / 255, col2_b / 255 }
        )
        obj.effect(
            "グロー",
            "強さ",
            2 * glow_strength,
            "拡散",
            40,
            "しきい値",
            60,
            "ぼかし",
            3,
            "形状",
            "通常"
        )
        obj.effect("斜めクリッピング", "幅", source_height)
        obj.effect("斜めクリッピング", "幅", source_width, "角度", 90)
        obj.setoption("blend", blend_mode)
        obj.draw()
    end
    obj.load("tempbuffer")
    obj.setoption("blend", "none")
end
