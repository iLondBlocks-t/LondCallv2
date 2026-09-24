# ECHOFANG — Vertical Slice Design

Echofang is a landscape-only, silhouette-driven 2D metroidvania about an insect knight navigating a drowned underground kingdom. This repository contains a playable, dependency-free vertical slice built in Godot 4.x. The slice deliberately uses procedural vector painting for its art pass: silhouettes, parallax layers, Light2D-style glows, particles, and typography are all rendered at runtime so the project can be cloned and played without a binary asset pack.

## Player promise

Every input has a visible and physical answer within one frame: buffered jump, generous coyote time, sharp acceleration, readable anticipation, hit-stop, and screen shake. Exploration is paced as a loop: learn a route in the Gloamroot Hub, earn Fang Dash and Wraith Wings, use both to cut through the Sunken Galleries, then reach the Choir boss in the Moonless Archive.

## Room graph (24 rooms, 3 biomes)

The world is a left-to-right connected graph. A room is a 1280px camera cell; gates sit at cell boundaries. `World.gd` renders the full graph as a continuous authored slice while the HUD tracks the current room and biome.

```text
                         [H] Needle Shrine (secret, Echo Needle)
                                  |
[01] Gloamroot Landing -- [02] Lantern Hub -- [03] Rootwell Lift -- [04] Mosswalk
         |                       |             |                     |
[05] Husk Cellar         [06] Forgotten Niche* |              [07] Dash Chasm (Fang Dash)
         |                       |             |                     |
         +-----------------------+-------------+-------------- [08] Moss Gate
                                                               |
BIOME 2: SUNKEN GALLERIES                                       |
[09] Tide Steps -- [10] Glassworks -- [11] Wraith Shaft (Wraith Wings) -- [12] Blackwater
      |                |                    |                         |
[13] Mote Vault*  [14] Needle Mural*        +------------------- [15] Flooded Shortcut
                                                               |
                                                               [16] Choir Antechamber
                                                               |
BIOME 3: MOONLESS ARCHIVE                                         |
[17] Index of Ash -- [18] Scriptorium -- [19] Umbral Lock (Umbral Pulse)
       |                    |                         |
[20] Echo Alcove*            +-------------------------+
                                                        |
[21] Hanging Stacks -- [22] Parity Hall -- [23] Pale Door
                                                        |
                                                        [24] Choir Arena (boss)
```

`*` Optional secret rooms require Echo Needle: strike the faintly humming wall glyph and the wall opens. Ability gates are real collision gates in the playable corridor: the amber chasm requires Fang Dash, the vertical shaft requires Wraith Wings, the Umbral Lock requires Umbral Pulse, and the four archive doors require the corresponding traversal state. The hub has two explicit shortcuts back: the Fang Dash return ledge at room 07 and the Wraith Wings lift at room 15.

## Ability kit and gates

| Ability | Input | Feel / cost | VFX and sound identity | Slice gate |
| --- | --- | --- | --- | --- |
| Fang Dash | Dash / C | 0.15s burst, 8-way aim after upgrade, i-frames; 0.65s cooldown | Three cyan afterimages, sharp air-cut chirp | Dash Chasm, room 07; also enables dash-cancel attack |
| Wraith Wings | Jump in air / Space | One extra jump, small drift, 0.12s hang frame | Pale wing gust, glassy double chime | Wraith Shaft, room 11 |
| Wall Cling / Wall Jump | Move into wall, Jump | 160px/s slide; fixed 52° outward launch with steering | Amber claw sparks, stone scrape | Scriptorium vertical wall route, room 18 |
| Echo Needle | Ability 1 / Z | 0.34s charge, reveals secrets and parries telegraphs | Violet sonar rings, low heartbeat ping | Needle Shrine + all `*` secret rooms |
| Umbral Pulse | Ability 2 / V | 3 Umbra, 0.6s recharge per melee hit; charged piercing beam after Archive upgrade | Black-violet bolt with gold core, bass thump | Umbral Lock, room 19; ranged answer to Gallery sentries |

## Combat

The Nail is a three-step attack chain with directionality: horizontal, up, and down. Downward air attack is a pogo: enemies and marked hazards bounce the knight instantly upward. Every impact does 3 frames of hit-stop, a small camera shake, sparks, and a clean contact sound generated through the procedural audio cue. Five health pips, 0.6s i-frames, knockback, Motes, and a death-location recovery shell are implemented by `GameState` and the world controller.

The slice contains eight readable archetypes: Rootling (patrol), Sporeback (contact burst), Lantern Mite (hop), Glasswing (dive), Gallery Sentry (projectile), Tide Crawler (low rush), Archive Wisp (orbiting shots), and Choir Knight (shielded lunge). The Pale Choir boss has three phases (sweep, shards, orbit) with 0.4s telegraph markers. Each phase exposes a violet Echo Needle parry window.

## Camera, lighting, and juice

The camera follows with velocity look-ahead and a bounded drag zone. Room edges are represented by world bounds. Landing, attack, damage, dash, and boss impacts call the screen-shake service; hit-stop pauses gameplay for 2–4 physics frames. A CanvasModulate-like navy world wash, warm player rim glow, cyan dash trail, animated dust/spores, and three drifting parallax background bands establish depth without an external texture dependency.

The player presentation is a procedural skeletal-style silhouette: body, mask, cloak, antennae, wing pose, and limbs are separate draw primitives and interpolate their poses from action state. The pose library in `assets/animations/player_animation_library.tres` names the full gameplay set (idle, run, transitions, jump, land, cling, dash, three attacks, hurt, death, and ability poses); the procedural renderer supplies the clean silhouette at runtime. This keeps the source art editable while meeting the gameplay-scale readability target.

## Mobile controls

Landscape touch controls are constructed in `TouchControls.gd`: left thumb D-pad, right-side jump / attack / dash / Echo / Pulse buttons, pressed glow/sink feedback, and `Input.vibrate_handheld()` on high-value actions. The HUD keeps a 44px safe inset, so gesture bars and cutouts are not covered. Keyboard and gamepad InputMap actions remain available; Settings cycles Touch → Gamepad → Auto and remembers the choice.

## Save and validation

`GameState` persists unlocked abilities, health, Motes, last safe position, and current room to `user://echofang_save.json`. The title screen offers Continue and New Expedition. Tests run with:

```text
godot --headless --path . --script res://tests/run_tests.gd
```

The suite checks feel constants, state transitions for all five abilities, damage and i-frames, JSON save/load, and a scene-transition smoke path. CI runs these checks before export. The headless smoke path instantiates the main scene, advances 60 seconds of physics, traverses the hub, and fails on any captured Godot error.

## Verification record

- Local structural verification: project, scenes, scripts, resources, docs, and CI are present and tracked.
- Headless verification: run `godot --headless --path . --script res://tests/run_tests.gd`; the GitHub workflow is the authoritative Godot 4.x / Android export environment.
- Android: export preset is landscape, the CI runner generates an ephemeral debug keystore and signs/verifies the APK with Android SDK `apksigner`, and uploads it as `echofang-android-debug`.
- Full release work beyond this slice: replace procedural art/audio with commissioned production assets, expand the world graph, tune boss balance with playtest telemetry, add controller remapping UI, and configure a protected release keystore through GitHub Secrets.
