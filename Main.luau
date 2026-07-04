local Players            = game:GetService("Players")
local RunService         = game:GetService("RunService")
local Lighting           = game:GetService("Lighting")
local UserInputService   = game:GetService("UserInputService")

local LocalPlayer = Players.LocalPlayer
local Camera      = workspace.CurrentCamera

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
	Camera = workspace.CurrentCamera
end)

local Vector2new     = Vector2.new
local Vector3new     = Vector3.new
local Color3fromRGB  = Color3.fromRGB
local Color3fromHSV  = Color3.fromHSV
local Color3new      = Color3.new
local CFramenew      = CFrame.new
local mathclamp      = math.clamp
local mathhuge       = math.huge
local mathatan2      = math.atan2
local mathcos        = math.cos
local mathsin        = math.sin
local mathmin        = math.min
local mathmax        = math.max
local mathfloor      = math.floor
local tableinsert    = table.insert
local tableremove    = table.remove

local EasyESP = {}
EasyESP.__index = EasyESP
EasyESP.Version = "1.0.0"

EasyESP.Defaults = {
	Master      = false,
	MaxDist     = 3000,
	RefreshRate = 0,

	ESP = {
		Enabled      = false,
		TeamCheck    = false,
		VisibleCheck = false,
		VisibleColor      = false,
		VisibleColorOn    = Color3fromRGB(0, 255, 0),
		VisibleColorOff   = Color3fromRGB(255, 0, 0),

		Boxes        = false,
		BoxStyle     = "2D",
		BoxColor     = Color3fromRGB(255, 255, 255),
		BoxOutline   = true,
		BoxFill      = false,
		BoxFillAlpha = 0.2,
		BoxThickness = 1,

		Names        = false,
		Usernames    = false,
		Distance     = false,
		Tool         = false,
		TextSize     = 13,
		TextColor    = Color3fromRGB(255, 255, 255),
		TextOutline  = true,
		TextFont     = 2,

		HealthBar        = false,
		HealthBarGradient= true,
		BarThickness     = 2,
		BarOutline       = false,

		Skeletons     = false,
		SkeletonColor = Color3fromRGB(255, 255, 255),

		HeadDot     = false,
		HeadDotSize = 3,

		LookLines = false,
		LookLen   = 10,

		Tracers      = false,
		TracerOrigin = "Bottom",
		TracerColor  = Color3fromRGB(255, 255, 255),

		Arrows      = false,
		ArrowRadius = 200,
		ArrowSize   = 15,

		Rainbow      = false,
		RainbowSpeed = 1,
	},

	Chams = {
		Enabled          = false,
		Mode             = "Highlight",

		Fill             = true,
		FillColor        = Color3fromRGB(255, 255, 255),
		FillTransparency = 0.5,

		Outline          = true,
		OutlineColor     = Color3fromRGB(255, 255, 255),
		OutlineTransparency = 0,

		DepthMode        = "AlwaysOnTop",

		Material         = "ForceField",
		MaterialColor    = Color3fromRGB(255, 255, 255),
		MaterialTransparency = 0,
		MaterialAffectHead = true,

		TeamCheck        = false,
		UseVisibleColor  = false,
		VisibleColor     = Color3fromRGB(0, 255, 0),
		HiddenColor      = Color3fromRGB(255, 0, 0),
	},

	World = {
		Enabled         = false,
		Fullbright      = false,
		FOV             = 70,
		NoFog           = false,
		Brightness      = 1,
		Ambient         = Color3fromRGB(0, 0, 0),
		OutdoorAmbient  = Color3fromRGB(0, 0, 0),
		Exposure        = 1,
		ColorCorrection = false,
		Saturation      = 0,
		Contrast        = 0,
	},

	Visuals = {
		Enabled = false,

		Box = {
			Enabled     = true,
			Style       = "Corner",
			Color       = Color3fromRGB(200, 60, 220),
			Thickness   = 1,
			Outline     = true,
			OutlineColor= Color3fromRGB(10, 10, 12),
			CornerScale = 0.28,
			Fill        = false,
			FillColor   = Color3fromRGB(200, 60, 220),
			FillAlpha   = 0.12,
			FillGradient= true,
		},

		Glow = {
			Enabled   = true,
			Color     = Color3fromRGB(200, 60, 220),
			Layers    = 4,
			Spread    = 2,
			Alpha     = 0.10,
			Pulse     = true,
			PulseSpeed= 3,
		},

		Name = {
			Enabled  = true,
			Size     = 13,
			Color    = Color3fromRGB(235, 235, 245),
			Font     = 2,
			Outline  = true,
			Shadow   = true,
			ShowUser = false,
		},

		Weapon = {
			Enabled  = true,
			Size     = 12,
			Color    = Color3fromRGB(200, 200, 210),
			Font     = 2,
			Outline  = true,
			ShowAmmo = true,
			AmmoAttribute = "Ammo",
		},

		Distance = {
			Enabled = true,
			Size    = 11,
			Color   = Color3fromRGB(180, 180, 190),
			Font    = 2,
			Outline = true,
			Suffix  = "m",
		},

		HealthBar = {
			Enabled   = true,
			Side      = "Left",
			Thickness = 3,
			Outline   = true,
			Gradient  = true,
			ColorFull = Color3fromRGB(80, 230, 120),
			ColorLow  = Color3fromRGB(230, 60, 60),
			ShowText  = true,
			Notch     = true,
		},

		ArmorBar = {
			Enabled   = false,
			Side      = "Bottom",
			Thickness = 3,
			Color     = Color3fromRGB(90, 160, 255),
			Outline   = true,
			Attribute = "Armor",
			MaxAttribute = "MaxArmor",
		},

		Flags = {
			Enabled   = true,
			Size      = 11,
			Font      = 2,
			Outline   = true,
			Side      = "Right",
			Spacing   = 1,
			DefaultColor = Color3fromRGB(220, 220, 230),
		},

		HitMarker = {
			Enabled   = true,
			Duration  = 0.35,
			FlashColor= Color3fromRGB(255, 255, 255),
			Damage    = true,
			DamageColor = Color3fromRGB(255, 90, 90),
		},

		LowHealthPulse = {
			Enabled   = true,
			Threshold = 0.35,
			Color     = Color3fromRGB(255, 40, 40),
			Speed     = 6,
		},

		Backtrack = {
			Enabled    = false,
			Ticks      = 8,
			Interval   = 0.05,
			Color      = Color3fromRGB(200, 60, 220),
			Alpha      = 0.5,
			Skeleton   = true,
			Box        = false,
			FadeTail   = true,
		},

		Rings = {
			Enabled   = false,
			Segments  = 48,
			Height    = 0.05,
			DepthTest = true,
			List = {
				{ Name = "KillAura", Radius = 14, Color = Color3fromRGB(255, 70, 70),  Thickness = 2, Alpha = 1, Style = "Solid", Effect = "None",  Spin = 0.4, Pulse = false, Filled = false, FillAlpha = 0.08 },
				{ Name = "Reach",    Radius = 6,  Color = Color3fromRGB(90, 200, 255),  Thickness = 2, Alpha = 1, Style = "Dashed", Effect = "None", Spin = 0,   Pulse = true,  Filled = false, FillAlpha = 0.08 },
			},
		},

		Sphere = {
			Enabled   = false,
			Radius    = 10,
			Rings     = 5,
			Segments  = 24,
			Color     = Color3fromRGB(200, 60, 220),
			Thickness = 1,
			Alpha     = 0.6,
			DepthTest = true,
			Spin      = 0.2,
			Effect    = "None",
		},

		Effects = {
			Confetti = {
				Enabled = false,
				Count   = 40,
				Radius  = 8,
				Height  = 12,
				Speed   = 6,
				Size    = 3,
				Rainbow = true,
				Color   = Color3fromRGB(255, 100, 200),
			},
			Rain = {
				Enabled = false,
				Count   = 60,
				Radius  = 7,
				Height  = 16,
				Speed   = 24,
				Length  = 1.2,
				Color   = Color3fromRGB(120, 170, 255),
				Alpha   = 0.6,
				Rainbow = false,
			},
			Synth = {
				Enabled  = false,
				Rings    = 6,
				Radius   = 12,
				Spacing  = 1.4,
				Height   = 0.0,
				Speed    = 4,
				Segments = 40,
				Thickness= 1,
				Alpha    = 0.7,
				Hue      = 0.85,
				HueRange = 0.25,
				Rise     = true,
			},
			Orbit = {
				Enabled  = false,
				Count    = 3,
				Radius   = 5,
				Speed    = 2,
				Size     = 4,
				Color    = Color3fromRGB(200, 60, 220),
				Vertical = 3,
				Rainbow  = false,
				Trail    = true,
				TrailLen = 5,
			},
			Spiral = {
				Enabled   = false,
				Radius    = 6,
				Height    = 10,
				Turns     = 3,
				Points    = 60,
				Speed     = 2,
				Thickness = 1,
				Alpha     = 0.85,
				Color     = Color3fromRGB(255, 120, 60),
				Rainbow   = true,
			},
			Vortex = {
				Enabled   = false,
				Particles = 50,
				Radius    = 8,
				Height    = 12,
				Speed     = 6,
				Twist     = 3,
				Size      = 3,
				Color     = Color3fromRGB(120, 80, 255),
				Rainbow   = true,
			},
			Shockwave = {
				Enabled   = false,
				Waves     = 3,
				Radius    = 14,
				Speed     = 4,
				Segments  = 44,
				Thickness = 2,
				Alpha     = 0.8,
				Color     = Color3fromRGB(255, 220, 120),
			},
			Aura = {
				Enabled   = false,
				Rings     = 4,
				Radius    = 5,
				Speed     = 2,
				Segments  = 36,
				Thickness = 1,
				Alpha     = 0.7,
				Color     = Color3fromRGB(90, 255, 200),
				Rainbow   = true,
			},
			Fireflies = {
				Enabled = false,
				Count   = 24,
				Radius  = 6,
				Height  = 8,
				Speed   = 4,
				Size    = 2,
				Color   = Color3fromRGB(255, 240, 150),
				Rainbow = false,
			},
			Lightning = {
				Enabled   = false,
				Bolts     = 3,
				Segments  = 6,
				Radius    = 6,
				Height    = 12,
				Jitter    = 1.5,
				Speed     = 6,
				Thickness = 2,
				Alpha     = 1,
				Color     = Color3fromRGB(180, 220, 255),
			},
			Helix = {
				Enabled   = false,
				Strands   = 2,
				Points    = 40,
				Turns     = 2,
				Radius    = 3,
				Height    = 12,
				Speed     = 2,
				Thickness = 1,
				Alpha     = 0.85,
				Color     = Color3fromRGB(120, 255, 180),
				Rainbow   = true,
			},
			Heartbeat = {
				Enabled   = false,
				Radius    = 8,
				Segments  = 40,
				Speed     = 1.2,
				Thickness = 2,
				Alpha     = 0.8,
				Color     = Color3fromRGB(255, 60, 90),
			},
			Grid = {
				Enabled = false,
				Lines   = 6,
				Size    = 10,
				Speed   = 2,
				Wave    = 1.2,
				Alpha   = 0.4,
				Color   = Color3fromRGB(80, 200, 255),
			},
			Tornado = {
				Enabled   = false,
				Particles = 60,
				Radius    = 6,
				Height    = 14,
				Speed     = 6,
				Spin      = 3,
				Twist     = 2,
				Size      = 2,
				Color     = Color3fromRGB(180, 180, 200),
				Rainbow   = false,
			},
			Portal = {
				Enabled   = false,
				Rings     = 5,
				Radius    = 6,
				Height    = 0.1,
				Segments  = 40,
				Speed     = 3,
				Spin      = 1,
				Thickness = 2,
				Alpha     = 0.7,
				Hue       = 0.75,
			},
			Snow = {
				Enabled = false,
				Count   = 50,
				Radius  = 8,
				Height  = 16,
				Speed   = 4,
				Size    = 1.5,
				Alpha   = 0.9,
				Color   = Color3fromRGB(255, 255, 255),
			},
			Embers = {
				Enabled = false,
				Count   = 40,
				Radius  = 5,
				Height  = 12,
				Speed   = 5,
				Size    = 2,
			},
			Radar = {
				Enabled   = false,
				Radius    = 14,
				Segments  = 40,
				Speed     = 2,
				ArcLen    = 1.2,
				Thickness = 2,
				Alpha     = 0.8,
				Color     = Color3fromRGB(80, 255, 120),
			},
			StarBurst = {
				Enabled     = false,
				OuterRadius = 6,
				InnerRadius = 2.5,
				Points      = 5,
				Spin        = 1,
				Thickness   = 2,
				Alpha       = 0.9,
				Color       = Color3fromRGB(255, 220, 90),
				Rainbow     = true,
			},
		},

		TeamCheck    = false,
		VisibleCheck = false,
		Rainbow      = false,
		RainbowSpeed = 1,

		Preview = {
			Enabled  = false,
			X        = 60,
			Y        = 0,
			Width    = 70,
			Height   = 150,
			FakeHealth = -1,
		},

		Trail = {
			Enabled   = false,
			Length    = 30,
			Interval  = 0.05,
			Thickness = 2,
			Alpha     = 0.8,
			Color     = Color3fromRGB(200, 60, 220),
			Rainbow   = true,
		},

		FovCircle = {
			Enabled   = false,
			Radius    = 120,
			Thickness = 1,
			Sides     = 64,
			Alpha     = 1,
			Color     = Color3fromRGB(255, 255, 255),
			Rainbow   = false,
			Filled    = false,
			FillAlpha = 0.05,
		},

		Crosshair = {
			Enabled   = false,
			Gap       = 4,
			Length    = 8,
			Thickness = 1,
			Alpha     = 1,
			Color     = Color3fromRGB(0, 255, 120),
			Rainbow   = false,
			Outline   = true,
			Dot       = false,
			DotSize   = 1,
		},
	},
}

