================================================================================
                         E a s y E S P   v 3 . 2 . 0
                        Complete Documentation
================================================================================

  A high-performance, feature-rich ESP library
  for the Potassium Roblox executor. Uses the Drawing API with an
  optimised object-pool renderer and dirty-flag caching.

  Loadstring:
    loadstring(game:HttpGet("https://raw.githubusercontent.com/ToiletStarter/EasyESP/refs/heads/main/Main.luau"))()

  Requires: Potassium executor

================================================================================
  TABLE OF CONTENTS
================================================================================

  1.  Quick Start
  2.  Configuration Overview
  3.  Full Config Reference
      3.1  Global Settings
      3.2  Box ESP
      3.3  Glow
      3.4  Name Tags
      3.5  Weapon Display
      3.6  Distance
      3.7  Health Bar
      3.8  Armor Bar
      3.9  Flags
      3.10 Skeleton / Bones
      3.11 Head Dot
      3.12 Gaze (Look Direction)
      3.13 Tracers
      3.14 Off-Screen Arrows
      3.15 Hit Flash & Damage Numbers
      3.16 Low-Health Pulse
      3.17 Bone Trail (Ghost)
      3.18 World Rings
      3.19 World Ball (3D Sphere)
      3.20 Particle Effects (FX)
      3.21 Self Visuals (Trail, FOV, Crosshair, Preview)
      3.22 Chams
      3.23 World Environment
      3.24 Performance Settings
  4.  API Reference
      4.1  Lifecycle (new, start, stop, destroy)
      4.2  Friends System
      4.3  Custom Entities
      4.4  Custom Rings
      4.5  Flag Providers
      4.6  Draw Hooks
      4.7  Module System
      4.8  Config Persistence
      4.9  Debug / Stats
      4.10 Hit Tracking
  5.  Examples
      5.1  Minimal Setup
      5.2  Full-Featured Setup
      5.3  Custom Entity (Item ESP)
      5.4  Custom Module
      5.5  Rainbow ESP
  6.  Bug Fixes in v3.1.0
  7.  Performance Guide
  8.  Troubleshooting
  9.  v3.2.0 Additions


================================================================================
  1. QUICK START
================================================================================

  local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/ToiletStarter/EasyESP/refs/heads/main/Main.luau"))()

  local esp = ESP.new({
      enabled = true,
  })

  esp:start()

  -- Later, to change settings:
  esp.cfg.box.color = Color3.fromRGB(255, 0, 0)
  esp.cfg.name.on = true
  esp.cfg.hp.on = true

  -- To completely stop and clean up:
  esp:destroy()


================================================================================
  2. CONFIGURATION OVERVIEW
================================================================================

  All settings live in `esp.cfg`. The config is a deeply-nested table.
  You can modify individual properties at any time — changes take effect
  on the next frame.

  Preset colours are defined in the palette:
    accent   → rgb(190, 70, 235)   purple
    visible  → rgb(90, 235, 130)   green
    hidden   → rgb(235, 70, 70)    red
    text     → rgb(235, 235, 245)  white
    ink      → rgb(12, 12, 16)     near-black
    friend   → rgb(80, 180, 255)   blue


================================================================================
  3. FULL CONFIG REFERENCE
================================================================================

── 3.1 GLOBAL SETTINGS ────────────────────────────────────────────────────────

  cfg.enabled         (bool)    Master toggle. Default: false
  cfg.maxRange        (number)  Max distance for any ESP feature. Default: 3000
  cfg.espRange        (number)  Max render distance for player ESP. Default: 3000
  cfg.refresh         (number)  Min seconds between ticks. 0 = every frame. Default: 0
  cfg.teamCheck       (bool)    Skip teammates. Default: false
  cfg.wallCheck       (bool)    Run raycast visibility check per player. Default: false
  cfg.wallHide        (bool)    Hide players behind walls. Default: false
  cfg.wallColors      (bool)    Colour ESP by visible/hidden. Default: false
  cfg.rainbow         (bool)    Rainbow mode for all colourable elements. Default: false
  cfg.rainbowRate     (number)  Speed multiplier for rainbow cycling. Default: 1
  cfg.friendHighlight (bool)    Override accent colour for friends. Default: true
  cfg.friendColor     (Color3)  Friend override colour. Default: blue


── 3.2 BOX ESP ────────────────────────────────────────────────────────────────

  cfg.box.on            (bool)    Enable box rendering. Default: true
  cfg.box.style         (string)  "full" | "corner" | "3d" | "3dcorner". Default: "corner"
  cfg.box.color         (Color3)  Box colour. Default: accent (purple)
  cfg.box.thickness     (number)  Line thickness in px. Default: 1
  cfg.box.outline       (bool)    Draw black outline behind box. Default: true
  cfg.box.cornerScale   (number)  Corner length as fraction of box size. Default: 0.28
  cfg.box.fill          (bool)    Fill the box interior. Default: false
  cfg.box.fillColor     (Color3)  Fill colour. Default: accent
  cfg.box.fillAlpha     (number)  Fill transparency (0–1). Default: 0.12
  cfg.box.colorMode     (string)  "static" | "team" | "health" | "distance". Default: "static"
      static   → always use box.color
      team     → use player's TeamColor
      health   → lerp from healthLow (full hp) to healthFull (low hp)
      distance → lerp from healthFull (close) to healthLow (far)
  cfg.box.healthFull    (Color3)  Colour for full health / close distance. Default: green
  cfg.box.healthLow     (Color3)  Colour for low health / far distance. Default: red
  cfg.box.distanceFade  (bool)    Fade box alpha with distance. Default: false
  cfg.box.fadeStart     (number)  Distance where fading begins. Default: 150
  cfg.box.fadeEnd       (number)  Distance where box is mostly invisible. Default: 600


