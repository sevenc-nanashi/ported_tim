--label:tim2
--track0:展開,0,100,50
--track1:強度,0,200,100
--track2:しきい値,0,200,100
--track3:周期/燃幅,10,200,100
--value@col1:燃焼色1/col,0xff4747
--value@col2:燃焼色2/col,0xffce5b
--value@orAP:画像表示/chk,1
--value@fiAP:炎表示/chk,1
--value@seed:シード,0
--value@mode:合成ﾓｰﾄﾞ[0-9],1
--value@map:レイヤー指定,0
--value@GE:ｴﾌｪｸﾄ取得/chk,1
--value@IE:一時保存EXT/chk,0
--check0:展開を調整,0;

if orAP == 1 or fiAP == 1 then
    require("T_burning_Module")
    local userdata, w, h
    local T = (obj.track0 * 0.02 - 1) * 128
    local Si = obj.track3 * 0.01
    local ST, Sh

    seed = seed or 0
    map = map or 0

    if obj.check0 then
        ST = 60
        if Si < 1 then
            ST = 60 / Si
        end
        Sh = 30 * Si + 30
        ST = (ST + 2 * obj.track1 - 200) * 0.01
        Sh = Sh * obj.track2 * 0.01 * 0.01
    else
        ST = obj.track1 * 0.006
        Sh = obj.track2 * 0.006
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

    if obj.check0 then
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
