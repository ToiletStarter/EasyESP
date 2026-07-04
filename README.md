https://raw.githubusercontent.com/ToiletStarter/EasyESP/refs/heads/main/Main.luau

================================================================================
 EasyESP  -  Complete Documentation
 A Potassium-only ESP / Visuals engine for Roblox.
================================================================================

EasyESP is one consolidated visuals engine. Everything is driven by a single
config table (esp.cfg) plus a small, consistent set of methods. Turn on what you
want, ignore the rest. Nothing here is a black box: every drawing primitive it
uses internally is also exposed to you, so anything the built-in features can do,
your own features can do too.

--------------------------------------------------------------------------------
 CONTENTS
--------------------------------------------------------------------------------
  1.  Why Potassium only (and how it uses it)
  2.  Install & quick start
  3.  Core methods & lifecycle
  4.  The config tree (esp.cfg) - every field explained
  5.  Ranges & the performance model (what LOD does and does not touch)
  6.  Box color modes & distance fade
  7.  Range rings (yours + per-enemy) and managing multiple rings
  8.  Entity ESP - putting ESP on ANY non-player object
  9.  Flags - add / remove your own
 10.  Custom draw hooks (lightweight)
 11.  THE TOOLKIT - building full custom ESP features (esp:register)
 12.  The drawing engine - every primitive you can call
 13.  Save / load / export / import
 14.  Cleanup & unloading
 15.  Full API quick reference

================================================================================
 1. WHY POTASSIUM ONLY (AND HOW IT USES IT)
================================================================================
On the very first line the module checks for the Potassium Drawing API and
hard-errors if it is missing:

    if not Drawing or not setrenderproperty or not cleardrawcache then
        error("EasyESP requires the Potassium executor ...")
    end

This is deliberate. Because we KNOW we are on Potassium, the engine drops every
"does this function exist?" branch and calls the native API directly. Concretely
it relies on:

    Drawing.new(type)        Creates pooled drawing objects (Line, Square,
                             Circle, Triangle, Quad, Text).
    setrenderproperty(d,k,v) The batched property setter. Every visual write in
                             the hot path goes through this. On lines it is
                             paired with a per-property "dirty cache" so an
                             unchanged endpoint / color / thickness / alpha is
                             NOT re-sent to the renderer.
    cleardrawcache()         Wipes every pooled drawing in one call on destroy -
                             far cheaper than removing objects individually.
    Drawing.Fonts            The font-name -> id table (UI/System/Plex/Monospace).
    isfolder/makefolder/isfile/writefile/readfile/listfiles
                             Potassium's filesystem, used for save/load configs.
    setclipboard             Used by the example to copy an export string.

The result is a leaner render loop with no portability overhead. It will not run
on other executors by design; that guarantee is what keeps the code simple and
fast.

================================================================================
 2. INSTALL & QUICK START
================================================================================
    local EasyESP = loadstring(game:HttpGet(".../Main.luau"))()
    local esp = EasyESP.new():start()

    esp.cfg.enabled = true
    esp.cfg.box.on  = true
    esp.cfg.name.on = true
    esp.cfg.hp.on   = true

new() also accepts an overrides table that is merged over the defaults:

    local esp = EasyESP.new({
        box = { color = Color3.fromRGB(0, 255, 180), style = "corner" },
        hp  = { side = "right" },
    }):start()

================================================================================
 3. CORE METHODS & LIFECYCLE
================================================================================
    EasyESP.new(overrides?) -> esp     Construct; optionally seed cfg.
    esp:start() -> esp                 Begin the RenderStepped loop (chainable).
    esp:destroy()                      Full teardown (see section 14).
    esp.cfg                            The live config table (section 4).
    esp.clock                          Seconds since start (use it for animation
                                       in your own hooks/modules).
    esp.gunOf = function(plr) ... end  Override how the "weapon" name is resolved
                                       (return a string or nil). Defaults to the
                                       player's first Tool.

Toggling esp.cfg.enabled = false pauses all drawing/chams and restores the world
without tearing anything down; set it true again to resume.

================================================================================
 4. THE CONFIG TREE (esp.cfg)
================================================================================
Every leaf is a plain value you can change live. Colors are Color3, sizes and
speeds are numbers, on/off are booleans, choices are lowercase strings.