── 3.3 GLOW ───────────────────────────────────────────────────────────────────

  cfg.glow.on       (bool)    Enable glow layers behind box. Default: false
  cfg.glow.color    (Color3)  Glow colour. Default: accent
  cfg.glow.layers   (number)  Number of expanding glow outlines. Default: 4
  cfg.glow.spread   (number)  Pixel gap between each layer. Default: 2
  cfg.glow.alpha    (number)  Base glow transparency. Default: 0.10
  cfg.glow.pulse    (bool)    Pulse the glow intensity. Default: true
  cfg.glow.rate     (number)  Pulse speed (Hz). Default: 3


── 3.4 NAME TAGS ──────────────────────────────────────────────────────────────

  cfg.name.on      (bool)    Show display name above box. Default: true
  cfg.name.user    (bool)    Append (username) after display name. Default: false
  cfg.name.size    (number)  Font size in px. Default: 13
  cfg.name.color   (Color3)  Text colour. Default: text (white)
  cfg.name.font    (number)  Drawing.Fonts value. Default: FONTS.Plex (2)
  cfg.name.shadow  (bool)    Draw dark shadow behind text. Default: true

  Available fonts:
    Drawing.Fonts.UI        = 0
    Drawing.Fonts.System    = 1
    Drawing.Fonts.Plex      = 2
    Drawing.Fonts.Monospace = 3


── 3.5 WEAPON DISPLAY ─────────────────────────────────────────────────────────

  cfg.gun.on        (bool)    Show equipped tool name below box. Default: false
  cfg.gun.size      (number)  Font size. Default: 12
  cfg.gun.color     (Color3)  Text colour. Default: light grey
  cfg.gun.ammoAttr  (string)  Player attribute name for ammo count. Default: "Ammo"


── 3.6 DISTANCE ───────────────────────────────────────────────────────────────

  cfg.dist.on      (bool)    Show distance label below box. Default: false
  cfg.dist.size    (number)  Font size. Default: 13
  cfg.dist.color   (Color3)  Text colour. Default: text (white)
  cfg.dist.font    (number)  Font ID. Default: FONTS.Plex
  cfg.dist.shadow  (bool)    Draw shadow. Default: true
  cfg.dist.suffix  (string)  Unit suffix. Default: "m"


── 3.7 HEALTH BAR ─────────────────────────────────────────────────────────────

  cfg.hp.on          (bool)    Show health bar. Default: true
  cfg.hp.side        (string)  "left" or "right". Default: "left"
  cfg.hp.thickness   (number)  Bar width in px. Default: 3
  cfg.hp.outline     (bool)    Black outline behind bar. Default: true
  cfg.hp.full        (Color3)  Colour at 100% health. Default: green
  cfg.hp.low         (Color3)  Colour at 0% health. Default: red
  cfg.hp.gradient    (bool)    Smooth colour lerp from low→full. Default: true
  cfg.hp.showText    (bool)    Show percentage above bar when < 100%. Default: false
  cfg.hp.showPercent (bool)    Show percentage below box. Default: false
  cfg.hp.notch       (bool)    Draw a centre-line notch on the bar. Default: true


── 3.8 ARMOR BAR ──────────────────────────────────────────────────────────────

  cfg.armor.on        (bool)    Show armor bar below box. Default: false
  cfg.armor.thickness (number)  Bar height in px. Default: 3
  cfg.armor.color     (Color3)  Bar colour. Default: blue
  cfg.armor.attr      (string)  Player attribute for current armor. Default: "Armor"
  cfg.armor.maxAttr   (string)  Player attribute for max armor. Default: "MaxArmor"


── 3.9 FLAGS ──────────────────────────────────────────────────────────────────

  cfg.flags.on       (bool)    Enable flag display. Default: false
  cfg.flags.size     (number)  Font size. Default: 11
  cfg.flags.font     (number)  Font ID. Default: FONTS.Plex
  cfg.flags.side     (string)  "right" or "left". Default: "right"
  cfg.flags.spacing  (number)  Vertical gap between flags in px. Default: 1
  cfg.flags.color    (Color3)  Default flag colour. Default: text (white)

  Built-in flags (automatically installed):
    "visible"  → V (green) / HID (red)
    "flying"   → FLY (blue) when in Freefall or Flying state
    "hp"       → <N>hp (green)
    "gun"      → weapon name (gold)
    "speed"    → <N> sps (cyan) when moving > 2 studs/s
    "sprint"   → SPRINT (orange) when WalkSpeed > 18
    "frozen"   → FROZEN (ice blue) when WalkSpeed == 0
    "god"      → GOD (gold) when MaxHealth >= 1,000,000
    "friend"   → FRIEND (blue) for marked friends

  Add custom flags:
    esp:addFlag("myFlag", function(ctx)
        -- ctx has: plr, rig, root, hum, head, dist, visible, esp
        if ctx.dist < 50 then return { "NEAR", Color3.new(1,1,0) } end
    end)


── 3.10 SKELETON / BONES ──────────────────────────────────────────────────────

  cfg.bones.on        (bool)    Draw skeleton lines. Default: false
  cfg.bones.color     (Color3)  Bone colour. Default: text (white)
  cfg.bones.thickness (number)  Line thickness. Default: 1

  Automatically detects R6 vs R15 rigs and draws the appropriate bone set.


── 3.11 HEAD DOT ──────────────────────────────────────────────────────────────

  cfg.headDot.on    (bool)    Filled circle on head position. Default: false
  cfg.headDot.size  (number)  Dot radius. Default: 3
  cfg.headDot.color (Color3)  Dot colour. Default: text (white)


