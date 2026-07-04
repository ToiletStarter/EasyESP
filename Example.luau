local UI_URL  = "https://raw.githubusercontent.com/ToiletStarter/EasyUICall/refs/heads/main/ui"
local ESP_URL = "https://raw.githubusercontent.com/ToiletStarter/EasyESP/refs/heads/main/Main.luau"

local function fetch(label, url)
	local ok, body = pcall(game.HttpGet, game, url)
	if not ok or type(body) ~= "string" or #body == 0 then
		error(("[%s] download failed: %s"):format(label, tostring(body)), 0)
	end
	local chunk, err = loadstring(body)
	if not chunk then error(("[%s] compile failed: %s"):format(label, tostring(err)), 0) end
	local built = chunk()
	assert(built ~= nil, "[" .. label .. "] returned nil")
	return built
end

local EasyUI  = fetch("EasyUI", UI_URL)
local EasyESP = fetch("EasyESP", ESP_URL)

local esp = EasyESP.new():start()
local cfg = esp.cfg

local UI = EasyUI.new({
	Title     = "EasyESP",
	Theme     = "Midnight",
	Accent    = Color3.fromRGB(190, 70, 235),
	MenuKey   = Enum.KeyCode.LeftAlt,
	Signature = "EasyESP",
	PanelMaxHeight = 480,
})

local session = { alive = true, conns = {} }
function session:kill()
	if not self.alive then return end
	self.alive = false
	for _, c in ipairs(self.conns) do
		if c and c.Connected then pcall(function() c:Disconnect() end) end
	end
	esp:destroy()
	UI:Destroy()
end

local general = UI:CreatePanel("General", { Width = 240, Open = true })
general:AddToggle("Enabled", cfg.enabled, function(on)
	cfg.enabled = on
	UI:Toast("EasyESP", on and "On" or "Off", 2, on and "ok" or "warn")
end)
general:AddSlider("ESP Range", 100, 5000, cfg.espRange, 0, function(n) cfg.espRange = n end)
general:AddSlider("World/Max Range", 100, 5000, cfg.maxRange, 0, function(n) cfg.maxRange = n end)
general:AddSlider("Refresh (ms)", 0, 100, cfg.refresh * 1000, 0, function(n) cfg.refresh = n / 1000 end)
general:AddToggle("Team Check", cfg.teamCheck, function(x) cfg.teamCheck = x end)
general:AddToggle("Wall Check (hide occluded)", cfg.wallHide, function(x) cfg.wallHide = x end)
general:AddToggle("Wall Colors", cfg.wallColors, function(x) cfg.wallColors = x end)
general:AddToggle("Rainbow", cfg.rainbow, function(x) cfg.rainbow = x end)
general:AddSlider("Rainbow Rate", 0, 10, cfg.rainbowRate, 1, function(x) cfg.rainbowRate = x end)
general:AddButton("Unload", function() session:kill() end, true)

local box = UI:CreatePanel("Box & Text", { Width = 260, Open = true })
box:AddToggle("Box", cfg.box.on, function(x) cfg.box.on = x end)
box:AddDropdown("Style", { "2d", "corner", "3d", "3dcorner" }, cfg.box.style, function(s) cfg.box.style = s end)
box:AddDropdown("Color Mode", { "static", "team", "health", "distance" }, cfg.box.colorMode, function(s) cfg.box.colorMode = s end)
box:AddToggle("Outline", cfg.box.outline, function(x) cfg.box.outline = x end)
box:AddToggle("Fill", cfg.box.fill, function(x) cfg.box.fill = x end)
box:AddSlider("Fill Alpha", 0, 1, cfg.box.fillAlpha, 2, function(n) cfg.box.fillAlpha = n end)
box:AddSlider("Thickness", 1, 5, cfg.box.thickness, 0, function(n) cfg.box.thickness = n end)
box:AddSlider("Corner Scale", 0.1, 0.5, cfg.box.cornerScale, 2, function(n) cfg.box.cornerScale = n end)
box:AddToggle("Distance Fade", cfg.box.distanceFade, function(x) cfg.box.distanceFade = x end)
box:AddColorPicker("Box Color", cfg.box.color, function(c) cfg.box.color = c end)

box:AddSeparator("Text")
box:AddToggle("Name", cfg.name.on, function(x) cfg.name.on = x end)
box:AddToggle("Username", cfg.name.user, function(x) cfg.name.user = x end)
box:AddToggle("Name Shadow", cfg.name.shadow, function(x) cfg.name.shadow = x end)
box:AddSlider("Name Size", 8, 22, cfg.name.size, 0, function(n) cfg.name.size = n end)
box:AddColorPicker("Name Color", cfg.name.color, function(c) cfg.name.color = c end)
box:AddToggle("Weapon + Ammo", cfg.gun.on, function(x) cfg.gun.on = x end)
box:AddToggle("Distance", cfg.dist.on, function(x) cfg.dist.on = x end)