TOP LEVEL
    enabled       Master switch.
    espRange      Studs. The 2D HUD (box, name, health/armor bars, flags, head
                  dot, gaze line, tracer, glow) draws within this range. This is
                  NOT affected by LOD - it always renders at full quality and is
                  optimized only in the backend, so raising it stays cheap.
    maxRange      Studs. The ceiling for collecting players and for the heavy
                  world visuals (spheres, rings, effects) that ARE LOD-managed.
                  Set it >= espRange.
    refresh       Seconds between updates (0 = every frame).
    teamCheck     Skip drawing teammates.
    wallCheck     Force a line-of-sight test even if nothing consumes it.
    wallHide      Hide a player entirely while occluded.
    wallColors    Recolor box + name by line of sight (uses .visible / .hidden).
    visible,hidden  The two colors wallColors uses.
    rainbow       Animate the accent through the hue wheel.
    rainbowRate   Hue cycle speed.

perf   (see section 5)
    mode ("auto"|"manual"|"off"), playerCap, ringDetail, ballDetail,
    fxDensity, near, mid, far, dropFxFar, frameSkip.

box
    on            Draw the box.
    style         "2d" | "corner" | "3d" | "3dcorner".
    color         Base color (used when colorMode = "static").
    thickness     Line thickness.
    outline       Black outline behind the box.
    cornerScale   Corner bracket length as a fraction of the box (corner style).
    fill,fillColor,fillAlpha    Translucent inner fill.
    colorMode     "static" | "team" | "health" | "distance" (section 6).
    healthFull,healthLow        Endpoint colors for health/distance modes.
    distanceFade  Fade the box out with distance.
    fadeStart,fadeEnd           The studs range over which the fade happens.

name
    on            Show the DisplayName.
    user          Also show the username. If both on -> "DisplayName(username)";
                  if only user -> "username"; if only name -> "DisplayName".
    size,color,font,shadow.
gun    on, size, color, font, ammoAttr (attribute read for ammo count).
dist   on, size, color, font, shadow, suffix. (Styled to match name exactly.)

hp     on, side ("left"|"right"), thickness, outline, full, low, gradient,
       showText, notch.
armor  on, thickness, color, attr, maxAttr (both are player attributes).

flags  on, size, font, side ("right"|"left"), spacing, color (section 9).

bones    on, color, thickness.
headDot  on, size, color.
gaze     on, length, color              (look/aim direction line).
tracer   on, from ("bottom"|"center"|"top"|"mouse"), color, thickness.
arrow    on, radius, size, color        (off-screen direction arrows).

hit    on, life, flash, showDmg, dmgColor. Flashes the box + floats damage
       numbers when HP drops. You can also trigger it: esp:markHit(userId, n).
pulse  on, threshold, color, rate       (low-HP box pulse).
trail  on, ticks, gap, color, alpha, fade  (skeleton backtrack ghost).

rings  on, onEnemies, specs = { ringSpec, ... }  (drawn flat at the feet).
ball   on, onEnemies, radius, rings, color, thickness, alpha, spin, fx.

fx     onEnemies + a sub-table per effect, each with .on and its own fields.
       Effects: confetti, rain, synth, orbit, spiral, vortex, shock, aura,
       flies, bolt, helix, pulse, tornado, portal, snow, embers, radar, burst,
       ripple, beam.

self   fx     (bool)  run the whole fx suite on YOUR character.
       rings  (bool)  draw cfg.rings.specs at your own feet.
       trail  { on, ticks, gap, thickness, alpha, color, rainbow }
       fov    { on, radius, thickness, sides, alpha, color, rainbow,
                fill, fillAlpha }
       cross  { on, gap, length, thickness, alpha, color, rainbow, outline,
                dot, dotSize }
       preview{ on, x, y, w, h, fakeHp }  A live on-screen mock box built from
                YOUR player + current settings, so you can tune the look.

chams  on, mode ("highlight"|"material"), teamCheck, depth ("top"|"occluded"),
       fill/fillColor/fillAlpha, outline/outlineColor/outlineAlpha,
       material/matColor/matAlpha/matHead, wallColors/visible/hidden,
       rainbow/rainbowRate.
       Material mode skips HumanoidRootPart and hidden parts (never a block in
       the torso), re-applies cleanly when you switch material live, and restores
       originals on off / death / leave / destroy.

world  on, fullbright, fov, noFog, brightness, ambient, outdoor, exposure,
       colorGrade, saturation, contrast. Originals are captured and restored
       when world is turned off or the engine is destroyed.

RING SPEC (used in rings.specs, addRingSpec, and attachRing):
    radius, color, thickness, alpha,
    style ("solid"|"dashed"), shape ("circle"|"square"|"pentagon"|"hexagon"|
    "star"|"radar"), fx ("none"|"rainbow"|"breathe"),
    spin, pulse, fill, fillAlpha, glow, glowAlpha, gradient, ticks,
    tickLen, tickUp, starPoints, arc, dashGap.

