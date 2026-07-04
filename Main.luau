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
        TextColor = Color3.fromRGB(255, 255, 255),
        TextOutline = true,

        HealthBar = false,
        HealthBarGradient = true,
        ArmorBar = false,
        ArmorColor = Color3.fromRGB(0, 180, 255),
        StaminaBar = false,
        StaminaColor = Color3.fromRGB(255, 255, 0),
        BarThickness = 2,
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

function EasyESP:GetDrawing(id, type)
    if self.State.Drawings[id] then return self.State.Drawings[id] end
    local obj = Drawing.new(type)
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
    local ray = Ray.new(origin, dir)
    local hit = workspace:FindPartOnRayWithIgnoreList(ray, {LocalPlayer.Character, model, Camera})
    return hit == nil
end

function EasyESP:Render3DBox(id, model, color, isCorner)
    local cf, size = model:GetBoundingBox()
    size = size * 0.5
    local corners = {}
    for i, offset in ipairs(BOX_OFFSETS) do
        local wp = (cf * CFrame.new(offset * size)).Position
        local pos, z, onScreen = self:W2S(wp)
        if not onScreen then return end
        corners[i] = pos
    end
    for i, edge in ipairs(BOX_EDGES) do
        local line = self:GetDrawing(id .. "_3d_" .. i, "Line")
        line.Visible = true; line.From = corners[edge[1]]; line.To = corners[edge[2]]
        line.Color = color; line.Thickness = self.Settings.ESP.BoxThickness
        if isCorner then
            local dir = (line.To - line.From)
            line.To = line.From + (dir * 0.2)
            local line2 = self:GetDrawing(id .. "_3dc_" .. i, "Line")
            line2.Visible = true; line2.From = corners[edge[2]]; line2.To = corners[edge[2]] - (dir * 0.2)
            line2.Color = color; line2.Thickness = self.Settings.ESP.BoxThickness
        end
    end
end

function EasyESP:RenderSkeleton(id, char, color)
    local rig = char:FindFirstChild("UpperTorso") and "R15" or "R6"
    for i, bone in ipairs(BONES[rig]) do
        local a, b = char:FindFirstChild(bone[1]), char:FindFirstChild(bone[2])
        if a and b then
            local posA, zA, visA = self:W2S(a.Position)
            local posB, zB, visB = self:W2S(b.Position)
            local line = self:GetDrawing(id .. "_skel_" .. i, "Line")
            if visA and visB and zA > 0 and zB > 0 then
                line.Visible = true; line.From = posA; line.To = posB
                line.Color = color; line.Thickness = 1
            else
                line.Visible = false
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
    line.Visible = true; line.From = origin; line.To = target
    line.Color = color; line.Thickness = 1
end

function EasyESP:RenderBar(id, x, y, h, pct, color, offset)
    local s = self.Settings.ESP
    local xPos = x - 5 - (offset * (s.BarThickness + 2))
    if s.BarOutline then
        local out = self:GetDrawing(id .. "_baro_" .. offset, "Square")
        out.Visible = true; out.Filled = true; out.Color = Color3.new(0,0,0)
        out.Position = Vector2.new(xPos - 1, y - 1); out.Size = Vector2.new(s.BarThickness + 2, h + 2)
    end
    local main = self:GetDrawing(id .. "_bar_" .. offset, "Square")
    main.Visible = true; main.Filled = true; main.Color = color
    main.Position = Vector2.new(xPos, y + (h * (1 - pct))); main.Size = Vector2.new(s.BarThickness, h * pct)
end

