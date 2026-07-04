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
		Enabled      = false,
		Mode         = "Highlight",
		FillColor    = Color3fromRGB(255, 255, 255),
		FillAlpha    = 0.5,
		OutlineColor = Color3fromRGB(255, 255, 255),
		OutlineAlpha = 0,
		OnTop        = true,
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
		Objects         = {},
		PlayerCallbacks = {},
		LastUpdate      = 0,
		RainbowVal      = 0,
		WorldApplied    = false,
		WorldOriginal   = nil,
	}

	self.RaycastParams = RaycastParams.new()
	self.RaycastParams.FilterType = Enum.RaycastFilterType.Exclude

	self.GetTool = function(plr)
		local char = plr.Character
		local tool = char and char:FindFirstChildOfClass("Tool")
		return tool and tool.Name or "None"
	end

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

function EasyESP:UpdateChams(plr, char)
	local c  = self.Settings.Chams
	local id = tostring(plr.UserId)

	if not c.Enabled or not char then
		local existing = self.State.Highlights[id]
		if existing then
			existing:Destroy()
			self.State.Highlights[id] = nil
		end
		return
	end

	local hl = self.State.Highlights[id]
	if not hl or hl.Parent ~= char then
		if hl then hl:Destroy() end
		hl = Instance.new("Highlight")
		hl.Name   = "EasyESP_Cham"
		hl.Parent = char
		self.State.Highlights[id] = hl
	end

	hl.Enabled           = true
	hl.FillColor         = c.FillColor
	hl.FillTransparency  = c.FillAlpha
	hl.OutlineColor      = c.OutlineColor
	hl.OutlineTransparency = c.OutlineAlpha
	hl.DepthMode = c.OnTop and Enum.HighlightDepthMode.AlwaysOnTop or Enum.HighlightDepthMode.Occluded
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

function EasyESP:Start()
	if self.State.Active then return end
	self.State.Active = true

	tableinsert(self.State.Connections, RunService.RenderStepped:Connect(function(dt)

		if not self.Settings.Master then
			self:HideAll()
			for _, hl in pairs(self.State.Highlights) do
				hl.Enabled = false
			end
			if self.State.WorldApplied then
				self:RestoreWorld()
			end
			return
		end

		self.State.RainbowVal = (self.State.RainbowVal + dt * self.Settings.ESP.RainbowSpeed * 0.1) % 1
		local rainbow = Color3fromHSV(self.State.RainbowVal, 1, 1)

		if os.clock() - self.State.LastUpdate < self.Settings.RefreshRate then
			return
		end
		self.State.LastUpdate = os.clock()

		self:HideAll()
		self:UpdateWorld()

		for _, plr in ipairs(Players:GetPlayers()) do
			if plr == LocalPlayer then continue end

			local id = tostring(plr.UserId)

			if self:IsTeamMate(plr) then
				local hl = self.State.Highlights[id]
				if hl then hl.Enabled = false end
				continue
			end

			local char = plr.Character
			if not char then continue end

			local root = char:FindFirstChild("HumanoidRootPart")
			local hum  = char:FindFirstChildOfClass("Humanoid")
			local head = char:FindFirstChild("Head")

			if not root or not hum or hum.Health <= 0 then
				local hl = self.State.Highlights[id]
				if hl then hl.Enabled = false end
				continue
			end

			self:UpdateChams(plr, char)

			local screenPos, depth, onScreen = self:W2S(root.Position)
			local dist = (Camera.CFrame.Position - root.Position).Magnitude
			if dist > self.Settings.MaxDist then continue end

			local s = self.Settings.ESP
			local color     = s.Rainbow and rainbow or s.BoxColor
			local textColor = s.Rainbow and rainbow or s.TextColor

			if s.VisibleCheck and not self:IsVisible(root, char) then
				color     = Color3fromRGB(255, 50, 50)
				textColor = Color3fromRGB(255, 80, 80)
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

	self:RestoreWorld()

	self.State.Drawings        = {}
	self.State.Connections     = {}
	self.State.Highlights      = {}
	self.State.Objects         = {}
	self.State.PlayerCallbacks = {}
end

return EasyESP
