--label:tim2\光効果
---$track:強さ
---min=0
---max=400
---step=0.1
local track_strength = 10

---$track:拡散
---min=0
---max=200
---step=0.1
local track_diffusion = 100

---$track:しきい値
---min=0
---max=100
---step=0.1
local track_threshold = 60

---$track:発光回転
---min=-3600
---max=3600
---step=0.1
local track_glow_rotation = 45

---$color:発光色
local col = 0xffffff

---$check:オリジナル色発光
local chk = 1

---$check:光のみ
local Lonly = 0

---$select:形状
---通常=0
---クロス(4本)=1
---クロス(6本)=2
---クロス(8本)=3
---クロス(10本)=4
---クロス(12本)=5
---ライン=6
local fig = 1

---$track:ぼかし
---min=0
---max=50
---step=1
local blur = 1

local w, h = obj.getpixel()

obj.copybuffer("cache:ori_img", "obj")

local deg = track_glow_rotation

local sin = math.abs(math.sin(math.rad(deg)))
local cos = math.abs(math.cos(math.rad(deg)))

local w0 = w * cos + h * sin
local h0 = h * cos + w * sin

obj.setoption("drawtarget", "tempbuffer", w0, h0)
obj.draw(0, 0, 0, 1, 1, 0, 0, -deg)
obj.copybuffer("obj", "tmp")

local fig_map = {
    [0] = "通常",
    [1] = "クロス(4本)",
    [2] = "クロス(6本)",
    [3] = "クロス(8本)",
    [4] = "クロス(10本)",
    [5] = "クロス(12本)",
    [6] = "ライン",
}

obj.effect(
    "グロー",
    "強さ",
    track_strength,
    "拡散",
    track_diffusion,
    "しきい値",
    track_threshold,
    "ぼかし",
    blur,
    "形状",
    fig_map[fig] or "通常",
    "光成分のみ",
    1,
    "光色",
    chk == 0 and col or ""
)
if Lonly == 0 then
    obj.copybuffer("tmp", "cache:ori_img")
    obj.setoption("blend", 1)
else
    obj.setoption("drawtarget", "tempbuffer", w, h)
end
obj.draw(0, 0, 0, 1, 1, 0, 0, deg)

obj.load("tempbuffer")
obj.setoption("blend", 0)