── 3.12 GAZE (LOOK DIRECTION) ────────────────────────────────────────────────

  cfg.gaze.on      (bool)    Line from head in look direction. Default: false
  cfg.gaze.length  (number)  Line length in studs. Default: 10
  cfg.gaze.color   (Color3)  Line colour. Default: text (white)


── 3.13 TRACERS ───────────────────────────────────────────────────────────────

  cfg.tracer.on        (bool)    Line from screen edge to player. Default: false
  cfg.tracer.from      (string)  "bottom" | "center" | "top" | "mouse". Default: "bottom"
  cfg.tracer.color     (Color3)  Line colour. Default: accent
  cfg.tracer.thickness (number)  Line thickness. Default: 1


── 3.14 OFF-SCREEN ARROWS ────────────────────────────────────────────────────

  cfg.arrow.on          (bool)    Show chevrons for off-screen players. Default: false
  cfg.arrow.radius      (number)  Distance from screen centre for arrow. Default: 200
  cfg.arrow.size        (number)  Arrow head size in px. Default: 15
  cfg.arrow.color       (Color3)  Arrow colour. Default: accent
  cfg.arrow.scaleFactor (number)  Scale factor for distance-based positioning. Default: 1

  Arrows only appear when a player is behind the camera or outside espRange.


── 3.15 HIT FLASH & DAMAGE NUMBERS ───────────────────────────────────────────

  cfg.hit.on        (bool)    Enable hit detection visuals. Default: false
  cfg.hit.life      (number)  Duration of flash in seconds. Default: 0.35
  cfg.hit.flash     (Color3)  Box flash colour. Default: white
  cfg.hit.showDmg   (bool)    Show damage number. Default: true
  cfg.hit.dmgColor  (Color3)  Damage text colour. Default: red

  Damage is auto-detected by comparing health changes each frame.
  You can also manually trigger:
    esp:markHit(userId, damageAmount)


── 3.16 LOW-HEALTH PULSE ─────────────────────────────────────────────────────

  cfg.pulse.on        (bool)    Pulse box colour when health is low. Default: false
  cfg.pulse.threshold (number)  Health fraction to trigger (0–1). Default: 0.35
  cfg.pulse.color     (Color3)  Pulse colour. Default: red
  cfg.pulse.rate      (number)  Pulse speed. Default: 6


── 3.17 BONE TRAIL (GHOST) ──────────────────────────────────────────────────

  cfg.trail.on     (bool)    Show ghost afterimages of bone positions. Default: false
  cfg.trail.ticks  (number)  Number of snapshots to keep. Default: 8
  cfg.trail.gap    (number)  Seconds between snapshots. Default: 0.05
  cfg.trail.color  (Color3)  Trail colour. Default: accent
  cfg.trail.alpha  (number)  Base transparency. Default: 0.5
  cfg.trail.fade   (bool)    Fade older ghosts. Default: true


── 3.18 WORLD RINGS ───────────────────────────────────────────────────────────

  cfg.rings.on        (bool)    Master toggle for rings. Default: false
  cfg.rings.onEnemies (bool)    Show rings on enemies. Default: false
  cfg.rings.specs     (table)   Array of ring specifications.

  Each spec in cfg.rings.specs:
    radius     (number)  Ring radius in studs. Default: 12
    color      (Color3)  Ring colour. Default: accent
    thickness  (number)  Line thickness. Default: 2
    alpha      (number)  Transparency. Default: 1
    style      (string)  "solid" | "dashed". Default: "solid"
    shape      (string)  "circle" | "square" | "pentagon" | "hexagon" | "star" | "radar"
    fx         (string)  "none" | "rainbow" | "breathe". Default: "none"
    spin       (number)  Rotation speed (rad/s). Default: 0.4
    pulse      (bool)    Pulse alpha. Default: false
    fill       (bool)    Fill the ring interior. Default: false
    fillAlpha  (number)  Fill transparency. Default: 0.08
    glow       (bool)    Add outer glow lines. Default: true
    ticks      (number)  Number of tick marks around ring. Default: 0

  Manage specs:
    esp:addRingSpec({ radius = 20, color = Color3.fromRGB(255,0,0), shape = "hexagon" })
    esp:removeRingSpec(1)    -- remove first spec
    esp:clearRingSpecs()     -- remove all


── 3.19 WORLD BALL (3D SPHERE) ────────────────────────────────────────────────

  cfg.ball.on        (bool)    Draw wireframe sphere around player. Default: false
  cfg.ball.onEnemies (bool)    Show on enemies. Default: false
  cfg.ball.radius    (number)  Sphere radius in studs. Default: 10
  cfg.ball.rings     (number)  Number of latitude bands. Default: 5
  cfg.ball.color     (Color3)  Wire colour. Default: accent
  cfg.ball.thickness (number)  Line thickness. Default: 1
  cfg.ball.alpha     (number)  Transparency. Default: 0.6
  cfg.ball.spin      (number)  Rotation speed. Default: 0.2
  cfg.ball.fx        (string)  "none" | "rainbow". Default: "none"


── 3.20 PARTICLE EFFECTS (FX) ────────────────────────────────────────────────

  cfg.fx.onEnemies  (bool)  Show FX on enemies. Default: true

  Each FX has a .on toggle. Available effects:

    confetti  – Falling confetti particles
    rain      – Rain drops around player
    synth     – Expanding rings rising upward (synthwave)
    orbit     – Orbiting sparkles with optional trails
    spiral    – Spiral line rising from feet
    vortex    – Swirling tornado-like particles
    shock     – Expanding shockwave rings
    aura      – Rotating tilted rings (orbital aura)
    flies     – Flickering firefly-like dots
    bolt      – Lightning bolts from above
    helix     – DNA-like double helix strands
    pulse     – Pulsing ring effect
    tornado   – Spinning debris particles
    portal    – Concentric spinning coloured rings
    snow      – Falling snowflakes
    embers    – Rising ember particles (heat-faded)
    radar     – Rotating radar sweep
    burst     – Spinning starburst
    ripple    – Expanding filled ripple rings
    beam      – Vertical laser beams in a circle

  Each effect has unique parameters (count, radius, height, speed, etc.).
  Refer to the config defaults in the source for exact parameter names.


