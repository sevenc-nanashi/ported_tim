--label:tim2
---$track:展開
---min=0
---max=100
---step=0.1
local rename_me_track0 = 50

---$track:強度
---min=0
---max=200
---step=0.1
local rename_me_track1 = 100

---$track:しきい値
---min=0
---max=200
---step=0.1
local rename_me_track2 = 100

---$track:周期/燃幅
---min=10
---max=200
---step=0.1
local rename_me_track3 = 100

---$color:燃焼色1
local col1 = 0xff4747

---$color:燃焼色2
local col2 = 0xffce5b

---$check:画像表示
local orAP = 1

---$check:炎表示
local fiAP = 1

---$value:シード
local seed = 0

---$value:合成ﾓｰﾄﾞ[0-9]
local mode = 1

---$value:レイヤー指定
local map = 0

---$check:ｴﾌｪｸﾄ取得
local GE = 1

---$check:一時保存EXT
local IE = 0

---$check:展開を調整
local rename_me_check0 = true

if orAP == 1 or fiAP == 1 then
    require("T_burning_Module")
    local userdata, w, h
    local T = (rename_me_track0 * 0.02 - 1) * 128
    local Si = rename_me_track3 * 0.01
    local ST, Sh

    seed = seed or 0
    map = map or 0

    if rename_me_check0 then
        ST = 60
        if Si < 1 then
            ST = 60 / Si
        end
        Sh = 30 * Si + 30
        ST = (ST + 2 * rename_me_track1 - 200) * 0.01
        Sh = Sh * rename_me_track2 * 0.01 * 0.01
    else
        ST = rename_me_track1 * 0.006
        Sh = rename_me_track2 * 0.006
    end

    obj.copybuffer("cache:ori", "obj")

    obj.effect("単色化", "color", 0xffffff, "輝度を保持する", 0)
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
            require("extbuffer")
            extbuffer.read(map)
        end
        local w, h = obj.getpixel()
        obj.effect("リサイズ", "X", w0 / w * 100, "Y", h0 / h * 100)
        obj.effect("領域拡張", "上", 100, "下", 100, "右", 100, "左", 100, "塗りつぶし", 1)
        ECW = 200 - Si * 20
    end

    if rename_me_check0 then
        local kaku = math.tan(math.pi * ECW * 0.0025)
        T = (1 + 1 / kaku) * T
    end

    userdata, w, h = obj.getpixeldata()
    T_burning_Module.ExtendedContrast(userdata, w, h, T, ECW)
    obj.putpixeldata(userdata)
    obj.copybuffer("cache:dst", "obj")

    obj.effect("グロー", "強さ", 40, "拡散", 30, "しきい値", 0, "ぼかし", 1)
    obj.copybuffer("cache:alp", "obj")

    obj.setoption("drawtarget", "tempbuffer", w, h)

    if orAP == 1 then
        obj.copybuffer("tmp", "cache:ori")
        userdata, w, h = obj.getpixeldata()
        T_burning_Module.ShiftChannels(userdata, w, h)
        obj.putpixeldata(userdata)
        obj.effect("反転", "透明度反転", 1)
        obj.setoption("blend", "alpha_sub")
        obj.draw()
        obj.draw()
    end

    if fiAP == 1 then
        obj.copybuffer("obj", "cache:alp")
        obj.effect("エッジ抽出", "輝度エッジを抽出", 1, "しきい値", 73 * Sh, "強さ", 100)
        userdata, w, h = obj.getpixeldata()
        T_burning_Module.Tritone(userdata, w, h, col1, col2)
        obj.putpixeldata(userdata)
        obj.effect("グロー", "強さ", 50 * ST, "拡散", 30, "しきい値", 40, "ぼかし", 3)
        obj.effect("斜めクリッピング", "幅", h0)
        obj.effect("斜めクリッピング", "幅", w0, "角度", 90)
        obj.setoption("blend", mode)
        obj.draw()

        obj.copybuffer("obj", "cache:dst")
        obj.effect("エッジ抽出", "輝度エッジを抽出", 1, "しきい値", 38 * Sh, "強さ", 330)
        userdata, w, h = obj.getpixeldata()
        T_burning_Module.Tritone(userdata, w, h, col1, col2)
        obj.putpixeldata(userdata)
        obj.effect("グロー", "強さ", 20 * ST, "拡散", 40, "しきい値", 40, "ぼかし", 3)
        obj.effect("斜めクリッピング", "幅", h0)
        obj.effect("斜めクリッピング", "幅", w0, "角度", 90)
        obj.setoption("blend", mode)
        obj.draw()
    end
    obj.load("tempbuffer")
    obj.setoption("blend", 0)
end
