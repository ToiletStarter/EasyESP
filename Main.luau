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

	Advanced = {
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
				Enabled = false,
				Count   = 3,
				Radius  = 5,
				Speed   = 2,
				Size    = 4,
				Color   = Color3fromRGB(200, 60, 220),
				Vertical= 3,
			},
		},

		TeamCheck    = false,
		VisibleCheck = false,
		Rainbow      = false,
		RainbowSpeed = 1,
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

function EasyESP.new()
	local self = setmetatable({}, EasyESP)

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
	if existing then return existing end
	local obj = Drawing.new(drawType)
	self.State.Drawings[id] = obj
	return obj
end

function EasyESP:HideAll()
	for _, v in pairs(self.State.Drawings) do
		v.Visible = false
	end
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
end

function EasyESP:CircleWorldPoints(center, radius, segments, spin, tiltNormalUp)
	local pts = {}
	local twoPi = 6.2831853071796
	for i = 0, segments - 1 do
		local a = (i / segments) * twoPi + (spin or 0)
		pts[#pts + 1] = center + Vector3new(mathcos(a) * radius, 0, mathsin(a) * radius)
	end
	return pts
end

function EasyESP:DrawWorldRing(id, center, radius, segments, color, thickness, alpha, spin, depthTest, dashed, filled, fillAlpha)
	local pts = self:CircleWorldPoints(center, radius, segments, spin)
	local screen = {}
	for i = 1, segments do
		local sp, depth = self:W2S(pts[i])
		screen[i] = { sp = sp, depth = depth }
	end

	for i = 1, segments do
		local a = screen[i]
		local b = screen[(i % segments) + 1]
		local line = self:GetDrawing(id .. "_r_" .. i, "Line")
		if a.depth > 0 and b.depth > 0 and (not dashed or (i % 2 == 0)) then
			line.Visible   = true
			line.From      = a.sp
			line.To        = b.sp
			line.Color     = color
			line.Thickness = thickness
			line.Transparency = alpha
		else
			line.Visible = false
		end
	end

	if filled then
		local cs, cd = self:W2S(center)
		for i = 1, segments do
			local a = screen[i]
			local b = screen[(i % segments) + 1]
			local tri = self:GetDrawing(id .. "_rf_" .. i, "Triangle")
			if cd > 0 and a.depth > 0 and b.depth > 0 then
				tri.Visible = true
				tri.PointA  = cs
				tri.PointB  = a.sp
				tri.PointC  = b.sp
				tri.Color   = color
				tri.Filled  = true
				tri.Transparency = fillAlpha or 0.08
			else
				tri.Visible = false
			end
		end
	end
end

function EasyESP:DrawWorldSphere(id, center, radius, ringCount, segments, color, thickness, alpha, spin, depthTest)
	local twoPi = 6.2831853071796
	local lineIdx = 0
	for r = 1, ringCount do
		local frac = r / (ringCount + 1)
		local y = (frac - 0.5) * 2 * radius
		local rr = math.sqrt(math.max(radius * radius - y * y, 0))
		local prev
		for i = 0, segments do
			local a = (i / segments) * twoPi + spin
			local wp = center + Vector3new(mathcos(a) * rr, y, mathsin(a) * rr)
			local sp, depth = self:W2S(wp)
			if prev and prev.depth > 0 and depth > 0 then
				lineIdx = lineIdx + 1
				local line = self:GetDrawing(id .. "_sp_" .. lineIdx, "Line")
				line.Visible = true
				line.From = prev.sp
				line.To = sp
				line.Color = color
				line.Thickness = thickness
				line.Transparency = alpha
			end
			prev = { sp = sp, depth = depth }
		end
	end
	local meridians = math.max(4, math.floor(segments / 4))
	for m = 0, meridians - 1 do
		local ang = (m / meridians) * math.pi + spin
		local prev
		for i = 0, segments do
			local t = (i / segments) * twoPi
			local wp = center + Vector3new(mathcos(t) * radius * mathcos(ang), mathsin(t) * radius, mathcos(t) * radius * mathsin(ang))
			local sp, depth = self:W2S(wp)
			if prev and prev.depth > 0 and depth > 0 then
				lineIdx = lineIdx + 1
				local line = self:GetDrawing(id .. "_sp_" .. lineIdx, "Line")
				line.Visible = true
				line.From = prev.sp
				line.To = sp
				line.Color = color
				line.Thickness = thickness
				line.Transparency = alpha
			end
			prev = { sp = sp, depth = depth }
		end
	end
end

function EasyESP:AdvancedBox(id, bx, by, bw, bh, cfg, color)
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

function EasyESP:AdvancedGlow(id, bx, by, bw, bh, cfg, color, clock)
	local layers = cfg.Layers
	local pulse = cfg.Pulse and (0.5 + 0.5 * mathsin(clock * cfg.PulseSpeed)) or 1
	for i = 1, layers do
		local g = i * cfg.Spread
		local alpha = cfg.Alpha * pulse * (1 - (i - 1) / layers)
		self:DrawSquare(id .. "_glow_" .. i, Vector2new(bx - g, by - g), Vector2new(bw + g * 2, bh + g * 2), color, false, 1, alpha)
	end
end

function EasyESP:AdvancedHealthBar(id, bx, by, bw, bh, pct, cfg)
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

function EasyESP:AdvancedArmorBar(id, bx, by, bw, bh, pct, cfg)
	local th = cfg.Thickness
	pct = mathclamp(pct, 0, 1)
	local yPos = by + bh + 3
	if cfg.Outline then
		self:DrawSquare(id .. "_abo", Vector2new(bx - 1, yPos - 1), Vector2new(bw + 2, th + 2), Color3new(0, 0, 0), true, 1, 0.7)
	end
	self:DrawSquare(id .. "_abg", Vector2new(bx, yPos), Vector2new(bw, th), Color3new(0.1, 0.1, 0.12), true, 1, 0.6)
	self:DrawSquare(id .. "_abf", Vector2new(bx, yPos), Vector2new(bw * pct, th), cfg.Color, true, 1, 1)
end

function EasyESP:AdvancedFlags(id, bx, by, bw, bh, ctx, cfg)
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
	local cfg = self.Settings.Advanced.Backtrack
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
	local cfg = self.Settings.Advanced.Backtrack
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

function EasyESP:RenderRings(id, footPos, clock)
	local cfg = self.Settings.Advanced.Rings
	for i, ring in ipairs(cfg.List) do
		local spin = clock * (ring.Spin or 0)
		local alpha = ring.Alpha or 1
		if ring.Pulse then alpha = alpha * (0.5 + 0.5 * mathsin(clock * 3)) end
		local color = ring.Color
		if ring.Effect == "Rainbow" then
			color = Color3fromHSV((clock * 0.15 + i * 0.1) % 1, 1, 1)
		end
		self:DrawWorldRing(
			id .. "_ring_" .. i,
			footPos + Vector3new(0, cfg.Height, 0),
			ring.Radius, cfg.Segments, color, ring.Thickness, alpha, spin,
			cfg.DepthTest, ring.Style == "Dashed", ring.Filled, ring.FillAlpha
		)
	end
end

function EasyESP:RenderSphere(id, center, clock)
	local cfg = self.Settings.Advanced.Sphere
	local color = cfg.Color
	if cfg.Effect == "Rainbow" then color = Color3fromHSV((clock * 0.15) % 1, 1, 1) end
	self:DrawWorldSphere(id, center, cfg.Radius, cfg.Rings, cfg.Segments, color, cfg.Thickness, cfg.Alpha, clock * cfg.Spin, cfg.DepthTest)
end

function EasyESP:RenderEffects(id, footPos, centerPos, clock)
	local e = self.Settings.Advanced.Effects
	local twoPi = 6.2831853071796

	if e.Confetti.Enabled then
		local c = e.Confetti
		for i = 1, c.Count do
			local seed = i * 12.9898
			local ang = (seed % twoPi)
			local rad = c.Radius * ((seed * 1.37) % 1)
			local phase = (clock * c.Speed + i * 0.61) % 1
			local y = c.Height * (1 - phase)
			local wp = footPos + Vector3new(mathcos(ang + clock) * rad, y, mathsin(ang + clock) * rad)
			local sp, depth = self:W2S(wp)
			local dot = self:GetDrawing(id .. "_cf_" .. i, "Circle")
			if depth > 0 then
				dot.Visible = true
				dot.Position = sp
				dot.Radius = c.Size
				dot.Filled = true
				dot.Transparency = 1
				dot.Color = c.Rainbow and Color3fromHSV((i / c.Count + clock * 0.2) % 1, 1, 1) or Color3fromRGB(255, 100, 200)
			else
				dot.Visible = false
			end
		end
	end

	if e.Rain.Enabled then
		local r = e.Rain
		for i = 1, r.Count do
			local seed = i * 7.31
			local ang = (seed % twoPi)
			local rad = r.Radius * ((seed * 2.11) % 1)
			local phase = (clock * r.Speed + i * 0.37) % r.Height
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
				line.Color = r.Color
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
			local prog = ((clock * sy.Speed * 0.1) + (ri / sy.Rings))
			local frac = prog % 1
			local radius = sy.Radius * frac
			local y = sy.Rise and (sy.Radius * frac * 0.4) or sy.Height
			local hue = (sy.Hue + frac * sy.HueRange) % 1
			local color = Color3fromHSV(hue, 1, 1)
			local alpha = sy.Alpha * (1 - frac)
			self:DrawWorldRing(id .. "_synth_" .. ri, footPos + Vector3new(0, y, 0), mathmax(radius, 0.1), sy.Segments, color, sy.Thickness, alpha, 0, true, false, false, 0)
		end
	end

	if e.Orbit.Enabled then
		local o = e.Orbit
		for i = 1, o.Count do
			local ang = clock * o.Speed + (i / o.Count) * twoPi
			local wp = centerPos + Vector3new(mathcos(ang) * o.Radius, mathsin(clock * o.Speed * 1.3 + i) * o.Vertical, mathsin(ang) * o.Radius)
			local sp, depth = self:W2S(wp)
			local dot = self:GetDrawing(id .. "_orbit_" .. i, "Circle")
			if depth > 0 then
				dot.Visible = true
				dot.Position = sp
				dot.Radius = o.Size
				dot.Filled = true
				dot.Transparency = 1
				dot.Color = o.Color
			else
				dot.Visible = false
			end
		end
	end
end

function EasyESP:RenderAdvancedPlayer(id, plr, char, root, hum, head, boxPos, boxSize, dist, visible, rainbow)
	local sk = self.Settings.Advanced
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
		self:AdvancedGlow(id, bx, by, bw, bh, sk.Glow, sk.Rainbow and rainbow or sk.Glow.Color, clock)
	end

	if sk.Backtrack.Enabled then
		self:RenderBacktrack(id, plr)
	end

	if sk.Box.Enabled then
		local boxColor = sk.Rainbow and rainbow or accent
		self:AdvancedBox(id, bx, by, bw, bh, sk.Box, boxColor)
	end

	if sk.HealthBar.Enabled and hum.MaxHealth > 0 then
		self:AdvancedHealthBar(id, bx, by, bw, bh, hum.Health / hum.MaxHealth, sk.HealthBar)
	end

	if sk.ArmorBar.Enabled then
		local armor = plr:GetAttribute(sk.ArmorBar.Attribute)
		local maxArmor = plr:GetAttribute(sk.ArmorBar.MaxAttribute) or 100
		if armor then
			self:AdvancedArmorBar(id, bx, by, bw, bh, armor / maxArmor, sk.ArmorBar)
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
		self:AdvancedFlags(id, bx, by, bw, bh, ctx, sk.Flags)
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

		local skRainbow = Color3fromHSV((self.State.Clock * self.Settings.Advanced.RainbowSpeed * 0.1) % 1, 1, 1)

		if os.clock() - self.State.LastUpdate < self.Settings.RefreshRate then
			return
		end
		self.State.LastUpdate = os.clock()

		self:HideAll()
		self:UpdateWorld()

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
			local sk = self.Settings.Advanced

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
						self:RenderAdvancedPlayer(id, plr, char, root, hum, head,
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
end

return EasyESP
