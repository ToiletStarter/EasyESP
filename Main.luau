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
        Rank = false,
        Flags = false,
        TextSize = 13,
        TextFont = 2, -- Drawing font: 0=UI, 1=System, 2=Plex, 3=Monospace
        TextColor = Color3.fromRGB(255, 255, 255),
        TextOutline = true,
        HealthBar = false,
        HealthBarGradient = true,
        ArmorBar = false,
        ArmorColor = Color3.fromRGB(0, 180, 255),
        StaminaBar = false,
        StaminaColor = Color3.fromRGB(255, 255, 0),
        BarThickness = 3,
        BarOutline = true,
        Skeletons = false,
        SkeletonColor = Color3.fromRGB(255, 255, 255),
        HeadSkeleton = false,
        HeadDot = false,
        HeadDotSize = 3,
        LookLines = false,
        LookLen = 10,
        Tracers = false,
        TracerOrigin = "Bottom",
        TracerColor = Color3.fromRGB(255, 255, 255),
        Inventory = false,
        Hotbar = false,
        MaxItems = 5,
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
        Ambient = Color3.fromRGB(0,0,0),
        OutdoorAmbient = Color3.fromRGB(0,0,0),
        Exposure = 1,
        ColorCorrection = false,
        Saturation = 0,
        Contrast = 0,
    }
}

local BONES = {
    R15 = {
        {"Head","UpperTorso"},{"UpperTorso","LowerTorso"},
        {"UpperTorso","LeftUpperArm"},{"LeftUpperArm","LeftLowerArm"},{"LeftLowerArm","LeftHand"},
        {"UpperTorso","RightUpperArm"},{"RightUpperArm","RightLowerArm"},{"RightLowerArm","RightHand"},
        {"LowerTorso","LeftUpperLeg"},{"LeftUpperLeg","LeftLowerLeg"},{"LeftLowerLeg","LeftFoot"},
        {"LowerTorso","RightUpperLeg"},{"RightUpperLeg","RightLowerLeg"},{"RightLowerLeg","RightFoot"}
    },
    R6 = {
        {"Head","Torso"},{"Torso","Left Arm"},{"Torso","Right Arm"},
        {"Torso","Left Leg"},{"Torso","Right Leg"}
    }
}

local BOX_OFFSETS = {
    Vector3.new(-1, 1, -1), Vector3.new(1, 1, -1), Vector3.new(1, 1, 1), Vector3.new(-1, 1, 1),
    Vector3.new(-1, -1, -1), Vector3.new(1, -1, -1), Vector3.new(1, -1, 1), Vector3.new(-1, -1, 1)
}

