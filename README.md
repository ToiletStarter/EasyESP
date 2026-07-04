================================================================================
 EasyESP v3  -  Complete Documentation
 A Potassium-only ESP / Visuals engine for Roblox.
================================================================================

EasyESP is a single, consolidated visuals engine. Everything is driven by one
config table (esp.cfg) and a small set of methods. Turn on what you want, leave
the rest. It is built specifically for the Potassium executor and uses its
Drawing API directly (Quad, ZIndex, setrenderproperty batching, cleardrawcache,
Drawing.Fonts, the filesystem library). It will hard-error on load in any other
environment - that is intentional, and it is what lets the engine skip every
portability branch and run leaner.

TABLE OF CONTENTS
  1. Install & quick start
  2. Core methods
  3. The config tree (esp.cfg) - every field
  4. Box color modes & fades
  5. Range rings toolkit
  6. Entity ESP (any non-player object)
  7. Flags
  8. Custom draw hooks
  9. The feature toolkit (esp:register)
 10. Save / load / export
 11. Performance model
 12. Drawing primitive reference
 13. Cleanup

--------------------------------------------------------------------------------
 1. INSTALL & QUICK START
--------------------------------------------------------------------------------
    local EasyESP = loadstring(game:HttpGet(".../Main.luau"))()
    local esp = EasyESP.new():start()

    esp.cfg.enabled = true
    esp.cfg.box.on  = true
    esp.cfg.name.on = true
    esp.cfg.hp.on   = true

new() accepts an overrides table that is merged over the defaults:

    local esp = EasyESP.new({
        box = { color = Color3.fromRGB(0, 255, 180), style = "corner" },
        hp  = { side = "right" },
    })

--------------------------------------------------------------------------------
 2. CORE METHODS
--------------------------------------------------------------------------------
    EasyESP.new(overrides?) -> esp     Construct, optionally seeding cfg.
    esp:start() -> esp                 Begin the render loop (chainable).
    esp:destroy()                      Full teardown: clears the draw cache,
                                       removes chams, restores lighting/FOV,
                                       tears down modules, wipes all state.
    esp.cfg                            The live config table (section 3).

Common feature methods (detailed later):
    esp:attachRing / detachRing / clearRings
    esp:addEntity / removeEntity
    esp:addFlag / removeFlag
    esp:onDraw / removeDraw
    esp:register / unregister / toggleModule / module
    esp:save / load / configs / export / import

--------------------------------------------------------------------------------
 3. THE CONFIG TREE (esp.cfg)
--------------------------------------------------------------------------------
Everything below is a plain field you can flip or tune at runtime. Colors are
Color3, angles/speeds are numbers, on/off are booleans.

TOP LEVEL
    enabled          Master switch.
    maxRange         Studs; players past this are ignored entirely.
    refresh          Seconds between updates (0 = every frame).
    teamCheck        Skip drawing teammates.
    wallCheck        Compute line-of-sight even if nothing consumes it.
    wallHide         Hide a player entirely while occluded.
    wallColors       Recolor by line of sight (uses .visible / .hidden below).
    visible, hidden  Colors used by wallColors (top level, shared).
    rainbow          Animate the box/accent through the hue wheel.
    rainbowRate      Hue cycle speed.

perf  (see section 11)
    mode ("auto"|"manual"|"off"), playerCap, ringDetail, ballDetail,
    fxDensity, near, mid, far, labelsOnlyFar, dropFxFar, frameSkip.

box
    on               Draw the box.
    style            "2d" | "corner" | "3d" | "3dcorner".
    color            Base color (used when colorMode = "static").
    thickness        Line thickness.
    outline          Black outline behind the box.
    cornerScale      Corner bracket length as a fraction of box size.
    fill, fillColor, fillAlpha    Translucent inner fill.
    colorMode        "static" | "team" | "health" | "distance"  (section 4).
    healthFull, healthLow         Endpoints for health/distance color modes.
    distanceFade     Fade the box out as targets get far.
    fadeStart, fadeEnd            Distance range over which the fade happens.

glow      on, color, layers, spread, alpha, pulse, rate.
name      on, size, color, font, shadow, showUser.
gun       on, size, color, font, ammoAttr (attribute read for the ammo count).
dist      on, size, color, suffix.

hp        on, side ("left"|"right"), thickness, outline, full, low,
          gradient, showText, notch.
