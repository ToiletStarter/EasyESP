-- // EasyESP Professional: Ultra-Feature-Rich Visual Backend
-- // Version: 3.0.0 (Enterprise Modular Edition)

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

-- // Default Configuration
EasyESP.Defaults = {
    Master = false,
    MaxDist = 2500,

    ESP = {
        Enabled = false,
        TeamCheck = false,
        VisibleCheck = false,
        
        -- Box Visuals
        Boxes = false,
        BoxStyle = "2D", -- "2D", "Corner", "3D", "3DCorner"
        BoxColor = Color3.fromRGB(255, 255, 255),
        BoxOutline = true,
        BoxFill = false,
        BoxFillAlpha = 0.2,
        BoxThickness = 1,

        -- Text Visuals
        Names = false, -- Display Name
        Usernames = false, -- @Username
        Distance = false,
        Tool = false,
        TextSize = 13,
        TextColor = Color3.fromRGB(255, 255, 255),
        TextOutline = true,

        -- Bars (Multi-Stacking)
        HealthBar = false,
        HealthBarGradient = true, -- Lerps Green -> Red
        ArmorBar = false,
        ArmorColor = Color3.fromRGB(0, 180, 255),
        BarThickness = 2,
        BarOutline = true,

        -- Extra Visuals
        Skeletons = false,
        SkeletonColor = Color3.fromRGB(255, 255, 255),
        HeadSkeleton = false, -- Detailed head cage
        HeadDot = false,
        LookLines = false,
        
        -- Inventory/Hotbar Framework
        Inventory = false,
        Hotbar = false,
        InvMaxItems = 5,
        
        -- Offscreen
        Arrows = false,
        ArrowRadius = 180,
    },

    Chams = {
        Enabled = false,
        Mode = "Highlight",
        FillColor = Color3.fromRGB(255, 255, 255),
        FillAlpha = 0.5,
        OnTop = true,
    },

    World = {
        Enabled = false,
        Fullbright = false,
        FOV = 70,
        NoFog = false,
    }
}

-- // Internal Constants
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

local OFFSETS_3D = {
    Vector3.new(-1, 1, -1), Vector3.new(1, 1, -1), Vector3.new(1, 1, 1), Vector3.new(-1, 1, 1),
    Vector3.new(-1, -1, -1), Vector3.new(1, -1, -1), Vector3.new(1, -1, 1), Vector3.new(-1, -1, 1)
}
local EDGES_3D = {
    {1,2},{2,3},{3,4},{4,1}, -- Top
    {5,6},{6,7},{7,8},{8,5}, -- Bottom
    {1,5},{2,6},{3,7},{4,8}  -- Connectors
}

-- // Utility
local function DeepCopy(t)
    local copy = {}
    for k, v in pairs(t) do
        if type(v) == "table" then copy[k] = DeepCopy(v) else copy[k] = v end
    end
    return copy
end

function EasyESP.new()
    local self = setmetatable({}, EasyESP)
    self.Settings = DeepCopy(EasyESP.Defaults)
    self.State = { Active = false, Drawings = {}, Highlights = {} }
    
    -- // CUSTOMIZABLE HOOKS (Override these for specific games)
    self.GetArmor = function(plr) return 0 end 
    self.GetMaxArmor = function(plr) return 100 end
    self.GetInventory = function(plr) return {} end -- Should return table of strings
    self.GetHotbar = function(plr) return {} end
    self.GetTool = function(plr) 
        local char = plr.Character
        local tool = char and char:FindFirstChildOfClass("Tool")
        return tool and tool.Name or "None"
    end

    return self
end

-- // Drawing Management
function EasyESP:GetDrawing(id, type)
    if self.State.Drawings[id] then return self.State.Drawings[id] end
    local obj = Drawing.new(type)
    self.State.Drawings[id] = obj
    return obj
end

function EasyESP:HideAll()
    for _, v in pairs(self.State.Drawings) do v.Visible = false end
end

-- // Feature Renderers
function EasyESP:Render3DBox(id, root, color, isCorner)
    local cf = root.CFrame
    local size = root.Parent:GetExtentsSize() * 0.6
    local corners = {}
    
    for i, offset in ipairs(OFFSETS_3D) do
        local wp = (cf * CFrame.new(offset * size)).Position
        local screenPos, z, onScreen = Camera:WorldToViewportPoint(wp)
        if not onScreen then return end
        corners[i] = Vector2.new(screenPos.X, screenPos.Y)
    end

    for i, edge in ipairs(EDGES_3D) do
        local line = self:GetDrawing(id .. "_3d_" .. i, "Line")
        line.Visible = true
        line.From = corners[edge[1]]
        line.To = corners[edge[2]]
        line.Color = color
        line.Thickness = self.Settings.ESP.BoxThickness
        
        if isCorner then
            -- Shorten the line for 3D corner style
            local dir = (line.To - line.From)
            line.To = line.From + (dir * 0.2)
            
            local line2 = self:GetDrawing(id .. "_3d_c" .. i, "Line")
            line2.Visible = true
            line2.From = corners[edge[2]]
            line2.To = corners[edge[2]] - (dir * 0.2)
            line2.Color = color
            line2.Thickness = self.Settings.ESP.BoxThickness
        end
    end
end

