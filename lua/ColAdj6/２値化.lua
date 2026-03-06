--label:tim2\T_Color_Module.anm
---$track:閾値
---min=0
---max=255
---step=1
local track_threshold = 128

-- ---$track:ｸﾞﾚｰ処理
-- ---min=0
-- ---max=2
-- ---step=1
---$select:グレー処理
---RGB平均=0
---NTSC加重平均法=1
---HDTV法=2
local track_gray_process = 1

-- ---$track:自動判定
-- ---min=0
-- ---max=6
-- ---step=1
---$select:自動判定
---なし=0
---平均値=1
---中央値=2
---判別分析法=3
---Kittlerらの閾値選定法=4
---微分ヒストグラム法=5
---ラプラシアン・ヒストグラム法=6
local track_auto_detect = 0

--group:色変更
---$check:色付け
local colorize = false
---$color:明部色
local col1 = 0xff0000
---$color:暗部色
local col2 = 0x0000ff


-- require("T_Color_Module")
local T_Color_Module = obj.module("tim2")
local userdata, w, h = obj.getpixeldata("object", "bgra")
T_Color_Module.binarization(
    userdata,
    w,
    h,
    track_threshold,
    track_gray_process,
    track_auto_detect,
    colorize,
    col1,
    col2
)
obj.putpixeldata("object", userdata, w, h, "bgra")