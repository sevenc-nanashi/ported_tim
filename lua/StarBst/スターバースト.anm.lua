--label:tim2
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

---$value:形状[1-5]
local fig = 1

---$value:ぼかし
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
    "type",
    fig,
    "光成分のみ",
    1,
    "no_color",
    chk,
    "color",
    col
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