── 3.21 SELF VISUALS ─────────────────────────────────────────────────────────

  These apply to the LOCAL player only.

  cfg.self.fx      (bool)  Show FX on self. Default: false
  cfg.self.rings   (bool)  Show rings on self. Default: false

  cfg.self.trail   – Self position trail
    .on        (bool)    Default: false
    .ticks     (number)  Max trail segments. Default: 30
    .gap       (number)  Seconds between points. Default: 0.05
    .thickness (number)  Line thickness. Default: 2
    .alpha     (number)  Transparency. Default: 0.8
    .color     (Color3)  Trail colour. Default: accent
    .rainbow   (bool)    Rainbow trail. Default: true

  cfg.self.fov     – FOV circle (for aimbot visualisation)
    .on        (bool)    Default: false
    .radius    (number)  Circle radius in px. Default: 120
    .thickness (number)  Line thickness. Default: 1
    .sides     (number)  Polygon sides. Default: 64
    .alpha     (number)  Transparency. Default: 1
    .color     (Color3)  Circle colour. Default: white
    .rainbow   (bool)    Rainbow mode. Default: false
    .fill      (bool)    Fill the circle. Default: false
    .fillAlpha (number)  Fill transparency. Default: 0.05

  cfg.self.cross   – Crosshair
    .on        (bool)    Default: false
    .gap       (number)  Centre gap in px. Default: 4
    .length    (number)  Arm length in px. Default: 8
    .thickness (number)  Line thickness. Default: 1
    .alpha     (number)  Transparency. Default: 1
    .color     (Color3)  Crosshair colour. Default: green
    .rainbow   (bool)    Rainbow mode. Default: false
    .outline   (bool)    Black outline. Default: true
    .dot       (bool)    Centre dot. Default: false
    .dotSize   (number)  Dot radius. Default: 1

  cfg.self.preview – Live preview panel of current settings
    .on      (bool)    Show preview panel. Default: false
    .x       (number)  Panel X position. Default: 60
    .y       (number)  Panel Y position (0 = centred). Default: 0
    .w       (number)  Panel width. Default: 70
    .h       (number)  Panel height. Default: 150
    .fakeHp  (number)  Override HP (-1 = use real HP). Default: -1


── 3.22 CHAMS ─────────────────────────────────────────────────────────────────

  cfg.chams.on          (bool)    Enable chams. Default: false
  cfg.chams.mode        (string)  "highlight" | "material". Default: "highlight"
  cfg.chams.teamCheck   (bool)    Skip teammates. Default: false
  cfg.chams.depth       (string)  "top" | "occluded". Default: "top"
      top       → always visible through walls
      occluded  → only visible when NOT through walls

  Highlight mode:
    cfg.chams.fill         (bool)    Enable fill. Default: true
    cfg.chams.fillColor    (Color3)  Fill colour. Default: white
    cfg.chams.fillAlpha    (number)  Fill transparency. Default: 0.5
    cfg.chams.outline      (bool)    Enable outline. Default: true
    cfg.chams.outlineColor (Color3)  Outline colour. Default: white
    cfg.chams.outlineAlpha (number)  Outline transparency. Default: 0

  Material mode:
    cfg.chams.material  (string)  Material name (e.g. "ForceField", "Neon"). Default: "ForceField"
    cfg.chams.matColor  (Color3)  Part colour override. Default: white
    cfg.chams.matAlpha  (number)  Part transparency. Default: 0
    cfg.chams.matHead   (bool)    Include the Head part. Default: true

  Shared options:
    cfg.chams.wallColors  (bool)    Colour by visibility. Default: false
    cfg.chams.visible     (Color3)  Colour when visible. Default: green
    cfg.chams.hidden      (Color3)  Colour when behind wall. Default: red
    cfg.chams.rainbow     (bool)    Rainbow chams. Default: false
    cfg.chams.rainbowRate (number)  Rainbow speed. Default: 1


── 3.23 WORLD ENVIRONMENT ────────────────────────────────────────────────────

  cfg.world.on          (bool)    Enable world modifications. Default: false
  cfg.world.fullbright  (bool)    Max brightness. Default: false
  cfg.world.fov         (number)  Camera FOV. Default: 70
  cfg.world.noFog       (bool)    Remove fog. Default: false
  cfg.world.brightness  (number)  Lighting brightness. Default: 1
  cfg.world.ambient     (Color3)  Ambient light colour. Default: black
  cfg.world.outdoor     (Color3)  Outdoor ambient colour. Default: black
  cfg.world.exposure    (number)  Exposure compensation. Default: 1
  cfg.world.colorGrade  (bool)    Enable colour correction. Default: false
  cfg.world.saturation  (number)  Saturation shift (-1 to 1). Default: 0
  cfg.world.contrast    (number)  Contrast shift (-1 to 1). Default: 0