box:AddSeparator("Glow")
box:AddToggle("Glow", cfg.glow.on, function(x) cfg.glow.on = x end)
box:AddToggle("Glow Pulse", cfg.glow.pulse, function(x) cfg.glow.pulse = x end)
box:AddSlider("Glow Layers", 1, 8, cfg.glow.layers, 0, function(n) cfg.glow.layers = n end)
box:AddSlider("Glow Alpha", 0, 0.5, cfg.glow.alpha, 2, function(n) cfg.glow.alpha = n end)
box:AddColorPicker("Glow Color", cfg.glow.color, function(c) cfg.glow.color = c end)

local lines = UI:CreatePanel("Lines & Bars", { Width = 250, Open = false })
lines:AddToggle("Skeleton", cfg.bones.on, function(x) cfg.bones.on = x end)
lines:AddColorPicker("Skeleton Color", cfg.bones.color, function(c) cfg.bones.color = c end)
lines:AddToggle("Head Dot", cfg.headDot.on, function(x) cfg.headDot.on = x end)
lines:AddToggle("Gaze Line", cfg.gaze.on, function(x) cfg.gaze.on = x end)
lines:AddToggle("Tracer", cfg.tracer.on, function(x) cfg.tracer.on = x end)
lines:AddDropdown("Tracer From", { "bottom", "center", "top", "mouse" }, cfg.tracer.from, function(s) cfg.tracer.from = s end)
lines:AddColorPicker("Tracer Color", cfg.tracer.color, function(c) cfg.tracer.color = c end)
lines:AddToggle("Off-Screen Arrows", cfg.arrow.on, function(x) cfg.arrow.on = x end)

lines:AddSeparator("Bars")
lines:AddToggle("Health Bar", cfg.hp.on, function(x) cfg.hp.on = x end)
lines:AddDropdown("HP Side", { "left", "right" }, cfg.hp.side, function(s) cfg.hp.side = s end)
lines:AddToggle("HP Gradient", cfg.hp.gradient, function(x) cfg.hp.gradient = x end)
lines:AddToggle("HP Notch", cfg.hp.notch, function(x) cfg.hp.notch = x end)
lines:AddToggle("HP Text", cfg.hp.showText, function(x) cfg.hp.showText = x end)
lines:AddToggle("Armor Bar", cfg.armor.on, function(x) cfg.armor.on = x end)

lines:AddSeparator("Flags")
lines:AddToggle("Flags", cfg.flags.on, function(x) cfg.flags.on = x end)
lines:AddDropdown("Flags Side", { "right", "left" }, cfg.flags.side, function(s) cfg.flags.side = s end)
lines:AddSlider("Flags Size", 8, 16, cfg.flags.size, 0, function(n) cfg.flags.size = n end)

lines:AddSeparator("Combat")
lines:AddToggle("Hit Markers", cfg.hit.on, function(x) cfg.hit.on = x end)
lines:AddToggle("Low HP Pulse", cfg.pulse.on, function(x) cfg.pulse.on = x end)
lines:AddToggle("Backtrack Trail", cfg.trail.on, function(x) cfg.trail.on = x end)
lines:AddSlider("Backtrack Ticks", 2, 20, cfg.trail.ticks, 0, function(n) cfg.trail.ticks = n end)

local worldTab = UI:CreatePanel("World Visuals", { Width = 260, Open = false })
worldTab:AddSeparator("Range Rings")
worldTab:AddToggle("Rings On Enemies", cfg.rings.onEnemies, function(x) cfg.rings.on = x cfg.rings.onEnemies = x end)
worldTab:AddToggle("Rings On Me", cfg.self.rings, function(x) cfg.self.rings = x end)