function EasyESP:RenderList(id, x, y, items, title)
    if #items == 0 then return 0 end
    local s = self.Settings.ESP
    local txt = self:GetDrawing(id .. "_l_" .. title, "Text")
    txt.Visible = true; txt.Size = s.TextSize - 2; txt.Color = Color3.new(0.8, 0.8, 0.8); txt.Outline = true
    local str = title .. ":"
    for i = 1, math.min(#items, s.MaxItems) do str = str .. "\n- " .. tostring(items[i]) end
    txt.Text = str; txt.Position = Vector2.new(x, y)
    return txt.TextBounds.Y + 5
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
            local color = self.Settings.ESP.Rainbow and rainbow or self.Settings.ESP.BoxColor
            
            if self.Settings.ESP.VisibleCheck and not self:IsVisible(root, char) then
                color = Color3.fromRGB(255, 50, 50)
            end
            
            if onScreen then
                local size = (Vector2.new(2000, 2000) / depth)
                local x, y = screenPos.X - (size.X / 2), screenPos.Y - (size.Y / 2)
                
                if self.Settings.ESP.Enabled then
                    local style = self.Settings.ESP.BoxStyle
                    if style == "3D" then self:Render3DBox(id, char, color, false)
                    elseif style == "3DCorner" then self:Render3DBox(id, char, color, true)
                    elseif style == "Corner" or style == "2D" then
                        local box = self:GetDrawing(id .. "_b", "Square")
                        box.Visible = true; box.Position = Vector2.new(x, y); box.Size = size; box.Color = color
                        box.Thickness = self.Settings.ESP.BoxThickness; box.Filled = self.Settings.ESP.BoxFill; box.Transparency = self.Settings.ESP.BoxFillAlpha
                    end
                    
                    if self.Settings.ESP.Skeletons then self:RenderSkeleton(id, char, color) end
                    if self.Settings.ESP.HeadDot and head then
                        local hPos, hDepth, hOn = self:W2S(head.Position)
                        if hOn then
                            local dot = self:GetDrawing(id .. "_hdot", "Circle")
                            dot.Visible = true; dot.Position = hPos; dot.Radius = self.Settings.ESP.HeadDotSize; dot.Color = color; dot.Filled = true
                        end
                    end
                    if self.Settings.ESP.LookLines and head then
                        local gaze = self:W2S(head.Position + head.CFrame.LookVector * self.Settings.ESP.LookLen)
                        local line = self:GetDrawing(id .. "_look", "Line")
                        line.Visible = true; line.From = self:W2S(head.Position); line.To = gaze; line.Color = color; line.Thickness = 1
                    end
                    if self.Settings.ESP.Tracers then self:RenderTracer(id, Vector2.new(screenPos.X, y + size.Y), color) end
                    
                    local bIdx = 0
                    if self.Settings.ESP.HealthBar then
                        local pct = math.clamp(hum.Health / hum.MaxHealth, 0, 1)
                        self:RenderBar(id, x, y, size.Y, pct, self.Settings.ESP.HealthBarGradient and Color3.fromHSV(pct * 0.3, 1, 1) or Color3.new(0,1,0), bIdx); bIdx = bIdx + 1
                    end
                    if self.Settings.ESP.ArmorBar then
                        self:RenderBar(id, x, y, size.Y, math.clamp(self.GetArmor(plr) / self.GetMaxArmor(plr), 0, 1), self.Settings.ESP.ArmorColor, bIdx); bIdx = bIdx + 1
                    end
                    if self.Settings.ESP.StaminaBar then
                        self:RenderBar(id, x, y, size.Y, math.clamp(self.GetStamina(plr) / self.GetMaxStamina(plr), 0, 1), self.Settings.ESP.StaminaColor, bIdx)
                    end
                    
                    local ty = y - 15
                    if self.Settings.ESP.Names or self.Settings.ESP.Usernames then
                        local t = self:GetDrawing(id .. "_n", "Text")
                        t.Visible = true; t.Size = self.Settings.ESP.TextSize; t.Center = true; t.Outline = true; t.Color = self.Settings.ESP.TextColor
                        local str = ""
                        if self.Settings.ESP.Names then str = plr.DisplayName end
                        if self.Settings.ESP.Usernames then str = str .. (str ~= "" and " (@" or "@") .. plr.Name .. (str ~= "" and ")" or "") end
                        t.Text = str; t.Position = Vector2.new(screenPos.X, ty); ty = ty - 15
                    end
                    if self.Settings.ESP.Rank then
                        local t = self:GetDrawing(id .. "_rank", "Text")
                        t.Visible = true; t.Center = true; t.Outline = true; t.Size = self.Settings.ESP.TextSize - 2
                        t.Text = self.GetRank(plr); t.Position = Vector2.new(screenPos.X, ty); ty = ty - 12
                    end
                    
                    local by = y + size.Y + 2
                    if self.Settings.ESP.Distance then
                        local t = self:GetDrawing(id .. "_d", "Text")
                        t.Visible = true; t.Center = true; t.Outline = true; t.Size = self.Settings.ESP.TextSize - 2
                        t.Text = math.floor(dist) .. "m"; t.Position = Vector2.new(screenPos.X, by); by = by + 12
                    end
                    if self.Settings.ESP.Tool then
                        local t = self:GetDrawing(id .. "_t", "Text")
                        t.Visible = true; t.Center = true; t.Outline = true; t.Size = self.Settings.ESP.TextSize - 2
                        t.Text = self.GetTool(plr); t.Position = Vector2.new(screenPos.X, by); by = by + 12
                    end
                    if self.Settings.ESP.Flags then
                        local flags = self.GetFlags(plr)
                        if #flags > 0 then
                            local t = self:GetDrawing(id .. "_f", "Text")
                            t.Visible = true; t.Center = true; t.Outline = true; t.Size = self.Settings.ESP.TextSize - 3; t.Color = Color3.new(1,0,0)
                            t.Text = table.concat(flags, " | "); t.Position = Vector2.new(screenPos.X, by); by = by + 10
                        end
                    end
                    
                    local lx, ly = x + size.X + 5, y
                    if self.Settings.ESP.Hotbar then ly = ly + self:RenderList(id, lx, ly, self.GetHotbar(plr), "Hotbar") end
                    if self.Settings.ESP.Inventory then self:RenderList(id, lx, ly, self.GetInventory(plr), "Inventory") end
                end
            elseif self.Settings.ESP.Arrows then
                local center = Vector2.new(Camera.ViewportSize.X / 2, Camera.ViewportSize.Y / 2)
                local dir = (Vector2.new(screenPos.X, screenPos.Y) - center).Unit
                local arrowPos = center + dir * self.Settings.ESP.ArrowRadius
                local a1 = self:GetDrawing(id .. "_a1", "Line")
                local a2 = self:GetDrawing(id .. "_a2", "Line")
                local rot = math.atan2(dir.Y, dir.X)
                a1.Visible = true; a1.Color = color; a1.From = arrowPos; a1.To = arrowPos - Vector2.new(math.cos(rot + 0.5), math.sin(rot + 0.5)) * self.Settings.ESP.ArrowSize
                a2.Visible = true; a2.Color = color; a2.From = arrowPos; a2.To = arrowPos - Vector2.new(math.cos(rot - 0.5), math.sin(rot - 0.5)) * self.Settings.ESP.ArrowSize
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