── 3.24 PERFORMANCE SETTINGS ─────────────────────────────────────────────────

  cfg.perf.mode        (string)  "off" | "auto" | "manual". Default: "auto"
      off    → no LOD reduction
      auto   → auto-caps at 24 players when roster > 24
      manual → use playerCap value

  cfg.perf.playerCap   (number)  Max rendered players (0 = unlimited). Default: 0
  cfg.perf.ringDetail  (number)  Base polygon count for rings. Default: 48
  cfg.perf.ballDetail  (number)  Base polygon count for balls. Default: 24
  cfg.perf.fxDensity   (number)  FX particle density multiplier. Default: 1
  cfg.perf.near        (number)  Distance threshold for LOD 0. Default: 120
  cfg.perf.mid         (number)  Distance threshold for LOD 1. Default: 320
  cfg.perf.far         (number)  Distance threshold for LOD 2. Default: 700
  cfg.perf.dropFxFar   (bool)    Disable FX at LOD 3+. Default: true
  cfg.perf.frameSkip   (number)  Skip N frames between renders. Default: 0
  cfg.perf.visPoints   (number)  Multi-point wall check (1–6). Default: 3
      1 → HRP only
      2 → HRP + Head
      3 → + Right Arm
      4 → + Left Arm
      5 → + Right Leg
      6 → + Left Leg

  LOD levels:
    0 (near)  → full detail, all effects
    1 (mid)   → 66% polygon count, trail ghosts disabled
    2 (far)   → 40% polygon count, 50% FX density, no bones/FX
    3 (very far) → 25% polygon count, no FX at all


================================================================================
  4. API REFERENCE
================================================================================

── 4.1 LIFECYCLE ──────────────────────────────────────────────────────────────

  ESP.new(overrides?) → ESP
      Create a new ESP instance. `overrides` is merged into the default config.

  esp:start() → ESP
      Begin the render loop. Connects to RenderStepped and PlayerRemoving.
      Auto-loads the last saved config if one exists.

  esp:stop()
      Pause the render loop. Auto-saves config.

  esp:destroy()
      Full cleanup: disconnects all events, destroys all drawings, highlights,
      and material overrides. Restores world lighting. Resets all state.
      Call this when you want to completely unload EasyESP.


── 4.2 FRIENDS SYSTEM ────────────────────────────────────────────────────────

  esp:markFriend(userId)
      Mark a player as a friend. Friends get highlighted in the friend colour
      (default: blue) when cfg.friendHighlight is enabled.

  esp:unmarkFriend(userId)
      Remove friend status.

  esp:isFriend(player) → bool
      Check if a player is marked as a friend.

  Example:
    esp:markFriend(12345678)
    esp.cfg.friendHighlight = true


── 4.3 CUSTOM ENTITIES ────────────────────────────────────────────────────────

  esp:addEntity(id, options) → entity
      Register a custom entity to render ESP for.

      id       – unique string/number identifier
      options:
        .get()      – function returning an Instance or Vector3 (required)
        .label      – name text
        .color      – entity colour (Color3)
        .box        – show box (bool, default true)
        .name       – show name (bool, default true)
        .distance   – show distance (bool)
        .tracer     – show tracer line (bool)
        .dot        – show dot at base (bool)
        .ring       – ring spec table (optional)
        .size       – bounding box size Vector3 (default 3,4,3)
        .maxRange   – max render distance (default cfg.maxRange)
        .draw(esp, key, pos, lx, ly, bw, bh, dist) – custom draw callback

  esp:removeEntity(id)
      Remove a custom entity.

  Example — Item ESP:
    local items = {}
    for _, item in ipairs(workspace.Items:GetChildren()) do
        esp:addEntity("item_" .. item.Name .. "_" .. item:GetDebugId(), {
            get = function() return item end,
            label = item.Name,
            color = Color3.fromRGB(255, 255, 0),
            distance = true,
        })
    end


── 4.4 CUSTOM RINGS ──────────────────────────────────────────────────────────

  esp:attachRing(id, options) → ring
      Attach a world-space ring to a target.

      id       – unique identifier
      options:
        .preset  – "killaura" | "reach" | "grab" | "rainbow" | "neon" | "target"
        .target  – Player, Instance, Vector3, or function returning Vector3
        .lift    – vertical offset in studs

      All ring spec properties are also accepted (radius, color, shape, etc.)

  esp:detachRing(id)
      Remove a ring.

  esp:clearRings()
      Remove all attached rings.

  Example:
    esp:attachRing("myRing", {
        preset = "neon",
        target = me,
        radius = 8,
        color = Color3.fromRGB(0, 255, 255),
    })


── 4.5 FLAG PROVIDERS ────────────────────────────────────────────────────────

  esp:addFlag(name, function)
      Register a custom flag. The function receives a context table:
        { plr, rig, root, hum, head, dist, visible, esp }
      Return a table { text, color } to show the flag, or nil to hide it.

  esp:removeFlag(name)
      Remove a flag provider.

  Example:
    esp:addFlag("vip", function(ctx)
        if ctx.plr:GetRankInGroup(12345) >= 100 then
            return { "VIP", Color3.fromRGB(255, 215, 0) }
        end
    end)


── 4.6 DRAW HOOKS ────────────────────────────────────────────────────────────

  esp:onDraw(name, function)
      Register a per-player draw hook. Called for every rendered player.
      Signature: function(esp, player, rig, lx, ly, bw, bh, dist)

  esp:removeDraw(name)
      Remove a draw hook.

  Example:
    esp:onDraw("healthText", function(esp, plr, rig, x, y, w, h, dist)
        local hum = rig:FindFirstChildOfClass("Humanoid")
        if hum then
            esp.pool:text("ht_" .. plr.UserId,
                math.floor(hum.Health) .. " HP",
                x + w/2, y + h + 20, 11, Color3.new(1,1,1), true, 2, true)
        end
    end)