================================================================================
 5. RANGES & THE PERFORMANCE MODEL
================================================================================
There are two ranges on purpose:

    espRange -> how far the 2D HUD (box/name/bars/flags/etc.) shows. This part
                is NEVER scaled by LOD. It is kept cheap purely in the backend:
                drawings are pooled and reused, and line writes skip the renderer
                when nothing changed. Crank it up freely.
    maxRange -> the ceiling for player collection and for the heavy 3D world
                visuals (spheres, rings, particle effects). These ARE the things
                LOD manages, because they are what actually costs frames.

perf.mode:
    "off"    No scaling; full detail at every distance.
    "manual" Uses the numbers below exactly.
    "auto"   The numbers PLUS automatic distance LOD and an automatic ~24
             fully-rendered-player cap.

perf fields:
    playerCap   Max fully-rendered players (0 = unlimited). Nearest first.
    ringDetail  Base segment count for rings.
    ballDetail  Base segment count for spheres.
    fxDensity   0-1 multiplier on particle counts.
    near/mid/far  Distance thresholds that pick the LOD tier for heavy visuals.
    dropFxFar   Skip particle effects at the farthest tier.
    frameSkip   Render every (frameSkip+1)th frame; 1-2 helps weak machines.

Other always-on optimizations: off-screen / behind-camera / dead / teammate
players are culled before drawing, on-screen boxes are clipped to the viewport,
projection returns raw numbers (no per-call Vector allocation), and spheres reuse
cached trig with zero per-vertex table churn.

================================================================================
 6. BOX COLOR MODES & DISTANCE FADE
================================================================================
box.colorMode changes how the box (and the name, when wallColors is off) is
tinted:
    "static"   -> box.color.
    "team"     -> the target's TeamColor.
    "health"   -> lerp healthLow -> healthFull by the target's HP fraction.
    "distance" -> lerp healthFull -> healthLow by distance / espRange.

box.distanceFade fades box opacity from fadeStart (full) to fadeEnd (faint).
wallColors and the low-HP pulse still layer on top of whatever colorMode picks.

================================================================================
 7. RANGE RINGS
================================================================================
There are two independent ring systems.

A) Your own rings (attach to anything)
    esp:attachRing(id, opt)   opt = a ring spec plus:
        preset  "killaura" | "reach" | "grab" | "neon" | "rainbow" | "target"
        target  nil (you, default) | Vector3 | Player | BasePart | Model |
                function returning a Vector3
        lift    vertical offset off the ground
    esp:detachRing(id)
    esp:clearRings()
    esp.selfRings[id]          the live ring table - tweak fields directly.

    esp:attachRing("aura",  { preset = "killaura", radius = 14 })
    esp:attachRing("enemy", { target = somePlayer, radius = 6, shape = "radar" })

B) Per-target rings (drawn on every enemy and/or on you)
    cfg.rings.on          master toggle
    cfg.rings.onEnemies   draw them on enemies
    cfg.self.rings        draw them at your own feet
    cfg.rings.specs       a list of ring specs (defaults to ONE ring)

    Manage the list with:
        esp:addRingSpec(opt?)   -> the new spec (opt overrides the defaults)
        esp:removeRingSpec(idx) -> removes that index (defaults to the last)
        esp:clearRingSpecs()    -> empties the list
    Or edit in place: esp.cfg.rings.specs[2].color = Color3.fromRGB(0,255,0)

================================================================================
 8. ENTITY ESP  (ANY non-player object)
================================================================================
Register anything with a position and it gets the same treatment as a player.

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
        draw     = function(self, key, pos, lx, ly, bw, bh, dist) end, -- optional
    })
    esp:removeEntity(id)

get may return a BasePart, a Model, or a raw Vector3. Use it for chests, drops,
objectives, vehicles, nodes, spawns - anything with a position. The optional
draw callback lets you add extra visuals on top using the pool (section 12).

================================================================================
 9. FLAGS
================================================================================
Flags are the small labels stacked beside the box. Built in: visible, flying,
hp, gun, speed, sprint, frozen, god. (Distance is its own text under the box,
not a flag.)

Add your own - return { text, color } to show it, or nil to skip it this frame:

    esp:addFlag("ping", function(t)
        local ok, p = pcall(function() return t.plr:GetNetworkPing() end)
        return ok and p and { math.floor(p*1000).."ms",
            Color3.fromRGB(200,200,120) } or nil
    end)
    esp:removeFlag("ping")

The ctx t has: plr, rig, root, hum, head, dist, visible, esp.

================================================================================
 10. CUSTOM DRAW HOOKS  (lightweight)
