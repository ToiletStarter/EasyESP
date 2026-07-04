local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer
local Camera = workspace.CurrentCamera

workspace:GetPropertyChangedSignal("CurrentCamera"):Connect(function()
    Camera = workspace.CurrentCamera
end)

local EasyESP = {}
EasyESP.__index = EasyESP

EasyESP.Version = "2.0.0"

EasyESP.Defaults = {
    Master = false,
    MaxDist = 3000,
    RefreshRate = 0,
    ESP = {
        Enabled = false,
        TeamCheck = false,
        VisibleCheck = false,
        Boxes = false,
        BoxStyle = "2D",
        BoxColor = Color3.fromRGB(255, 255, 255),
        BoxOutline = true,
        BoxFill = false,
        BoxFillAlpha = 0.2,
        BoxThickness = 1,
        Names = false,
        Usernames = false,
        Distance = false,
        Tool = false,
        TextSize = 13,
        TextColor = Color3.fromRGB(255, 255, 255),
        TextOutline = true,
        HealthBar = false,
        HealthBarGradient = true,
        BarThickness = 2,
        BarOutline = false,
        Skeletons = false,
        SkeletonColor = Color3.fromRGB(255, 255, 255),
        HeadDot = false,
        HeadDotSize = 3,
        LookLines = false,
        LookLen = 10,
        Tracers = false,
        TracerOrigin = "Bottom",
        TracerColor = Color3.fromRGB(255, 255, 255),
        Arrows = false,
        ArrowRadius = 200,
        ArrowSize = 15,
        Rainbow = false,
        RainbowSpeed = 1,
    },
    World = {
        Enabled = false,
        Fullbright = false,
        FOV = 70,
        NoFog = false,
        Brightness = 1,
        Ambient = Color3.fromRGB(127, 127, 127),
        OutdoorAmbient = Color3.fromRGB(127, 127, 127),
        Exposure = 0,
        ColorCorrection = false,
        Saturation = 0,
        Contrast = 0,
    }
}

local BONES = {
    R15 = {
        {"Head", "UpperTorso"}, {"UpperTorso", "LowerTorso"},
        {"UpperTorso", "LeftUpperArm"}, {"LeftUpperArm", "LeftLowerArm"}, {"LeftLowerArm", "LeftHand"},
        {"UpperTorso", "RightUpperArm"}, {"RightUpperArm", "RightLowerArm"}, {"RightLowerArm", "RightHand"},
        {"LowerTorso", "LeftUpperLeg"}, {"LeftUpperLeg", "LeftLowerLeg"}, {"LeftLowerLeg", "LeftFoot"},
        {"LowerTorso", "RightUpperLeg"}, {"RightUpperLeg", "RightLowerLeg"}, {"RightLowerLeg", "RightFoot"}
    },
    R6 = {
        {"Head", "Torso"}, {"Torso", "Left Arm"}, {"Torso", "Right Arm"},
        {"Torso", "Left Leg"}, {"Torso", "Right Leg"}
    }
}

local BOX_OFFSETS = {
    Vector3.new(-1, 1, -1), Vector3.new(1, 1, -1), Vector3.new(1, 1, 1), Vector3.new(-1, 1, 1),
    Vector3.new(-1, -1, -1), Vector3.new(1, -1, -1), Vector3.new(1, -1, 1), Vector3.new(-1, -1, 1)
}

local BOX_EDGES = {
    {1, 2}, {2, 3}, {3, 4}, {4, 1},
    {5, 6}, {6, 7}, {7, 8}, {8, 5},
    {1, 5}, {2, 6}, {3, 7}, {4, 8}
}

function EasyESP.new()
    local self = setmetatable({}, EasyESP)
    self.Settings = self:DeepCopy(EasyESP.Defaults)
    self.State = {
        Active = false,
        Drawings = {},
        Connections = {},
        LastUpdate = 0,
        RainbowVal = 0,
        CustomFeatures = {}
    }
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
        copy[k] = type(v) == "table" and self:DeepCopy(v) or v
    end
    return copy
end

