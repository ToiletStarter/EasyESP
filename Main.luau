if not Drawing or not setrenderproperty or not cleardrawcache then
	error("EasyESP requires the Potassium executor (Drawing / setrenderproperty API missing)", 2)
end

local Players    = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting   = game:GetService("Lighting")
local Input      = game:GetService("UserInputService")
local HttpJson   = game:GetService("HttpService")

local me  = Players.LocalPlayer
local cam = workspace.CurrentCamera
workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	cam = workspace.CurrentCamera
end)

local v2, v3 = Vector2.new, Vector3.new
local cnew   = CFrame.new
local rgb, hsv, rawc = Color3.fromRGB, Color3.fromHSV, Color3.new
local clamp, floor, sqrt, sin, cos, atan2, huge, pi =
	math.clamp, math.floor, math.sqrt, math.sin, math.cos, math.atan2, math.huge, math.pi
local insert, remove, sort = table.insert, table.remove, table.sort
local sp = setrenderproperty
local TAU = pi * 2

local FONTS = Drawing.Fonts
local BLACK = rawc(0, 0, 0)

local function hueAt(t)
	return hsv(t % 1, 1, 1)
end

local RIG15 = {
	{"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
	{"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
	{"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
	{"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
	{"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"},
}
local RIG6 = {
	{"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},
	{"Torso","Left Leg"},{"Torso","Right Leg"},
}

local CORNERS = {
	v3(-1, 1,-1), v3(1, 1,-1), v3(1, 1,1), v3(-1, 1,1),
	v3(-1,-1,-1), v3(1,-1,-1), v3(1,-1,1), v3(-1,-1,1),
}
local EDGES = {
	{1,2},{2,3},{3,4},{4,1},{5,6},{6,7},{7,8},{8,5},{1,5},{2,6},{3,7},{4,8},
}


local function sameColor(a, b)
	return a == b or (a.R == b.R and a.G == b.G and a.B == b.B)
end

local Pool = {}
Pool.__index = Pool

function Pool.new()
	return setmetatable({
		bank   = {},
		shadow = {},
		live   = {},
		wasLive= {},
	}, Pool)
end

function Pool:grab(key, kind)
	local d = self.bank[key]
	if not d then
		d = Drawing.new(kind)
		self.bank[key] = d
		self.shadow[key] = {}
	end
	self.live[key] = true
	return d, self.shadow[key]
end

function Pool:openFrame()
	local live = self.live
	for k in pairs(live) do live[k] = nil end
end

function Pool:closeFrame()
	local live, was, bank, shadow = self.live, self.wasLive, self.bank, self.shadow
	for k in pairs(was) do
		if not live[k] then
			local d = bank[k]
			if d then d.Visible = false end
			local sh = shadow[k]
			if sh then sh.Visible = false end
		end
	end
	self.wasLive, self.live = live, was
end

function Pool:nuke()
	cleardrawcache()
	self.bank, self.shadow, self.live, self.wasLive = {}, {}, {}, {}
end

function Pool:line(key, ax, ay, bx, by, color, thick, alpha, z)
	local d, sh = self:grab(key, "Line")
	if not sh.Visible then sp(d, "Visible", true) sh.Visible = true end
	if sh.fx ~= ax or sh.fy ~= ay then sp(d, "From", v2(ax, ay)) sh.fx, sh.fy = ax, ay end
	if sh.tx ~= bx or sh.ty ~= by then sp(d, "To", v2(bx, by)) sh.tx, sh.ty = bx, by end
	if not sh.col or not sameColor(sh.col, color) then sp(d, "Color", color) sh.col = color end
	thick = thick or 1
	if sh.th ~= thick then sp(d, "Thickness", thick) sh.th = thick end
	alpha = alpha or 1
	if sh.a ~= alpha then sp(d, "Transparency", alpha) sh.a = alpha end
	if z and sh.z ~= z then sp(d, "ZIndex", z) sh.z = z end
	return d
end

function Pool:rect(key, x, y, w, h, color, filled, thick, alpha, z)
	local d = self:grab(key, "Square")
	sp(d, "Visible", true)
	sp(d, "Position", v2(x, y))
	sp(d, "Size", v2(w, h))
	sp(d, "Color", color)
	sp(d, "Filled", filled == true)
	sp(d, "Thickness", thick or 1)
	sp(d, "Transparency", alpha or 1)
	if z then sp(d, "ZIndex", z) end
	return d
end

function Pool:dot(key, x, y, radius, color, filled, alpha, sides, z)
	local d = self:grab(key, "Circle")
	sp(d, "Visible", true)
	sp(d, "Position", v2(x, y))
	sp(d, "Radius", radius)
	sp(d, "Color", color)
	sp(d, "Filled", filled ~= false)
	sp(d, "NumSides", sides or 24)
	sp(d, "Transparency", alpha or 1)
	if z then sp(d, "ZIndex", z) end
	return d
end

function Pool:tri(key, ax, ay, bx, by, cx, cy, color, alpha, z)
	local d = self:grab(key, "Triangle")
	sp(d, "Visible", true)
	sp(d, "PointA", v2(ax, ay))
	sp(d, "PointB", v2(bx, by))
	sp(d, "PointC", v2(cx, cy))
	sp(d, "Color", color)
	sp(d, "Filled", true)
	sp(d, "Transparency", alpha or 1)
	if z then sp(d, "ZIndex", z) end
	return d
end

function Pool:quad(key, ax, ay, bx, by, cx, cy, dx, dy, color, filled, thick, alpha, z)
	local d = self:grab(key, "Quad")
	sp(d, "Visible", true)
	sp(d, "PointA", v2(ax, ay))
	sp(d, "PointB", v2(bx, by))
	sp(d, "PointC", v2(cx, cy))
	sp(d, "PointD", v2(dx, dy))
	sp(d, "Color", color)
	sp(d, "Filled", filled == true)
	sp(d, "Thickness", thick or 1)
	sp(d, "Transparency", alpha or 1)
	if z then sp(d, "ZIndex", z) end
	return d
end

function Pool:text(key, str, x, y, size, color, centered, font, outlined, z)
	local d = self:grab(key, "Text")
	sp(d, "Visible", true)
	sp(d, "Text", str)
	sp(d, "Position", v2(x, y))
	sp(d, "Size", size)
	sp(d, "Color", color)
	sp(d, "Center", centered ~= false)
	sp(d, "Outline", outlined ~= false)
	sp(d, "OutlineColor", BLACK)
	sp(d, "Font", font or FONTS.Plex)
	if z then sp(d, "ZIndex", z) end
	return d
end

local function palette()
	return {
		accent  = rgb(190, 70, 235),
		visible = rgb(90, 235, 130),
		hidden  = rgb(235, 70, 70),
		text    = rgb(235, 235, 245),
		ink     = rgb(12, 12, 16),
	}
end

local function baseConfig()
	local p = palette()
	return {
		enabled  = false,
		maxRange = 3000,
		refresh  = 0,
		teamCheck   = false,
		wallCheck   = false,
		wallHide    = false,
		wallColors  = false,
		rainbow     = false,
		rainbowRate = 1,

		perf = {
			mode       = "auto",
			playerCap  = 0,
			ringDetail = 48,
			ballDetail = 24,
			fxDensity  = 1,
			near       = 120,
			mid        = 320,
			far        = 700,
			labelsOnlyFar = true,
			dropFxFar  = true,
			frameSkip  = 0,
		},

		box = {
			on = true, style = "corner",
			color = p.accent, thickness = 1,
			outline = true, cornerScale = 0.28,
			fill = false, fillColor = p.accent, fillAlpha = 0.12,
		},
		glow = { on = false, color = p.accent, layers = 4, spread = 2, alpha = 0.10, pulse = true, rate = 3 },
		name = { on = true, size = 13, color = p.text, font = FONTS.Plex, shadow = true, showUser = false },
		gun  = { on = false, size = 12, color = rgb(205, 205, 215), ammoAttr = "Ammo" },
		dist = { on = false, size = 11, color = rgb(180, 180, 190), suffix = "m" },

		hp = {
			on = true, side = "left", thickness = 3, outline = true,
			full = rgb(90, 235, 120), low = rgb(235, 70, 70),
			gradient = true, showText = false, notch = true,
		},
		armor = { on = false, thickness = 3, color = rgb(95, 160, 255), attr = "Armor", maxAttr = "MaxArmor" },

		flags = { on = false, size = 11, font = FONTS.Plex, side = "right", spacing = 1, color = p.text },

		bones   = { on = false, color = p.text, thickness = 1 },
		headDot = { on = false, size = 3, color = p.text },
		gaze    = { on = false, length = 10, color = p.text },
		tracer  = { on = false, from = "bottom", color = p.accent, thickness = 1 },
		arrow   = { on = false, radius = 200, size = 15, color = p.accent },

		hit   = { on = false, life = 0.35, flash = rawc(1,1,1), showDmg = true, dmgColor = rgb(255, 90, 90) },
		pulse = { on = false, threshold = 0.35, color = rgb(255, 45, 45), rate = 6 },
		trail = { on = false, ticks = 8, gap = 0.05, color = p.accent, alpha = 0.5, fade = true },

		rings = {
			on = false, onEnemies = false,
			specs = {
				{ radius = 14, color = rgb(255, 70, 70), thickness = 2, style = "solid", shape = "circle", fx = "none", spin = 0.4, pulse = false, fill = false, fillAlpha = 0.08, glow = false, ticks = 0 },
				{ radius = 6,  color = rgb(90, 200, 255), thickness = 2, style = "dashed", shape = "circle", fx = "none", spin = 0, pulse = true, fill = false, fillAlpha = 0.08, glow = false, ticks = 0 },
			},
		},
		ball = { on = false, onEnemies = false, radius = 10, rings = 5, color = p.accent, thickness = 1, alpha = 0.6, spin = 0.2, fx = "none" },

		fx = {
			onEnemies = true,
			confetti  = { on = false, count = 40, radius = 8, height = 12, speed = 6, size = 3, rainbow = true, color = rgb(255, 100, 200) },
			rain      = { on = false, count = 60, radius = 7, height = 16, speed = 24, length = 1.2, color = rgb(120, 170, 255), alpha = 0.6, rainbow = false },
			synth     = { on = false, rings = 6, radius = 12, speed = 4, sides = 40, thickness = 1, alpha = 0.7, hue = 0.85, hueSpan = 0.25, rise = true, glow = true },
			orbit     = { on = false, count = 3, radius = 5, speed = 2, size = 4, color = p.accent, lift = 3, rainbow = false, trail = true, trailLen = 5 },
			spiral    = { on = false, radius = 6, height = 10, turns = 3, points = 60, speed = 2, thickness = 1, alpha = 0.85, color = rgb(255, 120, 60), rainbow = true },
			vortex    = { on = false, count = 50, radius = 8, height = 12, speed = 6, twist = 3, size = 3, color = rgb(120, 80, 255), rainbow = true },
			shock     = { on = false, waves = 3, radius = 14, speed = 4, sides = 44, thickness = 2, alpha = 0.8, color = rgb(255, 220, 120) },
			aura      = { on = false, rings = 4, radius = 5, speed = 2, sides = 36, thickness = 1, alpha = 0.7, color = rgb(90, 255, 200), rainbow = true },
			flies     = { on = false, count = 24, radius = 6, height = 8, speed = 4, size = 2, color = rgb(255, 240, 150), rainbow = false },
			bolt      = { on = false, count = 3, segs = 6, radius = 6, height = 12, jitter = 1.5, speed = 6, thickness = 2, alpha = 1, color = rgb(180, 220, 255) },
			helix     = { on = false, strands = 2, points = 40, turns = 2, radius = 3, height = 12, speed = 2, thickness = 1, alpha = 0.85, color = rgb(120, 255, 180), rainbow = true },
			pulse     = { on = false, radius = 8, sides = 40, speed = 1.2, thickness = 2, alpha = 0.8, color = rgb(255, 60, 90) },
			tornado   = { on = false, count = 60, radius = 6, height = 14, speed = 6, spin = 3, twist = 2, size = 2, color = rgb(180, 180, 200), rainbow = false },
			portal    = { on = false, rings = 5, radius = 6, sides = 40, speed = 3, spin = 1, thickness = 2, alpha = 0.7, hue = 0.75 },
			snow      = { on = false, count = 50, radius = 8, height = 16, speed = 4, size = 1.5, alpha = 0.9, color = rawc(1,1,1) },
			embers    = { on = false, count = 40, radius = 5, height = 12, speed = 5, size = 2 },
			radar     = { on = false, radius = 14, sides = 40, speed = 2, arc = 1.2, thickness = 2, alpha = 0.8, color = rgb(80, 255, 120) },
			burst     = { on = false, outer = 6, inner = 2.5, points = 5, spin = 1, thickness = 2, alpha = 0.9, color = rgb(255, 220, 90), rainbow = true },
			ripple    = { on = false, waves = 4, radius = 12, speed = 3, sides = 44, alpha = 0.18, color = rgb(120, 90, 255) },
			beam      = { on = false, count = 5, radius = 4, height = 18, speed = 3, thickness = 2, alpha = 0.5, color = rgb(120, 200, 255), rainbow = true },
		},

		self = {
			fx      = false,
			rings   = false,
			trail   = { on = false, ticks = 30, gap = 0.05, thickness = 2, alpha = 0.8, color = p.accent, rainbow = true },
			fov     = { on = false, radius = 120, thickness = 1, sides = 64, alpha = 1, color = rawc(1,1,1), rainbow = false, fill = false, fillAlpha = 0.05 },
			cross   = { on = false, gap = 4, length = 8, thickness = 1, alpha = 1, color = rgb(0, 255, 120), rainbow = false, outline = true, dot = false, dotSize = 1 },
			preview = { on = false, x = 60, y = 0, w = 70, h = 150, fakeHp = -1 },
		},

		chams = {
			on = false, mode = "highlight", teamCheck = false,
			depth = "top",
			fill = true, fillColor = rawc(1,1,1), fillAlpha = 0.5,
			outline = true, outlineColor = rawc(1,1,1), outlineAlpha = 0,
			material = "ForceField", matColor = rawc(1,1,1), matAlpha = 0, matHead = true,
			wallColors = false, visible = rgb(0, 255, 0), hidden = rgb(255, 0, 0),
			rainbow = false, rainbowRate = 1,
		},

		world = {
			on = false, fullbright = false, fov = 70, noFog = false,
			brightness = 1, ambient = BLACK, outdoor = BLACK,
			exposure = 1, colorGrade = false, saturation = 0, contrast = 0,
		},
	}
end

local RING_PRESETS = {
	killaura = { radius = 14, color = rgb(255, 70, 70), thickness = 2, style = "solid", spin = 0.4, glow = true, ticks = 12, tickLen = 0.8 },
	reach    = { radius = 6, color = rgb(90, 200, 255), thickness = 2, style = "dashed", pulse = true },
	grab     = { radius = 4, color = rgb(90, 255, 150), thickness = 2, style = "solid", fill = true, fillAlpha = 0.1 },
	rainbow  = { radius = 12, color = rawc(1,1,1), thickness = 3, fx = "rainbow", spin = 1, glow = true },
	neon     = { radius = 10, color = rgb(190, 70, 235), thickness = 2, glow = true, glowAlpha = 0.5, pulse = true },
	target   = { radius = 8, color = rgb(255, 160, 40), thickness = 2, shape = "radar", spin = 2 },
}

local function deepClone(src)
	local out = {}
	for k, val in pairs(src) do
		local tv = typeof(val)
		if type(val) == "table" and tv ~= "Color3" and tv ~= "Vector3" and tv ~= "Vector2" then
			out[k] = deepClone(val)
		else
			out[k] = val
		end
	end
	return out
end

local function merge(into, from)
	for k, val in pairs(from) do
		if type(val) == "table" and type(into[k]) == "table" and typeof(val) ~= "Color3" then
			merge(into[k], val)
		else
			into[k] = val
		end
	end
end

local function jitter(seed)
	local x = sin(seed * 127.1 + 311.7) * 43758.5453
	return x - floor(x)
end

local ESP = {}
ESP.__index = ESP
ESP.version = "3.0.0"

function ESP.new(overrides)
	local self = setmetatable({}, ESP)
	self.cfg = baseConfig()
	if overrides then merge(self.cfg, overrides) end

	self.pool = Pool.new()
	self.ring = RaycastParams.new()
	self.ring.FilterType = Enum.RaycastFilterType.Exclude

	self.flagProviders = {}
	self.entities  = {}
	self.selfRings = {}
	self.tagHooks  = {}
	self.modules   = {}
	self.moduleOrder = {}
	self._pctx = { esp = self }

	self.hl   = {}
	self.mat  = {}
	self.matKind = {}
	self.hits = {}
	self.hpMem= {}
	self.btrk = {}
	self.myTrail = {}

	self.running   = false
	self.clock     = 0
	self.frame     = 0
	self.lastTick  = 0
	self.worldSnap = nil
	self.roster    = {}
	self.rosterN   = 0

	self.gunOf = function(plr)
		local rig = plr.Character
		local tool = rig and rig:FindFirstChildOfClass("Tool")
		return tool and tool.Name
	end

	self:installFlags()
	return self
end

function ESP:project(worldPos)
	local scr, onScreen = cam:WorldToViewportPoint(worldPos)
	return scr.X, scr.Y, scr.Z, onScreen
end

function ESP:sees(part, rig)
	local eye = cam.CFrame.Position
	self.ring.FilterDescendantsInstances = { me.Character, rig }
	return workspace:Raycast(eye, part.Position - eye, self.ring) == nil
end

function ESP:isAlly(plr)
	return plr.Team ~= nil and plr.Team == me.Team
end

function ESP:screenBox(rig)
	local pivot, size = rig:GetBoundingBox()
	local half = size * 0.5
	local lx, ly, hx, hy = huge, huge, -huge, -huge
	for i = 1, 8 do
		local x, y, depth = self:project((pivot * cnew(CORNERS[i] * half)).Position)
		if depth <= 0 then return nil end
		if x < lx then lx = x end
		if y < ly then ly = y end
		if x > hx then hx = x end
		if y > hy then hy = y end
	end
	return lx, ly, hx - lx, hy - ly
end

function ESP:footOf(root, hum)
	local drop = (hum and hum.HipHeight and hum.HipHeight > 0) and hum.HipHeight + 0.1 or 2.5
	return root.Position - v3(0, drop, 0)
end

function ESP:lodOf(dist)
	local perf = self.cfg.perf
	if perf.mode == "off" then return 0 end
	if dist <= perf.near then return 0 end
	if dist <= perf.mid then return 1 end
	if dist <= perf.far then return 2 end
	return 3
end

local function scaleSides(base, lod)
	if lod == 0 then return base end
	if lod == 1 then return math.max(8, floor(base * 0.66)) end
	if lod == 2 then return math.max(6, floor(base * 0.4)) end
	return math.max(4, floor(base * 0.25))
end

function ESP:worldRing(key, cx, cy, cz, radius, sides, color, thick, alpha, spin, opt)
	opt = opt or {}
	sides = clamp(floor(sides), 6, 128)
	spin = spin or 0
	local buf = self._rbuf
	if not buf then buf = {}; self._rbuf = buf end
	local origin = v3(cx, cy, cz)

	for i = 0, sides - 1 do
		local a = (i / sides) * TAU + spin
		local x, y, d = self:project(origin + v3(cos(a) * radius, 0, sin(a) * radius))
		local slot = buf[i + 1]
		if slot then slot[1], slot[2], slot[3] = x, y, d else buf[i + 1] = { x, y, d } end
	end

	local dashed, gap = opt.dashed, opt.gap or 2
	local glow, glowA = opt.glow, opt.glowAlpha or alpha * 0.35
	local fadeTo = opt.gradient
	for i = 1, sides do
		local a = buf[i]
		local b = buf[(i % sides) + 1]
		local shown = a[3] > 0 and b[3] > 0 and (not dashed or (i % gap == 0))
		if shown then
			local col = fadeTo and color:Lerp(fadeTo, i / sides) or color
			self.pool:line(key .. i, a[1], a[2], b[1], b[2], col, thick, alpha)
			if glow then self.pool:line(key .. "g" .. i, a[1], a[2], b[1], b[2], color, thick + 3, glowA) end
		end
	end

	if opt.filled then
		local cxs, cys, cd = self:project(origin)
		if cd > 0 then
			for i = 1, sides do
				local a, b = buf[i], buf[(i % sides) + 1]
				if a[3] > 0 and b[3] > 0 then
					self.pool:tri(key .. "f" .. i, cxs, cys, a[1], a[2], b[1], b[2], color, opt.fillAlpha or 0.08)
				end
			end
		end
	end
end

function ESP:worldPoly(key, cx, cy, cz, radius, faces, color, thick, alpha, spin)
	faces = clamp(floor(faces), 3, 16)
	local origin = v3(cx, cy, cz)
	local px, py, pd
	for i = 0, faces do
		local a = (i / faces) * TAU + (spin or 0)
		local x, y, d = self:project(origin + v3(cos(a) * radius, 0, sin(a) * radius))
		if px and pd > 0 and d > 0 then
			self.pool:line(key .. i, px, py, x, y, color, thick, alpha)
		end
		px, py, pd = x, y, d
	end
end

function ESP:worldStar(key, cx, cy, cz, outer, inner, points, color, thick, alpha, spin)
	points = clamp(floor(points), 3, 12)
	local origin = v3(cx, cy, cz)
	local n = points * 2
	local pts = {}
	for i = 0, n - 1 do
		local a = (i / n) * TAU + (spin or 0)
		local r = (i % 2 == 0) and outer or inner
		local x, y, d = self:project(origin + v3(cos(a) * r, 0, sin(a) * r))
		pts[i + 1] = { x, y, d }
	end
	for i = 1, n do
		local a, b = pts[i], pts[(i % n) + 1]
		if a[3] > 0 and b[3] > 0 then
			self.pool:line(key .. i, a[1], a[2], b[1], b[2], color, thick, alpha)
		end
	end
end

function ESP:worldSweep(key, cx, cy, cz, radius, angle, arc, sides, color, thick, alpha)
	sides = clamp(floor(sides), 2, 32)
	local origin = v3(cx, cy, cz)
	local px, py, pd
	for i = 0, sides do
		local a = angle - arc + (i / sides) * arc
		local x, y, d = self:project(origin + v3(cos(a) * radius, 0, sin(a) * radius))
		if px and pd > 0 and d > 0 then
			self.pool:line(key .. i, px, py, x, y, color, thick, alpha * (i / sides))
		end
		px, py, pd = x, y, d
	end
end

function ESP:worldBall(key, cx, cy, cz, radius, bands, sides, color, thick, alpha, spin)
	sides = clamp(floor(sides), 6, 64)
	bands = clamp(floor(bands), 2, 16)
	local origin = v3(cx, cy, cz)
	local n = 0
	local function span(pa, pb)
		if pa and pa[3] > 0 and pb[3] > 0 then
			n = n + 1
			self.pool:line(key .. n, pa[1], pa[2], pb[1], pb[2], color, thick, alpha)
		end
	end
	for r = 1, bands do
		local frac = r / (bands + 1)
		local y = (frac - 0.5) * 2 * radius
		local rr = sqrt(math.max(radius * radius - y * y, 0))
		local prev
		for i = 0, sides do
			local a = (i / sides) * TAU + spin
			local x, yy, d = self:project(origin + v3(cos(a) * rr, y, sin(a) * rr))
			local cur = { x, yy, d }
			if prev then span(prev, cur) end
			prev = cur
		end
	end
	local mer = math.max(4, floor(sides / 4))
	for m = 0, mer - 1 do
		local ang = (m / mer) * pi + spin
		local prev
		for i = 0, sides do
			local t = (i / sides) * TAU
			local x, yy, d = self:project(origin + v3(cos(t) * radius * cos(ang), sin(t) * radius, cos(t) * radius * sin(ang)))
			local cur = { x, yy, d }
			if prev then span(prev, cur) end
			prev = cur
		end
	end
end

function ESP:worldSpark(key, wx, wy, wz, size, color, alpha)
	local x, y, d = self:project(v3(wx, wy, wz))
	if d <= 0 then return false end
	self.pool:dot(key, x, y, size, color, true, alpha or 1, 10)
	return true
end

function ESP:paintRing(key, cx, cy, cz, ring, tint, lod)
	local spin = self.clock * (ring.spin or 0)
	local alpha = ring.alpha or 1
	if ring.pulse then alpha = alpha * (0.55 + 0.45 * sin(self.clock * (ring.pulseRate or 3))) end

	local color = ring.color
	if ring.fx == "rainbow" then
		color = hueAt(self.clock * 0.15 + (tint or 0) * 0.08)
	elseif ring.fx == "breathe" then
		color = ring.color:Lerp(ring.color2 or rawc(1,1,1), 0.5 + 0.5 * sin(self.clock * 2))
	end

	local sides = scaleSides(ring.sides or self.cfg.perf.ringDetail, lod or 0)
	local shape = ring.shape or "circle"

	if shape == "square" then
		return self:worldPoly(key, cx, cy, cz, ring.radius, 4, color, ring.thickness or 2, alpha, spin + 0.785)
	elseif shape == "pentagon" then
		return self:worldPoly(key, cx, cy, cz, ring.radius, 5, color, ring.thickness or 2, alpha, spin)
	elseif shape == "hexagon" then
		return self:worldPoly(key, cx, cy, cz, ring.radius, 6, color, ring.thickness or 2, alpha, spin)
	elseif shape == "star" then
		return self:worldStar(key, cx, cy, cz, ring.radius, ring.radius * 0.5, ring.starPoints or 5, color, ring.thickness or 2, alpha, spin)
	elseif shape == "radar" then
		self:worldRing(key .. "b", cx, cy, cz, ring.radius, sides, color, 1, alpha * 0.4, 0, nil)
		return self:worldSweep(key .. "s", cx, cy, cz, ring.radius, self.clock * (ring.spin ~= 0 and ring.spin or 2), ring.arc or 1.2, 20, color, ring.thickness or 2, alpha)
	end

	self:worldRing(key, cx, cy, cz, ring.radius, sides, color, ring.thickness or 2, alpha, spin, {
		dashed = ring.style == "dashed",
		gap = ring.dashGap or 2,
		gradient = ring.gradient,
		glow = ring.glow,
		glowAlpha = ring.glowAlpha,
		filled = ring.fill,
		fillAlpha = ring.fillAlpha,
	})

	if ring.ticks and ring.ticks > 0 and (lod or 0) < 2 then
		local origin = v3(cx, cy, cz)
		for t = 0, ring.ticks - 1 do
			local a = (t / ring.ticks) * TAU + spin
			local ix, iy, id = self:project(origin + v3(cos(a) * ring.radius, 0, sin(a) * ring.radius))
			local ox, oy, od = self:project(origin + v3(cos(a) * (ring.radius + (ring.tickLen or 0.6)), ring.tickUp or 0.4, sin(a) * (ring.radius + (ring.tickLen or 0.6))))
			if id > 0 and od > 0 then
				self.pool:line(key .. "t" .. t, ix, iy, ox, oy, color, ring.thickness or 2, alpha)
			end
		end
	end
end

function ESP:attachRing(id, opt)
	opt = opt or {}
	local ring = deepClone(RING_PRESETS[opt.preset or "neon"])
	merge(ring, opt)
	ring.target = opt.target
	ring.lift = opt.lift or 0
	self.selfRings[id] = ring
	return ring
end

function ESP:detachRing(id) self.selfRings[id] = nil end
function ESP:clearRings() self.selfRings = {} end

function ESP:centerOf(target)
	if target == nil then
		local rig = me.Character
		local root = rig and rig:FindFirstChild("HumanoidRootPart")
		local hum = rig and rig:FindFirstChildOfClass("Humanoid")
		return root and self:footOf(root, hum) or nil
	end
	local kind = typeof(target)
	if kind == "Vector3" then return target end
	if kind == "function" then return target() end
	if kind == "Instance" then
		if target:IsA("Player") then
			local rig = target.Character
			local root = rig and rig:FindFirstChild("HumanoidRootPart")
			local hum = rig and rig:FindFirstChildOfClass("Humanoid")
			return root and self:footOf(root, hum) or nil
		elseif target:IsA("BasePart") then
			return target.Position - v3(0, target.Size.Y / 2, 0)
		elseif target:IsA("Model") then
			local base = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
			return base and base.Position or nil
		end
	end
end

function ESP:drawSelfRings()
	local n = 0
	for id, ring in pairs(self.selfRings) do
		n = n + 1
		local c = self:centerOf(ring.target)
		if c then
			c = c + v3(0, ring.lift or 0, 0)
			self:paintRing("sr" .. id, c.X, c.Y, c.Z, ring, n, 0)
		end
	end
end

function ESP:drawSelfWorld()
	local s = self.cfg.self
	if not (s.fx or s.rings) then return end
	local rig = me.Character
	local root = rig and rig:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local hum = rig:FindFirstChildOfClass("Humanoid")
	local foot = self:footOf(root, hum)
	if s.rings then
		for i, spec in ipairs(self.cfg.rings.specs) do
			self:paintRing("mefx_rg" .. i, foot.X, foot.Y, foot.Z, spec, i, 0)
		end
	end
	if s.fx then
		self:drawFx("mefx", foot, root.Position, 0)
	end
end

function ESP:addEntity(id, opt)
	assert(opt and opt.get, "entity needs a .get returning an Instance or Vector3")
	self.entities[id] = {
		get      = opt.get,
		label    = opt.label,
		color    = opt.color or self.cfg.box.color,
		box      = opt.box ~= false,
		name     = opt.name ~= false,
		distance = opt.distance == true,
		tracer   = opt.tracer == true,
		dot      = opt.dot == true,
		ring     = opt.ring,
		size     = opt.size or v3(3, 4, 3),
		maxRange = opt.maxRange or self.cfg.maxRange,
		draw     = opt.draw,
	}
	return self.entities[id]
end

function ESP:removeEntity(id) self.entities[id] = nil end

function ESP:resolveEntity(ent)
	local subject = ent.get()
	if not subject then return nil end
	local kind = typeof(subject)
	if kind == "Vector3" then return subject, nil end
	if kind == "Instance" then
		if subject:IsA("BasePart") then return subject.Position, subject.Size end
		if subject:IsA("Model") then
			local pivot, size = subject:GetBoundingBox()
			return pivot.Position, size
		end
	end
end

function ESP:drawEntities()
	local eye = cam.CFrame.Position
	for id, ent in pairs(self.entities) do
		local pos, size = self:resolveEntity(ent)
		if pos then
			local dist = (eye - pos).Magnitude
			if dist <= ent.maxRange then
				local x, y, depth, onScreen = self:project(pos)
				if onScreen and depth > 0 then
					local key = "ent" .. id
					size = size or ent.size
					local half = size * 0.5
					local lx, ly, hx, hy = huge, huge, -huge, -huge
					local ok = true
					for i = 1, 8 do
						local px, py, pd = self:project(pos + CORNERS[i] * half)
						if pd <= 0 then ok = false break end
						if px < lx then lx = px end
						if py < ly then ly = py end
						if px > hx then hx = px end
						if py > hy then hy = py end
					end
					if ok then
						local bw, bh = hx - lx, hy - ly
						local mid = lx + bw / 2
						if ent.box then
							self.pool:rect(key .. "bo", lx - 1, ly - 1, bw + 2, bh + 2, BLACK, false, 3, 1)
							self.pool:rect(key .. "b", lx, ly, bw, bh, ent.color, false, 1, 1)
						end
						if ent.dot then self.pool:dot(key .. "d", mid, hy, 3, ent.color, true, 1, 12) end
						local below = hy + 3
						if ent.name and ent.label then
							self.pool:text(key .. "n", ent.label, mid, ly - 16, 13, ent.color, true, FONTS.Plex, true)
						end
						if ent.distance then
							self.pool:text(key .. "ds", floor(dist) .. "m", mid, below, 11, ent.color, true, FONTS.Plex, true)
						end
						if ent.tracer then
							local vp = cam.ViewportSize
							self.pool:line(key .. "tr", vp.X / 2, vp.Y, mid, hy, ent.color, 1, 1)
						end
						if ent.ring then
							self:paintRing(key .. "r", pos.X, pos.Y - (size.Y / 2), pos.Z, ent.ring, 0, self:lodOf(dist))
						end
						if ent.draw then ent.draw(self, key, pos, lx, ly, bw, bh, dist) end
					end
				end
			end
		end
	end
end

local DEPTH = { top = Enum.HighlightDepthMode.AlwaysOnTop, occluded = Enum.HighlightDepthMode.Occluded }

function ESP:dropMatCham(uid)
	local saved = self.mat[uid]
	if not saved then return end
	for part, orig in pairs(saved) do
		if part.Parent then
			part.Material, part.Color, part.Transparency = orig[1], orig[2], orig[3]
		end
	end
	self.mat[uid] = nil
	self.matKind[uid] = nil
end

function ESP:killCham(uid)
	local h = self.hl[uid]
	if h then h:Destroy() self.hl[uid] = nil end
	self:dropMatCham(uid)
end

function ESP:paintCham(plr, rig, visible)
	local c = self.cfg.chams
	local uid = plr.UserId
	if not c.on or not rig then return self:killCham(uid) end

	local fill, line = c.fillColor, c.outlineColor
	if c.wallColors then
		local tint = visible and c.visible or c.hidden
		fill, line = tint, tint
	elseif c.rainbow then
		local tint = hueAt(self.clock * c.rainbowRate * 0.1 + uid * 0.05)
		fill, line = tint, tint
	end

	if c.mode == "material" then
		local live = self.hl[uid]
		if live then live:Destroy() self.hl[uid] = nil end
		local ok, mat = pcall(function() return Enum.Material[c.material] end)
		mat = ok and mat or Enum.Material.ForceField
		if self.matKind[uid] ~= c.material then
			self:dropMatCham(uid)
			self.matKind[uid] = c.material
		end
		local tint = (c.wallColors or c.rainbow) and fill or c.matColor
		local saved = self.mat[uid] or {}
		self.mat[uid] = saved
		for _, part in ipairs(rig:GetChildren()) do
			if part:IsA("BasePart") and part.Name ~= "HumanoidRootPart" and part.Transparency < 1 and (part.Name ~= "Head" or c.matHead) then
				if not saved[part] then saved[part] = { part.Material, part.Color, part.Transparency } end
				part.Material = mat
				part.Color = tint
				part.Transparency = clamp(c.matAlpha, 0, 0.95)
			end
		end
		return
	end

	self:dropMatCham(uid)
	local h = self.hl[uid]
	if not h or h.Parent ~= rig then
		if h then h:Destroy() end
		h = Instance.new("Highlight")
		h.Name = "esp_cham"
		h.Adornee = rig
		h.Parent = rig
		self.hl[uid] = h
	end
	h.Enabled = true
	h.FillColor = fill
	h.FillTransparency = c.fill and c.fillAlpha or 1
	h.OutlineColor = line
	h.OutlineTransparency = c.outline and c.outlineAlpha or 1
	h.DepthMode = DEPTH[c.depth] or DEPTH.top
end

function ESP:snapshotWorld()
	if self.worldSnap then return end
	self.worldSnap = {
		Lighting.Brightness, Lighting.Ambient, Lighting.OutdoorAmbient,
		Lighting.ExposureCompensation, Lighting.FogEnd, cam.FieldOfView,
	}
end

function ESP:restoreWorld()
	local s = self.worldSnap
	if not s then return end
	Lighting.Brightness = s[1]
	Lighting.Ambient = s[2]
	Lighting.OutdoorAmbient = s[3]
	Lighting.ExposureCompensation = s[4]
	Lighting.FogEnd = s[5]
	cam.FieldOfView = s[6]
	local grade = Lighting:FindFirstChild("esp_grade")
	if grade then grade:Destroy() end
	self.worldApplied = false
end

function ESP:driveWorld()
	local w = self.cfg.world
	if not w.on then
		if self.worldApplied then self:restoreWorld() end
		return
	end
	self:snapshotWorld()
	self.worldApplied = true
	Lighting.Brightness = w.fullbright and 3 or w.brightness
	Lighting.Ambient = w.ambient
	Lighting.OutdoorAmbient = w.outdoor
	Lighting.ExposureCompensation = w.exposure
	cam.FieldOfView = w.fov
	Lighting.FogEnd = w.noFog and 1e7 or self.worldSnap[5]

	local grade = Lighting:FindFirstChild("esp_grade")
	if not grade then
		grade = Instance.new("ColorCorrectionEffect")
		grade.Name = "esp_grade"
		grade.Parent = Lighting
	end
	grade.Enabled = w.colorGrade
	grade.Saturation = w.saturation
	grade.Contrast = w.contrast
end

function ESP:addFlag(name, fn) self.flagProviders[name] = fn end
function ESP:removeFlag(name) self.flagProviders[name] = nil end

function ESP:installFlags()
	local white  = rgb(220, 220, 230)
	local green  = rgb(90, 235, 130)
	local red    = rgb(235, 80, 80)
	local blue   = rgb(120, 170, 255)
	local gold   = rgb(255, 210, 90)

	self:addFlag("visible", function(t)
		if t.visible == nil then return end
		return t.visible and { "V", green } or { "HID", red }
	end)
	self:addFlag("flying", function(t)
		local h = t.hum
		if h and (h:GetState() == Enum.HumanoidStateType.Freefall or h:GetState() == Enum.HumanoidStateType.Flying) then
			return { "FLY", blue }
		end
	end)
	self:addFlag("hp", function(t) return t.hum and { floor(t.hum.Health) .. "hp", green } or nil end)
	self:addFlag("distance", function(t) return { floor(t.dist) .. "m", white } end)
	self:addFlag("gun", function(t)
		local g = self.gunOf(t.plr)
		return g and { g, gold } or nil
	end)
	self:addFlag("speed", function(t)
		if not t.root then return end
		local v = floor(t.root.AssemblyLinearVelocity.Magnitude + 0.5)
		return v > 2 and { v .. " sps", rgb(120, 220, 255) } or nil
	end)
	self:addFlag("sprint", function(t) return (t.hum and t.hum.WalkSpeed > 18) and { "SPRINT", rgb(255, 170, 60) } or nil end)
	self:addFlag("frozen", function(t) return (t.hum and t.hum.WalkSpeed == 0 and t.hum.Health > 0) and { "FROZEN", rgb(140, 210, 255) } or nil end)
	self:addFlag("god", function(t) return (t.hum and t.hum.MaxHealth >= 1e6) and { "GOD", gold } or nil end)
end

function ESP:drawFlags(key, lx, ly, bw, ctx)
	local f = self.cfg.flags
	local right = f.side ~= "left"
	local col = right and lx + bw + 5 or lx - 5
	local row = ly
	local i = 0
	for _, provider in pairs(self.flagProviders) do
		local ok, out = pcall(provider, ctx)
		if ok and out then
			i = i + 1
			local d = self.pool:grab(key .. "fl" .. i, "Text")
			sp(d, "Visible", true)
			sp(d, "Text", out[1])
			sp(d, "Size", f.size)
			sp(d, "Color", out[2] or f.color)
			sp(d, "Font", f.font)
			sp(d, "Outline", true)
			sp(d, "OutlineColor", BLACK)
			sp(d, "Center", false)
			sp(d, "Position", right and v2(col, row) or v2(col - d.TextBounds.X, row))
			row = row + f.size + f.spacing
		end
	end
end

function ESP:drawBones(key, rig, color, thick)
	local set = rig:FindFirstChild("UpperTorso") and RIG15 or RIG6
	for i, bone in ipairs(set) do
		local a = rig:FindFirstChild(bone[1])
		local b = rig:FindFirstChild(bone[2])
		if a and b then
			local ax, ay, ad = self:project(a.Position)
			local bx, by, bd = self:project(b.Position)
			if ad > 0 and bd > 0 then
				self.pool:line(key .. "s" .. i, ax, ay, bx, by, color, thick or 1)
			end
		end
	end
end

function ESP:drawTrailGhost(key, plr)
	local t = self.cfg.trail
	local hist = self.btrk[plr.UserId]
	if not hist then return end
	local total = #hist
	local n = 0
	for h = 1, total do
		local snap = hist[h]
		local a = t.fade and (h / total) or 1
		for _, bone in ipairs(snap.set) do
			local pa, pb = snap.joints[bone[1]], snap.joints[bone[2]]
			if pa and pb then
				local ax, ay, ad = self:project(pa)
				local bx, by, bd = self:project(pb)
				n = n + 1
				if ad > 0 and bd > 0 then
					self.pool:line(key .. "gh" .. n, ax, ay, bx, by, t.color, 1, t.alpha * a)
				end
			end
		end
	end
end

function ESP:draw3DBox(key, rig, color, cornered, thick)
	local pivot, size = rig:GetBoundingBox()
	local half = size * 0.5
	local pts = {}
	for i = 1, 8 do
		local x, y, d = self:project((pivot * cnew(CORNERS[i] * half)).Position)
		if d <= 0 then return end
		pts[i] = { x, y }
	end
	for i, edge in ipairs(EDGES) do
		local a, b = pts[edge[1]], pts[edge[2]]
		if cornered then
			local dx, dy = b[1] - a[1], b[2] - a[2]
			local len = sqrt(dx * dx + dy * dy)
			if len > 0 then
				local ux, uy, q = dx / len, dy / len, len * 0.25
				self.pool:line(key .. "e" .. i, a[1], a[2], a[1] + ux * q, a[2] + uy * q, color, thick)
				self.pool:line(key .. "f" .. i, b[1], b[2], b[1] - ux * q, b[2] - uy * q, color, thick)
			end
		else
			self.pool:line(key .. "e" .. i, a[1], a[2], b[1], b[2], color, thick)
		end
	end
end

function ESP:drawPlayer(plr, rig, root, hum, head, lx, ly, bw, bh, dist, visible, lod)
	local cfg = self.cfg
	local key = "p" .. plr.UserId
	local mid = lx + bw / 2
	local labelsOnly = lod >= 3 and cfg.perf.labelsOnlyFar and cfg.perf.mode ~= "off"

	local accent = cfg.rainbow and hueAt(self.clock * cfg.rainbowRate * 0.1) or cfg.box.color
	if cfg.wallColors and visible ~= nil then
		accent = visible and cfg.visible or cfg.hidden
	end
	if cfg.pulse.on and hum.MaxHealth > 0 and hum.Health / hum.MaxHealth <= cfg.pulse.threshold then
		accent = accent:Lerp(cfg.pulse.color, 0.5 + 0.5 * sin(self.clock * cfg.pulse.rate))
	end

	local hit = self.hits[plr.UserId]
	if cfg.hit.on and hit and self.clock - hit.at < cfg.hit.life then
		accent = accent:Lerp(cfg.hit.flash, 1 - (self.clock - hit.at) / cfg.hit.life)
	end

	if not labelsOnly then
		if cfg.glow.on then
			local g = cfg.glow
			local beat = g.pulse and (0.5 + 0.5 * sin(self.clock * g.rate)) or 1
			for i = 1, g.layers do
				local pad = i * g.spread
				self.pool:rect(key .. "gl" .. i, lx - pad, ly - pad, bw + pad * 2, bh + pad * 2, g.color, false, 1, g.alpha * beat * (1 - (i - 1) / g.layers))
			end
		end
		if cfg.trail.on and lod < 2 then self:drawTrailGhost(key, plr) end

		if cfg.box.on then
			local b = cfg.box
			if b.style == "3d" then
				self:draw3DBox(key, rig, accent, false, b.thickness)
			elseif b.style == "3dcorner" then
				self:draw3DBox(key, rig, accent, true, b.thickness)
			elseif b.style == "corner" then
				local len = math.min(bw, bh) * b.cornerScale
				local seg = {
					lx, ly, lx + len, ly,   lx, ly, lx, ly + len,
					lx + bw, ly, lx + bw - len, ly,   lx + bw, ly, lx + bw, ly + len,
					lx, ly + bh, lx + len, ly + bh,   lx, ly + bh, lx, ly + bh - len,
					lx + bw, ly + bh, lx + bw - len, ly + bh,   lx + bw, ly + bh, lx + bw, ly + bh - len,
				}
				for i = 1, 8 do
					local o = (i - 1) * 4
					if b.outline then self.pool:line(key .. "co" .. i, seg[o+1], seg[o+2], seg[o+3], seg[o+4], BLACK, b.thickness + 2) end
					self.pool:line(key .. "c" .. i, seg[o+1], seg[o+2], seg[o+3], seg[o+4], accent, b.thickness)
				end
			else
				if b.outline then self.pool:rect(key .. "bo", lx - 1, ly - 1, bw + 2, bh + 2, BLACK, false, b.thickness + 2) end
				self.pool:rect(key .. "b", lx, ly, bw, bh, accent, false, b.thickness)
			end
			if b.fill then self.pool:rect(key .. "bf", lx, ly, bw, bh, b.fillColor, true, 1, b.fillAlpha) end
		end

		if cfg.bones.on and lod < 2 then self:drawBones(key, rig, cfg.rainbow and accent or cfg.bones.color, cfg.bones.thickness) end

		if cfg.hp.on and hum.MaxHealth > 0 then
			local h = cfg.hp
			local pct = clamp(hum.Health / hum.MaxHealth, 0, 1)
			local col = h.side ~= "right"
			local bx = col and lx - 4 - h.thickness or lx + bw + 4
			if h.outline then self.pool:rect(key .. "ho", bx - 1, ly - 1, h.thickness + 2, bh + 2, BLACK, true, 1, 0.7) end
			self.pool:rect(key .. "hg", bx, ly, h.thickness, bh, rawc(0.1, 0.1, 0.12), true, 1, 0.6)
			local barCol = h.gradient and h.low:Lerp(h.full, pct) or (pct < 0.3 and h.low or h.full)
			local fillH = bh * pct
			self.pool:rect(key .. "hf", bx, ly + (bh - fillH), h.thickness, math.max(fillH, 1), barCol, true, 1, 1)
			if h.notch then self.pool:line(key .. "hn", bx, ly + bh * 0.5, bx + h.thickness, ly + bh * 0.5, BLACK, 1, 0.5) end
			if h.showText and pct < 1 then self.pool:text(key .. "ht", tostring(floor(pct * 100)), bx + h.thickness / 2, ly - 12, 10, rawc(1,1,1), true, FONTS.Plex, true) end
		end

		if cfg.armor.on then
			local a = cfg.armor
			local val = plr:GetAttribute(a.attr)
			if val then
				local maxv = plr:GetAttribute(a.maxAttr) or 100
				local pct = clamp(val / maxv, 0, 1)
				local ay = ly + bh + 3
				if a.outline then self.pool:rect(key .. "ao", lx - 1, ay - 1, bw + 2, a.thickness + 2, BLACK, true, 1, 0.7) end
				self.pool:rect(key .. "ag", lx, ay, bw, a.thickness, rawc(0.1, 0.1, 0.12), true, 1, 0.6)
				self.pool:rect(key .. "af", lx, ay, bw * pct, a.thickness, a.color, true, 1, 1)
			end
		end

		if cfg.headDot.on and head then
			local hx, hy, hd = self:project(head.Position)
			if hd > 0 then self.pool:dot(key .. "hd", hx, hy, clamp(cfg.headDot.size, 1, 15), cfg.rainbow and accent or cfg.headDot.color, true, 1, 12) end
		end
		if cfg.gaze.on and head then
			local hx, hy, hd = self:project(head.Position)
			local gx, gy, gd = self:project(head.Position + head.CFrame.LookVector * cfg.gaze.length)
			if hd > 0 and gd > 0 then self.pool:line(key .. "gz", hx, hy, gx, gy, cfg.rainbow and accent or cfg.gaze.color, 1) end
		end
		if cfg.tracer.on then
			local vp = cam.ViewportSize
			local ox, oy = vp.X / 2, vp.Y
			local from = cfg.tracer.from
			if from == "center" then oy = vp.Y / 2 elseif from == "top" then oy = 0 elseif from == "mouse" then local m = Input:GetMouseLocation() ox, oy = m.X, m.Y end
			self.pool:line(key .. "tr", ox, oy, mid, ly + bh, cfg.rainbow and accent or cfg.tracer.color, cfg.tracer.thickness)
		end
	end

	local topY = ly - 4
	if cfg.name.on then
		local n = cfg.name
		local label = n.showUser and ("@" .. plr.Name) or plr.DisplayName
		topY = topY - n.size
		if n.shadow then self.pool:text(key .. "nsh", label, mid + 1, topY + 1, n.size, BLACK, true, n.font, false) end
		self.pool:text(key .. "n", label, mid, topY, n.size, cfg.wallColors and accent or n.color, true, n.font, true)
	end

	local below = ly + bh + 3
	if cfg.gun.on then
		local g = self.gunOf(plr)
		if g then
			local ammo = plr:GetAttribute(cfg.gun.ammoAttr)
			if ammo then g = g .. " [" .. tostring(ammo) .. "]" end
			self.pool:text(key .. "g", g, mid, below, cfg.gun.size, cfg.gun.color, true, FONTS.Plex, true)
			below = below + cfg.gun.size
		end
	end
	if cfg.dist.on then
		self.pool:text(key .. "d", floor(dist) .. cfg.dist.suffix, mid, below, cfg.dist.size, cfg.dist.color, true, FONTS.Plex, true)
	end

	if cfg.flags.on and not labelsOnly then
		self:drawFlags(key, lx, ly, bw, { plr = plr, rig = rig, root = root, hum = hum, head = head, dist = dist, visible = visible, esp = self })
	end

	if cfg.hit.on and cfg.hit.showDmg and hit and self.clock - hit.at < cfg.hit.life and hit.dmg and hit.dmg > 0 then
		local prog = (self.clock - hit.at) / cfg.hit.life
		self.pool:text(key .. "dm", "-" .. hit.dmg, mid + 20, ly + bh * 0.3 - prog * 15, 13, cfg.hit.dmgColor, true, FONTS.Plex, true)
	end

	if not labelsOnly then
		local foot = self:footOf(root, hum)
		if cfg.rings.on and cfg.rings.onEnemies then
			for i, spec in ipairs(cfg.rings.specs) do
				self:paintRing(key .. "rg" .. i, foot.X, foot.Y, foot.Z, spec, i, lod)
			end
		end
		if cfg.ball.on and cfg.ball.onEnemies then
			local b = cfg.ball
			local col = b.fx == "rainbow" and hueAt(self.clock * 0.15) or b.color
			self:worldBall(key .. "bl", root.Position.X, root.Position.Y, root.Position.Z, b.radius, b.rings, scaleSides(self.cfg.perf.ballDetail, lod), col, b.thickness, b.alpha, self.clock * (b.spin or 0))
		end
		if cfg.fx.onEnemies and not (lod >= 3 and cfg.perf.dropFxFar) then
			self:drawFx(key, foot, root.Position, lod)
		end
		for _, hook in pairs(self.tagHooks) do
			pcall(hook, self, plr, rig, lx, ly, bw, bh, dist)
		end
		if self.moduleOrder[1] then
			local ctx = self._pctx
			ctx.plr, ctx.rig, ctx.root, ctx.hum, ctx.head = plr, rig, root, hum, head
			ctx.x, ctx.y, ctx.w, ctx.h, ctx.dist, ctx.visible, ctx.lod = lx, ly, bw, bh, dist, visible, lod
			ctx.key, ctx.accent, ctx.foot = key, accent, foot
			for _, name in ipairs(self.moduleOrder) do
				local mod = self.modules[name]
				if mod.enabled and mod.player then
					pcall(mod.player, mod.state, ctx)
				end
			end
		end
	end
end

function ESP:drawFx(key, foot, mid, lod)
	local fx = self.cfg.fx
	local t = self.clock
	local density = self.cfg.perf.fxDensity
	if lod >= 2 then density = density * 0.5 end
	local fx0, fy0, fz0 = foot.X, foot.Y, foot.Z
	local mx, my, mz = mid.X, mid.Y, mid.Z

	if fx.confetti.on then
		local c = fx.confetti
		for i = 1, math.max(1, floor(c.count * density)) do
			local ang = jitter(i) * TAU
			local rad = c.radius * (0.3 + 0.7 * jitter(i * 1.7))
			local ph = (t * c.speed * (0.7 + 0.6 * jitter(i * 2.3)) * 0.1 + jitter(i * 3.1)) % 1
			local sway = sin(t * 3 + i) * 0.6
			local col = c.rainbow and hueAt(jitter(i * 5.9) + t * 0.2) or c.color
			self:worldSpark(key .. "cf" .. i, fx0 + cos(ang) * rad + sway, fy0 + c.height * (1 - ph), fz0 + sin(ang) * rad, c.size * (0.6 + 0.5 * (1 - ph)), col, clamp(ph * 3, 0, 1))
		end
	end

	if fx.rain.on then
		local r = fx.rain
		for i = 1, math.max(1, floor(r.count * density)) do
			local ang = jitter(i * 1.3) * TAU
			local rad = r.radius * jitter(i * 2.7)
			local ph = (t * r.speed + jitter(i) * r.height) % r.height
			local yt = r.height - ph
			local ax, ay, ad = self:project(v3(fx0 + cos(ang) * rad, fy0 + yt, fz0 + sin(ang) * rad))
			local bx, by, bd = self:project(v3(fx0 + cos(ang) * rad, fy0 + yt - r.length, fz0 + sin(ang) * rad))
			if ad > 0 and bd > 0 then
				local col = r.rainbow and hsv((t * 0.1 + jitter(i)) % 1, 0.6, 1) or r.color
				self.pool:line(key .. "rn" .. i, ax, ay, bx, by, col, 1, r.alpha)
			end
		end
	end

	if fx.synth.on then
		local s = fx.synth
		local sides = scaleSides(s.sides, lod)
		for i = 1, s.rings do
			local frac = ((t * s.speed * 0.1) + i / s.rings) % 1
			local rad = math.max(s.radius * frac, 0.1)
			local y = s.rise and s.radius * frac * 0.5 or 0
			local fade = s.alpha * (1 - frac)
			self:worldRing(key .. "sy" .. i .. "_", fx0, fy0 + y, fz0, rad, sides, hsv((s.hue + frac * s.hueSpan) % 1, 1, 1), s.thickness, fade, 0, s.glow and { glow = true, glowAlpha = fade * 0.4 } or nil)
		end
	end

	if fx.orbit.on then
		local o = fx.orbit
		for i = 1, o.count do
			local base = (i / o.count) * TAU
			local ang = t * o.speed + base
			local col = o.rainbow and hueAt(t * 0.2 + i / o.count) or o.color
			self:worldSpark(key .. "ob" .. i, mx + cos(ang) * o.radius, my + sin(t * o.speed * 1.3 + base) * o.lift, mz + sin(ang) * o.radius, o.size, col, 1)
			if o.trail and lod < 2 then
				for k = 1, o.trailLen do
					local ta = ang - k * 0.12
					self:worldSpark(key .. "obt" .. i .. "_" .. k, mx + cos(ta) * o.radius, my + sin(t * o.speed * 1.3 + base - k * 0.12) * o.lift, mz + sin(ta) * o.radius, o.size * (1 - k / (o.trailLen + 1)), col, 1 - k / (o.trailLen + 1))
				end
			end
		end
	end

	if fx.spiral.on then
		local s = fx.spiral
		local px, py, pd
		for i = 0, s.points do
			local frac = i / s.points
			local ang = frac * TAU * s.turns + t * s.speed
			local rad = s.radius * frac
			local x, y, d = self:project(v3(fx0 + cos(ang) * rad, fy0 + s.height * frac, fz0 + sin(ang) * rad))
			if px and pd > 0 and d > 0 then
				self.pool:line(key .. "sp" .. i, px, py, x, y, s.rainbow and hueAt(frac + t * 0.2) or s.color, s.thickness, s.alpha)
			end
			px, py, pd = x, y, d
		end
	end

	if fx.vortex.on then
		local vx = fx.vortex
		for i = 1, math.max(1, floor(vx.count * density)) do
			local base = jitter(i) * TAU
			local life = (t * vx.speed * 0.1 + jitter(i * 2.1)) % 1
			local rad = vx.radius * (1 - life)
			local ang = base + life * TAU * vx.twist
			local col = vx.rainbow and hueAt(life + t * 0.2) or vx.color
			self:worldSpark(key .. "vx" .. i, fx0 + cos(ang) * rad, fy0 + vx.height * life, fz0 + sin(ang) * rad, vx.size * (1 - life * 0.5), col, clamp(life * 2, 0, 1))
		end
	end

	if fx.shock.on then
		local s = fx.shock
		for w = 1, s.waves do
			local frac = ((t * s.speed * 0.1) + w / s.waves) % 1
			self:worldRing(key .. "sh" .. w, fx0, fy0, fz0, math.max(s.radius * frac, 0.1), scaleSides(s.sides, lod), s.color, s.thickness, s.alpha * (1 - frac), 0, { glow = true, glowAlpha = s.alpha * (1 - frac) * 0.5 })
		end
	end

	if fx.aura.on then
		local au = fx.aura
		local sides = scaleSides(au.sides, lod)
		for i = 1, au.rings do
			local ang = t * au.speed * (i % 2 == 0 and 1 or -1)
			local tilt = (i / au.rings) * pi
			local px, py, pd
			for s = 0, sides do
				local a = (s / sides) * TAU
				local ax = cos(a) * au.radius
				local ay = sin(a) * au.radius * sin(tilt)
				local az = sin(a) * au.radius * cos(tilt)
				local rx = ax * cos(ang) - az * sin(ang)
				local rz = ax * sin(ang) + az * cos(ang)
				local x, y, d = self:project(v3(mx + rx, my + ay, mz + rz))
				if px and pd > 0 and d > 0 then
					self.pool:line(key .. "au" .. i .. "_" .. s, px, py, x, y, au.rainbow and hueAt(i / au.rings + t * 0.15) or au.color, au.thickness, au.alpha)
				end
				px, py, pd = x, y, d
			end
		end
	end

	if fx.flies.on then
		local ff = fx.flies
		for i = 1, math.max(1, floor(ff.count * density)) do
			local tt = t * ff.speed * 0.1
			local ax = sin(tt + jitter(i) * TAU) * ff.radius
			local az = cos(tt * 1.3 + jitter(i * 2.1) * TAU) * ff.radius
			local ay = ff.height * (0.3 + 0.7 * (0.5 + 0.5 * sin(tt * 2 + i)))
			local flick = 0.4 + 0.6 * (0.5 + 0.5 * sin(t * 8 + i * 1.7))
			local col = ff.rainbow and hsv((jitter(i) + t * 0.1) % 1, 0.7, 1) or ff.color
			self:worldSpark(key .. "fl" .. i, fx0 + ax, fy0 + ay, fz0 + az, ff.size * flick, col, flick)
		end
	end

	if fx.bolt.on and lod < 2 then
		local b = fx.bolt
		for j = 1, b.count do
			local stamp = floor(t * b.speed + j)
			local seed = stamp * 13.1 + j * 7.3
			local ang = jitter(seed) * TAU
			local flash = 1 - (t * b.speed % 1)
			local prev = v3(fx0 + cos(ang) * b.radius, fy0 + b.height, fz0 + sin(ang) * b.radius)
			for s = 1, b.segs do
				local frac = s / b.segs
				local jx = (jitter(seed + s) - 0.5) * b.jitter
				local jz = (jitter(seed + s * 2.3) - 0.5) * b.jitter
				local cur = v3(fx0 + cos(ang) * b.radius * (1 - frac) + jx, fy0 + b.height * (1 - frac), fz0 + sin(ang) * b.radius * (1 - frac) + jz)
				local ax, ay, ad = self:project(prev)
				local bx, by, bd = self:project(cur)
				if ad > 0 and bd > 0 then
					self.pool:line(key .. "bo" .. j .. "_" .. s, ax, ay, bx, by, b.color, b.thickness, clamp(flash * b.alpha, 0, 1))
				end
				prev = cur
			end
		end
	end

	if fx.helix.on then
		local hx = fx.helix
		for strand = 0, hx.strands - 1 do
			local off = (strand / hx.strands) * TAU
			local px, py, pd
			for i = 0, hx.points do
				local frac = i / hx.points
				local ang = frac * TAU * hx.turns + t * hx.speed + off
				local x, y, d = self:project(v3(mx + cos(ang) * hx.radius, my + hx.height * frac - hx.height / 2, mz + sin(ang) * hx.radius))
				if px and pd > 0 and d > 0 then
					self.pool:line(key .. "hx" .. strand .. "_" .. i, px, py, x, y, hx.rainbow and hueAt(frac + t * 0.2) or hx.color, hx.thickness, hx.alpha)
				end
				px, py, pd = x, y, d
			end
		end
	end

	if fx.pulse.on then
		local p = fx.pulse
		local beat = (t * p.speed) % 1
		local swell = beat < 0.15 and beat / 0.15 or math.max(0, 1 - (beat - 0.15) / 0.85)
		self:worldRing(key .. "pl", fx0, fy0, fz0, p.radius * (0.6 + 0.4 * swell), scaleSides(p.sides, lod), p.color, p.thickness, p.alpha * (0.4 + 0.6 * swell), 0, { glow = true, glowAlpha = 0.3 * swell })
	end

	if fx.tornado.on then
		local tn = fx.tornado
		for i = 1, math.max(1, floor(tn.count * density)) do
			local seed = jitter(i)
			local life = (t * tn.speed * 0.1 + seed) % 1
			local rad = tn.radius * (0.2 + 0.8 * (1 - life))
			local ang = seed * TAU + t * tn.spin + life * TAU * tn.twist
			local col = tn.rainbow and hsv((life + t * 0.15) % 1, 0.8, 1) or tn.color
			self:worldSpark(key .. "tn" .. i, fx0 + cos(ang) * rad, fy0 + tn.height * life, fz0 + sin(ang) * rad, tn.size * (0.5 + life * 0.5), col, clamp((1 - life) * 2, 0, 1))
		end
	end

	if fx.portal.on then
		local po = fx.portal
		for i = 1, po.rings do
			local frac = i / po.rings
			local rad = po.radius * frac + sin(t * po.speed + i) * 0.3
			self:worldRing(key .. "po" .. i, fx0, fy0, fz0, rad, scaleSides(po.sides, lod), hsv((po.hue + frac * 0.3 + t * 0.1) % 1, 1, 1), po.thickness, po.alpha, t * po.spin * (i % 2 == 0 and 1 or -1), { glow = true, glowAlpha = po.alpha * 0.4 })
		end
	end

	if fx.snow.on then
		local sn = fx.snow
		for i = 1, math.max(1, floor(sn.count * density)) do
			local seed = jitter(i)
			local ang = seed * TAU
			local rad = sn.radius * jitter(i * 1.7)
			local ph = (t * sn.speed * 0.1 + seed) % 1
			self:worldSpark(key .. "sn" .. i, fx0 + cos(ang) * rad + sin(t * 2 + i) * 0.8, fy0 + sn.height * (1 - ph), fz0 + sin(ang) * rad, sn.size, sn.color, sn.alpha)
		end
	end

	if fx.embers.on then
		local em = fx.embers
		for i = 1, math.max(1, floor(em.count * density)) do
			local seed = jitter(i)
			local ang = seed * TAU
			local rad = em.radius * jitter(i * 2.3) * (0.5 + 0.5 * sin(t + i))
			local ph = (t * em.speed * 0.1 + seed) % 1
			local heat = 1 - ph
			self:worldSpark(key .. "em" .. i, fx0 + cos(ang) * rad, fy0 + em.height * ph, fz0 + sin(ang) * rad, em.size * heat, rgb(255, floor(120 + 100 * heat), floor(40 * heat)), clamp(heat * 1.5, 0, 1))
		end
	end

	if fx.radar.on then
		local ra = fx.radar
		self:worldRing(key .. "rab", fx0, fy0, fz0, ra.radius, scaleSides(ra.sides, lod), ra.color, 1, ra.alpha * 0.4, 0, nil)
		self:worldSweep(key .. "ras", fx0, fy0, fz0, ra.radius, t * ra.speed, ra.arc, scaleSides(20, lod), ra.color, ra.thickness, ra.alpha)
	end

	if fx.burst.on then
		local bu = fx.burst
		self:worldStar(key .. "bu", mx, my, mz, bu.outer, bu.inner, bu.points, bu.rainbow and hueAt(t * 0.2) or bu.color, bu.thickness, bu.alpha, t * bu.spin)
	end

	if fx.ripple.on then
		local rp = fx.ripple
		local sides = scaleSides(rp.sides, lod)
		for w = 1, rp.waves do
			local frac = ((t * rp.speed * 0.1) + w / rp.waves) % 1
			local rad = math.max(rp.radius * frac, 0.1)
			self:worldRing(key .. "rp" .. w .. "_", fx0, fy0 + 0.05, fz0, rad, sides, rp.color, 1, 0, 0, { filled = true, fillAlpha = rp.alpha * (1 - frac) })
		end
	end

	if fx.beam.on then
		local bm = fx.beam
		for i = 1, bm.count do
			local ang = (i / bm.count) * TAU + t * bm.speed
			local px = fx0 + cos(ang) * bm.radius
			local pz = fz0 + sin(ang) * bm.radius
			local ax, ay, ad = self:project(v3(px, fy0, pz))
			local bx, by, bd = self:project(v3(px, fy0 + bm.height, pz))
			if ad > 0 and bd > 0 then
				local col = bm.rainbow and hueAt(t * 0.2 + i / bm.count) or bm.color
				self.pool:line(key .. "bm" .. i, ax, ay, bx, by, col, bm.thickness, bm.alpha)
			end
		end
	end
end

function ESP:drawSelfTrail()
	local t = self.cfg.self.trail
	if not t.on then return end
	local rig = me.Character
	local root = rig and rig:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local hist = self.myTrail
	local last = hist[#hist]
	if not last or self.clock - last.at >= t.gap then
		insert(hist, { at = self.clock, pos = root.Position - v3(0, 2.5, 0) })
		while #hist > t.ticks do remove(hist, 1) end
	end
	if #hist < 2 then return end
	for i = 1, #hist - 1 do
		local ax, ay, ad = self:project(hist[i].pos)
		local bx, by, bd = self:project(hist[i + 1].pos)
		if ad > 0 and bd > 0 then
			local frac = i / #hist
			self.pool:line("mt" .. i, ax, ay, bx, by, t.rainbow and hueAt(frac + self.clock * 0.2) or t.color, t.thickness, t.alpha * frac)
		end
	end
end

function ESP:drawFov()
	local f = self.cfg.self.fov
	if not f.on then return end
	local vp = cam.ViewportSize
	local col = f.rainbow and hueAt(self.clock * 0.2) or f.color
	self.pool:dot("fov", vp.X / 2, vp.Y / 2, f.radius, col, false, f.alpha, f.sides).Thickness = f.thickness
	if f.fill then self.pool:dot("fovf", vp.X / 2, vp.Y / 2, f.radius, col, true, f.fillAlpha, f.sides) end
end

function ESP:drawCross()
	local c = self.cfg.self.cross
	if not c.on then return end
	local vp = cam.ViewportSize
	local cx, cy = vp.X / 2, vp.Y / 2
	local col = c.rainbow and hueAt(self.clock * 0.3) or c.color
	local seg = {
		cx - c.gap - c.length, cy, cx - c.gap, cy,
		cx + c.gap, cy, cx + c.gap + c.length, cy,
		cx, cy - c.gap - c.length, cx, cy - c.gap,
		cx, cy + c.gap, cx, cy + c.gap + c.length,
	}
	for i = 1, 4 do
		local o = (i - 1) * 4
		if c.outline then self.pool:line("xo" .. i, seg[o+1], seg[o+2], seg[o+3], seg[o+4], BLACK, c.thickness + 2, c.alpha) end
		self.pool:line("xh" .. i, seg[o+1], seg[o+2], seg[o+3], seg[o+4], col, c.thickness, c.alpha)
	end
	if c.dot then self.pool:dot("xd", cx, cy, c.dotSize, col, true, c.alpha, 10) end
end

function ESP:drawPreview()
	local pv = self.cfg.self.preview
	if not pv.on then return end
	local vp = cam.ViewportSize
	local bw, bh = pv.w, pv.h
	local lx = pv.x
	local ly = pv.y ~= 0 and pv.y or vp.Y * 0.5 - bh * 0.5
	local mid = lx + bw / 2
	local cfg = self.cfg
	local rig = me.Character
	local hum = rig and rig:FindFirstChildOfClass("Humanoid")
	local hp, maxHp = pv.fakeHp, 100
	if hum and hp < 0 then hp, maxHp = hum.Health, hum.MaxHealth elseif hp < 0 then hp = 100 end
	local pct = maxHp > 0 and hp / maxHp or 1
	local accent = cfg.rainbow and hueAt(self.clock * cfg.rainbowRate * 0.1) or cfg.box.color

	if cfg.glow.on then
		local g = cfg.glow
		for i = 1, g.layers do
			local pad = i * g.spread
			self.pool:rect("pvg" .. i, lx - pad, ly - pad, bw + pad * 2, bh + pad * 2, g.color, false, 1, g.alpha * (1 - (i - 1) / g.layers))
		end
	end
	if cfg.box.on then
		local b = cfg.box
		if b.style == "corner" then
			local len = math.min(bw, bh) * b.cornerScale
			local seg = {
				lx, ly, lx + len, ly,   lx, ly, lx, ly + len,
				lx + bw, ly, lx + bw - len, ly,   lx + bw, ly, lx + bw, ly + len,
				lx, ly + bh, lx + len, ly + bh,   lx, ly + bh, lx, ly + bh - len,
				lx + bw, ly + bh, lx + bw - len, ly + bh,   lx + bw, ly + bh, lx + bw, ly + bh - len,
			}
			for i = 1, 8 do
				local o = (i - 1) * 4
				if b.outline then self.pool:line("pvc0" .. i, seg[o+1], seg[o+2], seg[o+3], seg[o+4], BLACK, b.thickness + 2) end
				self.pool:line("pvc" .. i, seg[o+1], seg[o+2], seg[o+3], seg[o+4], accent, b.thickness)
			end
		else
			if b.outline then self.pool:rect("pvbo", lx - 1, ly - 1, bw + 2, bh + 2, BLACK, false, b.thickness + 2) end
			self.pool:rect("pvb", lx, ly, bw, bh, accent, false, b.thickness)
		end
	end
	if cfg.hp.on then
		local h = cfg.hp
		local bx = lx - 4 - h.thickness
		self.pool:rect("pvho", bx - 1, ly - 1, h.thickness + 2, bh + 2, BLACK, true, 1, 0.7)
		self.pool:rect("pvhg", bx, ly, h.thickness, bh, rawc(0.1,0.1,0.12), true, 1, 0.6)
		local fillH = bh * pct
		self.pool:rect("pvhf", bx, ly + (bh - fillH), h.thickness, math.max(fillH, 1), h.gradient and h.low:Lerp(h.full, pct) or h.full, true, 1, 1)
	end
	if cfg.name.on then
		self.pool:text("pvn", me.DisplayName, mid, ly - 4 - cfg.name.size, cfg.name.size, cfg.name.color, true, cfg.name.font, true)
	end
	self.pool:text("pvlbl", "PREVIEW", mid, ly + bh + 6, 11, rgb(120, 120, 130), true, FONTS.Plex, true)
end

function ESP:markHit(uid, dmg)
	self.hits[uid] = { at = self.clock, dmg = dmg }
end

function ESP:trackHealth(plr, hum)
	local uid = plr.UserId
	local was = self.hpMem[uid]
	if was and hum.Health < was then self:markHit(uid, floor(was - hum.Health)) end
	self.hpMem[uid] = hum.Health
end

function ESP:recordGhost(plr, rig)
	local t = self.cfg.trail
	if not t.on then return end
	local uid = plr.UserId
	local hist = self.btrk[uid] or {}
	self.btrk[uid] = hist
	local last = hist[#hist]
	if last and self.clock - last.at < t.gap then return end
	local set = rig:FindFirstChild("UpperTorso") and RIG15 or RIG6
	local joints = {}
	for _, bone in ipairs(set) do
		for _, name in ipairs(bone) do
			if not joints[name] then
				local part = rig:FindFirstChild(name)
				if part then joints[name] = part.Position end
			end
		end
	end
	insert(hist, { at = self.clock, set = set, joints = joints })
	while #hist > t.ticks do remove(hist, 1) end
end

local function serialize(node, pad)
	local out = {}
	for k, val in pairs(node) do
		local key = type(k) == "number" and "[" .. k .. "]" or k
		if typeof(val) == "Color3" then
			out[#out+1] = pad .. key .. " = Color3.fromRGB(" .. floor(val.R*255) .. "," .. floor(val.G*255) .. "," .. floor(val.B*255) .. "),"
		elseif type(val) == "table" then
			out[#out+1] = pad .. key .. " = {"
			out[#out+1] = serialize(val, pad .. "  ")
			out[#out+1] = pad .. "},"
		elseif type(val) == "string" then
			out[#out+1] = pad .. key .. ' = "' .. val .. '",'
		else
			out[#out+1] = pad .. key .. " = " .. tostring(val) .. ","
		end
	end
	return table.concat(out, "\n")
end

function ESP:export()
	return "return {\n" .. serialize(self.cfg, "  ") .. "\n}"
end

function ESP:import(source)
	local chunk = loadstring(source)
	if not chunk then return false end
	local ok, loaded = pcall(chunk)
	if not ok or type(loaded) ~= "table" then return false end
	merge(self.cfg, loaded)
	return true
end

function ESP:save(name)
	if not isfolder("EasyESP") then makefolder("EasyESP") end
	writefile("EasyESP/" .. name .. ".txt", self:export())
end

function ESP:load(name)
	local path = "EasyESP/" .. name .. ".txt"
	if not isfile(path) then return false end
	return self:import(readfile(path))
end

function ESP:configs()
	if not isfolder("EasyESP") then return {} end
	local names = {}
	for _, path in ipairs(listfiles("EasyESP")) do
		local n = path:match("([^/\\]+)%.txt$")
		if n then names[#names+1] = n end
	end
	return names
end

function ESP:onDraw(name, fn) self.tagHooks[name] = fn end
function ESP:removeDraw(name) self.tagHooks[name] = nil end

function ESP:register(spec)
	assert(spec and spec.name, "module needs a name")
	local mod = {
		name    = spec.name,
		enabled = spec.enabled == true,
		state   = spec.state or {},
		setup   = spec.setup,
		player  = spec.player,
		world   = spec.world,
		screen  = spec.screen,
		teardown= spec.teardown,
	}
	mod.state.esp = self
	mod.state.cfg = mod.state.cfg or spec.config
	if self.modules[spec.name] and self.modules[spec.name].teardown then
		pcall(self.modules[spec.name].teardown, self.modules[spec.name].state)
	end
	if not self.modules[spec.name] then insert(self.moduleOrder, spec.name) end
	self.modules[spec.name] = mod
	if mod.setup then pcall(mod.setup, mod.state, self) end
	return mod
end

function ESP:module(name) return self.modules[name] end

function ESP:toggleModule(name, on)
	local mod = self.modules[name]
	if mod then mod.enabled = on == nil and not mod.enabled or on end
end

function ESP:unregister(name)
	local mod = self.modules[name]
	if not mod then return end
	if mod.teardown then pcall(mod.teardown, mod.state) end
	self.modules[name] = nil
	for i, n in ipairs(self.moduleOrder) do
		if n == name then remove(self.moduleOrder, i) break end
	end
end

function ESP:runModuleWorld()
	for _, name in ipairs(self.moduleOrder) do
		local mod = self.modules[name]
		if mod.enabled and mod.world then pcall(mod.world, mod.state, self) end
	end
end

function ESP:runModuleScreen()
	for _, name in ipairs(self.moduleOrder) do
		local mod = self.modules[name]
		if mod.enabled and mod.screen then pcall(mod.screen, mod.state, self) end
	end
end

function ESP:collectRoster()
	local eye = cam.CFrame.Position
	local roster, n = self.roster, 0
	for _, plr in ipairs(Players:GetPlayers()) do
		if plr ~= me then
			local rig = plr.Character
			local root = rig and rig:FindFirstChild("HumanoidRootPart")
			local hum = rig and rig:FindFirstChildOfClass("Humanoid")
			if not root or not hum or hum.Health <= 0 then
				local h = self.hl[plr.UserId]
				if h then h.Enabled = false end
				if self.mat[plr.UserId] then self:dropMatCham(plr.UserId) end
			else
				local dist = (eye - root.Position).Magnitude
				if dist <= self.cfg.maxRange then
					n = n + 1
					local slot = roster[n]
					if slot then
						slot.plr, slot.rig, slot.root, slot.hum, slot.dist = plr, rig, root, hum, dist
					else
						roster[n] = { plr = plr, rig = rig, root = root, hum = hum, dist = dist }
					end
				end
			end
		end
	end
	for i = n + 1, self.rosterN do roster[i] = nil end
	self.rosterN = n
	if n > 1 then sort(roster, function(a, b) return a.dist < b.dist end) end
	return n
end

function ESP:tick(dt)
	local cfg = self.cfg
	if not cfg.enabled then
		self.pool:openFrame()
		self.pool:closeFrame()
		for _, h in pairs(self.hl) do h.Enabled = false end
		for uid in pairs(self.mat) do self:dropMatCham(uid) end
		if self.worldApplied then self:restoreWorld() end
		return
	end

	self.clock = self.clock + dt
	self.frame = self.frame + 1
	if cfg.perf.frameSkip > 0 and self.frame % (cfg.perf.frameSkip + 1) ~= 0 then return end
	if os.clock() - self.lastTick < cfg.refresh then return end
	self.lastTick = os.clock()

	self.pool:openFrame()
	self:driveWorld()
	self:runModuleWorld()
	self:drawSelfRings()
	self:drawSelfWorld()
	self:drawSelfTrail()
	self:drawFov()
	self:drawCross()
	self:drawPreview()
	self:drawEntities()

	local perf = cfg.perf
	local n = self:collectRoster()
	local cap = perf.playerCap
	if perf.mode == "auto" and cap == 0 and n > 24 then cap = 24 end
	local shown = 0

	for i = 1, n do
		local slot = self.roster[i]
		local plr, rig, root, hum, dist = slot.plr, slot.rig, slot.root, slot.hum, slot.dist
		local head = rig:FindFirstChild("Head")

		if cfg.hit.on then self:trackHealth(plr, hum) end
		if cfg.trail.on then self:recordGhost(plr, rig) end

		local visible
		local needSight = cfg.wallCheck or cfg.wallHide or cfg.wallColors or (cfg.chams.on and cfg.chams.wallColors)
		if needSight then visible = self:sees(root, rig) end

		if cfg.chams.teamCheck and self:isAlly(plr) then
			self:killCham(plr.UserId)
		else
			self:paintCham(plr, rig, visible)
		end

		local skip = (cfg.teamCheck and self:isAlly(plr)) or (cfg.wallHide and visible == false)
		if not skip and (cap == 0 or shown < cap) then
			local sx, sy, depth, onScreen = self:project(root.Position)
			if onScreen and depth > 0 then
				local lx, ly, bw, bh = self:screenBox(rig)
				if lx then
					if bw < 4 then bw = 4 end
					if bh < 6 then bh = 6 end
					local vp = cam.ViewportSize
					if lx + bw >= -48 and lx <= vp.X + 48 and ly + bh >= -48 and ly <= vp.Y + 48 then
						shown = shown + 1
						self:drawPlayer(plr, rig, root, hum, head, lx, ly, bw, bh, dist, visible, self:lodOf(dist))
					end
				end
			elseif cfg.arrow.on then
				local vp = cam.ViewportSize
				if depth < 0 then sx, sy = vp.X - sx, vp.Y - sy end
				local dx, dy = sx - vp.X / 2, sy - vp.Y / 2
				local len = sqrt(dx * dx + dy * dy)
				if len > 0 then
					dx, dy = dx / len, dy / len
					local ax, ay = vp.X / 2 + dx * cfg.arrow.radius, vp.Y / 2 + dy * cfg.arrow.radius
					local rot = atan2(dy, dx)
					local col = cfg.rainbow and hueAt(self.clock * 0.15) or cfg.arrow.color
					self.pool:line("ar" .. plr.UserId .. "1", ax, ay, ax - cos(rot + 0.5) * cfg.arrow.size, ay - sin(rot + 0.5) * cfg.arrow.size, col, 2)
					self.pool:line("ar" .. plr.UserId .. "2", ax, ay, ax - cos(rot - 0.5) * cfg.arrow.size, ay - sin(rot - 0.5) * cfg.arrow.size, col, 2)
				end
			end
		end
	end

	self:runModuleScreen()
	self.pool:closeFrame()
end

function ESP:start()
	if self.running then return self end
	self.running = true

	self.playerLeft = Players.PlayerRemoving:Connect(function(plr)
		local uid = plr.UserId
		self.hits[uid], self.btrk[uid], self.hpMem[uid] = nil, nil, nil
		self:killCham(uid)
	end)

	self.loop = RunService.RenderStepped:Connect(function(dt)
		self:tick(dt)
	end)
	return self
end

function ESP:destroy()
	self.running = false
	if self.loop then self.loop:Disconnect() end
	if self.playerLeft then self.playerLeft:Disconnect() end
	for _, name in ipairs(self.moduleOrder) do
		local mod = self.modules[name]
		if mod and mod.teardown then pcall(mod.teardown, mod.state) end
	end
	self.pool:nuke()
	for _, h in pairs(self.hl) do pcall(function() h:Destroy() end) end
	for uid in pairs(self.mat) do self:dropMatCham(uid) end
	self:restoreWorld()
	self.hl, self.mat, self.matKind, self.hits, self.hpMem, self.btrk, self.myTrail = {}, {}, {}, {}, {}, {}, {}
	self.entities, self.selfRings, self.tagHooks = {}, {}, {}
	self.modules, self.moduleOrder = {}, {}
end

return ESP