================================================================================
A quick per-player callback that runs after the built-ins each frame:

    esp:onDraw("tag", function(self, plr, rig, lx, ly, bw, bh, dist)
        self.pool:text("tag"..plr.UserId, "!", lx + bw/2, ly - 40, 12,
            Color3.new(1,1,1), true)
    end)
    esp:removeDraw("tag")

For anything with its own state, settings, screen HUD, or 3D world pass, use the
full toolkit below instead.

================================================================================
 11. THE TOOLKIT - BUILD FULL CUSTOM ESP FEATURES
================================================================================
This is the heart of extending EasyESP. A "module" is a table of lifecycle hooks
that plug straight into the same render loop, drawing pool, projection, LOD, and
cleanup the built-in features use. You get a real feature with almost no
boilerplate, and it is torn down automatically.

    esp:register({
        name    = "velocity",     -- unique id
        enabled = true,           -- start on/off
        state   = {},             -- your private scratch; state.esp is set for you
        config  = { color = ... },-- optional; lands on state.cfg
        setup   = function(state, esp) end,   -- once, when registered
        player  = function(state, ctx) end,   -- per on-screen player, each frame
        world   = function(state, esp) end,   -- once per frame, 3D world pass
        screen  = function(state, esp) end,   -- once per frame, 2D HUD pass
        teardown= function(state) end,        -- on unregister / destroy
    })

MANAGING MODULES (add / remove / hold / fetch)
    esp:toggleModule(name, on)   -- true / false, or nil to flip. "Hold" a
                                 -- feature off without unregistering it.
    esp:module(name)             -- get the module table (read state, etc.)
    esp:unregister(name)         -- remove it and run its teardown
    -- Re-registering the same name replaces the old one (its teardown runs first).

THE PLAYER CTX (fully populated - never re-fetch anything):
    ctx.esp                      the engine (so you can call any method)
    ctx.plr, ctx.rig, ctx.root, ctx.hum, ctx.head
    ctx.x, ctx.y, ctx.w, ctx.h   the on-screen box (top-left + size)
    ctx.dist                     distance to the target
    ctx.visible                  line-of-sight (nil unless a wall check ran)
    ctx.lod                      current LOD tier (0 near .. 3 far)
    ctx.accent                   the box's final resolved color this frame
    ctx.foot                     Vector3 at the target's feet (for ground rings)
    ctx.key                      the target's unique drawing-key prefix

DRAWING FROM A MODULE
Use ctx.esp.pool for 2D and the world-space helpers for 3D (section 12). Keys are
recycled for you - whatever you stop drawing is hidden automatically, so you
never manage visibility manually. Give each drawing a stable key, usually keyed
off the player so multiple targets do not collide:

    ctx.esp.pool:text("myvel"..ctx.plr.UserId, "...", ctx.x, ctx.y, 12, col, true)

EXAMPLE A - velocity tag above every enemy (player hook):
    esp:register({
        name = "velocity", enabled = true, state = {},
        player = function(_, ctx)
            local mag = math.floor(ctx.root.AssemblyLinearVelocity.Magnitude)
            ctx.esp.pool:text("vel"..ctx.plr.UserId, mag.." sps",
                ctx.x + ctx.w/2, ctx.y - ctx.h - 8, 11,
                Color3.fromRGB(120,220,255), true)
        end,
    })

EXAMPLE B - a ground beacon under every low-HP player (world hook):
    esp:register({
        name = "beacon", enabled = true, state = {},
        world = function(_, engine)
            for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
                local rig  = plr.Character
                local hum  = rig and rig:FindFirstChildOfClass("Humanoid")
                local root = rig and rig:FindFirstChild("HumanoidRootPart")
                if root and hum and hum.Health/hum.MaxHealth < 0.4 then
                    engine:worldRing("beacon"..plr.UserId,
                        root.Position.X, root.Position.Y-2.5, root.Position.Z,
                        5, 32, Color3.fromRGB(255,40,40), 2, 0.8, engine.clock,
                        { glow = true })
                end
            end
        end,
    })

EXAMPLE C - a compass letter at the top of the screen (screen hook):
    esp:register({
        name = "compass", enabled = true, state = {},
        screen = function(_, engine)
            local vp = workspace.CurrentCamera.ViewportSize
            engine.pool:text("compass", "N", vp.X/2, 20, 16,
                Color3.new(1,1,1), true)
        end,
    })