local BOX_EDGES = {
    {1,2},{2,3},{3,4},{4,1},
    {5,6},{6,7},{7,8},{8,5},
    {1,5},{2,6},{3,7},{4,8}
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
    self.GetArmor = function(plr) return 0 end
    self.GetMaxArmor = function(plr) return 100 end
    self.GetStamina = function(plr) return 0 end
    self.GetMaxStamina = function(plr) return 100 end
    self.GetInventory = function(plr) return {} end
    self.GetHotbar = function(plr) return {} end
    self.GetRank = function(plr) return "None" end
    self.GetFlags = function(plr) return {} end
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

function EasyESP:GetDrawing(id, drawingType)
    if self.State.Drawings[id] then return self.State.Drawings[id] end
    local obj = Drawing.new(drawingType)
    if drawingType == "Text" then
        obj.Font = self.Settings.ESP.TextFont or 2
        obj.Color = Color3.new(1, 1, 1)
        obj.Outline = true
    end
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
    local rayParams = RaycastParams.new()
    rayParams.FilterDescendantsInstances = {LocalPlayer.Character, model, Camera}
    rayParams.FilterType = Enum.RaycastFilterType.Exclude
    local result = workspace:Raycast(origin, dir, rayParams)
    return result == nil
end

-- Get accurate 2D bounding box from projecting all 8 3D corners
function EasyESP:GetScreenBox(model)
    local cf, size = model:GetBoundingBox()
    local halfSize = size * 0.5
    local minX, minY = math.huge, math.huge
    local maxX, maxY = -math.huge, -math.huge
    local anyOnScreen = false
    local avgDepth = 0
    for _, offset in ipairs(BOX_OFFSETS) do
        local wp = (cf * CFrame.new(offset * halfSize)).Position
        local sp, onScreen = Camera:WorldToViewportPoint(wp)
        if sp.Z > 0 then
            if sp.X < minX then minX = sp.X end
            if sp.Y < minY then minY = sp.Y end
            if sp.X > maxX then maxX = sp.X end
            if sp.Y > maxY then maxY = sp.Y end
            avgDepth = avgDepth + sp.Z
            if onScreen then anyOnScreen = true end
        end
    end
    if minX == math.huge then return nil end
    return {
        x = minX,
        y = minY,
        w = maxX - minX,
        h = maxY - minY,
        onScreen = anyOnScreen,
        depth = avgDepth / 8
    }
end

function EasyESP:Render3DBox(id, model, color, isCorner)
    local cf, size = model:GetBoundingBox()
    size = size * 0.5
    local corners = {}
    for i, offset in ipairs(BOX_OFFSETS) do
        local wp = (cf * CFrame.new(offset * size)).Position
        local sp, onScreen = Camera:WorldToViewportPoint(wp)
        if sp.Z <= 0 then return end
        corners[i] = Vector2.new(sp.X, sp.Y)
    end
    for i, edge in ipairs(BOX_EDGES) do
        local line = self:GetDrawing(id .. "_3d_" .. i, "Line")
        line.Visible = true
        line.Color = color
        line.Thickness = self.Settings.ESP.BoxThickness
        if isCorner then
            local dir = (corners[edge[2]] - corners[edge[1]])
            line.From = corners[edge[1]]
            line.To = corners[edge[1]] + (dir * 0.25)
            local line2 = self:GetDrawing(id .. "_3dc_" .. i, "Line")
            line2.Visible = true
            line2.From = corners[edge[2]]
            line2.To = corners[edge[2]] - (dir * 0.25)
            line2.Color = color
            line2.Thickness = self.Settings.ESP.BoxThickness
        else
            line.From = corners[edge[1]]
            line.To = corners[edge[2]]
        end
    end
end

function EasyESP:RenderSkeleton(id, char, color)
    local rig = char:FindFirstChild("UpperTorso") and "R15" or "R6"
    for i, bone in ipairs(BONES[rig]) do
        local a, b = char:FindFirstChild(bone[1]), char:FindFirstChild(bone[2])
        local line = self:GetDrawing(id .. "_skel_" .. i, "Line")
        if a and b then
            local spA, onA = Camera:WorldToViewportPoint(a.Position)
            local spB, onB = Camera:WorldToViewportPoint(b.Position)
            if spA.Z > 0 and spB.Z > 0 then
                line.Visible = true
                line.From = Vector2.new(spA.X, spA.Y)
                line.To = Vector2.new(spB.X, spB.Y)
                line.Color = color
                line.Thickness = 1
            end
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

function EasyESP:RenderBar(id, x, y, h, pct, color, offset)
    local s = self.Settings.ESP
    local thickness = s.BarThickness
    local spacing = thickness + 3
    local xPos = x - 5 - (offset * spacing)
    pct = math.clamp(pct, 0, 1)
    
    if s.BarOutline then
        local out = self:GetDrawing(id .. "_baro_" .. offset, "Square")
        out.Visible = true
        out.Filled = true
        out.Color = Color3.new(0, 0, 0)
        out.Position = Vector2.new(xPos - 1, y - 1)
        out.Size = Vector2.new(thickness + 2, h + 2)
        out.Thickness = 1
    end
    
    -- Background of bar (dark)
    local bg = self:GetDrawing(id .. "_barbg_" .. offset, "Square")
    bg.Visible = true
    bg.Filled = true
    bg.Color = Color3.fromRGB(30, 30, 30)
    bg.Position = Vector2.new(xPos, y)
    bg.Size = Vector2.new(thickness, h)
    
    -- Filled portion (bottom-up)
    local fillH = h * pct
    local main = self:GetDrawing(id .. "_bar_" .. offset, "Square")
    main.Visible = true
    main.Filled = true
    main.Color = color
    main.Position = Vector2.new(xPos, y + (h - fillH))
    main.Size = Vector2.new(thickness, fillH)
end

function EasyESP:RenderList(id, x, y, items, title)
    if #items == 0 then return 0 end
    local s = self.Settings.ESP
    local txt = self:GetDrawing(id .. "_l_" .. title, "Text")
    txt.Visible = true
    txt.Size = s.TextSize - 1
    txt.Color = Color3.fromRGB(220, 220, 220)
    txt.Outline = true
    txt.OutlineColor = Color3.new(0, 0, 0)
    txt.Font = s.TextFont or 2
    local str = title .. ":"
    for i = 1, math.min(#items, s.MaxItems) do
        str = str .. "\n• " .. tostring(items[i])
    end
    txt.Text = str
    txt.Position = Vector2.new(x, y)
    return txt.TextBounds.Y + 4
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
    local cc = Lighting:FindFirstChild("EasyESP_CC") or Instance.new("ColorCorrectionEffect", Lighting)
    cc.Name = "EasyESP_CC"
    cc.Enabled = w.ColorCorrection
    cc.Saturation = w.Saturation
    cc.Contrast = w.Contrast
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
        
        local sESP = self.Settings.ESP
        
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LocalPlayer or not plr.Character then continue end
            local char = plr.Character
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            local head = char:FindFirstChild("Head")
            if not root or not hum or hum.Health <= 0 then continue end
            
            local dist = (Camera.CFrame.Position - root.Position).Magnitude
            if dist > self.Settings.MaxDist then continue end
            
            local id = tostring(plr.UserId)
            local color = sESP.Rainbow and rainbow or sESP.BoxColor
            
            if sESP.VisibleCheck and not self:IsVisible(root, char) then
                color = Color3.fromRGB(255, 50, 50)
            end
            
            local rootScreen, rootDepth, rootOnScreen = self:W2S(root.Position)
            
            if rootOnScreen and rootDepth > 0 then
                -- Get accurate 2D box from 3D bounding box projection
                local box = self:GetScreenBox(char)
                if not box then continue end
                
                local x, y, w, h = box.x, box.y, box.w, box.h
                
                if sESP.Enabled then
                    local style = sESP.BoxStyle
                    
                    if style == "3D" then
                        self:Render3DBox(id, char, color, false)
                    elseif style == "3DCorner" then
                        self:Render3DBox(id, char, color, true)
                    elseif style == "2D" then
                        -- Outline for contrast
                        if sESP.BoxOutline then
                            local outline = self:GetDrawing(id .. "_bo", "Square")
                            outline.Visible = true
                            outline.Position = Vector2.new(x - 1, y - 1)
                            outline.Size = Vector2.new(w + 2, h + 2)
                            outline.Color = Color3.new(0, 0, 0)
                            outline.Thickness = sESP.BoxThickness + 2
                            outline.Filled = false
                        end
                        local boxD = self:GetDrawing(id .. "_b", "Square")
                        boxD.Visible = true
                        boxD.Position = Vector2.new(x, y)
                        boxD.Size = Vector2.new(w, h)
                        boxD.Color = color
                        boxD.Thickness = sESP.BoxThickness
                        boxD.Filled = false
                        if sESP.BoxFill then
                            local fill = self:GetDrawing(id .. "_bf", "Square")
                            fill.Visible = true
                            fill.Position = Vector2.new(x, y)
                            fill.Size = Vector2.new(w, h)
                            fill.Color = color
                            fill.Filled = true
                            fill.Transparency = sESP.BoxFillAlpha
                        end
                    elseif style == "Corner" then
                        local cornerLen = math.min(w, h) * 0.25
                        local corners = {
                            {Vector2.new(x, y), Vector2.new(x + cornerLen, y), Vector2.new(x, y + cornerLen)},
                            {Vector2.new(x + w, y), Vector2.new(x + w - cornerLen, y), Vector2.new(x + w, y + cornerLen)},
                            {Vector2.new(x, y + h), Vector2.new(x + cornerLen, y + h), Vector2.new(x, y + h - cornerLen)},
                            {Vector2.new(x + w, y + h), Vector2.new(x + w - cornerLen, y + h), Vector2.new(x + w, y + h - cornerLen)},
                        }
                        for ci, c in ipairs(corners) do
                            local l1 = self:GetDrawing(id .. "_c1_" .. ci, "Line")
                            local l2 = self:GetDrawing(id .. "_c2_" .. ci, "Line")
                            l1.Visible = true; l1.From = c[1]; l1.To = c[2]; l1.Color = color; l1.Thickness = sESP.BoxThickness
                            l2.Visible = true; l2.From = c[1]; l2.To = c[3]; l2.Color = color; l2.Thickness = sESP.BoxThickness
                        end
                    end
                    
                    if sESP.Skeletons then self:RenderSkeleton(id, char, color) end
                    
                    if sESP.HeadDot and head then
                        local hp, _, hOn = self:W2S(head.Position)
                        if hOn then
                            local dot = self:GetDrawing(id .. "_hdot", "Circle")
                            dot.Visible = true
                            dot.Position = hp
                            dot.Radius = sESP.HeadDotSize
                            dot.Color = color
                            dot.Filled = true
                            dot.NumSides = 12
                        end
                    end
                    
                    if sESP.LookLines and head then
                        -- Use small world-space offset (studs), independent of screen size
                        local startPos, _, sOn = self:W2S(head.Position)
                        local endWorld = head.Position + head.CFrame.LookVector * (sESP.LookLen or 10)
                        local endPos, endZ, eOn = self:W2S(endWorld)
                        if sOn and endZ > 0 then
                            local line = self:GetDrawing(id .. "_look", "Line")
                            line.Visible = true
                            line.From = startPos
                            line.To = endPos
                            line.Color = color
                            line.Thickness = 1
                        end
                    end
                    
                    if sESP.Tracers then
                        self:RenderTracer(id, Vector2.new(x + w / 2, y + h), color)
                    end
                    
                    -- BARS: scaled to actual character screen height
                    local bIdx = 0
                    if sESP.HealthBar then
                        local pct = hum.MaxHealth > 0 and hum.Health / hum.MaxHealth or 0
                        local barColor = sESP.HealthBarGradient and Color3.fromHSV(math.clamp(pct, 0, 1) * 0.33, 1, 1) or Color3.new(0, 1, 0)
                        self:RenderBar(id, x, y, h, pct, barColor, bIdx)
                        bIdx = bIdx + 1
                    end
                    if sESP.ArmorBar then
                        local maxA = self.GetMaxArmor(plr)
                        local pct = maxA > 0 and self.GetArmor(plr) / maxA or 0
                        self:RenderBar(id, x, y, h, pct, sESP.ArmorColor, bIdx)
                        bIdx = bIdx + 1
                    end
                    if sESP.StaminaBar then
                        local maxS = self.GetMaxStamina(plr)
                        local pct = maxS > 0 and self.GetStamina(plr) / maxS or 0
                        self:RenderBar(id, x, y, h, pct, sESP.StaminaColor, bIdx)
                    end
                    
                    -- TEXT ABOVE HEAD
                    local cx = x + w / 2
                    local textPad = 4
                    local ty = y - sESP.TextSize - textPad
                    
                    if sESP.Flags then
                        local flags = self.GetFlags(plr)
                        if #flags > 0 then
                            local t = self:GetDrawing(id .. "_f", "Text")
                            t.Visible = true
                            t.Center = true
                            t.Outline = true
                            t.OutlineColor = Color3.new(0, 0, 0)
                            t.Size = sESP.TextSize - 2
                            t.Color = Color3.fromRGB(255, 60, 60)
                            t.Font = sESP.TextFont or 2
                            t.Text = table.concat(flags, " | ")
                            t.Position = Vector2.new(cx, ty)
                            ty = ty - (sESP.TextSize)
                        end
                    end
                    
                    if sESP.Rank then
                        local t = self:GetDrawing(id .. "_rank", "Text")
                        t.Visible = true
                        t.Center = true
                        t.Outline = true
                        t.OutlineColor = Color3.new(0, 0, 0)
                        t.Size = sESP.TextSize - 1
                        t.Color = Color3.fromRGB(200, 200, 255)
                        t.Font = sESP.TextFont or 2
                        t.Text = "[" .. tostring(self.GetRank(plr)) .. "]"
                        t.Position = Vector2.new(cx, ty)
                        ty = ty - (sESP.TextSize)
                    end
                    
                    if sESP.Names or sESP.Usernames then
                        local t = self:GetDrawing(id .. "_n", "Text")
                        t.Visible = true
                        t.Size = sESP.TextSize
                        t.Center = true
                        t.Outline = true
                        t.OutlineColor = Color3.new(0, 0, 0)
                        t.Color = sESP.TextColor
                        t.Font = sESP.TextFont or 2
                        local str = ""
                        if sESP.Names and sESP.Usernames then
                            str = plr.DisplayName .. " (@" .. plr.Name .. ")"
                        elseif sESP.Names then
                            str = plr.DisplayName
                        elseif sESP.Usernames then
                            str = "@" .. plr.Name
                        end
                        t.Text = str
                        t.Position = Vector2.new(cx, ty)
                    end
                    
                    -- TEXT BELOW BOX
                    local by = y + h + 2
                    
                    if sESP.Distance then
                        local t = self:GetDrawing(id .. "_d", "Text")
                        t.Visible = true
                        t.Center = true
                        t.Outline = true
                        t.OutlineColor = Color3.new(0, 0, 0)
                        t.Size = sESP.TextSize - 1
                        t.Color = sESP.TextColor
                        t.Font = sESP.TextFont or 2
                        t.Text = "[" .. math.floor(dist) .. "m]"
                        t.Position = Vector2.new(cx, by)
                        by = by + (sESP.TextSize)
                    end
                    
                    if sESP.Tool then
                        local t = self:GetDrawing(id .. "_t", "Text")
                        t.Visible = true
                        t.Center = true
                        t.Outline = true
                        t.OutlineColor = Color3.new(0, 0, 0)
                        t.Size = sESP.TextSize - 1
                        t.Color = Color3.fromRGB(255, 255, 180)
                        t.Font = sESP.TextFont or 2
                        t.Text = tostring(self.GetTool(plr))
                        t.Position = Vector2.new(cx, by)
                        by = by + (sESP.TextSize)
                    end
                    
                    -- LISTS TO THE RIGHT
                    local lx, ly = x + w + 6, y
                    if sESP.Hotbar then
                        ly = ly + self:RenderList(id, lx, ly, self.GetHotbar(plr), "Hotbar") + 2
                    end
                    if sESP.Inventory then
                        self:RenderList(id, lx, ly, self.GetInventory(plr), "Inventory")
                    end
                end
            elseif sESP.Arrows then
                local viewport = Camera.ViewportSize
                local center = Vector2.new(viewport.X / 2, viewport.Y / 2)
                local sp = Vector2.new(rootScreen.X, rootScreen.Y)
                if rootDepth < 0 then sp = center * 2 - sp end
                local diff = sp - center
                if diff.Magnitude < 0.01 then continue end
                local dir = diff.Unit
                local arrowPos = center + dir * sESP.ArrowRadius
                local rot = math.atan2(dir.Y, dir.X)
                local a1 = self:GetDrawing(id .. "_a1", "Line")
                local a2 = self:GetDrawing(id .. "_a2", "Line")
                a1.Visible = true
                a1.Color = color
                a1.Thickness = 2
                a1.From = arrowPos
                a1.To = arrowPos - Vector2.new(math.cos(rot + 0.5), math.sin(rot + 0.5)) * sESP.ArrowSize
                a2.Visible = true
                a2.Color = color
                a2.Thickness = 2
                a2.From = arrowPos
                a2.To = arrowPos - Vector2.new(math.cos(rot - 0.5), math.sin(rot - 0.5)) * sESP.ArrowSize
            end
        end
    end))
end

function EasyESP:Destroy()
    self.State.Active = false
    for _, c in ipairs(self.State.Connections) do c:Disconnect() end
    for _, v in pairs(self.State.Drawings) do v:Remove() end
    self.State.Drawings = {}
end

return EasyESP