armor     on, thickness, color, attr, maxAttr  (both are player attributes).

flags     on, size, font, side ("right"|"left"), spacing, color  (section 7).

bones     on, color, thickness.
headDot   on, size, color.
gaze      on, length, color            (aim/look direction line).
tracer    on, from ("bottom"|"center"|"top"|"mouse"), color, thickness.
arrow     on, radius, size, color      (off-screen direction arrows).

hit       on, life, flash, showDmg, dmgColor.
             Flashes the box + floats damage numbers when HP drops. You can
             also trigger it yourself: esp:markHit(userId, amount).
pulse     on, threshold, color, rate   (low-HP box pulse).
trail     on, ticks, gap, color, alpha, fade  (skeleton backtrack ghost).

rings     on, onEnemies, specs = { ringSpec, ... }   (drawn at the feet).
ball      on, onEnemies, radius, rings, color, thickness, alpha, spin, fx.

fx        onEnemies + one sub-table per effect, each with .on plus its own
          fields. Effects: confetti, rain, synth, orbit, spiral, vortex, shock,
          aura, flies, bolt, helix, pulse, tornado, portal, snow, embers, radar,
          burst, ripple, beam.

self      fx (bool)     -> run the whole fx suite on YOUR character.
          rings (bool)  -> draw cfg.rings.specs at your own feet.
          trail  { on, ticks, gap, thickness, alpha, color, rainbow }
          fov    { on, radius, thickness, sides, alpha, color, rainbow,
                   fill, fillAlpha }
          cross  { on, gap, length, thickness, alpha, color, rainbow,
                   outline, dot, dotSize }
          preview{ on, x, y, w, h, fakeHp }   Live mock box drawn from YOUR
                   player + current settings so you can tune the look on screen.

chams     on, mode ("highlight"|"material"), teamCheck, depth ("top"|"occluded"),
          fill/fillColor/fillAlpha, outline/outlineColor/outlineAlpha,
          material/matColor/matAlpha/matHead, wallColors/visible/hidden,
          rainbow/rainbowRate.
          Material mode skips HumanoidRootPart and hidden parts (so it never
          leaves a block in the torso) and re-applies cleanly when you switch
          material live. Originals are restored on off / death / leave / destroy.

world     on, fullbright, fov, noFog, brightness, ambient, outdoor, exposure,
          colorGrade, saturation, contrast. Originals are captured and restored
          when you turn world off or destroy the engine.

RING SPEC (used in rings.specs and attachRing):
    radius, color, thickness, alpha,
    style ("solid"|"dashed"), shape ("circle"|"square"|"pentagon"|"hexagon"|
    "star"|"radar"), fx ("none"|"rainbow"|"breathe"),
    spin, pulse, fill, fillAlpha, glow, glowAlpha, gradient, ticks,
    tickLen, tickUp, starPoints, arc, dashGap.

--------------------------------------------------------------------------------
 4. BOX COLOR MODES & FADES
--------------------------------------------------------------------------------
box.colorMode changes how the box (and name, when wallColors is off) is tinted:
    "static"   -> box.color.
    "team"     -> the target's TeamColor.
    "health"   -> lerp healthLow -> healthFull by the target's HP fraction.
    "distance" -> lerp healthFull -> healthLow by distance / maxRange.

box.distanceFade fades box opacity from fadeStart (full) to fadeEnd (faint), so
far targets stay readable without clutter. wallColors and pulse still layer on
top of whatever colorMode picks.

--------------------------------------------------------------------------------
 5. RANGE RINGS TOOLKIT
--------------------------------------------------------------------------------
Attach a ground ring to anything. Great for your own reach/aura ranges.

    esp:attachRing(id, opt)   opt = a ring spec plus:
        preset  "killaura" | "reach" | "grab" | "neon" | "rainbow" | "target"
        target  nil (you, default) | Vector3 | Player | BasePart | Model |
                function returning a Vector3
        lift    vertical offset off the ground
    esp:detachRing(id)
    esp:clearRings()
    esp.selfRings[id]         The live ring table - tweak fields directly.

    esp:attachRing("aura",  { preset = "killaura", radius = 14 })
    esp:attachRing("enemy", { target = somePlayer, radius = 6, shape = "radar" })

cfg.rings.onEnemies additionally draws cfg.rings.specs on every enemy; cfg.self.
rings draws them on you.

