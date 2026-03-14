--label:tim2\アニメーション効果

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
local col1 = 0xff4747

---$color:燃焼色2
local col2 = 0xffce5b

---$check:画像表示
local orAP = 1

---$check:炎表示
local fiAP = 1

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
local track_layer_index = 0

---$check:エフェクト取得
local GE = 1

---$check:一時保存EXT
local IE = 0

---$check:展開を調整
local check0 = false

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

if orAP == 1 or fiAP == 1 then
    local T = (track_unfold * 0.02 - 1) * 128
    local Si = track_period_width * 0.01
    local ST, Sh

    local seed = track_seed or 0
    local map = track_layer_index or 0
    local mode = select_blend_mode or 1

    if check0 then
        ST = 60
        if Si < 1 then
            ST = 60 / Si
        end
        Sh = 30 * Si + 30
        ST = (ST + 2 * track_intensity - 200) * 0.01
        Sh = Sh * track_threshold * 0.01 * 0.01
    else
        ST = track_intensity * 0.006
        Sh = track_threshold * 0.006
    end

    obj.copybuffer("cache:ori", "object")

    obj.effect("単色化", "色", 0xffffff, "輝度を保持する", 0)
    local w0, h0 = obj.getpixel()

    local ECW
    if map == 0 then
        obj.effect("リサイズ", "拡大率", (w0 + 100) / w0 * 100)
        obj.effect("ノイズ", "周期X", Si, "周期Y", Si, "type", 0, "mode", 1, "seed", seed)
        ECW = 180
    else
        if IE == 0 then
            obj.load("layer", map, GE == 1)
        else
            ---$embed
            local extbuffer = require("extbuffer")
            extbuffer.read(map)
        end
        local w, h = obj.getpixel()
        obj.effect("リサイズ", "X", w0 / w * 100, "Y", h0 / h * 100)
        obj.effect("領域拡張", "上", 100, "下", 100, "右", 100, "左", 100, "塗りつぶし", 1)
        ECW = 200 - Si * 20
    end

    if check0 then
        local kaku = math.tan(math.pi * ECW * 0.0025)
        T = (1 + 1 / kaku) * T
    end

    obj.pixelshader("extended_contrast", "object", "object", { T, ECW })
    obj.copybuffer("cache:dst", "object")

    obj.effect("グロー", "強さ", 4, "拡散", 15, "しきい値", 0, "ぼかし", 1, "形状", "通常")
    obj.copybuffer("cache:alp", "obj")

    obj.setoption("drawtarget", "tempbuffer", obj.getpixel())

    if orAP == 1 then
        obj.copybuffer("tempbuffer", "cache:ori")
        obj.pixelshader("shift_and_reverse_channels", "object", "object")
        obj.setoption("blend", "alpha_sub")
        obj.draw()
        obj.draw()
    end

    if fiAP == 1 then
        obj.copybuffer("object", "cache:alp")
        -- NOTE: AviUtl1の内部フォーマット（YUY2）っぽく輝度を飽和させる
        obj.pixelshader("saturate_brightness", "object", "object")
        obj.effect("エッジ抽出", "輝度エッジを抽出", 1, "しきい値", 73 * Sh, "強さ", 100)
        obj.copybuffer("cache:test", "object")

        local col1_r, col1_g, col1_b = RGB(col1)
        local col2_r, col2_g, col2_b = RGB(col2)
        obj.pixelshader(
            "tritone",
            "object",
            "object",
            { col1_r / 255, col1_g / 255, col1_b / 255, col2_r / 255, col2_g / 255, col2_b / 255 }
        )
        obj.effect("グロー", "強さ", 2 * ST, "拡散", 30, "しきい値", 40, "ぼかし", 3, "形状", "通常")
        obj.effect("グロー", "強さ", 1 * ST, "拡散", 3, "しきい値", 60, "ぼかし", 3, "形状", "通常")
        obj.effect("斜めクリッピング", "幅", h0)
        obj.effect("斜めクリッピング", "幅", w0, "角度", 90)
        obj.setoption("blend", mode)
        obj.draw()

        obj.copybuffer("object", "cache:dst")
        obj.effect("エッジ抽出", "輝度エッジを抽出", 1, "しきい値", 38 * Sh, "強さ", 330)
        obj.pixelshader(
            "tritone",
            "object",
            "object",
            { col1_r / 255, col1_g / 255, col1_b / 255, col2_r / 255, col2_g / 255, col2_b / 255 }
        )
        obj.effect("グロー", "強さ", 2 * ST, "拡散", 40, "しきい値", 60, "ぼかし", 3, "形状", "通常")
        obj.effect("斜めクリッピング", "幅", h0)
        obj.effect("斜めクリッピング", "幅", w0, "角度", 90)
        obj.setoption("blend", mode)
        obj.draw()
    end
    obj.load("tempbuffer")
    obj.setoption("blend", "none")
end