── 4.7 MODULE SYSTEM ─────────────────────────────────────────────────────────

  esp:register(spec) → module
      Register a module with the ESP pipeline.

      spec:
        .name     (string)   Unique module name (required)
        .enabled  (bool)     Start enabled. Default: false
        .state    (table)    Shared state table. Gets .esp and .cfg injected.
        .config   (table)    Default module-specific config.
        .setup(state, esp)          Called once on register.
        .player(state, ctx)         Called per rendered player.
        .world(state, esp)          Called once per frame before players.
        .screen(state, esp)         Called once per frame after players.
        .teardown(state)            Called on unregister/destroy.

      The player context (ctx) contains:
        plr, rig, root, hum, head, x, y, w, h, dist, visible, lod, key, accent, foot

  esp:toggleModule(name, on?)
      Toggle a module on/off. If `on` is omitted, toggles.

  esp:module(name) → module
      Get a module by name.

  esp:unregister(name)
      Remove a module and call its teardown.

  Example — Kill counter module:
    esp:register({
        name = "killCounter",
        enabled = true,
        state = { kills = 0 },
        setup = function(state, esp)
            print("Kill counter module loaded!")
        end,
        screen = function(state, esp)
            esp.pool:text("kc", "Kills: " .. state.kills,
                10, 10, 16, Color3.new(1,1,1), false, 2, true)
        end,
    })


── 4.8 CONFIG PERSISTENCE ────────────────────────────────────────────────────

  esp:export() → string
      Serialise the current config to a Luau source string.

  esp:import(sourceString) → bool
      Merge a serialised config into the current config.

  esp:save(name)
      Save the current config to "EasyESP/<name>.txt".

  esp:load(name) → bool
      Load a config from "EasyESP/<name>.txt".

  esp:configs() → table of names
      List all saved config names.

  Note: Configs are auto-saved on esp:stop() and auto-loaded on esp:start().


── 4.9 DEBUG / STATS ─────────────────────────────────────────────────────────

  esp:getStats() → table
      Returns runtime statistics:
        .drawn     – number of players currently rendered
        .poolSize  – number of Drawing objects in the pool
        .fps       – measured frames per second
        .roster    – total players in render range
        .modules   – number of registered modules
        .entities  – number of custom entities
        .friends   – number of marked friends


── 4.10 HIT TRACKING ─────────────────────────────────────────────────────────

  esp:markHit(userId, damage)
      Manually register a hit for damage display.
      The hit flash and damage number will appear for cfg.hit.life seconds.

  esp:trackHealth(player, humanoid)
      Called internally each frame when cfg.hit.on is true.
      Compares current health to last known health and auto-detects damage.


================================================================================
  5. EXAMPLES
================================================================================

── 5.1 MINIMAL SETUP ──────────────────────────────────────────────────────────

  local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/ToiletStarter/EasyESP/refs/heads/main/Main.luau"))()
  local esp = ESP.new()
  esp.cfg.enabled = true
  esp:start()


── 5.2 FULL-FEATURED SETUP ───────────────────────────────────────────────────

  local ESP = loadstring(game:HttpGet("https://raw.githubusercontent.com/ToiletStarter/EasyESP/refs/heads/main/Main.luau"))()

  local esp = ESP.new({
      enabled     = true,
      espRange    = 2000,
      teamCheck   = false,
      wallColors  = true,
      rainbow     = false,

      box = {
          on = true,
          style = "corner",
          colorMode = "health",
          outline = true,
      },

      name = { on = true, user = true, size = 14 },
      hp   = { on = true, gradient = true, showPercent = true },
      dist = { on = true, suffix = " studs" },
      gun  = { on = true },
      bones = { on = true, thickness = 1.5 },
      headDot = { on = true, size = 4 },
      tracer = { on = true, from = "bottom" },
      arrow  = { on = true, radius = 180 },
      flags  = { on = true, side = "right" },

      chams = {
          on = true,
          mode = "highlight",
          depth = "top",
          fill = true,
          fillAlpha = 0.4,
          wallColors = true,
      },

      perf = {
          mode = "auto",
          visPoints = 4,
          ringDetail = 36,
      },
  })

  -- Mark friends
  esp:markFriend(game.PlayersFriend1.UserId)

  esp:start()


── 5.3 CUSTOM ENTITY (ITEM ESP) ──────────────────────────────────────────────

  -- After esp:start(), scan for items:
  local itemFolder = workspace:FindFirstChild("Items")
  if itemFolder then
      for _, item in ipairs(itemFolder:GetChildren()) do
          if item:IsA("Model") or item:IsA("BasePart") then
              esp:addEntity("item_" .. tostring(item), {
                  get = function() return item end,
                  label = item.Name,
                  color = Color3.fromRGB(255, 255, 0),
                  distance = true,
                  dot = true,
                  maxRange = 500,
              })
          end
      end
  end


── 5.4 CUSTOM MODULE ──────────────────────────────────────────────────────────

  -- Radar minimap module
  esp:register({
      name = "minimap",
      enabled = true,
      state = {
          cx = 100, cy = 100, radius = 80,
      },
      screen = function(state, esp)
          local p = esp.pool
          -- Background circle
          p:dot("mm_bg", state.cx, state.cy, state.radius,
              Color3.fromRGB(20, 20, 30), true, 0.6, 48)
          -- Border
          p:dot("mm_border", state.cx, state.cy, state.radius,
              Color3.fromRGB(100, 100, 120), false, 0.8, 48)

          -- Player dots
          for i = 1, esp.rosterN do
              local slot = esp.roster[i]
              local myRoot = game.Players.LocalPlayer.Character
                  and game.Players.LocalPlayer.Character:FindFirstChild("HumanoidRootPart")
              if myRoot and slot.root then
                  local offset = slot.root.Position - myRoot.Position
                  local px = state.cx + offset.X * 0.3
                  local py = state.cy + offset.Z * 0.3
                  local dist = (px - state.cx)^2 + (py - state.cy)^2
                  if dist < state.radius^2 then
                      p:dot("mm_p" .. i, px, py, 2,
                          Color3.fromRGB(255, 60, 60), true, 1, 8)
                  end
              end
          end
      end,
  })


