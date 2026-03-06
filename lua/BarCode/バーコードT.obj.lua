--label:tim2\未分類
---$track:最小幅
---min=1
---max=30
---step=1
local track_min_width = 2

---$track:高さ
---min=1
---max=1000
---step=1
local track_height = 50

---$track:左右余白
---min=10
---max=1000
---step=1
local track_left_right = 30

---$track:上下余白
---min=10
---max=1000
---step=1
local track_up_down = 20

---$value:データ
local TXT = "AviUtl"

---$color:線色
local col1 = 0x0

---$color:背景色
local col2 = 0xffffff

---$check:CodeCも併用
local UseC = 0

local PT = {
    [0] = 212222,
    222122,
    222221,
    121223,
    121322,
    131222,
    122213,
    122312,
    132212,
    221213,
    221312,
    231212,
    112232,
    122132,
    122231,
    113222,
    123122,
    123221,
    223221,
    221132,
    221231,
    213212,
    223112,
    312131,
    311222,
    321122,
    321221,
    312212,
    322112,
    322211,
    212123,
    212321,
    232121,
    111323,
    131123,
    131321,
    112313,
    132113,
    132311,
    211313,
    231113,
    231311,
    112133,
    112331,
    132131,
    113123,
    113321,
    133121,
    313121,
    211331,
    231131,
    213113,
    213311,
    213131,
    311123,
    311321,
    331121,
    312113,
    312311,
    332111,
    314111,
    221411,
    431111,
    111224,
    111422,
    121124,
    121421,
    141122,
    141221,
    112214,
    112412,
    122114,
    122411,
    142112,
    142211,
    241211,
    221114,
    413111,
    241112,
    134111,
    111242,
    121142,
    121241,
    114212,
    124112,
    124211,
    411212,
    421112,
    421211,
    212141,
    214121,
    412121,
    111143,
    111341,
    131141,
    114113,
    114311,
    411113,
    411311,
    113141,
    114131,
    311141,
    411131,
    211412,
    211214,
    211232,
}
local NM = {
    [" "] = 0,
    ["!"] = 1,
    ['"'] = 2,
    ["#"] = 3,
    ["$"] = 4,
    ["%"] = 5,
    ["&"] = 6,
    ["'"] = 7,
    ["("] = 8,
    [")"] = 9,
    ["*"] = 10,
    ["+"] = 11,
    [","] = 12,
    ["-"] = 13,
    ["."] = 14,
    ["/"] = 15,
    ["0"] = 16,
    ["1"] = 17,
    ["2"] = 18,
    ["3"] = 19,
    ["4"] = 20,
    ["5"] = 21,
    ["6"] = 22,
    ["7"] = 23,
    ["8"] = 24,
    ["9"] = 25,
    [":"] = 26,
    [";"] = 27,
    ["<"] = 28,
    ["="] = 29,
    [">"] = 30,
    ["?"] = 31,
    ["@"] = 32,
    ["A"] = 33,
    ["B"] = 34,
    ["C"] = 35,
    ["D"] = 36,
    ["E"] = 37,
    ["F"] = 38,
    ["G"] = 39,
    ["H"] = 40,
    ["I"] = 41,
    ["J"] = 42,
    ["K"] = 43,
    ["L"] = 44,
    ["M"] = 45,
    ["N"] = 46,
    ["O"] = 47,
    ["P"] = 48,
    ["Q"] = 49,
    ["R"] = 50,
    ["S"] = 51,
    ["T"] = 52,
    ["U"] = 53,
    ["V"] = 54,
    ["W"] = 55,
    ["X"] = 56,
    ["Y"] = 57,
    ["Z"] = 58,
    ["["] = 59,
    ["\\"] = 60,
    ["]"] = 61,
    ["^"] = 62,
    ["_"] = 63,
    ["`"] = 64,
    ["a"] = 65,
    ["b"] = 66,
    ["c"] = 67,
    ["d"] = 68,
    ["e"] = 69,
    ["f"] = 70,
    ["g"] = 71,
    ["h"] = 72,
    ["i"] = 73,
    ["j"] = 74,
    ["k"] = 75,
    ["l"] = 76,
    ["m"] = 77,
    ["n"] = 78,
    ["o"] = 79,
    ["p"] = 80,
    ["q"] = 81,
    ["r"] = 82,
    ["s"] = 83,
    ["t"] = 84,
    ["u"] = 85,
    ["v"] = 86,
    ["w"] = 87,
    ["x"] = 88,
    ["y"] = 89,
    ["z"] = 90,
    ["{"] = 91,
    ["|"] = 92,
    ["}"] = 93,
    ["~"] = 94,
}
local B = math.floor(track_min_width)
local H = math.floor(track_height)
local S = math.floor(track_left_right)
local D = 2 * math.floor(track_up_down)
S = 2 * math.max(S, 10 * B)
local N = string.len(TXT)
local MJ
local APT
if UseC == 1 then
    local st, ed = string.find(TXT, "%d+", 1)
    if st == nil then
        UseC = 0
    else
        local CoB = {}
        local CoC = {}
        for i = 1, N do
            CoB[i] = string.sub(TXT, i, i)
        end
        while st do
            local L = ed - st + 1
            if L > 3 then
                L = L - L % 2
                for i = 0, L - 1 do
                    local ii = st + i
                    CoC[ii], CoB[ii] = CoB[ii], nil
                end
            end
            st, ed = string.find(TXT, "%d+", ed + 1)
        end
        local s = 1
        local t = 1
        if CoB[1] then --CodeBスタート
            MJ = 104 * 1
            APT = "211214"
        else --CodeCスタート
            MJ = 105 * 1
            APT = "211232"
        end
        while s <= N do
            if CoB[s] then --CodeB
                while CoB[s] do
                    local Cn = NM[CoB[s]] or 0
                    MJ = MJ + t * Cn
                    APT = APT .. PT[Cn]
                    s = s + 1
                    t = t + 1
                end
                if s <= N then
                    MJ = MJ + t * 99
                    APT = APT .. "113141"
                    t = t + 1
                end
            else --CodeC
                while CoC[s] do
                    local Cn = CoC[s] * 10 + CoC[s + 1]
                    MJ = MJ + t * Cn
                    APT = APT .. PT[Cn]
                    s = s + 2
                    t = t + 1
                end
                if s <= N then
                    MJ = MJ + t * 100
                    APT = APT .. "114131"
                    t = t + 1
                end
            end
        end
    end