--------------------------------------------------------------------------------
 6. ENTITY ESP (any non-player object)
--------------------------------------------------------------------------------
    esp:addEntity(id, {
        get      = function() return workspace.Chest end,  -- Instance | Vector3
        label    = "Chest",
        color    = Color3.fromRGB(255, 200, 0),
        box      = true,     -- 3D-projected box
        name     = true,     -- draw the label
        distance = true,     -- "42m" under it
        dot      = false,    -- dot at the top
        tracer   = false,    -- line from bottom-center of screen
        ring     = { radius = 4, color = ..., thickness = 2, glow = true },
        maxRange = 2000,
        draw     = function(self, key, pos, lx, ly, bw, bh, dist) end,  -- optional
    })
    esp:removeEntity(id)

get may return a BasePart, a Model, or a raw Vector3. Boxes/labels are computed
the same way as players. Use it for chests, drops, objectives, vehicles, nodes,
spawns - literally anything with a position.

--------------------------------------------------------------------------------
 7. FLAGS
--------------------------------------------------------------------------------
The little labels stacked beside the box. Built in: visible, flying, hp,
distance, gun, speed, sprint, frozen, god.

    esp:addFlag("ping", function(t)
        local ok, p = pcall(function() return t.plr:GetNetworkPing() end)
        return ok and p and { math.floor(p*1000).."ms",
            Color3.fromRGB(200,200,120) } or nil
    end)
    esp:removeFlag("ping")

Return { text, color } to show a flag, or nil to skip it this frame. The ctx t
has: plr, rig, root, hum, head, dist, visible, esp.

--------------------------------------------------------------------------------
 8. CUSTOM DRAW HOOKS
--------------------------------------------------------------------------------
A lightweight per-player callback that runs after the built-ins:

    esp:onDraw("tag", function(self, plr, rig, lx, ly, bw, bh, dist)
        self.pool:text("tag"..plr.UserId, "!", lx + bw/2, ly - 40, 12,
            Color3.new(1,1,1), true)
    end)
    esp:removeDraw("tag")

For anything more involved, use the full toolkit below.

--------------------------------------------------------------------------------
 9. THE FEATURE TOOLKIT (esp:register)
--------------------------------------------------------------------------------
The proper way to build a real feature. A module is a table of lifecycle hooks
that plug straight into the render loop and share the same pooled drawing API,
projection, LOD, and cleanup as everything built in.

    esp:register({
        name    = "velocity",
        enabled = true,
        state   = {},               -- your scratch; state.esp is set for you
        config  = { color = ... },  -- optional; lands on state.cfg
        setup   = function(state, esp) end,      -- once, at register time
        player  = function(state, ctx) end,      -- per on-screen player
        world   = function(state, esp) end,      -- once/frame, 3D space
        screen  = function(state, esp) end,      -- once/frame, 2D HUD
        teardown= function(state) end,           -- on unregister / destroy
    })

    esp:toggleModule("velocity", true|false|nil)  -- nil flips it
    esp:module("velocity")                         -- fetch the module
    esp:unregister("velocity")

The `player` ctx is fully populated so you never re-fetch anything:
    ctx.esp, ctx.plr, ctx.rig, ctx.root, ctx.hum, ctx.head,
    ctx.x, ctx.y, ctx.w, ctx.h       -- the screen box
    ctx.dist, ctx.visible, ctx.lod, ctx.accent, ctx.foot, ctx.key

Draw with ctx.esp.pool (line/rect/dot/text/tri/quad) or the world-space helpers.
Drawing keys are auto-recycled: whatever you stop drawing is hidden for you.

Example - velocity tag over each enemy:
    esp:register({
        name = "velocity", enabled = true, state = {},
        player = function(_, ctx)
            local mag = math.floor(ctx.root.AssemblyLinearVelocity.Magnitude)
            ctx.esp.pool:text("vel"..ctx.plr.UserId, mag.." sps",
                ctx.x + ctx.w/2, ctx.y - ctx.h - 8, 11,
                Color3.fromRGB(120,220,255), true)
        end,
    })