── 5.5 RAINBOW ESP ───────────────────────────────────────────────────────────

  local esp = ESP.new({
      enabled = true,
      rainbow = true,
      rainbowRate = 0.5,   -- slower cycling
      box = { on = true, style = "full" },
      name = { on = true },
      tracer = { on = true },
  })
  esp:start()


================================================================================
  6. BUG FIXES IN v3.1.0
================================================================================

  CRITICAL FIXES:
  ───────────────
  1. paintCham material mode fall-through
     BUG:  After the material-mode block, execution fell through to the
           highlight code. This destroyed the materials that were just set,
           then created redundant Highlight instances.
     FIX:  Added explicit `return` after the material loop.

  2. worldBall meridian rotation
     BUG:  Meridian lines used `pi` for their angular range, covering only
           180° instead of 360°, leaving half the sphere unrendered.
     FIX:  Changed to use proper rotation (the latitude/longitude system
           already handles the 360° coverage via the ring trig table).

  3. Markdown URL artifacts throughout source
     BUG:  The original source contained [http://...](...) link artifacts
           and italic * markers that broke Luau syntax entirely.
     FIX:  All artifacts removed; source compiles cleanly.

  4. HTML entities
     BUG:  &amp;lt; and &amp;gt; were used instead of < and > in
           comparisons, causing syntax errors.
     FIX:  Replaced with proper comparison operators.

  PERFORMANCE FIXES:
  ──────────────────
  5. Shadow/dirty-flag caching on ALL Pool methods
     BUG:  Pool:rect, Pool:dot, Pool:text, Pool:tri, Pool:quad set ALL
           properties via setrenderproperty every single frame, even when
           nothing changed. This was the #1 performance bottleneck.
     FIX:  Every Pool method now tracks a shadow table and only calls
           setrenderproperty when the value actually changed.

  6. Pool:nuke safety
     BUG:  Calling Destroy() on already-invalidated drawing objects could
           error and halt cleanup.
     FIX:  Wrapped each Destroy() in pcall.

  MEMORY LEAK FIXES:
  ──────────────────
  7. Player removal cleanup
     BUG:  self.btrk, self.hpMem, and self.hits were cleaned on
           PlayerRemoving but self.hl (Highlight instances) were not.
     FIX:  Added self.hl[uid] = nil in the PlayerRemoving handler.

  8. Flag leftover objects
     BUG:  drawFlags used a counter `i` but never hid leftover flag text
           objects when the number of active flags decreased between frames.
     FIX:  Added a cleanup loop that hides leftover flag drawings.

  LOGIC FIXES:
  ────────────
  9. Multi-point visibility check
     IMPROVEMENT: The original only checked HumanoidRootPart for wall
           visibility. Now checks up to 6 body parts (configurable via
           cfg.perf.visPoints) for more accurate detection.

  10. Viewport culling
      IMPROVEMENT: Added early-out check before the expensive bounding-box
           calculation. Players fully outside the viewport are skipped
           before GetBoundingBox() is called.

  11. Nil safety throughout
      IMPROVEMENT: Added nil guards to screenBox, footOf, centerOf, sees,
           drawPlayer, and draw3DBox to prevent errors with broken rigs.

  12. Off-screen arrow distance scaling
      IMPROVEMENT: Added cfg.arrow.scaleFactor for distance-based arrow
           positioning so closer off-screen players appear nearer the edge.


================================================================================
  7. PERFORMANCE GUIDE
================================================================================

  RECOMMENDED SETTINGS BY SCENARIO:
  ─────────────────────────────────

  Low-end PC / Mobile:
    cfg.perf.mode = "auto"
    cfg.perf.playerCap = 12
    cfg.perf.ringDetail = 16
    cfg.perf.ballDetail = 12
    cfg.perf.fxDensity = 0.3
    cfg.perf.frameSkip = 1        -- render every other frame
    cfg.perf.dropFxFar = true
    cfg.perf.visPoints = 1
    -- Disable heavy features:
    cfg.bones.on = false
    cfg.glow.on = false
    cfg.fx.onEnemies = false
    cfg.trail.on = false
    cfg.rings.on = false
    cfg.ball.on = false

  Mid-range PC:
    cfg.perf.mode = "auto"
    cfg.perf.playerCap = 24
    cfg.perf.ringDetail = 36
    cfg.perf.fxDensity = 0.7
    cfg.perf.frameSkip = 0
    cfg.perf.visPoints = 3

  High-end PC:
    cfg.perf.mode = "off"
    cfg.perf.playerCap = 0        -- unlimited
    cfg.perf.ringDetail = 48
    cfg.perf.fxDensity = 1
    cfg.perf.frameSkip = 0
    cfg.perf.visPoints = 6

  OPTIMISATION TIPS:
  ──────────────────
  • frameSkip is the single most impactful setting. Setting it to 1
    halves the render cost. Set to 2 for 1/3 cost, etc.

  • visPoints controls raycast cost per player. 1 ray = fast. 6 rays = 6x
    the wall-check cost. Use 1–2 for large rosters.

  • fxDensity multiplies particle counts. Halving it roughly halves FX cost.

  • The object pool auto-reuses Drawing objects. You don't need to manage
    this manually. The dirty-flag cache avoids redundant setrenderproperty
    calls — this is the biggest per-frame optimisation.

  • The auto LOD system reduces polygon counts for distant players. Keep
    cfg.perf.mode = "auto" for the best balance.

  • Chams (Highlight instances) are limited to 31 per Roblox engine. If
    you have many players, consider chams.teamCheck = true.

  • cfg.refresh adds a minimum interval between ticks. Setting it to 0.016
    (≈60fps throttle) can help if RenderStepped fires too often.


================================================================================
  8. TROUBLESHOOTING
================================================================================

  "EasyESP requires the Potassium executor"
      → Your executor doesn't support the Drawing API. EasyESP only works
        on Potassium or compatible executors.

  ESP doesn't appear after start()
      → Make sure cfg.enabled = true. Check that there are other players
        in the server. Check espRange and maxRange aren't too low.

  Chams not showing
      → Roblox limits Highlights to 31 instances. If you have many players,
        older ones may lose their highlight. Enable chams.teamCheck to
        skip teammates.

  Performance drops with many players
      → Enable cfg.perf.mode = "auto" and reduce cfg.perf.playerCap.
        Set cfg.perf.frameSkip = 1 or higher. Disable heavy features
        like bones, glow, FX, and rings.

  Box flickers or disappears briefly
      → This can happen when frameSkip is enabled. The skipped frames
        preserve the previous frame's drawings, which is correct.
        If flickering persists, set frameSkip = 0.

  World lighting doesn't restore after stopping
      → Call esp:destroy() for full cleanup including world restore.
        esp:stop() only pauses the loop; esp:destroy() does full teardown.

  Config save/load not working
      → Make sure your executor supports writefile/readfile. The configs
        are saved to the "EasyESP/" folder in your executor workspace.

  Custom entity not rendering
      → Verify the .get() function returns a valid Instance or Vector3.
        Check that maxRange is large enough. The entity must be within
        espRange and pass viewport culling.

  Arrows pointing wrong direction
      → Arrows use the camera's viewport coordinate system. If the camera
        is rotated (e.g., in a cutscene), arrows may appear offset.

  Memory usage grows over time
      → Check that you're not creating ESP instances without destroying
        old ones. Each esp:destroy() cleans up all resources. Use
        esp:getStats() to monitor pool size and roster count.


================================================================================
  9. V3.2.0 ADDITIONS
================================================================================

  The v3.2.0 cleanup focused on three areas: removing every source-code
  comment, reducing Potassium Drawing API churn even further, and adding
  modern ESP quality-of-life overlays.

  NEW OVERLAYS:
  ─────────────

  Radar / minimap:
    cfg.radar.on          Enable screen-space radar.
    cfg.radar.x/y         Top-left radar position.
    cfg.radar.radius      Radar radius in pixels.
    cfg.radar.range       World studs represented by the radar edge.
    cfg.radar.rotate      Rotate blips by camera yaw.
    cfg.radar.grid        Draw cross/grid lines.
    cfg.radar.names       Draw player names beside blips.
    cfg.radar.maxBlips    Max blips to draw per frame.
    cfg.radar.showAllies  Include teammates on radar.

  Target selector / target overlay:
    cfg.target.on             Enable closest-to-crosshair target overlay.
    cfg.target.fov            Screen-space acquisition radius.
    cfg.target.showFov        Draw the acquisition circle.
    cfg.target.visibleOnly    Only select visible targets.
    cfg.target.includeFriends Include marked friends.
    cfg.target.includeAllies  Include teammates.
    cfg.target.brackets       Draw target brackets.
    cfg.target.snapline       Draw a line from screen center to target.
    cfg.target.label          Draw target name.
    cfg.target.health         Add HP percent to label.
    cfg.target.distance       Add distance to label.

  Compass:
    cfg.self.compass.on           Enable top-screen compass.
    cfg.self.compass.y            Vertical position.
    cfg.self.compass.width        Width in pixels.
    cfg.self.compass.scale        Pixels per heading degree.
    cfg.self.compass.showBearing  Show numeric bearing.

  Watermark / stats strip:
    cfg.self.watermark.on          Enable watermark.
    cfg.self.watermark.stats       Include FPS/drawn/pool stats.
    cfg.self.watermark.background  Draw background plate.

  IMPROVED OFF-SCREEN ARROWS:
  ───────────────────────────
    cfg.arrow.filled    Filled triangle arrows instead of two-line chevrons.
    cfg.arrow.outline   Black backing triangle for readability.
    cfg.arrow.distance  Show distance text under arrows.
    cfg.arrow.alpha     Arrow transparency.

  NEW API:
  ────────
    esp:applyPreset(name)
        Applies one of: "minimal", "balanced", "performance", "visual".
        Returns true if the preset exists.

    esp:presets()
        Returns a sorted list of available preset names.

    esp:clearFriends()
        Clears the friend list.

    esp:markFriend(playerOrUserId)
    esp:unmarkFriend(playerOrUserId)
    esp:isFriend(playerOrUserId)
        These now accept either a Player instance or numeric userId.

  POTASSIUM OPTIMISATION CHANGES:
  ───────────────────────────────
    • Fixed the pool visibility shadow bug: hidden drawings now correctly
      mark shadow.Visible=false, so reused drawings always come back.

    • Added Pool:hide() and Pool:prune(). Hidden stale objects can now be
      destroyed after cfg.perf.pruneAfter pool frames.

    • Added cfg.perf.pruneAfter and cfg.perf.pruneInterval to control
      stale Drawing cleanup when features are toggled or particle counts drop.

    • Pool size is tracked incrementally instead of recounting every frame.

    • Circle thickness is now handled inside Pool:dot(), so FOV/radar circles
      use the same dirty-flag path instead of direct property writes.

    • Left-side flag placement caches text width to avoid repeated Position
      writes each frame.

    • 3D boxes now reuse the same GetBoundingBox() result already computed
      for screen-box culling, avoiding a second expensive bounding-box call.

    • Reused buffers were added for 3D box points and star points to reduce
      per-frame table allocation churn.

    • Config save/load now safely returns false if file APIs are unavailable.

    • PlayerRemoving cleanup now destroys chams before clearing the highlight
      reference, preventing highlight leaks.

================================================================================
  END OF DOCUMENTATION
  EasyESP v3.2.0 — Built for Potassium
================================================================================