function EasyESP:GetDrawing(id, drawType)
    if not self.State.Drawings[id] then
        self.State.Drawings[id] = Drawing.new(drawType)
    end
    return self.State.Drawings[id]
end

function EasyESP:HideAll()
    for _, v in pairs(self.State.Drawings) do
        v.Visible = false
    end
end

function EasyESP:W2S(pos)
    local screenPos = Camera:WorldToViewportPoint(pos)
    return Vector2.new(screenPos.X, screenPos.Y), screenPos.Z, screenPos.Z > 0
end

function EasyESP:IsVisible(part, model)
    local origin = Camera.CFrame.Position
    local dir = (part.Position - origin).Unit * 500
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, model, Camera}
    return not workspace:Raycast(origin, dir, params)
end

function EasyESP:GetBoundingBox(char)
    local cf, size = char:GetBoundingBox()
    local halfSize = size * 0.5
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge

    for _, offset in ipairs(BOX_OFFSETS) do
        local worldPos = (cf * CFrame.new(offset * halfSize)).Position
        local screenPos, depth = self:W2S(worldPos)
        if depth <= 0 then return nil end
        minX, minY = math.min(minX, screenPos.X), math.min(minY, screenPos.Y)
        maxX, maxY = math.max(maxX, screenPos.X), math.max(maxY, screenPos.Y)
    end

    return Vector2.new(minX, minY), Vector2.new(maxX - minX, maxY - minY), true
end

function EasyESP:Render3DBox(id, model, color, isCorner)
    local cf, size = model:GetBoundingBox()
    local halfSize = size * 0.5
    local corners = {}

    for i, offset in ipairs(BOX_OFFSETS) do
        local pos, z = self:W2S((cf * CFrame.new(offset * halfSize)).Position)
        if z <= 0 then return end
        corners[i] = pos
    end

    for i, edge in ipairs(BOX_EDGES) do
        local line = self:GetDrawing(id .. "_3d_" .. i, "Line")
        line.Visible = true
        line.From = corners[edge[1]]
        line.To = corners[edge[2]]
        line.Color = color
        line.Thickness = self.Settings.ESP.BoxThickness

        if isCorner then
            local dir = (line.To - line.From)
            local len = dir.Magnitude
            if len > 0 then
                local unit = dir / len
                line.To = line.From + unit * (len * 0.25)
                local line2 = self:GetDrawing(id .. "_3dc_" .. i, "Line")
                line2.Visible = true
                line2.From = corners[edge[2]]
                line2.To = corners[edge[2]] - unit * (len * 0.25)
                line2.Color = color
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
            local posA, zA = self:W2S(a.Position)
            local posB, zB = self:W2S(b.Position)
            if zA > 0 and zB > 0 then
                line.Visible = true
                line.From = posA
                line.To = posB
                line.Color = color
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
    local origin = Vector2.new(viewport.X / 2, viewport.Y)
    if s.TracerOrigin == "Center" then
        origin = Vector2.new(viewport.X / 2, viewport.Y / 2)
    elseif s.TracerOrigin == "Top" then
        origin = Vector2.new(viewport.X / 2, 0)
    elseif s.TracerOrigin == "Mouse" then
        origin = UserInputService:GetMouseLocation()
    end
    local line = self:GetDrawing(id .. "_tracer", "Line")
    line.Visible = true
    line.From = origin
    line.To = target
    line.Color = color
    line.Thickness = 1
end

function EasyESP:RenderBar(id, boxX, boxY, boxH, pct, color, offset)
    local s = self.Settings.ESP
    local barW = s.BarThickness
    local xPos = boxX - 6 - (offset * (barW + 3))
    pct = math.clamp(pct, 0, 1)

    if s.BarOutline then
        local out = self:GetDrawing(id .. "_baro_" .. offset, "Square")
        out.Visible = true
        out.Filled = true
        out.Color = Color3.new(0, 0, 0)
        out.Transparency = 0.6
        out.Position = Vector2.new(xPos - 1, boxY - 1)
        out.Size = Vector2.new(barW + 2, boxH + 2)
    end

    local bg = self:GetDrawing(id .. "_barbg_" .. offset, "Square")
    bg.Visible = true
    bg.Filled = true
    bg.Color = Color3.fromRGB(30, 30, 30)
    bg.Transparency = 0.3
    bg.Position = Vector2.new(xPos, boxY)
    bg.Size = Vector2.new(barW, boxH)

    local fillH = boxH * pct
    local main = self:GetDrawing(id .. "_bar_" .. offset, "Square")
    main.Visible = true
    main.Filled = true
    main.Color = color
    main.Position = Vector2.new(xPos, boxY + (boxH - fillH))
    main.Size = Vector2.new(barW, math.max(fillH, 1))