end
if UseC == 0 then
    MJ = 104 * 1
    APT = "211214"
    for i = 1, N do
        local chr = string.sub(TXT, i, i)
        local Cn = NM[chr] or 0
        MJ = MJ + i * Cn
        APT = APT .. PT[Cn]
    end
end
MJ = MJ % 103
APT = APT .. PT[MJ] .. "2331112"
BW = {}
local M = string.len(APT)
L = 0
for i = 1, M do
    BW[i] = string.sub(APT, i, i)
    L = L + BW[i]
end
local W = B * L
local dw = math.abs(obj.screen_w - W) % 2
local dh = math.abs(obj.screen_h - H) % 2
obj.setoption("drawtarget", "tempbuffer")
obj.load("figure", "四角形", col2, 1)
obj.effect("リサイズ", "X", W + dw + S, "Y", H + dh + D, "ドット数でサイズ指定", 1)
obj.copybuffer("tmp", "obj")
obj.load("figure", "四角形", col2, 1)
obj.effect("リサイズ", "X", L, "Y", 1, "ドット数でサイズ指定", 1)
M = math.floor(M / 2)
obj.pixeloption("type", "col")
SUM = 0
for i = 1, M + 1 do
    for k = 0, BW[2 * i - 1] - 1 do
        obj.putpixel(SUM + k, 0, col1, 1)
    end
    SUM = SUM + BW[2 * i - 1] + (BW[2 * i] or 0)
end
obj.effect("リサイズ", "X", W, "Y", H, "ドット数でサイズ指定", 1, "補間なし", 1)
obj.effect("領域拡張", "塗りつぶし", 0, "下", dh, "右", dw)
obj.draw()
obj.copybuffer("obj", "tmp")
obj.cx = 0
obj.cy = 0
