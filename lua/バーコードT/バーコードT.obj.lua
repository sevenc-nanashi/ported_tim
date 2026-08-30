--label:${ROOT_CATEGORY}\カスタムオブジェクト
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
local track_horizontal_margin = 30

---$track:上下余白
---min=10
---max=1000
---step=1
local track_vertical_margin = 20

---$string:データ
local value_data = "AviUtl"

---$color:線色
local color_bars = 0x0

---$color:背景色
local color_background = 0xffffff

---$check:CodeCも併用
local check_use_code_c = 0

local bar_patterns = {
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
local character_values = {
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
local module_width = math.floor(track_min_width)
local barcode_height = math.floor(track_height)
local horizontal_margin = math.floor(track_horizontal_margin)
local vertical_margin = 2 * math.floor(track_vertical_margin)
horizontal_margin = 2 * math.max(horizontal_margin, 10 * module_width)
local data_length = string.len(value_data)
local checksum
local encoded_pattern
if check_use_code_c == 1 then
    local digit_run_start, digit_run_end = string.find(value_data, "%d+", 1)
    if digit_run_start == nil then
        check_use_code_c = 0
    else
        local code_b_characters = {}
        local code_c_digits = {}
        for i = 1, data_length do
            code_b_characters[i] = string.sub(value_data, i, i)
        end
        while digit_run_start do
            local run_length = digit_run_end - digit_run_start + 1
            if run_length > 3 then
                run_length = run_length - run_length % 2
                for i = 0, run_length - 1 do
                    local ii = digit_run_start + i
                    code_c_digits[ii], code_b_characters[ii] = code_b_characters[ii], nil
                end
            end
            digit_run_start, digit_run_end = string.find(value_data, "%d+", digit_run_end + 1)
        end
        local data_position = 1
        local checksum_weight = 1
        if code_b_characters[1] then --CodeBスタート
            checksum = 104 * 1
            encoded_pattern = "211214"
        else --CodeCスタート
            checksum = 105 * 1
            encoded_pattern = "211232"
        end
        while data_position <= data_length do
            if code_b_characters[data_position] then --CodeB
                while code_b_characters[data_position] do
                    local symbol_value = character_values[code_b_characters[data_position]] or 0
                    checksum = checksum + checksum_weight * symbol_value
                    encoded_pattern = encoded_pattern .. bar_patterns[symbol_value]
                    data_position = data_position + 1
                    checksum_weight = checksum_weight + 1
                end
                if data_position <= data_length then
                    checksum = checksum + checksum_weight * 99
                    encoded_pattern = encoded_pattern .. "113141"
                    checksum_weight = checksum_weight + 1
                end
            else --CodeC
                while code_c_digits[data_position] do
                    local symbol_value = code_c_digits[data_position] * 10 + code_c_digits[data_position + 1]
                    checksum = checksum + checksum_weight * symbol_value
                    encoded_pattern = encoded_pattern .. bar_patterns[symbol_value]
                    data_position = data_position + 2
                    checksum_weight = checksum_weight + 1
                end
                if data_position <= data_length then
                    checksum = checksum + checksum_weight * 100
                    encoded_pattern = encoded_pattern .. "114131"
                    checksum_weight = checksum_weight + 1
                end
            end
        end
    end
end
if check_use_code_c == 0 then
    checksum = 104 * 1
    encoded_pattern = "211214"
    for i = 1, data_length do
        local character = string.sub(value_data, i, i)
        local symbol_value = character_values[character] or 0
        checksum = checksum + i * symbol_value
        encoded_pattern = encoded_pattern .. bar_patterns[symbol_value]
    end
end
checksum = checksum % 103
encoded_pattern = encoded_pattern .. bar_patterns[checksum] .. "2331112"
local module_widths = {}
local pattern_length = string.len(encoded_pattern)
local total_module_count = 0
for i = 1, pattern_length do
    module_widths[i] = string.sub(encoded_pattern, i, i)
    total_module_count = total_module_count + module_widths[i]
end
local barcode_width = module_width * total_module_count
local width_parity_adjust = math.abs(obj.screen_w - barcode_width) % 2
local height_parity_adjust = math.abs(obj.screen_h - barcode_height) % 2
obj.setoption("drawtarget", "tempbuffer")
obj.load("figure", "四角形", color_background, 1)
obj.effect(
    "リサイズ",
    "X",
    barcode_width + width_parity_adjust + horizontal_margin,
    "Y",
    barcode_height + height_parity_adjust + vertical_margin,
    "ドット数でサイズ指定",
    1
)
obj.copybuffer("tempbuffer", "object")
obj.load("figure", "四角形", color_background, 1)
obj.effect("リサイズ", "X", total_module_count, "Y", 1, "ドット数でサイズ指定", 1)
pattern_length = math.floor(pattern_length / 2)
obj.pixeloption("type", "col")
local pixel_offset = 0
for i = 1, pattern_length + 1 do
    for k = 0, module_widths[2 * i - 1] - 1 do
        obj.putpixel(pixel_offset + k, 0, color_bars, 1)
    end
    pixel_offset = pixel_offset + module_widths[2 * i - 1] + (module_widths[2 * i] or 0)
end
obj.effect(
    "リサイズ",
    "X",
    barcode_width,
    "Y",
    barcode_height,
    "ドット数でサイズ指定",
    1,
    "補間なし",
    1
)
obj.effect("領域拡張", "塗りつぶし", 0, "下", height_parity_adjust, "右", width_parity_adjust)
obj.draw()
obj.copybuffer("object", "tempbuffer")
obj.cx = 0
obj.cy = 0