local ringIdx = 1
local function ring() return cfg.rings.specs[ringIdx] end
worldTab:AddSlider("Editing Ring #", 1, 8, 1, 0, function(n)
	ringIdx = math.clamp(math.floor(n), 1, #cfg.rings.specs)
end)
worldTab:AddButton("Add Ring", function()
	esp:addRingSpec({ radius = 8, color = Color3.fromRGB(90, 200, 255) })
	ringIdx = #cfg.rings.specs
	UI:Toast("EasyESP", "Ring " .. ringIdx .. " added", 2, "ok")
end)
worldTab:AddButton("Remove Current Ring", function()
	if #cfg.rings.specs > 1 then
		esp:removeRingSpec(ringIdx)
		ringIdx = math.clamp(ringIdx, 1, #cfg.rings.specs)
	end
end)
worldTab:AddDropdown("Ring Shape", { "circle", "square", "pentagon", "hexagon", "star", "radar" }, ring().shape, function(s) local r = ring(); if r then r.shape = s end end)
worldTab:AddDropdown("Ring Style", { "solid", "dashed" }, ring().style, function(s) local r = ring(); if r then r.style = s end end)
worldTab:AddDropdown("Ring FX", { "none", "rainbow", "breathe" }, ring().fx, function(s) local r = ring(); if r then r.fx = s end end)
worldTab:AddSlider("Ring Radius", 1, 40, ring().radius, 0, function(n) local r = ring(); if r then r.radius = n end end)
worldTab:AddSlider("Ring Thickness", 1, 6, ring().thickness, 0, function(n) local r = ring(); if r then r.thickness = n end end)
worldTab:AddSlider("Ring Spin", 0, 3, ring().spin, 1, function(n) local r = ring(); if r then r.spin = n end end)
worldTab:AddToggle("Ring Glow", ring().glow, function(x) local r = ring(); if r then r.glow = x end end)
worldTab:AddToggle("Ring Pulse", ring().pulse, function(x) local r = ring(); if r then r.pulse = x end end)
worldTab:AddToggle("Ring Fill", ring().fill, function(x) local r = ring(); if r then r.fill = x end end)
worldTab:AddSlider("Ring Ticks", 0, 24, ring().ticks, 0, function(n) local r = ring(); if r then r.ticks = math.floor(n) end end)
worldTab:AddColorPicker("Ring Color", ring().color, function(c) local r = ring(); if r then r.color = c end end)

worldTab:AddSeparator("Sphere")
worldTab:AddToggle("Sphere On Enemies", cfg.ball.onEnemies, function(x) cfg.ball.on = x cfg.ball.onEnemies = x end)
worldTab:AddSlider("Sphere Radius", 2, 30, cfg.ball.radius, 0, function(n) cfg.ball.radius = n end)
worldTab:AddSlider("Sphere Bands", 2, 12, cfg.ball.rings, 0, function(n) cfg.ball.rings = n end)
worldTab:AddSlider("Sphere Spin", 0, 3, cfg.ball.spin, 1, function(n) cfg.ball.spin = n end)
worldTab:AddColorPicker("Sphere Color", cfg.ball.color, function(c) cfg.ball.color = c end)

local mine = UI:CreatePanel("My Player", { Width = 250, Open = true })
mine:AddLabel("Effects & rings on YOU (also enemies below)")
mine:AddToggle("Effects On Me", cfg.self.fx, function(x) cfg.self.fx = x end)
mine:AddToggle("Also On Enemies", cfg.fx.onEnemies, function(x) cfg.fx.onEnemies = x end)
mine:AddSlider("FX Density", 0.1, 1, cfg.perf.fxDensity, 2, function(n) cfg.perf.fxDensity = n end)

mine:AddSeparator("Effects")
local fxList = {
	{ "Confetti", "confetti" }, { "Rain", "rain" }, { "Synth", "synth" }, { "Orbit", "orbit" },
	{ "Spiral", "spiral" }, { "Vortex", "vortex" }, { "Shockwave", "shock" }, { "Aura", "aura" },
	{ "Fireflies", "flies" }, { "Lightning", "bolt" }, { "Helix", "helix" }, { "Heartbeat", "pulse" },
	{ "Tornado", "tornado" }, { "Portal", "portal" }, { "Snow", "snow" }, { "Embers", "embers" },
	{ "Radar", "radar" }, { "Star Burst", "burst" }, { "Ripple", "ripple" }, { "Beam", "beam" },
}
for _, fx in ipairs(fxList) do
	mine:AddToggle(fx[1], cfg.fx[fx[2]].on, function(x) cfg.fx[fx[2]].on = x end)
end

mine:AddSeparator("Ring On Me")
mine:AddToggle("Enable", false, function(on)
	if on then esp:attachRing("me", { preset = "killaura", radius = 14 }) else esp:detachRing("me") end
end)
mine:AddDropdown("Preset", { "killaura", "reach", "grab", "neon", "rainbow", "target" }, "killaura", function(p)
	esp:attachRing("me", { preset = p })
	UI:Toast("EasyESP", "Preset: " .. p, 2, "accent")
end)
mine:AddSlider("Radius", 1, 40, 14, 0, function(n) local r = esp.selfRings.me; if r then r.radius = n end end)
mine:AddDropdown("Shape", { "circle", "square", "hexagon", "star", "radar" }, "circle", function(s) local r = esp.selfRings.me; if r then r.shape = s end end)
mine:AddColorPicker("Color", cfg.box.color, function(c) local r = esp.selfRings.me; if r then r.color = c end end)

mine:AddSeparator("HUD")
mine:AddToggle("Movement Trail", cfg.self.trail.on, function(x) cfg.self.trail.on = x end)
mine:AddToggle("FOV Circle", cfg.self.fov.on, function(x) cfg.self.fov.on = x end)
mine:AddSlider("FOV Radius", 20, 400, cfg.self.fov.radius, 0, function(n) cfg.self.fov.radius = n end)
mine:AddToggle("Crosshair", cfg.self.cross.on, function(x) cfg.self.cross.on = x end)
mine:AddToggle("Crosshair Dot", cfg.self.cross.dot, function(x) cfg.self.cross.dot = x end)
mine:AddToggle("ESP Preview", cfg.self.preview.on, function(x) cfg.self.preview.on = x end)
mine:AddSlider("Preview X", 0, 1200, cfg.self.preview.x, 0, function(n) cfg.self.preview.x = n end)

local perf = UI:CreatePanel("Performance", { Width = 240, Open = false })
perf:AddDropdown("Quality", { "auto", "manual", "off" }, cfg.perf.mode, function(m) cfg.perf.mode = m end)
perf:AddSlider("Player Cap (0=all)", 0, 40, cfg.perf.playerCap, 0, function(n) cfg.perf.playerCap = n end)
perf:AddSlider("Ring Detail", 8, 96, cfg.perf.ringDetail, 0, function(n) cfg.perf.ringDetail = n end)
perf:AddSlider("Sphere Detail", 6, 48, cfg.perf.ballDetail, 0, function(n) cfg.perf.ballDetail = n end)
perf:AddSlider("Frame Skip", 0, 4, cfg.perf.frameSkip, 0, function(n) cfg.perf.frameSkip = n end)
perf:AddSlider("LOD Near", 40, 300, cfg.perf.near, 0, function(n) cfg.perf.near = n end)
perf:AddSlider("LOD Mid", 150, 600, cfg.perf.mid, 0, function(n) cfg.perf.mid = n end)
perf:AddSlider("LOD Far", 400, 1500, cfg.perf.far, 0, function(n) cfg.perf.far = n end)
perf:AddToggle("Drop FX Far", cfg.perf.dropFxFar, function(x) cfg.perf.dropFxFar = x end)

local cham = UI:CreatePanel("Chams & World", { Width = 240, Open = false })
cham:AddToggle("Chams", cfg.chams.on, function(x) cfg.chams.on = x end)
cham:AddDropdown("Mode", { "highlight", "material" }, cfg.chams.mode, function(s) cfg.chams.mode = s end)
cham:AddDropdown("Depth", { "top", "occluded" }, cfg.chams.depth, function(s) cfg.chams.depth = s end)
cham:AddToggle("Fill", cfg.chams.fill, function(x) cfg.chams.fill = x end)
cham:AddSlider("Fill Transparency", 0, 1, cfg.chams.fillAlpha, 2, function(n) cfg.chams.fillAlpha = n end)
cham:AddColorPicker("Fill Color", cfg.chams.fillColor, function(c) cfg.chams.fillColor = c end)
cham:AddToggle("Outline", cfg.chams.outline, function(x) cfg.chams.outline = x end)
cham:AddColorPicker("Outline Color", cfg.chams.outlineColor, function(c) cfg.chams.outlineColor = c end)
cham:AddToggle("Rainbow", cfg.chams.rainbow, function(x) cfg.chams.rainbow = x end)
cham:AddDropdown("Material", { "ForceField", "Neon", "Glass", "Metal", "Ice", "Plastic", "Wood", "Marble" }, cfg.chams.material, function(s) cfg.chams.material = s end)
cham:AddToggle("Team Check", cfg.chams.teamCheck, function(x) cfg.chams.teamCheck = x end)

cham:AddSeparator("World")
cham:AddToggle("World", cfg.world.on, function(x) cfg.world.on = x end)
cham:AddToggle("Fullbright", cfg.world.fullbright, function(x) cfg.world.fullbright = x end)
cham:AddToggle("No Fog", cfg.world.noFog, function(x) cfg.world.noFog = x end)
cham:AddSlider("Brightness", 0, 5, cfg.world.brightness, 1, function(n) cfg.world.brightness = n end)
cham:AddSlider("FOV", 40, 120, cfg.world.fov, 0, function(n) cfg.world.fov = n end)
cham:AddToggle("Color Grade", cfg.world.colorGrade, function(x) cfg.world.colorGrade = x end)
cham:AddSlider("Saturation", -1, 3, cfg.world.saturation, 2, function(n) cfg.world.saturation = n end)

local kit = UI:CreatePanel("Toolkit & Entities", { Width = 250, Open = false })
kit:AddLabel("Custom features via esp:register{...}")

esp:register({
	name = "velocity",
	enabled = false,
	state = {},
	player = function(_, ctx)
		if not ctx.root then return end
		local speed = math.floor(ctx.root.AssemblyLinearVelocity.Magnitude + 0.5)
		ctx.esp.pool:text("vel" .. ctx.plr.UserId, speed .. " sps", ctx.x + ctx.w / 2, ctx.y - ctx.h - 8, 11, Color3.fromRGB(120, 220, 255), true)
	end,
})

esp:register({
	name = "lowhp_beacon",
	enabled = false,
	state = {},
	world = function(_, engine)
		for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
			local rig = plr.Character
			local hum = rig and rig:FindFirstChildOfClass("Humanoid")
			local root = rig and rig:FindFirstChild("HumanoidRootPart")
			if root and hum and hum.Health > 0 and hum.Health / hum.MaxHealth < 0.4 then
				engine:worldRing("beacon" .. plr.UserId, root.Position.X, root.Position.Y - 2.5, root.Position.Z, 5, 32, Color3.fromRGB(255, 40, 40), 2, 0.8, engine.clock, { glow = true })
			end
		end
	end,
})

esp:register({
	name = "compass",
	enabled = false,
	state = {},
	screen = function(_, engine)
		local vp = workspace.CurrentCamera.ViewportSize
		engine.pool:text("compass", "N", vp.X / 2, 20, 16, Color3.fromRGB(255, 255, 255), true)
	end,
})

kit:AddToggle("Velocity Tag (module)", false, function(x) esp:toggleModule("velocity", x) end)
kit:AddToggle("Low-HP Beacon (module)", false, function(x) esp:toggleModule("lowhp_beacon", x) end)
kit:AddToggle("Compass HUD (module)", false, function(x) esp:toggleModule("compass", x) end)

kit:AddSeparator("Custom Flags")
kit:AddButton("Add Ping Flag", function()
	esp:addFlag("ping", function(t)
		local ok, p = pcall(function() return t.plr:GetNetworkPing() end)
		return ok and p and { math.floor(p * 1000) .. "ms", Color3.fromRGB(200, 200, 120) } or nil
	end)
	UI:Toast("EasyESP", "Ping flag added", 3, "ok")
end)

kit:AddSeparator("Entity ESP")
kit:AddButton("Track 'Chest' In Workspace", function()
	esp:addEntity("chest", {
		get = function() return workspace:FindFirstChild("Chest") end,
		label = "Chest", distance = true, dot = true,
		color = Color3.fromRGB(255, 200, 0),
		ring = { radius = 4, color = Color3.fromRGB(255, 200, 0), thickness = 2, glow = true, spin = 0.5 },
	})
	UI:Toast("EasyESP", "Now tracking workspace.Chest", 3, "accent")
end)
kit:AddButton("Beacon At Origin (Vector3)", function()
	esp:addEntity("origin", {
		get = function() return Vector3.new(0, 5, 0) end,
		label = "Origin", distance = true, tracer = true,
		color = Color3.fromRGB(0, 255, 140),
	})
	UI:Toast("EasyESP", "Beacon added at 0,5,0", 3, "accent")
end)

local store = UI:CreatePanel("Config", { Width = 240, Open = false })
local slot = "default"
store:AddTextBox("Config Name", slot, "name", function(txt) slot = txt ~= "" and txt or "default" end)
store:AddButton("Save", function()
	esp:save(slot)
	UI:Toast("EasyESP", "Saved '" .. slot .. "'", 3, "ok")
end)
store:AddButton("Load", function()
	if esp:load(slot) then UI:Toast("EasyESP", "Loaded '" .. slot .. "'", 3, "ok")
	else UI:Toast("EasyESP", "No config '" .. slot .. "'", 3, "err") end
end)
store:AddButton("Copy Export String", function()
	if setclipboard then setclipboard(esp:export()) end
	UI:Toast("EasyESP", "Config copied to clipboard", 3, "ok")
end)

table.insert(session.conns, UI.gui.Destroying:Connect(function() session:kill() end))
UI:Toast("EasyESP", "Loaded. LeftAlt to toggle.", 5, "ok")
