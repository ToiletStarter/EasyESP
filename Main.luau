local Players = game:GetService("Players")
local RunService = game:GetService("RunService")
local Lighting = game:GetService("Lighting")
local UserInputService = game:GetService("UserInputService")
local LocalPlayer = Players.LocalPlayer

local EasyESP = {}
EasyESP.__index = EasyESP

EasyESP.Defaults = {
    Master = false,
    MaxDist = 2000,
    RefreshRate = 1,
    ESP = {
        Enabled = false,
        Boxes = true,
        BoxStyle = "Corner", -- "2D", "Corner", "3D"
        BoxThick = 1.5,
        BoxOutline = true,
        BoxFill = false,
        BoxFillAlpha = 0.2,
        
        Names = true,
        Distance = true,
        HealthBar = true,
        HealthText = false,
        Tool = false,
        
        Skeletons = false,
        HeadDot = false,
        LookLines = false,
        LookLen = 8,
        
        Tracers = false,
        TracerOrigin = "Bottom", -- "Bottom", "Center", "Mouse"
        
        Arrows = false,
        ArrowRadius = 150,
        ArrowSize = 12,
        
        TeamCheck = false,
        TeamColor = true,
        VisibleCheck = false,
        Color = Color3.fromRGB(255, 255, 255),
        VisibleColor = Color3.fromRGB(0, 255, 150),
    },
    Chams = {
        Enabled = false,
        Mode = "Highlight", -- "Highlight", "Material", "Wireframe"
        FillColor = Color3.fromRGB(255, 255, 255),
        OutlineColor = Color3.fromRGB(255, 255, 255),
        FillAlpha = 0.5,
        OutlineAlpha = 0,
        OnTop = true,
        Pulse = false,
    },
    World = {
        Enabled = false,
        Brightness = 1,
        Ambient = Color3.fromRGB(127, 127, 127),
        FOV = 70,
        NoFog = false,
        NoSky = false,
        NoShadows = false,
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

function EasyESP.new(options)
    local self = setmetatable({}, EasyESP)
    self.Settings = table.clone(EasyESP.Defaults)
    if options and options.Settings then
        for k, v in pairs(options.Settings) do
            if type(v) == "table" then
                for k2, v2 in pairs(v) do self.Settings[k][k2] = v2 end
            else
                self.Settings[k] = v
            end
        end
    end

    self.State = {
        Active = false,
        Entities = {},
        Drawings = {},
        Cache = { Parts = {}, Sky = {}, Lighting = {} },
        Connections = {}
    }
    
    return self
end

function EasyESP:W2S(pos)
    local cam = workspace.CurrentCamera
    if not cam then return Vector2.new(), 0, false end
    local screenPos, onScreen = cam:WorldToViewportPoint(pos)
    return Vector2.new(screenPos.X, screenPos.Y), screenPos.Z, onScreen
end

function EasyESP:GetDraw(id, type)
    if self.State.Drawings[id] then return self.State.Drawings[id] end
    local obj = Drawing.new(type)
    self.State.Drawings[id] = obj
    return obj
end

function EasyESP:ClearDrawings()
    for _, v in pairs(self.State.Drawings) do v:Remove() end
    self.State.Drawings = {}
end

function EasyESP:UpdateWorld()
    local w = self.Settings.World
    if not w.Enabled then return end
    
    Lighting.Brightness = w.Brightness
    Lighting.Ambient = w.Ambient
    Lighting.GlobalShadows = not w.NoShadows
    if w.NoFog then Lighting.FogEnd = 1e6 end
    workspace.CurrentCamera.FieldOfView = w.FOV
end

function EasyESP:RenderSkeleton(entity, pfx, color)
    local model = entity.model
    local rig = model:FindFirstChild("UpperTorso") and "R15" or "R6"
    for i, bone in ipairs(BONES[rig]) do
        local a, b = model:FindFirstChild(bone[1]), model:FindFirstChild(bone[2])
        if a and b then
            local posA, zA, visA = self:W2S(a.Position)
            local posB, zB, visB = self:W2S(b.Position)
            local line = self:GetDraw(pfx .. "_skel_" .. i, "Line")
            if visA and visB and zA > 0 and zB > 0 then
                line.Visible = true
                line.From = posA
                line.To = posB
                line.Color = color
                line.Thickness = 1
            else
                line.Visible = false
            end
        end
    end
end

function EasyESP:RenderEntity(entity)
    local s = self.Settings.ESP
    local root = entity.model:FindFirstChild("HumanoidRootPart")
    if not root then return end
    
    local pos, depth, onScreen = self:W2S(root.Position)
    local dist = (workspace.CurrentCamera.CFrame.Position - root.Position).Magnitude
    
    local pfx = tostring(entity.id)
    local color = s.Color
    if s.TeamColor and entity.teamColor then color = entity.teamColor end

    if not onScreen or depth <= 0 or dist > self.Settings.MaxDist then
        if s.Arrows and depth > 0 then
            -- Arrow logic here (simplified)
        end
        self:ToggleEntityVisuals(pfx, false)
        return
    end

    local size = (Vector2.new(2000, 2000) / depth)
    local x, y = pos.X - (size.X / 2), pos.Y - (size.Y / 2)

    if s.Boxes then
        local box = self:GetDraw(pfx .. "_box", "Square")
        box.Visible = true
        box.Position = Vector2.new(x, y)
        box.Size = size
        box.Color = color
        box.Thickness = s.BoxThick
        box.Filled = s.BoxFill
        box.Transparency = 1
    end

    if s.Names then
        local txt = self:GetDraw(pfx .. "_name", "Text")
        txt.Visible = true
        txt.Text = entity.name
        txt.Position = Vector2.new(pos.X, y - 15)
        txt.Color = color
        txt.Center = true
        txt.Outline = true
        txt.Size = 14
    end

    if s.HealthBar and entity.hum then
        local health = entity.hum.Health / entity.hum.MaxHealth
        local bar = self:GetDraw(pfx .. "_hp", "Square")
        bar.Visible = true
        bar.Position = Vector2.new(x - 6, y)
        bar.Size = Vector2.new(2, size.Y * health)
        bar.Color = Color3.fromRGB(255 * (1 - health), 255 * health, 0)
        bar.Filled = true
    end

    if s.Skeletons then
        self:RenderSkeleton(entity, pfx, color)
    end
end

function EasyESP:ToggleEntityVisuals(pfx, state)
    for id, draw in pairs(self.State.Drawings) do
        if string.find(id, pfx) then draw.Visible = state end
    end
end

function EasyESP:Start()
    if self.State.Active then return end
    self.State.Active = true
    
    table.insert(self.State.Connections, RunService.RenderStepped:Connect(function()
        if not self.Settings.Master then 
            self:ClearDrawings()
            return 
        end
        
        self:UpdateWorld()
        
        local entities = {}
        for _, plr in ipairs(Players:GetPlayers()) do
            if plr ~= LocalPlayer and plr.Character and plr.Character:FindFirstChild("Humanoid") then
                table.insert(entities, {
                    id = plr.UserId,
                    name = plr.Name,
                    model = plr.Character,
                    hum = plr.Character.Humanoid,
                    teamColor = plr.TeamColor.Color
                })
            end
        end
        
        for _, ent in ipairs(entities) do
            self:RenderEntity(ent)
        end
    end))
end

function EasyESP:Destroy()
    self.State.Active = false
    for _, c in ipairs(self.State.Connections) do c:Disconnect() end
    self:ClearDrawings()
end

return EasyESP