local BONES = {
	R15 = {
		{"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
		{"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
		{"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
		{"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
		{"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"},
	},
	R6 = {
		{"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
		{"Torso", "Left Leg"}, {"Torso", "Right Leg"},
	},
}

local BOX_OFFSETS = {
	Vector3new(-1, 1, -1), Vector3new(1, 1, -1), Vector3new(1, 1, 1), Vector3new(-1, 1, 1),
	Vector3new(-1, -1, -1), Vector3new(1, -1, -1), Vector3new(1, -1, 1), Vector3new(-1, -1, 1),
}

local BOX_EDGES = {
	{1, 2}, {2, 3}, {3, 4}, {4, 1},
	{5, 6}, {6, 7}, {7, 8}, {8, 5},
	{1, 5}, {2, 6}, {3, 7}, {4, 8},
}

local EMPTY = setmetatable({}, { __newindex = function() end })
local TAU = 6.2831853071796

local function hueShift(base, amt)
	local h, s, v = base:ToHSV()
	return Color3fromHSV((h + amt) % 1, s, v)
end

function EasyESP.new()
	local self = setmetatable({}, EasyESP)
	self._ringBuf = {}

	self.Settings = EasyESP.DeepCopy(nil, EasyESP.Defaults)

	self.State = {
		Active          = false,
		Drawings        = {},
		Connections     = {},
		Highlights      = {},
		MaterialChams   = {},
		Objects         = {},
		PlayerCallbacks = {},
		LastUpdate      = 0,
		RainbowVal      = 0,
		WorldApplied    = false,
		WorldOriginal   = nil,
		Clock           = 0,
		HitMarkers      = {},
		Backtrack       = {},
		LastHealth      = {},
		FlagProviders   = {},
		Seen            = {},
		PrevSeen        = {},
		RangeRings      = {},
		Particles       = {},
		LocalTrail      = {},
	}

	self.RaycastParams = RaycastParams.new()
	self.RaycastParams.FilterType = Enum.RaycastFilterType.Exclude

	self.GetTool = function(plr)
		local char = plr.Character
		local tool = char and char:FindFirstChildOfClass("Tool")
		return tool and tool.Name or "None"
	end

	self:RegisterDefaultFlags()

	return self
end

function EasyESP:DeepCopy(t)

	local copy = {}
	for k, v in pairs(t) do
		if type(v) == "table" then
			copy[k] = EasyESP.DeepCopy(nil, v)
		else
			copy[k] = v
		end
	end
	return copy
end

function EasyESP:GetDrawing(id, drawType)
	local existing = self.State.Drawings[id]
	if existing then
		self.State.Seen[id] = true
		return existing
	end
	local obj = Drawing.new(drawType)
	self.State.Drawings[id] = obj
	self.State.Seen[id] = true
	return obj
end

function EasyESP:BeginFrame()
	local seen = self.State.Seen
	for k in pairs(seen) do seen[k] = nil end
end

function EasyESP:EndFrame()
	local seen = self.State.Seen
	local drawings = self.State.Drawings
	local prev = self.State.PrevSeen
	for id in pairs(prev) do
		if not seen[id] then
			local d = drawings[id]
			if d then d.Visible = false end
		end
	end
	self.State.PrevSeen, self.State.Seen = seen, prev
end

function EasyESP:HideAll()
	for _, v in pairs(self.State.Drawings) do
		v.Visible = false
	end
	for k in pairs(self.State.Seen) do self.State.Seen[k] = nil end
	for k in pairs(self.State.PrevSeen) do self.State.PrevSeen[k] = nil end
end

function EasyESP:W2S(pos)
	local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
	return Vector2new(screenPos.X, screenPos.Y), screenPos.Z, onScreen
end

function EasyESP:IsVisible(part, model)
	local origin = Camera.CFrame.Position
	local dir = (part.Position - origin)
	self.RaycastParams.FilterDescendantsInstances = { LocalPlayer.Character, model }
	local result = workspace:Raycast(origin, dir, self.RaycastParams)
	return result == nil
end

function EasyESP:IsTeamMate(player)
	if not self.Settings.ESP.TeamCheck then return false end
	return player.Team ~= nil and player.Team == LocalPlayer.Team
end

function EasyESP:GetBoundingBox(model)
	local cf, size = model:GetBoundingBox()
	local halfSize = size * 0.5
	local minX, minY = mathhuge, mathhuge
	local maxX, maxY = -mathhuge, -mathhuge
	local allVisible = true

	for _, offset in ipairs(BOX_OFFSETS) do
		local worldPos = (cf * CFramenew(offset * halfSize)).Position
		local screenPos, depth = self:W2S(worldPos)
		if depth <= 0 then
			allVisible = false
			break
		end
		if screenPos.X < minX then minX = screenPos.X end
		if screenPos.Y < minY then minY = screenPos.Y end
		if screenPos.X > maxX then maxX = screenPos.X end
		if screenPos.Y > maxY then maxY = screenPos.Y end
	end

	if not allVisible then return nil, nil, false end

	local w = maxX - minX
	local h = maxY - minY
	return Vector2new(minX, minY), Vector2new(w, h), true
end

function EasyESP:DrawText(id, text, pos, size, color, center, font, outline, outlineColor)
	local t = self:GetDrawing(id, "Text")
	t.Visible      = true
	t.Text         = text
	t.Position     = pos
	t.Size         = size or self.Settings.ESP.TextSize
	t.Color        = color or self.Settings.ESP.TextColor
	t.Center       = center ~= false
	t.Outline      = outline ~= false
	t.OutlineColor = outlineColor or Color3new(0, 0, 0)
	t.Font         = font or self.Settings.ESP.TextFont
	return t
end

function EasyESP:DrawLine(id, from, to, color, thickness, transparency)
	local l = self:GetDrawing(id, "Line")
	l.Visible      = true
	l.From         = from
	l.To           = to
	l.Color        = color or Color3new(1, 1, 1)
	l.Thickness    = thickness or 1
	l.Transparency = transparency or 1
	return l
end

function EasyESP:DrawSquare(id, pos, size, color, filled, thickness, transparency)
	local s = self:GetDrawing(id, "Square")
	s.Visible      = true
	s.Position     = pos
	s.Size         = size
	s.Color        = color or Color3new(1, 1, 1)
	s.Filled       = filled == true
	s.Thickness    = thickness or 1
	s.Transparency = transparency or 1
	return s
end

function EasyESP:DrawCircle(id, pos, radius, color, filled, thickness, transparency)
	local c = self:GetDrawing(id, "Circle")
	c.Visible      = true
	c.Position     = pos
	c.Radius       = radius
	c.Color        = color or Color3new(1, 1, 1)
	c.Filled       = filled == true
	c.Thickness    = thickness or 1
	c.Transparency = transparency or 1
	return c
end

function EasyESP:DrawTriangle(id, p1, p2, p3, color, filled, thickness, transparency)
	local t = self:GetDrawing(id, "Triangle")
	t.Visible      = true
	t.PointA       = p1
	t.PointB       = p2
	t.PointC       = p3
	t.Color        = color or Color3new(1, 1, 1)
	t.Filled       = filled == true
	t.Thickness    = thickness or 1
	t.Transparency = transparency or 1
	return t
end

function EasyESP:DrawBar(id, boxX, boxY, boxH, pct, color, offset, thickness, outline)
	local barW      = thickness or self.Settings.ESP.BarThickness
	local offsetIdx = offset or 0
	local xPos      = boxX - 5 - (offsetIdx * (barW + 3)) - barW
	local barH      = boxH
	pct = mathclamp(pct, 0, 1)

	if outline then
		local out = self:GetDrawing(id .. "_baro_" .. offsetIdx, "Square")
		out.Visible      = true
		out.Filled       = true
		out.Color        = Color3new(0, 0, 0)
		out.Transparency = 0.6
		out.Position     = Vector2new(xPos - 1, boxY - 1)
		out.Size         = Vector2new(barW + 2, barH + 2)
	end

	local bg = self:GetDrawing(id .. "_barbg_" .. offsetIdx, "Square")
	bg.Visible      = true
	bg.Filled       = true
	bg.Color        = Color3new(0.15, 0.15, 0.15)
	bg.Transparency = 0.5
	bg.Position     = Vector2new(xPos, boxY)
	bg.Size         = Vector2new(barW, barH)

	local fillH = barH * pct
	local main  = self:GetDrawing(id .. "_bar_" .. offsetIdx, "Square")
	main.Visible      = true
	main.Filled       = true
	main.Color        = color
	main.Transparency = 1
	main.Position     = Vector2new(xPos, boxY + (barH - fillH))
	main.Size         = Vector2new(barW, mathmax(fillH, 1))
end

function EasyESP:AddPlayerCallback(name, callback)
	self.State.PlayerCallbacks[name] = callback
end

function EasyESP:RemovePlayerCallback(name)
	self.State.PlayerCallbacks[name] = nil
end

function EasyESP:RegisterObject(id, instance, renderCallback)
	self.State.Objects[id] = {
		Instance = instance,
		Callback = renderCallback,
	}
end

function EasyESP:UnregisterObject(id)
	local obj = self.State.Objects[id]
	if obj then

		for dId, d in pairs(self.State.Drawings) do
			if type(dId) == "string" and dId:sub(1, #id) == id then
				d.Visible = false
			end
		end
	end
	self.State.Objects[id] = nil
end

function EasyESP:Render3DBox(id, model, color, isCorner)
	local cf, size = model:GetBoundingBox()
	local halfSize = size * 0.5
	local corners = {}
	local allVisible = true

	for i, offset in ipairs(BOX_OFFSETS) do
		local wp = (cf * CFramenew(offset * halfSize)).Position
		local pos, z = self:W2S(wp)
		if z <= 0 then allVisible = false break end
		corners[i] = pos
	end

	if not allVisible then
		for i = 1, #BOX_EDGES do
			local line = self:GetDrawing(id .. "_3d_" .. i, "Line")
			line.Visible = false
			if isCorner then
				local line2 = self:GetDrawing(id .. "_3dc_" .. i, "Line")
				line2.Visible = false
			end
		end
		return
	end

	for i, edge in ipairs(BOX_EDGES) do
		local line = self:GetDrawing(id .. "_3d_" .. i, "Line")
		line.Visible   = true
		line.From      = corners[edge[1]]
		line.To        = corners[edge[2]]
		line.Color     = color
		line.Thickness = self.Settings.ESP.BoxThickness

		if isCorner then
			local dir = (line.To - line.From)
			local len = dir.Magnitude
			if len > 0 then
				local unit = dir / len
				line.To = line.From + unit * (len * 0.25)

				local line2 = self:GetDrawing(id .. "_3dc_" .. i, "Line")
				line2.Visible   = true
				line2.From      = corners[edge[2]]
				line2.To        = corners[edge[2]] - unit * (len * 0.25)
				line2.Color     = color
				line2.Thickness = self.Settings.ESP.BoxThickness
			end
		end
	end
end

function EasyESP:RenderSkeleton(id, char, color)
	local rig = char:FindFirstChild("UpperTorso") and "R15" or "R6"
	for i, bone in ipairs(BONES[rig]) do
		local a, b = char:FindFirstChild(bone[1]), char:FindFirstChild(bone[2])
		local line = self:GetDrawing(id .. "_skel_" .. i, "Line")
		if a and b then
			local posA, zA, visA = self:W2S(a.Position)
			local posB, zB, visB = self:W2S(b.Position)
			if visA and visB and zA > 0 and zB > 0 then
				line.Visible   = true
				line.From      = posA
				line.To        = posB
				line.Color     = color
				line.Thickness = 1
			else
				line.Visible = false
			end
		else
			line.Visible = false
		end
	end
end

function EasyESP:RenderTracer(id, target, color)
	local s = self.Settings.ESP
	local viewport = Camera.ViewportSize
	local origin = Vector2new(viewport.X / 2, viewport.Y)
	if s.TracerOrigin == "Center" then
		origin = Vector2new(viewport.X / 2, viewport.Y / 2)
	elseif s.TracerOrigin == "Top" then
		origin = Vector2new(viewport.X / 2, 0)
	elseif s.TracerOrigin == "Mouse" then
		origin = UserInputService:GetMouseLocation()
	end

	local line = self:GetDrawing(id .. "_tracer", "Line")
	line.Visible   = true
	line.From      = origin
	line.To        = target
	line.Color     = color
	line.Thickness = 1
end

local HIGHLIGHT_DEPTH = {
	AlwaysOnTop = Enum.HighlightDepthMode.AlwaysOnTop,
	Occluded    = Enum.HighlightDepthMode.Occluded,
}

function EasyESP:RestoreMaterialCham(id)
	local saved = self.State.MaterialChams[id]
	if not saved then return end
	for part, orig in pairs(saved) do
		if part.Parent then
			part.Material    = orig.Material
			part.Color       = orig.Color
			part.Transparency= orig.Transparency
		end
	end
	self.State.MaterialChams[id] = nil
end

function EasyESP:RemoveCham(id)
	local existing = self.State.Highlights[id]
	if existing then
		existing:Destroy()
		self.State.Highlights[id] = nil
	end
	self:RestoreMaterialCham(id)
end

function EasyESP:UpdateChams(plr, char, visible)
	local c  = self.Settings.Chams
	local id = tostring(plr.UserId)

	if not c.Enabled or not char then
		self:RemoveCham(id)
		return
	end

	local fillColor, outlineColor = c.FillColor, c.OutlineColor
	if c.UseVisibleColor then
		local col = visible and c.VisibleColor or c.HiddenColor
		fillColor, outlineColor = col, col
	end

	if c.Mode == "Material" then
		if self.State.Highlights[id] then
			self.State.Highlights[id]:Destroy()
			self.State.Highlights[id] = nil
		end

		local mat = Enum.Material[c.Material] or Enum.Material.ForceField
		local matColor = c.UseVisibleColor and fillColor or c.MaterialColor
		local saved = self.State.MaterialChams[id]
		if not saved then
			saved = {}
			self.State.MaterialChams[id] = saved
		end

		for _, part in ipairs(char:GetChildren()) do
			if part:IsA("BasePart") then
				if part.Name == "Head" and not c.MaterialAffectHead then continue end
				if not saved[part] then
					saved[part] = {
						Material     = part.Material,
						Color        = part.Color,
						Transparency = part.Transparency,
					}
				end
				part.Material     = mat
				part.Color        = matColor
				part.Transparency = c.MaterialTransparency
			end
		end
		return
	end

	self:RestoreMaterialCham(id)

	local hl = self.State.Highlights[id]
	if not hl or hl.Parent ~= char then
		if hl then hl:Destroy() end
		hl = Instance.new("Highlight")
		hl.Name    = "EasyESP_Cham"
		hl.Adornee = char
		hl.Parent  = char
		self.State.Highlights[id] = hl
	end

	hl.Enabled             = true
	hl.FillColor           = fillColor
	hl.FillTransparency    = c.Fill and c.FillTransparency or 1
	hl.OutlineColor        = outlineColor
	hl.OutlineTransparency = c.Outline and c.OutlineTransparency or 1
	hl.DepthMode           = HIGHLIGHT_DEPTH[c.DepthMode] or Enum.HighlightDepthMode.AlwaysOnTop
end

function EasyESP:CaptureWorldOriginal()
	if self.State.WorldOriginal then return end
	self.State.WorldOriginal = {
		Brightness           = Lighting.Brightness,
		Ambient              = Lighting.Ambient,
		OutdoorAmbient       = Lighting.OutdoorAmbient,
		ExposureCompensation = Lighting.ExposureCompensation,
		FogEnd               = Lighting.FogEnd,
		FieldOfView          = Camera.FieldOfView,
	}
end

function EasyESP:RestoreWorld()
	local o = self.State.WorldOriginal
	if not o then return end
	Lighting.Brightness           = o.Brightness
	Lighting.Ambient              = o.Ambient
	Lighting.OutdoorAmbient       = o.OutdoorAmbient
	Lighting.ExposureCompensation = o.ExposureCompensation
	Lighting.FogEnd               = o.FogEnd
	Camera.FieldOfView            = o.FieldOfView

	local cc = Lighting:FindFirstChild("EasyESP_CC")
	if cc then cc:Destroy() end
	self.State.WorldApplied = false
end

function EasyESP:UpdateWorld()
	local w = self.Settings.World

	if not w.Enabled then

		if self.State.WorldApplied then
			self:RestoreWorld()
		end
		return
	end

	self:CaptureWorldOriginal()
	self.State.WorldApplied = true

	Lighting.Brightness           = w.Fullbright and 3 or w.Brightness
	Lighting.Ambient              = w.Ambient
	Lighting.OutdoorAmbient       = w.OutdoorAmbient
	Lighting.ExposureCompensation = w.Exposure
	Camera.FieldOfView            = w.FOV

	if w.NoFog then
		Lighting.FogEnd = 1e7
	elseif self.State.WorldOriginal then
		Lighting.FogEnd = self.State.WorldOriginal.FogEnd
	end

	local cc = Lighting:FindFirstChild("EasyESP_CC")
	if not cc then
		cc = Instance.new("ColorCorrectionEffect")
		cc.Name   = "EasyESP_CC"
		cc.Parent = Lighting
	end
	cc.Enabled    = w.ColorCorrection
	cc.Saturation = w.Saturation
	cc.Contrast   = w.Contrast
end

function EasyESP:AddFlag(name, provider)
	self.State.FlagProviders[name] = provider
end

function EasyESP:RemoveFlag(name)
	self.State.FlagProviders[name] = nil
end

function EasyESP:RegisterDefaultFlags()
	local white  = Color3fromRGB(220, 220, 230)
	local yellow = Color3fromRGB(255, 210, 90)
	local green  = Color3fromRGB(90, 230, 130)
	local red    = Color3fromRGB(255, 80, 80)
	local blue   = Color3fromRGB(120, 170, 255)

	self:AddFlag("Visible", function(ctx)
		if ctx.visible == nil then return nil end
		if ctx.visible then return { text = "V", color = green } end
		return { text = "HID", color = red }
	end)

	self:AddFlag("Flying", function(ctx)
		local hum = ctx.humanoid
		if hum and (hum:GetState() == Enum.HumanoidStateType.Freefall
			or hum:GetState() == Enum.HumanoidStateType.Flying) then
			return { text = "FLY", color = blue }
		end
		return nil
	end)

	self:AddFlag("Health", function(ctx)
		if not ctx.humanoid then return nil end
		return { text = mathfloor(ctx.humanoid.Health) .. "hp", color = green }
	end)

	self:AddFlag("Distance", function(ctx)
		return { text = mathfloor(ctx.distance) .. "m", color = white }
	end)

	self:AddFlag("Weapon", function(ctx)
		local t = self.GetTool(ctx.player)
		if t and t ~= "None" then return { text = t, color = yellow } end
		return nil
	end)

	self:AddFlag("Money", function(ctx)
		local v = ctx.player:GetAttribute("Money") or ctx.player:GetAttribute("Cash")
		if v then return { text = "$" .. tostring(v), color = green } end
		return nil
	end)

	self:AddFlag("Level", function(ctx)
		local v = ctx.player:GetAttribute("Level")
		if v then return { text = "Lvl " .. tostring(v), color = blue } end
		return nil
	end)

	self:AddFlag("Speed", function(ctx)
		if not ctx.root then return nil end
		local spd = mathfloor(ctx.root.AssemblyLinearVelocity.Magnitude + 0.5)
		if spd > 2 then return { text = spd .. " sps", color = Color3fromRGB(120, 220, 255) } end
		return nil
	end)

	self:AddFlag("Airborne", function(ctx)
		if not ctx.root then return nil end
		if ctx.root.AssemblyLinearVelocity.Y > 3 then
			return { text = "JUMP", color = Color3fromRGB(255, 230, 120) }
		end
		return nil
	end)

	self:AddFlag("Sprinting", function(ctx)
		local hum = ctx.humanoid
		if hum and hum.WalkSpeed > 18 then
			return { text = "SPRINT", color = Color3fromRGB(255, 170, 60) }
		end
		return nil
	end)

	self:AddFlag("Crouch", function(ctx)
		local hum = ctx.humanoid
		if hum and hum:GetState() == Enum.HumanoidStateType.PlatformStanding then
			return { text = "CROUCH", color = Color3fromRGB(180, 180, 200) }
		end
		return nil
	end)

	self:AddFlag("Frozen", function(ctx)
		local hum = ctx.humanoid
		if hum and hum.WalkSpeed == 0 and hum.Health > 0 then
			return { text = "FROZEN", color = Color3fromRGB(140, 210, 255) }
		end
		return nil
	end)

	self:AddFlag("God", function(ctx)
		local hum = ctx.humanoid
		if hum and hum.MaxHealth >= 1e6 then
			return { text = "GOD", color = Color3fromRGB(255, 215, 0) }
		end
		return nil
	end)

	self:AddFlag("Bacon", function(ctx)
		local char = ctx.character
		if char and char:FindFirstChild("Pal Hair") then
			return { text = "BACON", color = Color3fromRGB(230, 160, 90) }
		end
		return nil
	end)

	self:AddFlag("Armor", function(ctx)
		local v = ctx.player:GetAttribute("Armor") or ctx.player:GetAttribute("Shield")
		if v and v > 0 then return { text = mathfloor(v) .. "ar", color = Color3fromRGB(120, 180, 255) } end
		return nil
	end)
end

function EasyESP:CircleWorldPoints(center, radius, segments, spin)
	local pts = {}
	spin = spin or 0
	for i = 0, segments - 1 do
		local a = (i / segments) * TAU + spin
		pts[i + 1] = center + Vector3new(mathcos(a) * radius, 0, mathsin(a) * radius)
	end
	return pts
end

function EasyESP:DrawWorldRing(id, center, radius, segments, color, thickness, alpha, spin, opts)
	opts = opts or EMPTY
	segments = mathclamp(mathfloor(segments), 6, 128)
	spin = spin or 0

	local scr = self._ringBuf
	local n = 0
	for i = 0, segments - 1 do
		local a = (i / segments) * TAU + spin
		local wp = center + Vector3new(mathcos(a) * radius, 0, mathsin(a) * radius)
		local sp, depth = self:W2S(wp)
		n = n + 1
		local slot = scr[n]
		if slot then
			slot.x, slot.y, slot.d = sp.X, sp.Y, depth
		else
			scr[n] = { x = sp.X, y = sp.Y, d = depth }
		end
	end

	local dashed   = opts.dashed
	local dashGap  = opts.dashGap or 2
	local gradient = opts.gradient
	local gradTo   = opts.gradientColor
	local glow     = opts.glow
	local glowAlpha= opts.glowAlpha or (alpha * 0.35)

	for i = 1, segments do
		local a = scr[i]
		local b = scr[(i % segments) + 1]
		local line = self:GetDrawing(id .. "_r_" .. i, "Line")
		local show = a.d > 0 and b.d > 0 and (not dashed or ((i % dashGap) == 0))
		if show then
			local segColor = color
			if gradient and gradTo then
				segColor = color:Lerp(gradTo, i / segments)
			end
			line.Visible      = true
			line.From         = Vector2new(a.x, a.y)
			line.To           = Vector2new(b.x, b.y)
			line.Color        = segColor
			line.Thickness    = thickness
			line.Transparency = alpha
		else
			line.Visible = false
		end

		if glow then
			local g = self:GetDrawing(id .. "_rg_" .. i, "Line")
			if show then
				g.Visible = true
				g.From = line.From
				g.To = line.To
				g.Color = color
				g.Thickness = thickness + 3
				g.Transparency = glowAlpha
			else
				g.Visible = false
			end
		end
	end

	if opts.filled then
		local cs, cd = self:W2S(center)
		local fillAlpha = opts.fillAlpha or 0.08
		for i = 1, segments do
			local a = scr[i]
			local b = scr[(i % segments) + 1]
			local tri = self:GetDrawing(id .. "_rf_" .. i, "Triangle")
			if cd > 0 and a.d > 0 and b.d > 0 then
				tri.Visible = true
				tri.PointA  = cs
				tri.PointB  = Vector2new(a.x, a.y)
				tri.PointC  = Vector2new(b.x, b.y)
				tri.Color   = color
				tri.Filled  = true
				tri.Transparency = fillAlpha
			else
				tri.Visible = false
			end
		end
	end
end

function EasyESP:DrawWorldSphere(id, center, radius, ringCount, segments, color, thickness, alpha, spin, opts)
	opts = opts or EMPTY
	segments = mathclamp(mathfloor(segments), 6, 64)
	ringCount = mathclamp(mathfloor(ringCount), 2, 16)
	local lineIdx = 0

	local function link(pA, pB)
		if pA and pA.d > 0 and pB.d > 0 then
			lineIdx = lineIdx + 1
			local line = self:GetDrawing(id .. "_sp_" .. lineIdx, "Line")
			line.Visible = true
			line.From = Vector2new(pA.x, pA.y)
			line.To = Vector2new(pB.x, pB.y)
			line.Color = color
			line.Thickness = thickness
			line.Transparency = alpha
		end
	end

	for r = 1, ringCount do
		local frac = r / (ringCount + 1)
		local y = (frac - 0.5) * 2 * radius
		local rr = math.sqrt(mathmax(radius * radius - y * y, 0))
		local prev
		for i = 0, segments do
			local a = (i / segments) * TAU + spin
			local sp, depth = self:W2S(center + Vector3new(mathcos(a) * rr, y, mathsin(a) * rr))
			local cur = { x = sp.X, y = sp.Y, d = depth }
			if prev then link(prev, cur) end
			prev = cur
		end
	end

	local meridians = mathmax(4, mathfloor(segments / 4))
	for m = 0, meridians - 1 do
		local ang = (m / meridians) * math.pi + spin
		local prev
		for i = 0, segments do
			local t = (i / segments) * TAU
			local sp, depth = self:W2S(center + Vector3new(mathcos(t) * radius * mathcos(ang), mathsin(t) * radius, mathcos(t) * radius * mathsin(ang)))
			local cur = { x = sp.X, y = sp.Y, d = depth }
			if prev then link(prev, cur) end
			prev = cur
		end
	end
end

function EasyESP:DrawWorldArc(id, center, radius, segments, startA, sweep, color, thickness, alpha)
	segments = mathclamp(mathfloor(segments), 2, 64)
	local prev
	for i = 0, segments do
		local a = startA + (i / segments) * sweep
		local sp, depth = self:W2S(center + Vector3new(mathcos(a) * radius, 0, mathsin(a) * radius))
		local cur = { x = sp.X, y = sp.Y, d = depth }
		if prev and prev.d > 0 and cur.d > 0 then
			local line = self:GetDrawing(id .. "_arc_" .. i, "Line")
			line.Visible = true
			line.From = Vector2new(prev.x, prev.y)
			line.To = Vector2new(cur.x, cur.y)
			line.Color = color
			line.Thickness = thickness
			line.Transparency = alpha
		end
		prev = cur
	end
end

function EasyESP:DrawWorldDot(id, worldPos, size, color, alpha)
	local sp, depth = self:W2S(worldPos)
	local dot = self:GetDrawing(id, "Circle")
	if depth > 0 then
		dot.Visible = true
		dot.Position = sp
		dot.Radius = size
		dot.Filled = true
		dot.Color = color
		dot.Transparency = alpha or 1
		dot.NumSides = 12
	else
		dot.Visible = false
	end
	return depth > 0
end


function EasyESP:DrawWorldPolygon(id, center, radius, sides, color, thickness, alpha, spin)
	sides = mathclamp(mathfloor(sides), 3, 16)
	spin = spin or 0
	local prev, first
	for i = 0, sides do
		local a = (i / sides) * TAU + spin
		local sp, depth = self:W2S(center + Vector3new(mathcos(a) * radius, 0, mathsin(a) * radius))
		local cur = { x = sp.X, y = sp.Y, d = depth }
		if i == 0 then first = cur end
		if prev and prev.d > 0 and cur.d > 0 then
			local line = self:GetDrawing(id .. "_poly_" .. i, "Line")
			line.Visible = true
			line.From = Vector2new(prev.x, prev.y)
			line.To = Vector2new(cur.x, cur.y)
			line.Color = color
			line.Thickness = thickness
			line.Transparency = alpha
		end
		prev = cur
	end
end

function EasyESP:DrawWorldStar(id, center, outerR, innerR, points, color, thickness, alpha, spin)
	points = mathclamp(mathfloor(points), 3, 12)
	spin = spin or 0
	local verts = {}
	local total = points * 2
	for i = 0, total - 1 do
		local a = (i / total) * TAU + spin
		local r = (i % 2 == 0) and outerR or innerR
		local sp, depth = self:W2S(center + Vector3new(mathcos(a) * r, 0, mathsin(a) * r))
		verts[i + 1] = { x = sp.X, y = sp.Y, d = depth }
	end
	for i = 1, total do
		local a = verts[i]
		local b = verts[(i % total) + 1]
		local line = self:GetDrawing(id .. "_star_" .. i, "Line")
		if a.d > 0 and b.d > 0 then
			line.Visible = true
			line.From = Vector2new(a.x, a.y)
			line.To = Vector2new(b.x, b.y)
			line.Color = color
			line.Thickness = thickness
			line.Transparency = alpha
		else
			line.Visible = false
		end
	end
end

function EasyESP:DrawRadarSweep(id, center, radius, sweepAngle, arcLen, segments, color, thickness, alpha)
	segments = mathclamp(mathfloor(segments), 2, 32)
	local prev
	for i = 0, segments do
		local a = sweepAngle - arcLen + (i / segments) * arcLen
		local sp, depth = self:W2S(center + Vector3new(mathcos(a) * radius, 0, mathsin(a) * radius))
		local cur = { x = sp.X, y = sp.Y, d = depth }
		if prev and prev.d > 0 and cur.d > 0 then
			local line = self:GetDrawing(id .. "_sweep_" .. i, "Line")
			line.Visible = true
			line.From = Vector2new(prev.x, prev.y)
			line.To = Vector2new(cur.x, cur.y)
			line.Color = color
			line.Thickness = thickness
			line.Transparency = alpha * (i / segments)
		end
		prev = cur
	end
	local cs, cd = self:W2S(center)
	local ep, ed = self:W2S(center + Vector3new(mathcos(sweepAngle) * radius, 0, mathsin(sweepAngle) * radius))
	local hand = self:GetDrawing(id .. "_sweephand", "Line")
	if cd > 0 and ed > 0 then
		hand.Visible = true
		hand.From = cs
		hand.To = ep
		hand.Color = color
		hand.Thickness = thickness
		hand.Transparency = alpha
	else
		hand.Visible = false
	end
end

function EasyESP:VisualsBox(id, bx, by, bw, bh, cfg, color)
	local style = cfg.Style
	local th    = cfg.Thickness
	local out   = cfg.OutlineColor

	if cfg.Fill then
		self:DrawSquare(id .. "_sfill", Vector2new(bx, by), Vector2new(bw, bh), cfg.FillColor, true, 1, cfg.FillAlpha)
	end

	if style == "Corner" then
		local len = mathmin(bw, bh) * cfg.CornerScale
		local segs = {
			{Vector2new(bx, by), Vector2new(bx + len, by)}, {Vector2new(bx, by), Vector2new(bx, by + len)},
			{Vector2new(bx + bw, by), Vector2new(bx + bw - len, by)}, {Vector2new(bx + bw, by), Vector2new(bx + bw, by + len)},
			{Vector2new(bx, by + bh), Vector2new(bx + len, by + bh)}, {Vector2new(bx, by + bh), Vector2new(bx, by + bh - len)},
			{Vector2new(bx + bw, by + bh), Vector2new(bx + bw - len, by + bh)}, {Vector2new(bx + bw, by + bh), Vector2new(bx + bw, by + bh - len)},
		}
		if cfg.Outline then
			for i, sgm in ipairs(segs) do
				self:DrawLine(id .. "_sco_" .. i, sgm[1], sgm[2], out, th + 2, 1)
			end
		end
		for i, sgm in ipairs(segs) do
			self:DrawLine(id .. "_sc_" .. i, sgm[1], sgm[2], color, th, 1)
		end
	else
		if cfg.Outline then
			self:DrawSquare(id .. "_sbo", Vector2new(bx - 1, by - 1), Vector2new(bw + 2, bh + 2), out, false, th + 2, 1)
			self:DrawSquare(id .. "_sbo2", Vector2new(bx + 1, by + 1), Vector2new(bw - 2, bh - 2), out, false, 1, 1)
		end
		self:DrawSquare(id .. "_sb", Vector2new(bx, by), Vector2new(bw, bh), color, false, th, 1)
	end
end

function EasyESP:VisualsGlow(id, bx, by, bw, bh, cfg, color, clock)
	local layers = cfg.Layers
	local pulse = cfg.Pulse and (0.5 + 0.5 * mathsin(clock * cfg.PulseSpeed)) or 1
	for i = 1, layers do
		local g = i * cfg.Spread
		local alpha = cfg.Alpha * pulse * (1 - (i - 1) / layers)
		self:DrawSquare(id .. "_glow_" .. i, Vector2new(bx - g, by - g), Vector2new(bw + g * 2, bh + g * 2), color, false, 1, alpha)
	end
end

function EasyESP:VisualsHealthBar(id, bx, by, bw, bh, pct, cfg)
	local th = cfg.Thickness
	local left = cfg.Side ~= "Right"
	local xPos = left and (bx - 4 - th) or (bx + bw + 4)
	pct = mathclamp(pct, 0, 1)

	if cfg.Outline then
		self:DrawSquare(id .. "_hbo", Vector2new(xPos - 1, by - 1), Vector2new(th + 2, bh + 2), Color3new(0, 0, 0), true, 1, 0.7)
	end
	self:DrawSquare(id .. "_hbg", Vector2new(xPos, by), Vector2new(th, bh), Color3new(0.1, 0.1, 0.12), true, 1, 0.6)

	local col = cfg.ColorFull
	if cfg.Gradient then
		col = cfg.ColorLow:Lerp(cfg.ColorFull, pct)
	elseif pct < 0.3 then
		col = cfg.ColorLow
	end
	local fillH = bh * pct
	self:DrawSquare(id .. "_hbf", Vector2new(xPos, by + (bh - fillH)), Vector2new(th, mathmax(fillH, 1)), col, true, 1, 1)

	if cfg.Notch then
		self:DrawLine(id .. "_hbn", Vector2new(xPos, by + bh * 0.5), Vector2new(xPos + th, by + bh * 0.5), Color3new(0, 0, 0), 1, 0.5)
	end
	if cfg.ShowText and pct < 1 then
		self:DrawText(id .. "_hbt", tostring(mathfloor(pct * 100)), Vector2new(xPos + th / 2, by - 12), 10, Color3new(1, 1, 1), true, 2, true)
	end
end

function EasyESP:VisualsArmorBar(id, bx, by, bw, bh, pct, cfg)
	local th = cfg.Thickness
	pct = mathclamp(pct, 0, 1)
	local yPos = by + bh + 3
	if cfg.Outline then
		self:DrawSquare(id .. "_abo", Vector2new(bx - 1, yPos - 1), Vector2new(bw + 2, th + 2), Color3new(0, 0, 0), true, 1, 0.7)
	end
	self:DrawSquare(id .. "_abg", Vector2new(bx, yPos), Vector2new(bw, th), Color3new(0.1, 0.1, 0.12), true, 1, 0.6)
	self:DrawSquare(id .. "_abf", Vector2new(bx, yPos), Vector2new(bw * pct, th), cfg.Color, true, 1, 1)
end

function EasyESP:VisualsFlags(id, bx, by, bw, bh, ctx, cfg)
	local right = cfg.Side ~= "Left"
	local xPos = right and (bx + bw + 5) or (bx - 5)
	local yPos = by
	local i = 0
	for _, provider in pairs(self.State.FlagProviders) do
		local ok, res = pcall(provider, ctx)
		if ok and res and res.text then
			i = i + 1
			local t = self:GetDrawing(id .. "_flag_" .. i, "Text")
			t.Visible      = true
			t.Text         = res.text
			t.Size         = cfg.Size
			t.Color        = res.color or cfg.DefaultColor
			t.Font         = cfg.Font
			t.Outline      = cfg.Outline
			t.OutlineColor = Color3new(0, 0, 0)
			t.Center       = false
			if right then
				t.Position = Vector2new(xPos, yPos)
			else
				t.Position = Vector2new(xPos - t.TextBounds.X, yPos)
			end
			yPos = yPos + cfg.Size + cfg.Spacing
		end
	end
	for j = i + 1, (self._maxFlags or 0) do
		local d = self.State.Drawings[id .. "_flag_" .. j]
		if d then d.Visible = false end
	end
	self._maxFlags = mathmax(self._maxFlags or 0, i)
end

function EasyESP:TriggerHitMarker(userId, damage)
	self.State.HitMarkers[tostring(userId)] = { t = self.State.Clock, dmg = damage }
end

function EasyESP:UpdateHitTracking(plr, hum)
	local id = tostring(plr.UserId)
	local last = self.State.LastHealth[id]
	if last ~= nil and hum.Health < last then
		self:TriggerHitMarker(plr.UserId, mathfloor(last - hum.Health))
	end
	self.State.LastHealth[id] = hum.Health
end

function EasyESP:RecordBacktrack(plr, char)
	local cfg = self.Settings.Visuals.Backtrack
	if not cfg.Enabled then return end
	local id = tostring(plr.UserId)
	local hist = self.State.Backtrack[id]
	if not hist then hist = {}; self.State.Backtrack[id] = hist end
	local now = self.State.Clock
	local lastTick = hist[#hist]
	if lastTick and (now - lastTick.t) < cfg.Interval then return end

	local rig = char:FindFirstChild("UpperTorso") and "R15" or "R6"
	local snapshot = { t = now, rig = rig, joints = {} }
	local seen = {}
	for _, bone in ipairs(BONES[rig]) do
		for _, part in ipairs(bone) do
			if not seen[part] then
				local p = char:FindFirstChild(part)
				if p then snapshot.joints[part] = p.Position end
				seen[part] = true
			end
		end
	end
	hist[#hist + 1] = snapshot
	while #hist > cfg.Ticks do tableremove(hist, 1) end
end

function EasyESP:RenderBacktrack(id, plr)
	local cfg = self.Settings.Visuals.Backtrack
	local hist = self.State.Backtrack[tostring(plr.UserId)]
	if not hist then return end
	local n = #hist
	local lineIdx = 0
	for h = 1, n do
		local snap = hist[h]
		local fade = cfg.FadeTail and (h / n) or 1
		local alpha = cfg.Alpha * fade
		if cfg.Skeleton then
			for _, bone in ipairs(BONES[snap.rig]) do
				local a = snap.joints[bone[1]]
				local b = snap.joints[bone[2]]
				if a and b then
					local pa, za = self:W2S(a)
					local pb, zb = self:W2S(b)
					lineIdx = lineIdx + 1
					local line = self:GetDrawing(id .. "_bt_" .. lineIdx, "Line")
					if za > 0 and zb > 0 then
						line.Visible = true
						line.From = pa
						line.To = pb
						line.Color = cfg.Color
						line.Thickness = 1
						line.Transparency = alpha
					else
						line.Visible = false
					end
				end
			end
		end
	end
	self._maxBT = mathmax(self._maxBT or 0, lineIdx)
	for j = lineIdx + 1, (self._maxBT or 0) do
		local d = self.State.Drawings[id .. "_bt_" .. j]
		if d then d.Visible = false end
	end
end

function EasyESP:GetFootPos(root, hum)
	local drop = 2.5
	if hum and hum.HipHeight and hum.HipHeight > 0 then
		drop = hum.HipHeight + 2.6
	end
	return root.Position - Vector3new(0, drop, 0)
end

function EasyESP:ResolveRingColor(ring, clock, i)
	if ring.Effect == "Rainbow" then
		return Color3fromHSV((clock * 0.15 + (i or 0) * 0.08) % 1, 1, 1)
	elseif ring.Effect == "Breathe" then
		return ring.Color:Lerp(ring.Color2 or Color3new(1, 1, 1), 0.5 + 0.5 * mathsin(clock * 2))
	end
	return ring.Color
end

function EasyESP:DrawRingSpec(id, center, ring, clock, i)
	local spin  = clock * (ring.Spin or 0)
	local alpha = ring.Alpha or 1
	if ring.Pulse then alpha = alpha * (0.55 + 0.45 * mathsin(clock * (ring.PulseSpeed or 3))) end
	local color = self:ResolveRingColor(ring, clock, i)
	local segs  = ring.Segments or 48
	local shape = ring.Shape or "Circle"

	if shape == "Square" then
		self:DrawWorldPolygon(id, center, ring.Radius, 4, color, ring.Thickness or 2, alpha, spin + 0.785)
		return
	elseif shape == "Pentagon" then
		self:DrawWorldPolygon(id, center, ring.Radius, 5, color, ring.Thickness or 2, alpha, spin)
		return
	elseif shape == "Hexagon" then
		self:DrawWorldPolygon(id, center, ring.Radius, 6, color, ring.Thickness or 2, alpha, spin)
		return
	elseif shape == "Star" then
		self:DrawWorldStar(id, center, ring.Radius, ring.Radius * 0.5, ring.StarPoints or 5, color, ring.Thickness or 2, alpha, spin)
		return
	elseif shape == "Radar" then
		self:DrawWorldRing(id .. "_rb", center, ring.Radius, segs, color, 1, alpha * 0.4, 0, EMPTY)
		self:DrawRadarSweep(id .. "_rs", center, ring.Radius, clock * (ring.Spin ~= 0 and ring.Spin or 2), ring.ArcLen or 1.2, 20, color, ring.Thickness or 2, alpha)
		return
	end

	self:DrawWorldRing(id, center, ring.Radius, segs, color, ring.Thickness or 2, alpha, spin, {
		dashed        = ring.Style == "Dashed",
		dashGap       = ring.DashGap or 2,
		gradient      = ring.Gradient,
		gradientColor = ring.GradientColor,
		glow          = ring.Glow,
		glowAlpha     = ring.GlowAlpha,
		filled        = ring.Filled,
		fillAlpha     = ring.FillAlpha,
	})

	if ring.Ticks and ring.Ticks > 0 then
		for t = 0, ring.Ticks - 1 do
			local a = (t / ring.Ticks) * TAU + spin
			local inner = center + Vector3new(mathcos(a) * ring.Radius, 0, mathsin(a) * ring.Radius)
			local outer = center + Vector3new(mathcos(a) * (ring.Radius + (ring.TickLen or 0.6)), (ring.TickUp or 0.4), mathsin(a) * (ring.Radius + (ring.TickLen or 0.6)))
			local p1, d1 = self:W2S(inner)
			local p2, d2 = self:W2S(outer)
			local line = self:GetDrawing(id .. "_tick_" .. t, "Line")
			if d1 > 0 and d2 > 0 then
				line.Visible = true
				line.From = p1
				line.To = p2
				line.Color = color
				line.Thickness = ring.Thickness or 2
				line.Transparency = alpha
			else
				line.Visible = false
			end
		end
	end
end

function EasyESP:AddRangeRing(id, opts)
	opts = opts or {}
	self.State.RangeRings[id] = {
		Target    = opts.Target,
		Radius    = opts.Radius or 10,
		Color     = opts.Color or Color3fromRGB(200, 60, 220),
		Color2    = opts.Color2,
		GradientColor = opts.GradientColor,
		Thickness = opts.Thickness or 2,
		Alpha     = opts.Alpha or 1,
		Segments  = opts.Segments or 48,
		Style     = opts.Style or "Solid",
		DashGap   = opts.DashGap or 2,
		Effect    = opts.Effect or "None",
		Spin      = opts.Spin or 0,
		Pulse     = opts.Pulse or false,
		PulseSpeed= opts.PulseSpeed or 3,
		Filled    = opts.Filled or false,
		FillAlpha = opts.FillAlpha or 0.08,
		Glow      = opts.Glow or false,
		GlowAlpha = opts.GlowAlpha,
		Gradient  = opts.Gradient or false,
		Ticks     = opts.Ticks or 0,
		TickLen   = opts.TickLen or 0.6,
		TickUp    = opts.TickUp or 0.4,
		HeightOffset = opts.HeightOffset or 0.05,
		Shape     = opts.Shape or "Circle",
		StarPoints= opts.StarPoints or 5,
		ArcLen    = opts.ArcLen or 1.2,
	}
	return self.State.RangeRings[id]
end

function EasyESP:RemoveRangeRing(id)
	self.State.RangeRings[id] = nil
end

function EasyESP:ClearRangeRings()
	for k in pairs(self.State.RangeRings) do self.State.RangeRings[k] = nil end
end

function EasyESP:ResolveRingCenter(target)
	if target == nil then
		local char = LocalPlayer.Character
		local root = char and char:FindFirstChild("HumanoidRootPart")
		local hum = char and char:FindFirstChildOfClass("Humanoid")
		if root then return self:GetFootPos(root, hum) end
		return nil
	elseif typeof(target) == "Vector3" then
		return target
	elseif typeof(target) == "Instance" then
		if target:IsA("Player") then
			local char = target.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local hum = char and char:FindFirstChildOfClass("Humanoid")
			if root then return self:GetFootPos(root, hum) end
			return nil
		elseif target:IsA("BasePart") then
			return target.Position - Vector3new(0, target.Size.Y / 2, 0)
		elseif target:IsA("Model") then
			local pp = target.PrimaryPart or target:FindFirstChildWhichIsA("BasePart")
			if pp then return pp.Position end
		end
	elseif type(target) == "function" then
		return target()
	end
	return nil
end

function EasyESP:RenderRangeRings(dt)
	local clock = self.State.Clock
	local i = 0
	for id, ring in pairs(self.State.RangeRings) do
		i = i + 1
		local center = self:ResolveRingCenter(ring.Target)
		if center then
			self:DrawRingSpec("rr_" .. id, center + Vector3new(0, ring.HeightOffset or 0.05, 0), ring, clock, i)
		end
	end
end

EasyESP.RingPresets = {
	KillAura = { Radius = 14, Color = Color3fromRGB(255, 70, 70),  Thickness = 2, Style = "Solid",  Spin = 0.4, Glow = true, Ticks = 12, TickLen = 0.8 },
	Reach    = { Radius = 6,  Color = Color3fromRGB(90, 200, 255), Thickness = 2, Style = "Dashed", Pulse = true },
	Grab     = { Radius = 4,  Color = Color3fromRGB(90, 255, 150), Thickness = 2, Style = "Solid",  Filled = true, FillAlpha = 0.1 },
	Rainbow  = { Radius = 12, Color = Color3fromRGB(255, 255, 255), Thickness = 3, Effect = "Rainbow", Spin = 1, Glow = true },
	Neon     = { Radius = 10, Color = Color3fromRGB(200, 60, 220), Thickness = 2, Glow = true, GlowAlpha = 0.5, Pulse = true },
	Target   = { Radius = 8,  Color = Color3fromRGB(255, 160, 40), Thickness = 2, Ticks = 24, TickLen = 1.0, Spin = 0.2 },
}

function EasyESP:ApplyRingPreset(id, presetName, overrides)
	local preset = EasyESP.RingPresets[presetName]
	if not preset then return nil end
	local opts = {}
	for k, v in pairs(preset) do opts[k] = v end
	if overrides then
		for k, v in pairs(overrides) do opts[k] = v end
	end
	return self:AddRangeRing(id, opts)
end

function EasyESP:RecordLocalTrail()
	local cfg = self.Settings.Visuals.Trail
	if not cfg or not cfg.Enabled then return end
	local char = LocalPlayer.Character
	local root = char and char:FindFirstChild("HumanoidRootPart")
	if not root then return end
	local hist = self.State.LocalTrail
	if not hist then hist = {}; self.State.LocalTrail = hist end
	local now = self.State.Clock
	local last = hist[#hist]
	if last and (now - last.t) < (cfg.Interval or 0.05) then return end
	hist[#hist + 1] = { t = now, pos = root.Position - Vector3new(0, 2.5, 0) }
	while #hist > (cfg.Length or 30) do tableremove(hist, 1) end
end

function EasyESP:RenderLocalTrail()
	local cfg = self.Settings.Visuals.Trail
	if not cfg or not cfg.Enabled then return end
	local hist = self.State.LocalTrail
	if not hist or #hist < 2 then return end
	local clock = self.State.Clock
	for i = 1, #hist - 1 do
		local a = hist[i]
		local b = hist[i + 1]
		local pa, da = self:W2S(a.pos)
		local pb, db = self:W2S(b.pos)
		local line = self:GetDrawing("localtrail_" .. i, "Line")
		if da > 0 and db > 0 then
			local frac = i / #hist
			line.Visible = true
			line.From = pa
			line.To = pb
			line.Color = cfg.Rainbow and Color3fromHSV((frac + clock * 0.2) % 1, 1, 1) or cfg.Color
			line.Thickness = cfg.Thickness or 2
			line.Transparency = (cfg.Alpha or 0.8) * frac
		else
			line.Visible = false
		end
	end
end

function EasyESP:ExportVisuals()
	local function ser(t, indent)
		local out = {}
		for k, v in pairs(t) do
			local key = type(k) == "number" and ("[" .. k .. "]") or tostring(k)
			if type(v) == "table" then
				if typeof(v) == "Color3" then
					out[#out + 1] = indent .. key .. " = Color3.fromRGB(" .. mathfloor(v.R * 255) .. ", " .. mathfloor(v.G * 255) .. ", " .. mathfloor(v.B * 255) .. "),"
				else
					out[#out + 1] = indent .. key .. " = {"
					out[#out + 1] = ser(v, indent .. "  ")
					out[#out + 1] = indent .. "},"
				end
			elseif type(v) == "string" then
				out[#out + 1] = indent .. key .. ' = "' .. v .. '",'
			else
				out[#out + 1] = indent .. key .. " = " .. tostring(v) .. ","
			end
		end
		return table.concat(out, "\n")
	end
	return "{\n" .. ser(self.Settings.Visuals, "  ") .. "\n}"
end

function EasyESP:RenderFovCircle()
	local cfg = self.Settings.Visuals.FovCircle
	if not cfg or not cfg.Enabled then return end
	local viewport = Camera.ViewportSize
	local center = Vector2new(viewport.X / 2, viewport.Y / 2)
	local color = cfg.Rainbow and Color3fromHSV((self.State.Clock * 0.2) % 1, 1, 1) or cfg.Color

	local circle = self:GetDrawing("fovcircle", "Circle")
	circle.Visible = true
	circle.Position = center
	circle.Radius = cfg.Radius
	circle.Color = color
	circle.Thickness = cfg.Thickness or 1
	circle.Filled = false
	circle.NumSides = cfg.Sides or 64
	circle.Transparency = cfg.Alpha or 1

	if cfg.Filled then
		local fill = self:GetDrawing("fovcircle_fill", "Circle")
		fill.Visible = true
		fill.Position = center
		fill.Radius = cfg.Radius
		fill.Color = color
		fill.Filled = true
		fill.NumSides = cfg.Sides or 64
		fill.Transparency = cfg.FillAlpha or 0.05
	end
end

function EasyESP:RenderCrosshair()
	local cfg = self.Settings.Visuals.Crosshair
	if not cfg or not cfg.Enabled then return end
	local viewport = Camera.ViewportSize
	local cx, cy = viewport.X / 2, viewport.Y / 2
	local color = cfg.Rainbow and Color3fromHSV((self.State.Clock * 0.3) % 1, 1, 1) or cfg.Color
	local gap = cfg.Gap or 4
	local len = cfg.Length or 8
	local th = cfg.Thickness or 1
	local a = cfg.Alpha or 1

	local segs = {
		{ Vector2new(cx - gap - len, cy), Vector2new(cx - gap, cy) },
		{ Vector2new(cx + gap, cy), Vector2new(cx + gap + len, cy) },
		{ Vector2new(cx, cy - gap - len), Vector2new(cx, cy - gap) },
		{ Vector2new(cx, cy + gap), Vector2new(cx, cy + gap + len) },
	}
	for i, s in ipairs(segs) do
		if cfg.Outline then
			local o = self:GetDrawing("xhair_o_" .. i, "Line")
			o.Visible = true o.From = s[1] o.To = s[2]
			o.Color = Color3new(0, 0, 0) o.Thickness = th + 2 o.Transparency = a
		end
		local l = self:GetDrawing("xhair_" .. i, "Line")
		l.Visible = true l.From = s[1] l.To = s[2]
		l.Color = color l.Thickness = th l.Transparency = a
	end
	if cfg.Dot then
		local d = self:GetDrawing("xhair_dot", "Circle")
		d.Visible = true d.Position = Vector2new(cx, cy)
		d.Radius = cfg.DotSize or 1 d.Filled = true d.Color = color d.Transparency = a
	end
end

function EasyESP:RenderRings(id, footPos, clock)
	local cfg = self.Settings.Visuals.Rings
	for i, ring in ipairs(cfg.List) do
		local r = {
			Radius = ring.Radius, Color = ring.Color, Color2 = ring.Color2,
			GradientColor = ring.GradientColor, Thickness = ring.Thickness,
			Alpha = ring.Alpha, Segments = ring.Segments or cfg.Segments,
			Style = ring.Style, DashGap = ring.DashGap, Effect = ring.Effect,
			Spin = ring.Spin, Pulse = ring.Pulse, PulseSpeed = ring.PulseSpeed,
			Filled = ring.Filled, FillAlpha = ring.FillAlpha, Glow = ring.Glow,
			GlowAlpha = ring.GlowAlpha, Gradient = ring.Gradient, Ticks = ring.Ticks,
			TickLen = ring.TickLen, TickUp = ring.TickUp,
		}
		self:DrawRingSpec(id .. "_ring_" .. i, footPos + Vector3new(0, cfg.Height, 0), r, clock, i)
	end
end

function EasyESP:RenderSphere(id, center, clock)
	local cfg = self.Settings.Visuals.Sphere
	local color = cfg.Color
	if cfg.Effect == "Rainbow" then color = Color3fromHSV((clock * 0.15) % 1, 1, 1) end
	self:DrawWorldSphere(id, center, cfg.Radius, cfg.Rings, cfg.Segments, color, cfg.Thickness, cfg.Alpha, clock * (cfg.Spin or 0))
end

local function rnd(seed)
	local x = mathsin(seed * 127.1 + 311.7) * 43758.5453
	return x - mathfloor(x)
end

function EasyESP:RenderEffects(id, footPos, centerPos, clock)
	local e = self.Settings.Visuals.Effects

	if e.Confetti.Enabled then
		local c = e.Confetti
		for i = 1, c.Count do
			local ang = rnd(i) * TAU
			local rad = c.Radius * (0.3 + 0.7 * rnd(i * 1.7))
			local speed = c.Speed * (0.7 + 0.6 * rnd(i * 2.3))
			local phase = (clock * speed * 0.1 + rnd(i * 3.1)) % 1
			local y = c.Height * (1 - phase)
			local sway = mathsin(clock * 3 + i) * 0.6
			local wp = footPos + Vector3new(mathcos(ang) * rad + sway, y, mathsin(ang) * rad)
			local col = c.Rainbow and Color3fromHSV((rnd(i * 5.9) + clock * 0.2) % 1, 1, 1) or c.Color
			self:DrawWorldDot(id .. "_cf_" .. i, wp, c.Size * (0.6 + 0.5 * (1 - phase)), col, mathclamp(phase * 3, 0, 1))
		end
	end

	if e.Rain.Enabled then
		local r = e.Rain
		for i = 1, r.Count do
			local ang = rnd(i * 1.3) * TAU
			local rad = r.Radius * rnd(i * 2.7)
			local phase = (clock * r.Speed + rnd(i) * r.Height) % r.Height
			local yTop = r.Height - phase
			local top = footPos + Vector3new(mathcos(ang) * rad, yTop, mathsin(ang) * rad)
			local bot = top - Vector3new(0, r.Length, 0)
			local sp1, d1 = self:W2S(top)
			local sp2, d2 = self:W2S(bot)
			local line = self:GetDrawing(id .. "_rain_" .. i, "Line")
			if d1 > 0 and d2 > 0 then
				line.Visible = true
				line.From = sp1
				line.To = sp2
				line.Color = r.Rainbow and Color3fromHSV((clock * 0.1 + rnd(i)) % 1, 0.6, 1) or r.Color
				line.Thickness = 1
				line.Transparency = r.Alpha
			else
				line.Visible = false
			end
		end
	end

	if e.Synth.Enabled then
		local sy = e.Synth
		for ri = 1, sy.Rings do
			local prog = (clock * sy.Speed * 0.1) + (ri / sy.Rings)
			local frac = prog % 1
			local radius = mathmax(sy.Radius * frac, 0.1)
			local y = sy.Rise and (sy.Radius * frac * 0.4) or sy.Height
			local hue = (sy.Hue + frac * sy.HueRange) % 1
			self:DrawWorldRing(id .. "_synth_" .. ri, footPos + Vector3new(0, y, 0), radius, sy.Segments, Color3fromHSV(hue, 1, 1), sy.Thickness, sy.Alpha * (1 - frac), 0, { glow = true, glowAlpha = sy.Alpha * (1 - frac) * 0.4 })
		end
	end

	if e.Orbit.Enabled then
		local o = e.Orbit
		for i = 1, o.Count do
			local base = (i / o.Count) * TAU
			local ang = clock * o.Speed + base
			local vy = mathsin(clock * o.Speed * 1.3 + base) * o.Vertical
			local wp = centerPos + Vector3new(mathcos(ang) * o.Radius, vy, mathsin(ang) * o.Radius)
			local col = o.Rainbow and Color3fromHSV((clock * 0.2 + i / o.Count) % 1, 1, 1) or o.Color
			self:DrawWorldDot(id .. "_orbit_" .. i, wp, o.Size, col, 1)
			if o.Trail then
				for tr = 1, o.TrailLen or 5 do
					local ta = ang - tr * 0.12
					local tvy = mathsin(clock * o.Speed * 1.3 + base - tr * 0.12) * o.Vertical
					local twp = centerPos + Vector3new(mathcos(ta) * o.Radius, tvy, mathsin(ta) * o.Radius)
					self:DrawWorldDot(id .. "_orbtr_" .. i .. "_" .. tr, twp, o.Size * (1 - tr / ((o.TrailLen or 5) + 1)), col, 1 - tr / ((o.TrailLen or 5) + 1))
				end
			end
		end
	end

	if e.Spiral and e.Spiral.Enabled then
		local sp = e.Spiral
		local turns = sp.Turns or 3
		local pts = sp.Points or 60
		local prev
		for i = 0, pts do
			local frac = i / pts
			local ang = frac * TAU * turns + clock * sp.Speed
			local rad = sp.Radius * frac
			local y = sp.Height * frac
			local cur = self:W2S(footPos + Vector3new(mathcos(ang) * rad, y, mathsin(ang) * rad))
			local _, depth = self:W2S(footPos + Vector3new(mathcos(ang) * rad, y, mathsin(ang) * rad))
			if prev and prev.d > 0 and depth > 0 then
				local line = self:GetDrawing(id .. "_spiral_" .. i, "Line")
				line.Visible = true
				line.From = Vector2new(prev.x, prev.y)
				line.To = cur
				line.Color = sp.Rainbow and Color3fromHSV((frac + clock * 0.2) % 1, 1, 1) or sp.Color
				line.Thickness = sp.Thickness or 1
				line.Transparency = sp.Alpha or 0.8
			end
			prev = { x = cur.X, y = cur.Y, d = depth }
		end
	end

	if e.Vortex and e.Vortex.Enabled then
		local vx = e.Vortex
		for i = 1, vx.Particles do
			local base = rnd(i) * TAU
			local life = (clock * vx.Speed * 0.1 + rnd(i * 2.1)) % 1
			local rad = vx.Radius * (1 - life)
			local ang = base + life * TAU * (vx.Twist or 3)
			local y = vx.Height * life
			local wp = footPos + Vector3new(mathcos(ang) * rad, y, mathsin(ang) * rad)
			local col = vx.Rainbow and Color3fromHSV((life + clock * 0.2) % 1, 1, 1) or vx.Color
			self:DrawWorldDot(id .. "_vortex_" .. i, wp, vx.Size * (1 - life * 0.5), col, mathclamp(life * 2, 0, 1))
		end
	end

	if e.Shockwave and e.Shockwave.Enabled then
		local sw = e.Shockwave
		for w = 1, sw.Waves do
			local frac = ((clock * sw.Speed * 0.1) + (w / sw.Waves)) % 1
			local radius = mathmax(sw.Radius * frac, 0.1)
			self:DrawWorldRing(id .. "_shock_" .. w, footPos, radius, sw.Segments or 40, sw.Color, sw.Thickness or 2, sw.Alpha * (1 - frac), 0, { glow = true, glowAlpha = sw.Alpha * (1 - frac) * 0.5 })
		end
	end

	if e.Aura and e.Aura.Enabled then
		local au = e.Aura
		for i = 1, au.Rings do
			local ang = clock * au.Speed * (i % 2 == 0 and 1 or -1)
			local tilt = (i / au.Rings) * math.pi
			local prev
			local segs = au.Segments or 36
			for s = 0, segs do
				local a = (s / segs) * TAU
				local local3 = Vector3new(mathcos(a) * au.Radius, mathsin(a) * au.Radius * mathsin(tilt), mathsin(a) * au.Radius * mathcos(tilt))
				local rotated = Vector3new(local3.X * mathcos(ang) - local3.Z * mathsin(ang), local3.Y, local3.X * mathsin(ang) + local3.Z * mathcos(ang))
				local sp, depth = self:W2S(centerPos + rotated)
				local cur = { x = sp.X, y = sp.Y, d = depth }
				if prev and prev.d > 0 and depth > 0 then
					local line = self:GetDrawing(id .. "_aura_" .. i .. "_" .. s, "Line")
					line.Visible = true
					line.From = Vector2new(prev.x, prev.y)
					line.To = Vector2new(cur.x, cur.y)
					line.Color = au.Rainbow and Color3fromHSV((i / au.Rings + clock * 0.15) % 1, 1, 1) or au.Color
					line.Thickness = au.Thickness or 1
					line.Transparency = au.Alpha or 0.7
				end
				prev = cur
			end
		end
	end

	if e.Fireflies and e.Fireflies.Enabled then
		local ff = e.Fireflies
		for i = 1, ff.Count do
			local t = clock * ff.Speed * 0.1
			local ax = mathsin(t + rnd(i) * TAU) * ff.Radius
			local az = mathcos(t * 1.3 + rnd(i * 2.1) * TAU) * ff.Radius
			local ay = ff.Height * (0.3 + 0.7 * (0.5 + 0.5 * mathsin(t * 2 + i)))
			local flick = 0.4 + 0.6 * (0.5 + 0.5 * mathsin(clock * 8 + i * 1.7))
			local col = ff.Rainbow and Color3fromHSV((rnd(i) + clock * 0.1) % 1, 0.7, 1) or ff.Color
			self:DrawWorldDot(id .. "_ff_" .. i, footPos + Vector3new(ax, ay, az), ff.Size * flick, col, flick)
		end
	end

	if e.Lightning and e.Lightning.Enabled then
		local lt = e.Lightning
		local bolts = lt.Bolts or 3
		for b = 1, bolts do
			local phase = mathfloor(clock * lt.Speed + b) 
			local seedBase = phase * 13.1 + b * 7.3
			local ang = rnd(seedBase) * TAU
			local segs = lt.Segments or 6
			local topY = lt.Height
			local prev = footPos + Vector3new(mathcos(ang) * lt.Radius, topY, mathsin(ang) * lt.Radius)
			local flash = 1 - (clock * lt.Speed % 1)
			for s = 1, segs do
				local frac = s / segs
				local jitter = (rnd(seedBase + s) - 0.5) * lt.Jitter
				local jz = (rnd(seedBase + s * 2.3) - 0.5) * lt.Jitter
				local cur = footPos + Vector3new(mathcos(ang) * lt.Radius * (1 - frac) + jitter, topY * (1 - frac), mathsin(ang) * lt.Radius * (1 - frac) + jz)
				local p1, d1 = self:W2S(prev)
				local p2, d2 = self:W2S(cur)
				local line = self:GetDrawing(id .. "_lt_" .. b .. "_" .. s, "Line")
				if d1 > 0 and d2 > 0 then
					line.Visible = true
					line.From = p1
					line.To = p2
					line.Color = lt.Color
					line.Thickness = lt.Thickness or 2
					line.Transparency = mathclamp(flash * (lt.Alpha or 1), 0, 1)
				else
					line.Visible = false
				end
				prev = cur
			end
		end
	end

	if e.Helix and e.Helix.Enabled then
		local hx = e.Helix
		local pts = hx.Points or 40
		local strands = hx.Strands or 2
		for st = 0, strands - 1 do
			local offset = (st / strands) * TAU
			local prev
			for i = 0, pts do
				local frac = i / pts
				local ang = frac * TAU * (hx.Turns or 2) + clock * hx.Speed + offset
				local y = hx.Height * frac
				local wp = centerPos + Vector3new(mathcos(ang) * hx.Radius, y - hx.Height / 2, mathsin(ang) * hx.Radius)
				local sp, depth = self:W2S(wp)
				local cur = { x = sp.X, y = sp.Y, d = depth }
				if prev and prev.d > 0 and depth > 0 then
					local line = self:GetDrawing(id .. "_hx_" .. st .. "_" .. i, "Line")
					line.Visible = true
					line.From = Vector2new(prev.x, prev.y)
					line.To = Vector2new(cur.x, cur.y)
					line.Color = hx.Rainbow and Color3fromHSV((frac + clock * 0.2) % 1, 1, 1) or hx.Color
					line.Thickness = hx.Thickness or 1
					line.Transparency = hx.Alpha or 0.8
				end
				prev = cur
			end
		end
	end

	if e.Heartbeat and e.Heartbeat.Enabled then
		local hb = e.Heartbeat
		local beat = (clock * hb.Speed) % 1
		local pulse = beat < 0.15 and (beat / 0.15) or mathmax(0, 1 - (beat - 0.15) / 0.85)
		local radius = hb.Radius * (0.6 + 0.4 * pulse)
		self:DrawWorldRing(id .. "_hb", footPos, radius, hb.Segments or 40, hb.Color, hb.Thickness or 2, (hb.Alpha or 0.8) * (0.4 + 0.6 * pulse), 0, { glow = true, glowAlpha = 0.3 * pulse })
	end

	if e.Grid and e.Grid.Enabled then
		local gr = e.Grid
		local n = gr.Lines or 6
		local size = gr.Size or 10
		local step = (size * 2) / n
		for i = 0, n do
			local off = -size + i * step
			local phase = mathsin(clock * gr.Speed + i) * gr.Wave
			local a1 = footPos + Vector3new(off, phase, -size)
			local a2 = footPos + Vector3new(off, phase, size)
			local b1 = footPos + Vector3new(-size, phase, off)
			local b2 = footPos + Vector3new(size, phase, off)
			local pa1, da1 = self:W2S(a1)
			local pa2, da2 = self:W2S(a2)
			local pb1, db1 = self:W2S(b1)
			local pb2, db2 = self:W2S(b2)
			local l1 = self:GetDrawing(id .. "_gridA_" .. i, "Line")
			if da1 > 0 and da2 > 0 then
				l1.Visible = true l1.From = pa1 l1.To = pa2
				l1.Color = gr.Color l1.Thickness = 1 l1.Transparency = gr.Alpha or 0.5
			else l1.Visible = false end
			local l2 = self:GetDrawing(id .. "_gridB_" .. i, "Line")
			if db1 > 0 and db2 > 0 then
				l2.Visible = true l2.From = pb1 l2.To = pb2
				l2.Color = gr.Color l2.Thickness = 1 l2.Transparency = gr.Alpha or 0.5
			else l2.Visible = false end
		end
	end

	if e.Tornado and e.Tornado.Enabled then
		local tn = e.Tornado
		for i = 1, tn.Particles do
			local seed = rnd(i)
			local life = (clock * tn.Speed * 0.1 + seed) % 1
			local h = tn.Height * life
			local rad = tn.Radius * (0.2 + 0.8 * (1 - life))
			local ang = seed * TAU + clock * tn.Spin + life * TAU * tn.Twist
			local wp = footPos + Vector3new(mathcos(ang) * rad, h, mathsin(ang) * rad)
			local col = tn.Rainbow and Color3fromHSV((life + clock * 0.15) % 1, 0.8, 1) or tn.Color
			self:DrawWorldDot(id .. "_tor_" .. i, wp, tn.Size * (0.5 + life * 0.5), col, mathclamp((1 - life) * 2, 0, 1))
		end
	end

	if e.Portal and e.Portal.Enabled then
		local po = e.Portal
		for r = 1, po.Rings do
			local frac = r / po.Rings
			local wobble = mathsin(clock * po.Speed + r) * 0.3
			local radius = po.Radius * frac + wobble
			local hue = (po.Hue + frac * 0.3 + clock * 0.1) % 1
			self:DrawWorldRing(id .. "_portal_" .. r, footPos + Vector3new(0, po.Height, 0), radius, po.Segments or 40, Color3fromHSV(hue, 1, 1), po.Thickness or 2, po.Alpha, clock * po.Spin * (r % 2 == 0 and 1 or -1), { glow = true, glowAlpha = po.Alpha * 0.4 })
		end
	end

	if e.Snow and e.Snow.Enabled then
		local sn = e.Snow
		for i = 1, sn.Count do
			local seed = rnd(i)
			local ang = seed * TAU
			local rad = sn.Radius * rnd(i * 1.7)
			local phase = (clock * sn.Speed * 0.1 + seed) % 1
			local y = sn.Height * (1 - phase)
			local sway = mathsin(clock * 2 + i) * 0.8
			local wp = footPos + Vector3new(mathcos(ang) * rad + sway, y, mathsin(ang) * rad)
			self:DrawWorldDot(id .. "_snow_" .. i, wp, sn.Size, sn.Color, sn.Alpha or 0.9)
		end
	end

	if e.Embers and e.Embers.Enabled then
		local em = e.Embers
		for i = 1, em.Count do
			local seed = rnd(i)
			local ang = seed * TAU
			local rad = em.Radius * rnd(i * 2.3) * (0.5 + 0.5 * mathsin(clock + i))
			local phase = (clock * em.Speed * 0.1 + seed) % 1
			local y = em.Height * phase
			local wp = footPos + Vector3new(mathcos(ang) * rad, y, mathsin(ang) * rad)
			local heat = 1 - phase
			local col = Color3fromRGB(255, mathfloor(120 + 100 * heat), mathfloor(40 * heat))
			self:DrawWorldDot(id .. "_ember_" .. i, wp, em.Size * heat, col, mathclamp(heat * 1.5, 0, 1))
		end
	end

	if e.Radar and e.Radar.Enabled then
		local ra = e.Radar
		local sweep = clock * ra.Speed
		self:DrawWorldRing(id .. "_radarbase", footPos, ra.Radius, ra.Segments or 40, ra.Color, 1, ra.Alpha * 0.4, 0, EMPTY)
		self:DrawRadarSweep(id .. "_radarsw", footPos, ra.Radius, sweep, ra.ArcLen or 1.2, ra.Segments or 20, ra.Color, ra.Thickness or 2, ra.Alpha)
	end

	if e.StarBurst and e.StarBurst.Enabled then
		local sb = e.StarBurst
		self:DrawWorldStar(id .. "_starburst", centerPos, sb.OuterRadius, sb.InnerRadius, sb.Points or 5, sb.Rainbow and Color3fromHSV((clock * 0.2) % 1, 1, 1) or sb.Color, sb.Thickness or 2, sb.Alpha or 0.9, clock * sb.Spin)
	end
end

function EasyESP:RenderPreview(rainbow)
	local sk = self.Settings.Visuals
	local p = sk.Preview
	local clock = self.State.Clock
	local id = "__preview__"

	local viewport = Camera.ViewportSize
	local bw, bh = p.Width, p.Height
	local bx = p.X
	local by = (p.Y ~= 0) and p.Y or (viewport.Y * 0.5 - bh * 0.5)
	local centerX = bx + bw / 2

	local plr = LocalPlayer
	local char = plr and plr.Character
	local hum = char and char:FindFirstChildOfClass("Humanoid")

	local health = p.FakeHealth
	local maxHealth = 100
	local name = plr and plr.DisplayName or "Preview"
	if hum and health < 0 then
		health = hum.Health
		maxHealth = hum.MaxHealth
	elseif health < 0 then
		health = 100
	end
	local pct = maxHealth > 0 and (health / maxHealth) or 1

	local accent = sk.Rainbow and rainbow or sk.Box.Color
	if sk.LowHealthPulse.Enabled and pct <= sk.LowHealthPulse.Threshold then
		accent = accent:Lerp(sk.LowHealthPulse.Color, 0.5 + 0.5 * mathsin(clock * sk.LowHealthPulse.Speed))
	end

	if sk.Glow.Enabled then
		self:VisualsGlow(id, bx, by, bw, bh, sk.Glow, sk.Rainbow and rainbow or sk.Glow.Color, clock)
	end
	if sk.Box.Enabled then
		self:VisualsBox(id, bx, by, bw, bh, sk.Box, sk.Rainbow and rainbow or accent)
	end
	if sk.HealthBar.Enabled then
		self:VisualsHealthBar(id, bx, by, bw, bh, pct, sk.HealthBar)
	end
	if sk.ArmorBar.Enabled then
		self:VisualsArmorBar(id, bx, by, bw, bh, 0.7, sk.ArmorBar)
	end

	local topY = by - 4
	if sk.Name.Enabled then
		topY = topY - sk.Name.Size
		if sk.Name.Shadow then
			self:DrawText(id .. "_nmsh", name, Vector2new(centerX + 1, topY + 1), sk.Name.Size, Color3new(0, 0, 0), true, sk.Name.Font, false)
		end
		self:DrawText(id .. "_nm", name, Vector2new(centerX, topY), sk.Name.Size, sk.Name.Color, true, sk.Name.Font, sk.Name.Outline)
	end

	local botY = by + bh + 3
	if sk.Weapon.Enabled then
		local wep = plr and self.GetTool(plr) or "None"
		if wep == "None" then wep = "Weapon" end
		self:DrawText(id .. "_wep", wep, Vector2new(centerX, botY), sk.Weapon.Size, sk.Weapon.Color, true, sk.Weapon.Font, sk.Weapon.Outline)
		botY = botY + sk.Weapon.Size
	end
	if sk.Distance.Enabled then
		self:DrawText(id .. "_dist", "0" .. sk.Distance.Suffix, Vector2new(centerX, botY), sk.Distance.Size, sk.Distance.Color, true, sk.Distance.Font, sk.Distance.Outline)
	end

	if sk.Flags.Enabled then
		local ctx = {
			player = plr, character = char, root = char and char:FindFirstChild("HumanoidRootPart"),
			humanoid = hum, distance = 0, visible = true, esp = self,
		}
		self:VisualsFlags(id, bx, by, bw, bh, ctx, sk.Flags)
	end

	local lbl = self:GetDrawing(id .. "_label", "Text")
	lbl.Visible = true
	lbl.Text = "PREVIEW"
	lbl.Position = Vector2new(centerX, by + bh + 3 + sk.Distance.Size + 4)
	lbl.Size = 11
	lbl.Center = true
	lbl.Color = Color3fromRGB(120, 120, 130)
	lbl.Outline = true
	lbl.OutlineColor = Color3new(0, 0, 0)
end

function EasyESP:RenderVisualsPlayer(id, plr, char, root, hum, head, boxPos, boxSize, dist, visible, rainbow)
	local sk = self.Settings.Visuals
	local clock = self.State.Clock
	local bx, by = boxPos.X, boxPos.Y
	local bw, bh = boxSize.X, boxSize.Y
	local centerX = bx + bw / 2

	local accent = sk.Rainbow and rainbow or sk.Box.Color
	if sk.LowHealthPulse.Enabled and hum.MaxHealth > 0 then
		local pct = hum.Health / hum.MaxHealth
		if pct <= sk.LowHealthPulse.Threshold then
			local p = 0.5 + 0.5 * mathsin(clock * sk.LowHealthPulse.Speed)
			accent = accent:Lerp(sk.LowHealthPulse.Color, p)
		end
	end

	local hm = self.State.HitMarkers[id]
	local hitFlash = 0
	if hm and (clock - hm.t) < sk.HitMarker.Duration then
		hitFlash = 1 - (clock - hm.t) / sk.HitMarker.Duration
	end
	if sk.HitMarker.Enabled and hitFlash > 0 then
		accent = accent:Lerp(sk.HitMarker.FlashColor, hitFlash)
	end

	if sk.Glow.Enabled then
		self:VisualsGlow(id, bx, by, bw, bh, sk.Glow, sk.Rainbow and rainbow or sk.Glow.Color, clock)
	end

	if sk.Backtrack.Enabled then
		self:RenderBacktrack(id, plr)
	end

	if sk.Box.Enabled then
		local boxColor = sk.Rainbow and rainbow or accent
		self:VisualsBox(id, bx, by, bw, bh, sk.Box, boxColor)
	end

	if sk.HealthBar.Enabled and hum.MaxHealth > 0 then
		self:VisualsHealthBar(id, bx, by, bw, bh, hum.Health / hum.MaxHealth, sk.HealthBar)
	end

	if sk.ArmorBar.Enabled then
		local armor = plr:GetAttribute(sk.ArmorBar.Attribute)
		local maxArmor = plr:GetAttribute(sk.ArmorBar.MaxAttribute) or 100
		if armor then
			self:VisualsArmorBar(id, bx, by, bw, bh, armor / maxArmor, sk.ArmorBar)
		end
	end

	local topY = by - 4
	if sk.Name.Enabled then
		local nm = sk.Name.ShowUser and ("@" .. plr.Name) or plr.DisplayName
		topY = topY - sk.Name.Size
		if sk.Name.Shadow then
			self:DrawText(id .. "_nmsh", nm, Vector2new(centerX + 1, topY + 1), sk.Name.Size, Color3new(0, 0, 0), true, sk.Name.Font, false)
		end
		self:DrawText(id .. "_nm", nm, Vector2new(centerX, topY), sk.Name.Size, sk.Name.Color, true, sk.Name.Font, sk.Name.Outline)
	end

	local botY = by + bh + 3
	if sk.Weapon.Enabled then
		local wep = self.GetTool(plr)
		if wep and wep ~= "None" then
			local text = wep
			if sk.Weapon.ShowAmmo then
				local ammo = plr:GetAttribute(sk.Weapon.AmmoAttribute)
				if ammo then text = text .. " [" .. tostring(ammo) .. "]" end
			end
			self:DrawText(id .. "_wep", text, Vector2new(centerX, botY), sk.Weapon.Size, sk.Weapon.Color, true, sk.Weapon.Font, sk.Weapon.Outline)
			botY = botY + sk.Weapon.Size
		end
	end

	if sk.Distance.Enabled then
		self:DrawText(id .. "_dist", mathfloor(dist) .. sk.Distance.Suffix, Vector2new(centerX, botY), sk.Distance.Size, sk.Distance.Color, true, sk.Distance.Font, sk.Distance.Outline)
		botY = botY + sk.Distance.Size
	end

	if sk.Flags.Enabled then
		local ctx = {
			player = plr, character = char, root = root, humanoid = hum,
			head = head, distance = dist, visible = visible, esp = self,
		}
		self:VisualsFlags(id, bx, by, bw, bh, ctx, sk.Flags)
	end

	if sk.HitMarker.Enabled and sk.HitMarker.Damage and hitFlash > 0 and hm.dmg and hm.dmg > 0 then
		local dtext = self:DrawText(id .. "_dmg", "-" .. hm.dmg, Vector2new(centerX + 20, by + bh * 0.3 - (1 - hitFlash) * 15), 13, sk.HitMarker.DamageColor, true, 2, true)
	else
		local d = self.State.Drawings[id .. "_dmg"]
		if d then d.Visible = false end
	end

	local footPos = root.Position - Vector3new(0, (hum.HipHeight or 2) + 2.5, 0)
	if sk.Rings.Enabled then
		self:RenderRings(id, footPos, clock)
	end
	if sk.Sphere.Enabled then
		self:RenderSphere(id, root.Position, clock)
	end
	self:RenderEffects(id, footPos, root.Position, clock)
end

function EasyESP:Start()
	if self.State.Active then return end
	self.State.Active = true

	tableinsert(self.State.Connections, Players.PlayerRemoving:Connect(function(plr)
		local id = tostring(plr.UserId)
		self.State.HitMarkers[id] = nil
		self.State.Backtrack[id]  = nil
		self.State.LastHealth[id] = nil
		self:RemoveCham(id)
	end))

	tableinsert(self.State.Connections, RunService.RenderStepped:Connect(function(dt)

		if not self.Settings.Master then
			self:HideAll()
			for _, hl in pairs(self.State.Highlights) do
				hl.Enabled = false
			end
			for id in pairs(self.State.MaterialChams) do
				self:RestoreMaterialCham(id)
			end
			if self.State.WorldApplied then
				self:RestoreWorld()
			end
			return
		end

		self.State.RainbowVal = (self.State.RainbowVal + dt * self.Settings.ESP.RainbowSpeed * 0.1) % 1
		self.State.Clock = self.State.Clock + dt
		local rainbow = Color3fromHSV(self.State.RainbowVal, 1, 1)

		local skRainbow = Color3fromHSV((self.State.Clock * self.Settings.Visuals.RainbowSpeed * 0.1) % 1, 1, 1)

		if os.clock() - self.State.LastUpdate < self.Settings.RefreshRate then
			return
		end
		self.State.LastUpdate = os.clock()

		self:BeginFrame()
		self:UpdateWorld()
		self:RenderRangeRings(dt)
		self:RecordLocalTrail()
		self:RenderLocalTrail()
		self:RenderFovCircle()
		self:RenderCrosshair()
		if self.Settings.Visuals.Enabled and self.Settings.Visuals.Preview.Enabled then
			pcall(function() self:RenderPreview(skRainbow) end)
		end

		for _, plr in ipairs(Players:GetPlayers()) do
			if plr == LocalPlayer then continue end

			local id = tostring(plr.UserId)

			local espTeam  = self.Settings.ESP.TeamCheck and self:IsTeamMate(plr)
			local chamTeam = self.Settings.Chams.TeamCheck and self:IsTeamMate(plr)

			local char = plr.Character
			local root = char and char:FindFirstChild("HumanoidRootPart")
			local hum  = char and char:FindFirstChildOfClass("Humanoid")
			local head = char and char:FindFirstChild("Head")

			if not char or not root or not hum or hum.Health <= 0 then
				local hl = self.State.Highlights[id]
				if hl then hl.Enabled = false end
				if self.State.MaterialChams[id] then self:RestoreMaterialCham(id) end
				continue
			end

			local s = self.Settings.ESP
			local sk = self.Settings.Visuals

			if sk.Enabled and sk.HitMarker.Enabled then
				self:UpdateHitTracking(plr, hum)
			end
			if sk.Enabled and sk.Backtrack.Enabled then
				self:RecordBacktrack(plr, char)
			end

			local skTeam = sk.Enabled and sk.TeamCheck and self:IsTeamMate(plr)

			local visible
			local needVisibility = s.VisibleCheck or s.VisibleColor
				or (sk.Enabled and sk.VisibleCheck)
				or (self.Settings.Chams.Enabled and self.Settings.Chams.UseVisibleColor)
			if needVisibility then
				visible = self:IsVisible(root, char)
			end

			if chamTeam then
				local hl = self.State.Highlights[id]
				if hl then hl.Enabled = false end
				if self.State.MaterialChams[id] then self:RestoreMaterialCham(id) end
			else
				self:UpdateChams(plr, char, visible)
			end

			if espTeam then continue end

			local screenPos, depth, onScreen = self:W2S(root.Position)
			local dist = (Camera.CFrame.Position - root.Position).Magnitude
			if dist > self.Settings.MaxDist then continue end

			local color     = s.Rainbow and rainbow or s.BoxColor
			local textColor = s.Rainbow and rainbow or s.TextColor

			if s.VisibleCheck and not visible then continue end

			if s.VisibleColor then
				local vc = visible and s.VisibleColorOn or s.VisibleColorOff
				color     = vc
				textColor = vc
			end

			if onScreen and depth > 0 then
				local boxPos, boxSize, boxValid = self:GetBoundingBox(char)
				if not boxValid then continue end

				local bx, by = boxPos.X, boxPos.Y
				local bw, bh = boxSize.X, boxSize.Y
				if bw < 4 then bw = 4 end
				if bh < 6 then bh = 6 end
				local centerX = bx + bw / 2

				if s.Enabled then
					local style = s.BoxStyle

					if style == "3D" then
						self:Render3DBox(id, char, color, false)
					elseif style == "3DCorner" then
						self:Render3DBox(id, char, color, true)
					elseif style == "2D" then
						if s.BoxOutline then
							self:DrawSquare(id .. "_bo", Vector2new(bx - 1, by - 1), Vector2new(bw + 2, bh + 2), Color3new(0, 0, 0), false, s.BoxThickness + 2, 1)
						end
						self:DrawSquare(id .. "_b", Vector2new(bx, by), Vector2new(bw, bh), color, false, s.BoxThickness, 1)
						if s.BoxFill then
							self:DrawSquare(id .. "_bf", Vector2new(bx, by), Vector2new(bw, bh), color, true, 1, s.BoxFillAlpha)
						end
					elseif style == "Corner" then
						local cornerLen = mathmin(bw, bh) * 0.25
						if s.BoxOutline then
							local co = {
								{Vector2new(bx - 1, by - 1), Vector2new(bx + cornerLen + 1, by - 1)},
								{Vector2new(bx - 1, by - 1), Vector2new(bx - 1, by + cornerLen + 1)},
								{Vector2new(bx + bw + 1, by - 1), Vector2new(bx + bw - cornerLen - 1, by - 1)},
								{Vector2new(bx + bw + 1, by - 1), Vector2new(bx + bw + 1, by + cornerLen + 1)},
								{Vector2new(bx - 1, by + bh + 1), Vector2new(bx + cornerLen + 1, by + bh + 1)},
								{Vector2new(bx - 1, by + bh + 1), Vector2new(bx - 1, by + bh - cornerLen - 1)},
								{Vector2new(bx + bw + 1, by + bh + 1), Vector2new(bx + bw - cornerLen - 1, by + bh + 1)},
								{Vector2new(bx + bw + 1, by + bh + 1), Vector2new(bx + bw + 1, by + bh - cornerLen - 1)},
							}
							for ci, cp in ipairs(co) do
								self:DrawLine(id .. "_co_" .. ci, cp[1], cp[2], Color3new(0, 0, 0), s.BoxThickness + 2, 1)
							end
						end
						local ci_ = {
							{Vector2new(bx, by), Vector2new(bx + cornerLen, by)},
							{Vector2new(bx, by), Vector2new(bx, by + cornerLen)},
							{Vector2new(bx + bw, by), Vector2new(bx + bw - cornerLen, by)},
							{Vector2new(bx + bw, by), Vector2new(bx + bw, by + cornerLen)},
							{Vector2new(bx, by + bh), Vector2new(bx + cornerLen, by + bh)},
							{Vector2new(bx, by + bh), Vector2new(bx, by + bh - cornerLen)},
							{Vector2new(bx + bw, by + bh), Vector2new(bx + bw - cornerLen, by + bh)},
							{Vector2new(bx + bw, by + bh), Vector2new(bx + bw, by + bh - cornerLen)},
						}
						for ci, cp in ipairs(ci_) do
							self:DrawLine(id .. "_c_" .. ci, cp[1], cp[2], color, s.BoxThickness, 1)
						end
						if s.BoxFill then
							self:DrawSquare(id .. "_bf", Vector2new(bx, by), Vector2new(bw, bh), color, true, 1, s.BoxFillAlpha)
						end
					end

					if s.Skeletons then
						self:RenderSkeleton(id, char, s.Rainbow and rainbow or s.SkeletonColor)
					end

					if s.HeadDot and head then
						local hPos, hDepth, hOn = self:W2S(head.Position)
						if hOn and hDepth > 0 then
							local dotRadius = mathclamp(s.HeadDotSize, 1, 15)
							self:DrawCircle(id .. "_hdot", hPos, dotRadius, color, true, 1, 1)
						end
					end

					if s.LookLines and head then
						local headScreen, headDepth, headOn = self:W2S(head.Position)
						local lookEnd = head.Position + head.CFrame.LookVector * s.LookLen
						local lookScreen, lookDepth, lookOn = self:W2S(lookEnd)
						if headOn and lookOn and headDepth > 0 and lookDepth > 0 then
							self:DrawLine(id .. "_look", headScreen, lookScreen, color, 1, 1)
						end
					end

					if s.Tracers then
						self:RenderTracer(id, Vector2new(centerX, by + bh), s.Rainbow and rainbow or s.TracerColor)
					end

					if s.HealthBar then
						local pct = mathclamp(hum.Health / hum.MaxHealth, 0, 1)
						local barColor = s.HealthBarGradient and Color3fromHSV(pct * 0.3, 1, 1) or Color3new(0, 1, 0)
						self:DrawBar(id, bx, by, bh, pct, barColor, 0, s.BarThickness, s.BarOutline)
					end

					local topY = by - 4
					local fontSize = mathclamp(s.TextSize, 10, 24)

					if s.Names or s.Usernames then
						local str = ""
						if s.Names then str = plr.DisplayName end
						if s.Usernames then
							if str ~= "" then
								str = str .. " (@" .. plr.Name .. ")"
							else
								str = "@" .. plr.Name
							end
						end
						topY = topY - fontSize
						self:DrawText(id .. "_n", str, Vector2new(centerX, topY), fontSize, textColor, true, s.TextFont, s.TextOutline)
					end

					local botY = by + bh + 3
					if s.Distance then
						self:DrawText(id .. "_d", mathfloor(dist) .. "m", Vector2new(centerX, botY), fontSize - 2, Color3fromRGB(200, 200, 200), true, s.TextFont, s.TextOutline)
						botY = botY + (fontSize - 1)
					end

					if s.Tool then
						local toolName = self.GetTool(plr)
						if toolName and toolName ~= "None" then
							self:DrawText(id .. "_t", toolName, Vector2new(centerX, botY), fontSize - 2, Color3fromRGB(180, 220, 255), true, s.TextFont, s.TextOutline)
							botY = botY + (fontSize - 1)
						end
					end

					for _, cb in pairs(self.State.PlayerCallbacks) do
						pcall(cb, self, plr, char, Vector2new(bx, by), Vector2new(bw, bh), dist)
					end
				end

				if sk.Enabled and not skTeam and not (sk.VisibleCheck and visible == false) then
					pcall(function()
						self:RenderVisualsPlayer(id, plr, char, root, hum, head,
							Vector2new(bx, by), Vector2new(bw, bh), dist, visible, skRainbow)
					end)
				end

			elseif s.Arrows and s.Enabled then
				local viewport = Camera.ViewportSize
				local center = Vector2new(viewport.X / 2, viewport.Y / 2)

				local sx, sy = screenPos.X, screenPos.Y
				if depth < 0 then
					sx = viewport.X - sx
					sy = viewport.Y - sy
				end

				local dir = (Vector2new(sx, sy) - center)
				local len = dir.Magnitude
				if len > 0 then dir = dir / len end

				local arrowPos = center + dir * s.ArrowRadius
				local rot = mathatan2(dir.Y, dir.X)
				local tip   = arrowPos
				local left  = arrowPos - Vector2new(mathcos(rot + 0.5), mathsin(rot + 0.5)) * s.ArrowSize
				local right = arrowPos - Vector2new(mathcos(rot - 0.5), mathsin(rot - 0.5)) * s.ArrowSize

				self:DrawLine(id .. "_a1", tip, left, color, 2, 1)
				self:DrawLine(id .. "_a2", tip, right, color, 2, 1)
				self:DrawLine(id .. "_a3", left, right, color, 2, 1)
			end
		end

		for objId, objData in pairs(self.State.Objects) do
			if objData.Instance and objData.Instance.Parent and objData.Callback then
				pcall(objData.Callback, self, objId, objData.Instance)
			end
		end

		self:EndFrame()
	end))
end

function EasyESP:Destroy()
	self.State.Active = false

	for _, c in ipairs(self.State.Connections) do
		pcall(function() c:Disconnect() end)
	end
	for _, v in pairs(self.State.Drawings) do
		pcall(function() v:Remove() end)
	end
	for _, hl in pairs(self.State.Highlights) do
		pcall(function() hl:Destroy() end)
	end
	for id in pairs(self.State.MaterialChams) do
		pcall(function() self:RestoreMaterialCham(id) end)
	end

	self:RestoreWorld()

	self.State.Drawings        = {}
	self.State.Connections     = {}
	self.State.Highlights      = {}
	self.State.MaterialChams   = {}
	self.State.Objects         = {}
	self.State.PlayerCallbacks = {}
	self.State.HitMarkers      = {}
	self.State.Backtrack       = {}
	self.State.LastHealth      = {}
	self.State.RangeRings      = {}
	self.State.LocalTrail      = {}
	self.State.Seen            = {}
	self.State.PrevSeen        = {}
end

return EasyESP