end

function EasyESP:UpdateWorld()
    local w = self.Settings.World
    if not w.Enabled then return end
    Lighting.Brightness = w.Fullbright and 3 or w.Brightness
    Lighting.Ambient = w.Ambient
    Lighting.OutdoorAmbient = w.OutdoorAmbient
    Lighting.ExposureCompensation = w.Exposure
    Camera.FieldOfView = w.FOV
    if w.NoFog then Lighting.FogEnd = 1e7 end
    local cc = Lighting:FindFirstChild("EasyESP_CC")
    if not cc then
        cc = Instance.new("ColorCorrectionEffect")
        cc.Name = "EasyESP_CC"
        cc.Parent = Lighting
    end
    cc.Enabled = w.ColorCorrection
    cc.Saturation = w.Saturation
    cc.Contrast = w.Contrast
end

function EasyESP:MakeText(id, text, pos, size, color, center)
    local t = self:GetDrawing(id, "Text")
    t.Visible = true
    t.Text = text
    t.Position = pos
    t.Size = size or self.Settings.ESP.TextSize
    t.Color = color or self.Settings.ESP.TextColor
    t.Center = center ~= false
    t.Outline = true
    t.OutlineColor = Color3.new(0, 0, 0)
    t.Font = 2
    return t
end

function EasyESP:AddCustomFeature(id, callback, priority)
    self.State.CustomFeatures[id] = {
        callback = callback,
        priority = priority or 0
    }
end

function EasyESP:RemoveCustomFeature(id)
    self.State.CustomFeatures[id] = nil
end

function EasyESP:ClearCustomFeatures()
    self.State.CustomFeatures = {}
end

function EasyESP:GetTool(plr)
    return self.GetTool(plr)
end

