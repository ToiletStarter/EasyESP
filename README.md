EasyESP

Version: 3.3.0

EasyESP is a powerful, high-performance ESP (Extra Sensory Perception) library for Roblox. Built on the Drawing API, it provides a complete suite of visual overlays, player tracking, radar systems, visual effects, and advanced customization options.

Designed for both competitive and cinematic experiences, EasyESP offers extensive configuration, performance profiles, themes, and an extensible module system.
Features

    Core ESP Elements
        2D/3D Boxes (corner, 3D, filled)
        Player names & display names
        Health bars (gradient, side placement, notches)
        Armor bars
        Distance indicators
        Tracers (bottom, center, top, mouse)
        Head dots & gaze lines
        Bones / skeletons
        Team colors & health-based coloring

    Advanced Visuals
        Radar (mini-map with names, allies, rotation)
        Player list with health/distance/visibility
        Threat indicator
        Target system with FOV circle, snaplines, brackets
        Off-screen arrows
        Beacons & world lines
        Proximity rings
        View cones
        Foot arrows

    Special Effects
        15+ particle-style FX (confetti, rain, synth, orbit, spiral, vortex, shock, aura, flies, bolt, helix, pulse, tornado, portal, snow, embers, radar sweep, burst, ripple, beam)
        Self rings & trails
        Hit markers & damage numbers
        Pulse & rainbow effects
        Glow layers

    Chams & World
        Highlight & material chams
        Fullbright, no-fog, FOV override
        Color correction (saturation, contrast)
        Wall color differentiation

    Performance & Quality
        Automatic LOD system
        Frame skipping
        Pooling & pruning
        Player caps
        Multiple performance profiles (potato → insane)

    Customization
        12+ built-in themes
        Feature packs (competitive, cinematic, world, stealth, streamer)
        Presets & config import/export
        Full config serialization
        Friend highlighting
        Custom entities & NPC scanning

    Extensibility
        Module registration system
        Custom flag providers
        Tag hooks
        Toolkit utilities

Installation

    Require the library in your script:

    Lua

    local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/yourusername/EasyESP/main/EasyESP.lua"))()

    Create an instance:

    Lua

    local esp = ESP.new()
    esp:start()

Quick Start

Lua

local ESP = loadstring(game:HttpGet("..."))()

local esp = ESP.new({
    enabled = true,
    box = { on = true, style = "corner" },
    name = { on = true },
    hp = { on = true }
})

esp:start()

Main API
ESP.new(overrides?)

Creates a new ESP instance.

Parameters:

    overrides (table, optional): Initial configuration overrides

Returns: ESP instance
Instance Methods
Method	Description
start()	Starts the ESP loop
stop()	Stops the ESP loop (preserves config)
destroy()	Fully cleans up the instance
setEnabled(state)	Enables/disables ESP
toggle()	Toggles enabled state
tick(dt)	Manual tick (usually called internally)
Configuration Access

All settings live under esp.cfg:

Lua

esp.cfg.box.on = true
esp.cfg.name.size = 14
esp.cfg.radar.on = true

Configuration Sections
box

    on, style ("corner" | "3d" | "3dcorner"), color, thickness, outline, cornerScale
    fill, fillColor, fillAlpha
    colorMode ("static" | "team" | "health" | "distance")
    distanceFade, fadeStart, fadeEnd

name

    on, user (show username), size, color, font, shadow

hp

    on, side ("left" | "right"), thickness, outline
    full, low, gradient, showText, showPercent, notch

radar

    on, x, y, radius, range, rotate
    background, grid, border, names
    enemyColor, allyColor, friendColor, selfColor
    blipSize, maxBlips, showAllies

target

    on, fov, showFov, visibleOnly
    includeFriends, includeAllies
    color, friendColor, allyColor
    brackets, snapline, label, health, distance

list

    on, x, y, width, max, rowHeight
    background, title, showAllies
    health, distance, visible, index

fx

    onEnemies
    Multiple FX toggles and parameters (confetti, rain, synth, orbit, etc.)

self

    fx, rings, trail, fov, cross, preview, watermark, compass

chams

    on, mode ("highlight" | "material"), teamCheck
    fill, outline, material, wallColors
    visible, hidden, rainbow

world

    on, fullbright, fov, noFog
    brightness, ambient, exposure
    colorGrade, saturation, contrast

Performance Profiles

Apply via esp:applyPerformance(name):

    potato
    low
    balanced
    high
    insane

Themes

Apply via esp:applyTheme(name):

    void, carbon, rose, ocean, solar, matrix, blood, ice, gold, mono, grape, mint

Feature Packs

Apply via esp:applyFeaturePack(name):

    competitive
    cinematic
    world
    stealth
    streamer

Presets

Lua

esp:applyPreset("visual")
esp:applyPreset("minimal")
esp:applyPreset("performance")

Custom Entities

Lua

esp:addEntity("myEntity", {
    get = function() return workspace.Part end,
    label = "Special Object",
    box = true,
    name = true,
    distance = true
})

Modules & Extensions

Register custom modules:

Lua

esp:register({
    name = "myModule",
    enabled = true,
    player = function(state, ctx)
        -- ctx contains: plr, rig, x, y, w, h, dist, accent, etc.
    end,
    world = function(state, ctx) end,
    screen = function(state, ctx) end
})

Flags

Add custom status flags:

Lua

esp:addFlag("custom", function(ctx)
    if ctx.plr.Name == "Example" then
        return {"VIP", Color3.fromRGB(255, 215, 0)}
    end
end)

Toolkit

Access via ESP.Toolkit:

    clone(), merge(), fill()
    Color helpers (color(), hsv(), rainbow())
    Entity & module builders
    quickESP(), showcase(), competitive()

Scanning Utilities

Lua

esp:scanNPCs()
esp:scanTools()
esp:scanPickups()
esp:scanInstances(workspace, { names = {"Key", "Door"} })

Statistics

Lua

local stats = esp:getStats()
print(stats.drawn, stats.fps, stats.poolSize)

Full Configuration Export

Lua

local configString = esp:export()
esp:import(configString)
esp:save("MyConfig")
esp:load("MyConfig")

Best Practices

    Use performance profiles for different hardware
    Enable perf.dropFxFar on lower-end devices
    Use wallCheck + wallHide for competitive setups
    Leverage friendHighlight for team play
    Combine with EasyUI for a full menu system