EXAMPLE D - a module that carries its own settings and state:
    esp:register({
        name = "beam", enabled = true,
        config = { color = Color3.fromRGB(120,200,255), height = 20 },
        state = {},
        world = function(state, engine)
            local c = state.cfg
            for _, plr in ipairs(game:GetService("Players"):GetPlayers()) do
                local root = plr.Character and plr.Character:FindFirstChild("HumanoidRootPart")
                if root then
                    local p = root.Position
                    local ax, ay, ad = engine:project(p)
                    local bx, by, bd = engine:project(p + Vector3.new(0, c.height, 0))
                    if ad > 0 and bd > 0 then
                        engine.pool:line("beam"..plr.UserId, ax, ay, bx, by, c.color, 2, 0.6)
                    end
                end
            end
        end,
    })
    -- later: esp:module("beam").state.cfg.color = Color3.fromRGB(255,0,0)

================================================================================
 12. THE DRAWING ENGINE - EVERY PRIMITIVE YOU CAN CALL
================================================================================
Everything the engine draws is available to you. Keys are strings; reuse the same
key each frame and the underlying drawing is recycled, so you never create or
hide objects yourself.

2D, screen space (via esp.pool):
    pool:line(key, ax, ay, bx, by, color, thick, alpha, z)
    pool:rect(key, x, y, w, h, color, filled, thick, alpha, z)
    pool:dot(key, x, y, radius, color, filled, alpha, sides, z)
    pool:tri(key, ax, ay, bx, by, cx, cy, color, alpha, z)
    pool:quad(key, ax, ay, bx, by, cx, cy, dx, dy, color, filled, thick, alpha, z)
    pool:text(key, str, x, y, size, color, centered, font, outlined, z)
    (z = ZIndex, optional. font accepts a Drawing.Fonts id.)

3D, world space (numeric cx,cy,cz - no Vector allocation):
    esp:worldRing(key, cx, cy, cz, radius, sides, color, thick, alpha, spin, opt)
        opt = { dashed, gap, glow, glowAlpha, gradient, filled, fillAlpha }
    esp:worldPoly(key, cx, cy, cz, radius, faces, color, thick, alpha, spin)
    esp:worldStar(key, cx, cy, cz, outer, inner, points, color, thick, alpha, spin)
    esp:worldSweep(key, cx, cy, cz, radius, angle, arc, sides, color, thick, alpha)
    esp:worldBall(key, cx, cy, cz, radius, bands, sides, color, thick, alpha, spin)
    esp:worldSpark(key, wx, wy, wz, size, color, alpha)  -> true if on screen

Projection:
    esp:project(vector3) -> x, y, depth, onScreen
        depth <= 0 means the point is behind the camera; skip drawing it.

Animate anything with esp.clock (seconds). Example - a pulsing dot:
    local a = 0.5 + 0.5 * math.sin(esp.clock * 4)
    esp.pool:dot("k", x, y, 4, Color3.new(1,1,1), true, a)

================================================================================
 13. SAVE / LOAD / EXPORT / IMPORT  (Potassium filesystem)
================================================================================
    esp:save(name)      Writes EasyESP/<name>.txt.
    esp:load(name)      -> true/false; merges the file into cfg.
    esp:configs()       -> { names } of saved configs.
    esp:export()        -> a serialized cfg string you can share.
    esp:import(string)  -> true/false; merges a string into cfg.

Colors, nested tables, numbers, strings and booleans all round-trip. import and
load MERGE, so a partial config only overrides the keys it contains.

================================================================================
 14. CLEANUP & UNLOADING
================================================================================
Call esp:destroy() when your script unloads. It:
    * disconnects the render loop and the PlayerRemoving connection,
    * runs teardown on every registered module,
    * clears the entire Potassium draw cache in one call,
    * destroys all chams and restores material-cham parts,
    * restores the original lighting / FOV / fog,
    * wipes all internal state (rings, entities, flags, modules, caches).

For a soft pause that keeps everything registered, just set
esp.cfg.enabled = false.

================================================================================
 15. FULL API QUICK REFERENCE
================================================================================
Lifecycle:      new, start, destroy
Config:         esp.cfg (section 4), esp.clock, esp.gunOf
Rings (yours):  attachRing, detachRing, clearRings, esp.selfRings
Rings (list):   addRingSpec, removeRingSpec, clearRingSpecs
Entities:       addEntity, removeEntity
Flags:          addFlag, removeFlag
Draw hooks:     onDraw, removeDraw
Toolkit:        register, unregister, toggleModule, module
Combat:         markHit
Config files:   save, load, configs, export, import
2D drawing:     esp.pool:line/rect/dot/tri/quad/text
3D drawing:     worldRing/worldPoly/worldStar/worldSweep/worldBall/worldSpark
Projection:     project
================================================================================