function EasyESP:Start()
    if self.State.Active then return end
    self.State.Active = true

    table.insert(self.State.Connections, RunService.RenderStepped:Connect(function(dt)
        if not self.Settings.Master then
            self:HideAll()
            return
        end

        self.State.RainbowVal = (self.State.RainbowVal + dt * self.Settings.ESP.RainbowSpeed * 0.1) % 1
        local rainbow = Color3.fromHSV(self.State.RainbowVal, 1, 1)

        if os.clock() - self.State.LastUpdate < self.Settings.RefreshRate then return end
        self.State.LastUpdate = os.clock()

        self:HideAll()
        self:UpdateWorld()

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LocalPlayer or not plr.Character then continue end
            local char = plr.Character
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            local head = char:FindFirstChild("Head")
            if not root or not hum or hum.Health <= 0 then continue end

            local screenPos, depth = self:W2S(root.Position)
            local dist = (Camera.CFrame.Position - root.Position).Magnitude
            if dist > self.Settings.MaxDist then continue end

            local id = tostring(plr.UserId)
            local s = self.Settings.ESP
            local color = s.Rainbow and rainbow or s.BoxColor
            local textColor = s.Rainbow and rainbow or s.TextColor

            if s.VisibleCheck and not self:IsVisible(root, char) then
                color = Color3.fromRGB(255, 50, 50)
                textColor = Color3.fromRGB(255, 80, 80)
            end

            if depth > 0 then
                local boxPos, boxSize = self:GetBoundingBox(char)
                if not boxPos then continue end

                local bx, by = boxPos.X, boxPos.Y
                local bw, bh = math.max(boxSize.X, 4), math.max(boxSize.Y, 6)
                local centerX = bx + bw / 2

                if s.Enabled then
                    if s.Boxes then
                        local style = s.BoxStyle
                        if style == "3D" then
                            self:Render3DBox(id, char, color, false)
                        elseif style == "3DCorner" then
                            self:Render3DBox(id, char, color, true)
                        elseif style == "2D" then
                            if s.BoxOutline then
                                local outline = self:GetDrawing(id .. "_bo", "Square")
                                outline.Visible = true
                                outline.Position = Vector2.new(bx - 1, by - 1)
                                outline.Size = Vector2.new(bw + 2, bh + 2)
                                outline.Color = Color3.new(0, 0, 0)
                                outline.Thickness = s.BoxThickness + 2
                                outline.Filled = false
                            end
                            local box = self:GetDrawing(id .. "_b", "Square")
                            box.Visible = true
                            box.Position = Vector2.new(bx, by)
                            box.Size = Vector2.new(bw, bh)
                            box.Color = color
                            box.Thickness = s.BoxThickness
                            box.Filled = s.BoxFill
                            box.Transparency = s.BoxFill and s.BoxFillAlpha or 1
                        elseif style == "Corner" then
                            local cornerLen = math.min(bw, bh) * 0.2
                            local corners = {
                                {Vector2.new(bx, by), Vector2.new(bx + cornerLen, by), Vector2.new(bx, by), Vector2.new(bx, by + cornerLen)},
                                {Vector2.new(bx + bw, by), Vector2.new(bx + bw - cornerLen, by), Vector2.new(bx + bw, by), Vector2.new(bx + bw, by + cornerLen)},
                                {Vector2.new(bx, by + bh), Vector2.new(bx + cornerLen, by + bh), Vector2.new(bx, by + bh), Vector2.new(bx, by + bh - cornerLen)},
                                {Vector2.new(bx + bw, by + bh), Vector2.new(bx + bw - cornerLen, by + bh), Vector2.new(bx + bw, by + bh), Vector2.new(bx + bw, by + bh - cornerLen)}
                            }
                            for ci, c in ipairs(corners) do
                                if s.BoxOutline then
                                    local out1 = self:GetDrawing(id .. "_co_" .. ci .. "_1", "Line")
                                    local out2 = self:GetDrawing(id .. "_co_" .. ci .. "_2", "Line")
                                    out1.Visible, out1.From, out1.To, out1.Color, out1.Thickness = true, c[1] - Vector2.new(1,1), c[2] - Vector2.new(1,1), Color3.new(0,0,0), s.BoxThickness + 2
                                    out2.Visible, out2.From, out2.To, out2.Color, out2.Thickness = true, c[3] - Vector2.new(1,1), c[4] - Vector2.new(1,1), Color3.new(0,0,0), s.BoxThickness + 2
                                end
                                local l1 = self:GetDrawing(id .. "_c_" .. ci .. "_1", "Line")
                                local l2 = self:GetDrawing(id .. "_c_" .. ci .. "_2", "Line")
                                l1.Visible, l1.From, l1.To, l1.Color, l1.Thickness = true, c[1], c[2], color, s.BoxThickness
                                l2.Visible, l2.From, l2.To, l2.Color, l2.Thickness = true, c[3], c[4], color, s.BoxThickness
                            end
                            if s.BoxFill then
                                local fill = self:GetDrawing(id .. "_bf", "Square")
                                fill.Visible = true
                                fill.Position = Vector2.new(bx, by)
                                fill.Size = Vector2.new(bw, bh)
                                fill.Color = color
                                fill.Filled = true
                                fill.Transparency = s.BoxFillAlpha
                            end
                        end
                    end

                    if s.Skeletons then
                        self:RenderSkeleton(id, char, s.Rainbow and rainbow or s.SkeletonColor)
                    end

                    if s.HeadDot and head then
                        local hPos, hDepth = self:W2S(head.Position)
                        if hDepth > 0 then
                            local dot = self:GetDrawing(id .. "_hdot", "Circle")
                            dot.Visible = true
                            dot.Position = hPos
                            dot.Radius = s.HeadDotSize
                            dot.Color = color
                            dot.Filled = true
                            dot.Thickness = 0
                        end
                    end

                    if s.LookLines and head then
                        local headScreen, headDepth = self:W2S(head.Position)
                        local lookEnd = head.Position + head.CFrame.LookVector * s.LookLen
                        local lookScreen, lookDepth = self:W2S(lookEnd)
                        local line = self:GetDrawing(id .. "_look", "Line")
                        if headDepth > 0 and lookDepth > 0 then
                            line.Visible = true
                            line.From = headScreen
                            line.To = lookScreen
                            line.Color = color
                            line.Thickness = 1
                        else
                            line.Visible = false
                        end
                    end

                    if s.Tracers then
                        self:RenderTracer(id, Vector2.new(centerX, by + bh), color)
                    end

                    if s.HealthBar then
                        local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                        local barColor = s.HealthBarGradient and Color3.fromHSV(pct * 0.3, 1, 1) or Color3.new(0, 1, 0)
                        self:RenderBar(id, bx, by, bh, pct, barColor, 0)
                    end

                    local topY = by - 4
                    local fontSize = math.clamp(s.TextSize, 10, 24)

                    if s.Names or s.Usernames then
                        local str = ""
                        if s.Names then str = plr.DisplayName end
                        if s.Usernames then
                            str = str ~= "" and str .. " (@" .. plr.Name .. ")" or "@" .. plr.Name
                        end
                        self:MakeText(id .. "_n", str, Vector2.new(centerX, topY - fontSize), fontSize, textColor, true)
                    end

                    local botY = by + bh + 3

                    if s.Distance then
                        self:MakeText(id .. "_d", math.floor(dist) .. "m", Vector2.new(centerX, botY), fontSize - 2, Color3.fromRGB(200, 200, 200), true)
                        botY = botY + (fontSize - 1)
                    end

                    if s.Tool then
                        local toolName = self.GetTool(plr)
                        if toolName ~= "None" then
                            self:MakeText(id .. "_t", toolName, Vector2.new(centerX, botY), fontSize - 2, Color3.fromRGB(180, 220, 255), true)
                        end
                    end
                end

                for _, feature in pairs(self.State.CustomFeatures) do
                    feature.callback(self, plr, char, {
                        id = id,
                        boxPos = boxPos,
                        boxSize = Vector2.new(bw, bh),
                        screenPos = Vector2.new(screenPos.X, screenPos.Y),
                        depth = depth,
                        dist = dist,
                        color = color,
                        textColor = textColor,
                        root = root,
                        head = head,
                        hum = hum,
                        char = char
                    })
                end
            elseif s.Arrows and s.Enabled then
                local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local dir = (Vector2.new(screenPos.X, screenPos.Y) - center)
                local len = dir.Magnitude
                if len > 0 then dir = dir / len end
                local arrowPos = center + dir * s.ArrowRadius
                local rot = math.atan2(dir.Y, dir.X)
                local tip = arrowPos
                local left = arrowPos - Vector2.new(math.cos(rot + 0.5), math.sin(rot + 0.5)) * s.ArrowSize
                local right = arrowPos - Vector2.new(math.cos(rot - 0.5), math.sin(rot - 0.5)) * s.ArrowSize
                local a1, a2, a3 = self:GetDrawing(id .. "_a1", "Line"), self:GetDrawing(id .. "_a2", "Line"), self:GetDrawing(id .. "_a3", "Line")
                a1.Visible, a1.From, a1.To, a1.Color, a1.Thickness = true, tip, left, color, 2
                a2.Visible, a2.From, a2.To, a2.Color, a2.Thickness = true, tip, right, color, 2
                a3.Visible, a3.From, a3.To, a3.Color, a3.Thickness = true, left, right, color, 2
            end
        end
    end))
end

function EasyESP:Destroy()
    self.State.Active = false
    for _, c in ipairs(self.State.Connections) do c:Disconnect() end
    for _, v in pairs(self.State.Drawings) do v:Remove() end
    self.State.Drawings = {}
    self.State.Connections = {}
    self:ClearCustomFeatures()
    local cc = Lighting:FindFirstChild("EasyESP_CC")
    if cc then cc:Destroy() end
end

return EasyESP