function EasyESP:RenderBar(id, x, y, h, pct, color, offsetIdx)
    local s = self.Settings.ESP
    local xPos = x - 6 - (offsetIdx * (s.BarThickness + 2))
    
    local back = self:GetDrawing(id .. "_barbg_" .. offsetIdx, "Square")
    back.Visible = true
    back.Filled = true
    back.Color = Color3.new(0,0,0)
    back.Transparency = 0.5
    back.Position = Vector2.new(xPos, y)
    back.Size = Vector2.new(s.BarThickness, h)

    local main = self:GetDrawing(id .. "_bar_" .. offsetIdx, "Square")
    main.Visible = true
    main.Filled = true
    main.Color = color
    main.Position = Vector2.new(xPos, y + (h * (1 - pct)))
    main.Size = Vector2.new(s.BarThickness, h * pct)
end

function EasyESP:RenderInventory(id, x, y, items, title)
    if #items == 0 then return 0 end
    local s = self.Settings.ESP
    local height = 0
    
    local txt = self:GetDrawing(id .. "_inv_" .. title, "Text")
    txt.Visible = true
    txt.Size = s.TextSize - 2
    txt.Color = Color3.new(0.9, 0.9, 0.9)
    txt.Outline = true
    
    local str = title .. ":\n"
    for i = 1, math.min(#items, s.InvMaxItems) do
        str = str .. "- " .. items[i] .. "\n"
    end
    txt.Text = str
    txt.Position = Vector2.new(x, y)
    
    return txt.TextBounds.Y
end

-- // Main Loop
function EasyESP:Start()
    self.State.Active = true
    table.insert(self.State.Connections or {}, RunService.RenderStepped:Connect(function()
        if not self.Settings.Master then self:HideAll() return end
        self:HideAll()

        for _, plr in ipairs(Players:GetPlayers()) do
            if plr == LocalPlayer or not plr.Character then continue end
            local char = plr.Character
            local root = char:FindFirstChild("HumanoidRootPart")
            local hum = char:FindFirstChildOfClass("Humanoid")
            if not root or not hum or hum.Health <= 0 then continue end

            local screenPos, depth, onScreen = Camera:WorldToViewportPoint(root.Position)
            local dist = (Camera.CFrame.Position - root.Position).Magnitude
            if dist > self.Settings.MaxDist then continue end

            local color = self.Settings.ESP.BoxColor
            local id = tostring(plr.UserId)

            if onScreen then
                local size = (Vector2.new(2000, 2000) / depth)
                local x, y = screenPos.X - (size.X / 2), screenPos.Y - (size.Y / 2)
                
                -- Boxes
                if self.Settings.ESP.Boxes then
                    local style = self.Settings.ESP.BoxStyle
                    if style == "3D" then self:Render3DBox(id, root, color, false)
                    elseif style == "3DCorner" then self:Render3DBox(id, root, color, true)
                    else -- 2D Logic
                        local box = self:GetDrawing(id .. "_2d", "Square")
                        box.Visible = true
                        box.Position = Vector2.new(x, y); box.Size = size; box.Color = color
                    end
                end

                -- Bars
                local barIdx = 0
                if self.Settings.ESP.HealthBar then
                    local hpPct = hum.Health / hum.MaxHealth
                    local hpClr = self.Settings.ESP.HealthBarGradient and Color3.fromHSV(hpPct * 0.3, 1, 1) or Color3.new(0,1,0)
                    self:RenderBar(id, x, y, size.Y, hpPct, hpClr, barIdx)
                    barIdx = barIdx + 1
                end
                if self.Settings.ESP.ArmorBar then
                    local armPct = self.GetArmor(plr) / self.GetMaxArmor(plr)
                    self:RenderBar(id, x, y, size.Y, armPct, self.Settings.ESP.ArmorColor, barIdx)
                end

                -- Text Info Stacking
                local textY = y - 15
                if self.Settings.ESP.Names or self.Settings.ESP.Usernames then
                    local txt = self:GetDrawing(id .. "_name", "Text")
                    txt.Visible = true
                    txt.Size = self.Settings.ESP.TextSize; txt.Center = true; txt.Outline = true
                    local nameStr = ""
                    if self.Settings.ESP.Names then nameStr = plr.DisplayName end
                    if self.Settings.ESP.Usernames then nameStr = nameStr .. " (@" .. plr.Name .. ")" end
                    txt.Text = nameStr; txt.Position = Vector2.new(screenPos.X, textY); txt.Color = self.Settings.ESP.TextColor
                    textY = textY - 15
                end

                local bottomY = y + size.Y + 2
                if self.Settings.ESP.Distance then
                    local txt = self:GetDrawing(id .. "_dist", "Text")
                    txt.Visible = true; txt.Center = true; txt.Outline = true; txt.Size = self.Settings.ESP.TextSize - 2
                    txt.Text = "[" .. math.floor(dist) .. "m]"; txt.Position = Vector2.new(screenPos.X, bottomY)
                    bottomY = bottomY + 12
                end

                if self.Settings.ESP.Tool then
                    local txt = self:GetDrawing(id .. "_tool", "Text")
                    txt.Visible = true; txt.Center = true; txt.Outline = true; txt.Size = self.Settings.ESP.TextSize - 2
                    txt.Text = self.GetTool(plr); txt.Position = Vector2.new(screenPos.X, bottomY)
                    bottomY = bottomY + 12
                end

                -- Inventory/Hotbar
                local sideX = x + size.X + 5
                local sideY = y
                if self.Settings.ESP.Hotbar then
                    sideY = sideY + self:RenderInventory(id, sideX, sideY, self.GetHotbar(plr), "Hotbar")
                end
                if self.Settings.ESP.Inventory then
                    self:RenderInventory(id, sideX, sideY, self.GetInventory(plr), "Inventory")
                end
            end
        end
    end))
end

function EasyESP:Destroy()
    for _, c in ipairs(self.State.Connections or {}) do c:Disconnect() end
    for _, v in pairs(self.State.Drawings) do v:Remove() end
end

return EasyESP
