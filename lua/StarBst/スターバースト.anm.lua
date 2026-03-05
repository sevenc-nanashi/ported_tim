--label:tim2
---$track:強さ
---min=0
---max=400
---step=0.1
local rename_me_track0 = 10

---$track:拡散
---min=0
---max=200
---step=0.1
local rename_me_track1 = 100

---$track:しきい値
---min=0
---max=100
---step=0.1
local rename_me_track2 = 60

---$track:発光回転
---min=-3600
---max=3600
---step=0.1
local rename_me_track3 = 45

---$value:発光色/col
local col = 0xffffff

---$value:オリジナル色発光/chk
local chk = 1

---$value:光のみ/chk
local Lonly = 0

---$value:形状[1-5]
local fig = 1

---$value:ぼかし
local blur = 1

local w, h = obj.getpixel()

obj.copybuffer("cache:ori_img", "obj")

local deg = rename_me_track3

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
    rename_me_track0,
    "拡散",
    rename_me_track1,
    "しきい値",
    rename_me_track2,
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
