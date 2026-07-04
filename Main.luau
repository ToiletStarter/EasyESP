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
    Chams = {
        Enabled = false,
        Mode = "Highlight",
        FillColor = Color3.fromRGB(255, 255, 255),
        FillAlpha = 0.5,
        OutlineColor = Color3.fromRGB(255, 255, 255),
        OutlineAlpha = 0,
        OnTop = true,
    },
    World = {
        Enabled = false,
        Fullbright = false,
        FOV = 70,
        NoFog = false,
        Brightness = 1,
        Ambient = Color3.fromRGB(0, 0, 0),
        OutdoorAmbient = Color3.fromRGB(0, 0, 0),
        Exposure = 1,
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
        RainbowVal = 0
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
        if type(v) == "table" then copy[k] = self:DeepCopy(v) else copy[k] = v end
    end
    return copy
end

function EasyESP:GetDrawing(id, drawType)
    if self.State.Drawings[id] then return self.State.Drawings[id] end
    local obj = Drawing.new(drawType)
    self.State.Drawings[id] = obj
    return obj
end

function EasyESP:HideAll()
    for _, v in pairs(self.State.Drawings) do v.Visible = false end
end

function EasyESP:W2S(pos)
    local screenPos, onScreen = Camera:WorldToViewportPoint(pos)
    return Vector2.new(screenPos.X, screenPos.Y), screenPos.Z, onScreen
end

function EasyESP:IsVisible(part, model)
    local origin = Camera.CFrame.Position
    local dir = (part.Position - origin)
    local params = RaycastParams.new()
    params.FilterType = Enum.RaycastFilterType.Exclude
    params.FilterDescendantsInstances = {LocalPlayer.Character, model, Camera}
    local result = workspace:Raycast(origin, dir, params)
    return result == nil
end

-- Get a proper bounding box in screen space from the character model
function EasyESP:GetBoundingBox(char)
    local cf, size = char:GetBoundingBox()
    local halfSize = size * 0.5

    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local allOnScreen = true

    for _, offset in ipairs(BOX_OFFSETS) do
        local worldPos = (cf * CFrame.new(offset * halfSize)).Position
        local screenPos, depth, onScreen = self:W2S(worldPos)
        if depth <= 0 then
            allOnScreen = false
            break
        end
        if screenPos.X < minX then minX = screenPos.X end
        if screenPos.Y < minY then minY = screenPos.Y end
        if screenPos.X > maxX then maxX = screenPos.X end
        if screenPos.Y > maxY then maxY = screenPos.Y end
    end

    if not allOnScreen then return nil end

    local w = maxX - minX
    local h = maxY - minY

    return Vector2.new(minX, minY), Vector2.new(w, h), true
end

function EasyESP:Render3DBox(id, model, color, isCorner)
    local cf, size = model:GetBoundingBox()
    local halfSize = size * 0.5
    local corners = {}
    local allVisible = true

    for i, offset in ipairs(BOX_OFFSETS) do
        local wp = (cf * CFrame.new(offset * halfSize)).Position
        local pos, z, onScreen = self:W2S(wp)
        if z <= 0 then allVisible = false; break end
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
            local posA, zA, visA = self:W2S(a.Position)
            local posB, zB, visB = self:W2S(b.Position)
            if visA and visB and zA > 0 and zB > 0 then
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

function EasyESP:RenderHealthBar(id, boxX, boxY, boxH, pct, color)
    local s = self.Settings.ESP
    local barW = s.BarThickness
    local xPos = boxX - 5 - barW
    local barH = boxH

    pct = math.clamp(pct, 0, 1)

    if s.BarOutline then
        local out = self:GetDrawing(id .. "_baro", "Square")
        out.Visible = true
        out.Filled = true
        out.Color = Color3.new(0, 0, 0)
        out.Transparency = 0.6
        out.Position = Vector2.new(xPos - 1, boxY - 1)
        out.Size = Vector2.new(barW + 2, barH + 2)
    end

    -- Background
    local bg = self:GetDrawing(id .. "_barbg", "Square")
    bg.Visible = true
    bg.Filled = true
    bg.Color = Color3.new(0.15, 0.15, 0.15)
    bg.Transparency = 0.5
    bg.Position = Vector2.new(xPos, boxY)
    bg.Size = Vector2.new(barW, barH)

    -- Fill
    local fillH = barH * pct
    local main = self:GetDrawing(id .. "_bar", "Square")
    main.Visible = true
    main.Filled = true
    main.Color = color
    main.Transparency = 1
    main.Position = Vector2.new(xPos, boxY + (barH - fillH))
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

function EasyESP:MakeText(id, text, pos, size, color, center, font)
    local t = self:GetDrawing(id, "Text")
    t.Visible = true
    t.Text = text
    t.Position = pos
    t.Size = size or self.Settings.ESP.TextSize
    t.Color = color or self.Settings.ESP.TextColor
    t.Center = center ~= false
    t.Outline = true
    t.OutlineColor = Color3.new(0, 0, 0)
    t.Font = font or 2
    return t
end

function EasyESP:Start()
    if self.State.Active then return end
    self.State.Active = true

    table.insert(self.State.Connections, RunService.RenderStepped:Connect(function(dt)
        if not self.Settings.Master then self:HideAll() return end

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

            local screenPos, depth, onScreen = self:W2S(root.Position)
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

            if onScreen and depth > 0 then
                -- Get proper bounding box
                local boxPos, boxSize, boxValid = self:GetBoundingBox(char)
                if not boxValid then continue end

                local bx, by = boxPos.X, boxPos.Y
                local bw, bh = boxSize.X, boxSize.Y

                -- Clamp minimum box size
                if bw < 4 then bw = 4 end
                if bh < 6 then bh = 6 end

                local centerX = bx + bw / 2

                if s.Enabled then
                    local style = s.BoxStyle

                    -- ========================
                    -- BOXES
                    -- ========================
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
                            outline.Transparency = 1
                        end

                        local box = self:GetDrawing(id .. "_b", "Square")
                        box.Visible = true
                        box.Position = Vector2.new(bx, by)
                        box.Size = Vector2.new(bw, bh)
                        box.Color = color
                        box.Thickness = s.BoxThickness
                        box.Filled = false
                        box.Transparency = 1

                        if s.BoxFill then
                            local fill = self:GetDrawing(id .. "_bf", "Square")
                            fill.Visible = true
                            fill.Position = Vector2.new(bx, by)
                            fill.Size = Vector2.new(bw, bh)
                            fill.Color = color
                            fill.Filled = true
                            fill.Transparency = s.BoxFillAlpha
                        end
                    elseif style == "Corner" then
                        local cornerLen = math.min(bw, bh) * 0.25

                        if s.BoxOutline then
                            local corners_outline = {
                                -- Top-left
                                {Vector2.new(bx - 1, by - 1), Vector2.new(bx + cornerLen + 1, by - 1)},
                                {Vector2.new(bx - 1, by - 1), Vector2.new(bx - 1, by + cornerLen + 1)},
                                -- Top-right
                                {Vector2.new(bx + bw + 1, by - 1), Vector2.new(bx + bw - cornerLen - 1, by - 1)},
                                {Vector2.new(bx + bw + 1, by - 1), Vector2.new(bx + bw + 1, by + cornerLen + 1)},
                                -- Bottom-left
                                {Vector2.new(bx - 1, by + bh + 1), Vector2.new(bx + cornerLen + 1, by + bh + 1)},
                                {Vector2.new(bx - 1, by + bh + 1), Vector2.new(bx - 1, by + bh - cornerLen - 1)},
                                -- Bottom-right
                                {Vector2.new(bx + bw + 1, by + bh + 1), Vector2.new(bx + bw - cornerLen - 1, by + bh + 1)},
                                {Vector2.new(bx + bw + 1, by + bh + 1), Vector2.new(bx + bw + 1, by + bh - cornerLen - 1)},
                            }
                            for ci, cp in ipairs(corners_outline) do
                                local cl = self:GetDrawing(id .. "_co_" .. ci, "Line")
                                cl.Visible = true
                                cl.From = cp[1]
                                cl.To = cp[2]
                                cl.Color = Color3.new(0, 0, 0)
                                cl.Thickness = s.BoxThickness + 2
                            end
                        end

                        local corners_inner = {
                            {Vector2.new(bx, by), Vector2.new(bx + cornerLen, by)},
                            {Vector2.new(bx, by), Vector2.new(bx, by + cornerLen)},
                            {Vector2.new(bx + bw, by), Vector2.new(bx + bw - cornerLen, by)},
                            {Vector2.new(bx + bw, by), Vector2.new(bx + bw, by + cornerLen)},
                            {Vector2.new(bx, by + bh), Vector2.new(bx + cornerLen, by + bh)},
                            {Vector2.new(bx, by + bh), Vector2.new(bx, by + bh - cornerLen)},
                            {Vector2.new(bx + bw, by + bh), Vector2.new(bx + bw - cornerLen, by + bh)},
                            {Vector2.new(bx + bw, by + bh), Vector2.new(bx + bw, by + bh - cornerLen)},
                        }
                        for ci, cp in ipairs(corners_inner) do
                            local cl = self:GetDrawing(id .. "_c_" .. ci, "Line")
                            cl.Visible = true
                            cl.From = cp[1]
                            cl.To = cp[2]
                            cl.Color = color
                            cl.Thickness = s.BoxThickness
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

                    -- ========================
                    -- SKELETONS
                    -- ========================
                    if s.Skeletons then
                        self:RenderSkeleton(id, char, s.Rainbow and rainbow or s.SkeletonColor)
                    end

                    -- ========================
                    -- HEAD DOT
                    -- ========================
                    if s.HeadDot and head then
                        local hPos, hDepth, hOn = self:W2S(head.Position)
                        if hOn and hDepth > 0 then
                            local scaledRadius = math.clamp(s.HeadDotSize * (1000 / (dist + 100)), 2, 20)
                            local dot = self:GetDrawing(id .. "_hdot", "Circle")
                            dot.Visible = true
                            dot.Position = hPos
                            dot.Radius = scaledRadius
                            dot.Color = color
                            dot.Filled = true
                            dot.Transparency = 1
                        end
                    end

                    -- ========================
                    -- LOOK LINES
                    -- ========================
                    if s.LookLines and head then
                        local headScreen, headDepth, headOn = self:W2S(head.Position)
                        local lookEnd = head.Position + head.CFrame.LookVector * s.LookLen
                        local lookScreen, lookDepth, lookOn = self:W2S(lookEnd)
                        local line = self:GetDrawing(id .. "_look", "Line")
                        if headOn and lookOn and headDepth > 0 and lookDepth > 0 then
                            line.Visible = true
                            line.From = headScreen
                            line.To = lookScreen
                            line.Color = color
                            line.Thickness = 1
                        else
                            line.Visible = false
                        end
                    end

                    -- ========================
                    -- TRACERS
                    -- ========================
                    if s.Tracers then
                        self:RenderTracer(id, Vector2.new(centerX, by + bh), color)
                    end

                    -- ========================
                    -- HEALTH BAR
                    -- ========================
                    if s.HealthBar then
                        local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                        local barColor = s.HealthBarGradient and Color3.fromHSV(pct * 0.3, 1, 1) or Color3.new(0, 1, 0)
                        self:RenderHealthBar(id, bx, by, bh, pct, barColor)
                    end

                    -- ========================
                    -- TEXT ABOVE (names)
                    -- ========================
                    local topY = by - 4
                    local fontSize = math.clamp(s.TextSize, 10, 24)

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
                        self:MakeText(id .. "_n", str, Vector2.new(centerX, topY), fontSize, textColor, true, 2)
                    end

                    -- ========================
                    -- TEXT BELOW (distance, tool)
                    -- ========================
                    local botY = by + bh + 3

                    if s.Distance then
                        self:MakeText(id .. "_d", math.floor(dist) .. "m", Vector2.new(centerX, botY), fontSize - 2, Color3.fromRGB(200, 200, 200), true, 2)
                        botY = botY + (fontSize - 1)
                    end

                    if s.Tool then
                        local toolName = self.GetTool(plr)
                        if toolName and toolName ~= "None" then
                            self:MakeText(id .. "_t", toolName, Vector2.new(centerX, botY), fontSize - 2, Color3.fromRGB(180, 220, 255), true, 2)
                            botY = botY + (fontSize - 1)
                        end
                    end
                end

            elseif s.Arrows and s.Enabled then
                -- Off-screen arrows
                local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local dir = (Vector2.new(screenPos.X, screenPos.Y) - center)
                local len = dir.Magnitude
                if len > 0 then
                    dir = dir / len
                end
                local arrowPos = center + dir * s.ArrowRadius
                local rot = math.atan2(dir.Y, dir.X)

                local a1 = self:GetDrawing(id .. "_a1", "Line")
                local a2 = self:GetDrawing(id .. "_a2", "Line")
                local a3 = self:GetDrawing(id .. "_a3", "Line")

                local tip = arrowPos
                local left = arrowPos - Vector2.new(math.cos(rot + 0.5), math.sin(rot + 0.5)) * s.ArrowSize
                local right = arrowPos - Vector2.new(math.cos(rot - 0.5), math.sin(rot - 0.5)) * s.ArrowSize

                a1.Visible = true; a1.Color = color; a1.From = tip; a1.To = left; a1.Thickness = 2
                a2.Visible = true; a2.Color = color; a2.From = tip; a2.To = right; a2.Thickness = 2
                a3.Visible = true; a3.Color = color; a3.From = left; a3.To = right; a3.Thickness = 2
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

    local cc = Lighting:FindFirstChild("EasyESP_CC")
    if cc then cc:Destroy() end
end

return EasyESP