Example - a low-HP ground beacon on everyone (world hook):
    esp:register({
        name = "beacon", enabled = true, state = {},
        world = function(_, engine)
            for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
                local rig = plr.Character
                local hum = rig and rig:FindFirstChildOfClass("Humanoid")
                local root = rig and rig:FindFirstChild("HumanoidRootPart")
                if root and hum and hum.Health/hum.MaxHealth < 0.4 then
                    engine:worldRing("b"..plr.UserId, root.Position.X,
                        root.Position.Y-2.5, root.Position.Z, 5, 32,
                        Color3.fromRGB(255,40,40), 2, 0.8, engine.clock,
                        { glow = true })
                end
            end
        end,
    })

--------------------------------------------------------------------------------
 10. SAVE / LOAD / EXPORT  (Potassium filesystem)
--------------------------------------------------------------------------------
    esp:save(name)      Writes EasyESP/<name>.txt.
    esp:load(name)      -> true/false; merges the file into cfg.
    esp:configs()       -> { names } of saved configs.
    esp:export()        -> a serialized cfg string (share it).
    esp:import(string)  -> true/false; merges a string into cfg.

--------------------------------------------------------------------------------
 11. PERFORMANCE MODEL
--------------------------------------------------------------------------------
The engine is built to stay cheap with many players:

* Pooled drawings. A per-frame "live" set means only what stopped drawing gets
  hidden - no scrubbing the whole pool.
* Dirty-write cache on lines (the hot path: rings, skeletons, effects). If a
  line's endpoints/color/thickness/alpha did not change, no setrenderproperty
  call is made. Static boxes/skeletons cost almost nothing to keep on screen.
* project() returns raw numbers - no per-call Vector2 allocation.
* Spheres reuse cached trig and scratch points - zero per-vertex table churn.
* Players are distance-sorted; playerCap (or auto's ~24 cap) renders only the
  nearest. Off-screen, occluded, dead, far, and teammate players cull early,
  and on-screen boxes are additionally clipped to the viewport.

perf.mode:
    "off"    -> no scaling, full detail at all ranges.
    "manual" -> use the numbers below verbatim.
    "auto"   -> the numbers PLUS distance LOD and an automatic ~24 player cap.

perf fields:
    playerCap    Max fully-rendered players (0 = unlimited).
    ringDetail   Base ring segment count.
    ballDetail   Base sphere segment count.
    fxDensity    0-1 multiplier on particle counts.
    near/mid/far LOD distance thresholds.
    labelsOnlyFar  At the farthest LOD, draw only text.
    dropFxFar      At the farthest LOD, skip particle effects.
    frameSkip    Render every (frameSkip+1)th frame; 1-2 helps weak machines.

--------------------------------------------------------------------------------
 12. DRAWING PRIMITIVE REFERENCE
--------------------------------------------------------------------------------
2D (screen space), via esp.pool - keys are recycled automatically:
    pool:line(key, ax, ay, bx, by, color, thick, alpha, z)
    pool:rect(key, x, y, w, h, color, filled, thick, alpha, z)
    pool:dot(key, x, y, radius, color, filled, alpha, sides, z)
    pool:tri(key, ax, ay, bx, by, cx, cy, color, alpha, z)
    pool:quad(key, ax, ay, bx, by, cx, cy, dx, dy, color, filled, thick, alpha, z)
    pool:text(key, str, x, y, size, color, centered, font, outlined, z)

3D (world space, numeric cx,cy,cz - no Vector churn):
    esp:worldRing(key, cx, cy, cz, radius, sides, color, thick, alpha, spin, opt)
        opt = { dashed, gap, glow, glowAlpha, gradient, filled, fillAlpha }
    esp:worldPoly(key, cx, cy, cz, radius, faces, color, thick, alpha, spin)
    esp:worldStar(key, cx, cy, cz, outer, inner, points, color, thick, alpha, spin)
    esp:worldSweep(key, cx, cy, cz, radius, angle, arc, sides, color, thick, alpha)
    esp:worldBall(key, cx, cy, cz, radius, bands, sides, color, thick, alpha, spin)
    esp:worldSpark(key, wx, wy, wz, size, color, alpha)

Projection:
    esp:project(vector3) -> x, y, depth, onScreen   (depth <= 0 = behind camera)

--------------------------------------------------------------------------------
 13. CLEANUP
--------------------------------------------------------------------------------
Call esp:destroy() when unloading. It disconnects the loop, clears the Potassium
draw cache, destroys chams, restores lighting/FOV, and tears down every module.
For a soft pause just set esp.cfg.enabled = false.
================================================================================
