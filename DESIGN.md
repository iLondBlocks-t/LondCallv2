# ECHOFANG — Vertical Slice Design

Echofang is a landscape-only 2D metroidvania about an insect knight crossing the Moonroot Cathedral. This repository contains one playable, art-forward Godot 4.x level: generated painted background plates, illustrated hero/boss/codex cards, procedural character animation, particles, lighting, sound cues, and touch/gamepad/keyboard controls.

## Player promise

Every input has a visible and physical answer within one frame: buffered jump, generous coyote time, sharp acceleration, readable anticipation, hit-stop, and screen shake. Exploration is paced as a loop: learn a route in the Gloamroot Hub, earn Fang Dash and Wraith Wings, use both to cut through the Sunken Galleries, then reach the Choir boss in the Moonless Archive.

## One level: Moonroot Cathedral

The scope is intentionally one polished level rather than a broad empty graph. It is a 7,680px left-to-right route with four authored beats: the lantern landing, flooded library, traversal shaft, and Pale Choir arena. The camera follows one continuous playable space; gates are real collision gates and ability rewards are placed directly on the route.

```text
[START] Lantern Landing -- Echo Needle shrine -- Fang Chasm gate -- Flooded Library
                                      |                 |
                              Secret glyphs       Wraith Wings lift
                                                        |
                         Umbral Lock -- archive bridge -- Wall Cling / CHOIR DOOR
                                                                    |
                                                        [PALE CHOIR ARENA]
```

Echo Needle reveals four secret glyphs. Fang Dash crosses the first chasm, Wraith Wings reaches the high library lift, Umbral Pulse opens the lock, and Wall Cling opens the final choir door. The point is a complete beginning-to-boss journey that can be finished in one sitting, with no filler rooms.

## Ability kit and gates

| Ability | Input | Feel / cost | VFX and sound identity | Slice gate |
| --- | --- | --- | --- | --- |
| Fang Dash | Dash / C | 0.15s burst, 8-way aim after upgrade, i-frames; 0.65s cooldown | Three cyan afterimages, air-cut whoosh | First chasm in the single route; also enables dash-cancel attack |
| Wraith Wings | Jump in air / Space | One extra jump, small drift, 0.12s hang frame | Pale wing gust, glassy double chime | Flooded library high lift |
| Wall Cling / Wall Jump | Move into wall, Jump | 160px/s slide; fixed 52° outward launch with steering | Amber claw sparks, stone scrape | Final choir-door shaft |
| Echo Needle | Ability 1 / Z | 0.34s charge, reveals secrets and parries telegraphs | Violet sonar rings, low heartbeat ping | Lantern shrine + four secret glyphs |
| Umbral Pulse | Ability 2 / V | 3 Umbra, 0.6s recharge per melee hit; charged piercing beam | Black-violet bolt with gold core, boss-sting bass | Umbral Lock; ranged answer to sentries |

## Combat

The Nail is a three-step attack chain with directionality: horizontal, up, and down. Downward air attack is a pogo: enemies and marked hazards bounce the knight instantly upward. Every impact does 3 frames of hit-stop, a small camera shake, sparks, and a clean contact sound generated through the procedural audio cue. Five health pips, 0.6s i-frames, knockback, Motes, and a death-location recovery shell are implemented by `GameState` and the world controller.

The slice contains eight readable archetypes: Rootling (patrol), Sporeback (contact burst), Lantern Mite (hop), Glasswing (dive), Gallery Sentry (projectile), Tide Crawler (low rush), Archive Wisp (orbiting shots), and Choir Knight (shielded lunge). The Pale Choir boss has three phases (sweep, shards, orbit) with 0.4s telegraph markers. Each phase exposes a violet Echo Needle parry window.

## Camera, lighting, and juice

The camera follows with velocity look-ahead and a bounded drag zone. Room edges are represented by world bounds. Landing, attack, damage, dash, and boss impacts call the screen-shake service; hit-stop pauses gameplay for 2–4 physics frames. A CanvasModulate-like navy world wash, warm player rim glow, cyan dash trail, animated dust/spores, and three drifting parallax background bands establish depth without an external texture dependency.

The player presentation combines the procedural skeletal-style silhouette with the generated Echofang hero portrait. Body, mask, cloak, antennae, wing pose, and limbs are separate draw primitives and interpolate their poses from action state. The pose library in `assets/animations/player_animation_library.tres` names the full gameplay set (idle, run, transitions, jump, land, cling, dash, three attacks, hurt, death, and ability poses); the renderer supplies readable gameplay animation while the HUD carries illustrated hero, boss, and enemy-codex cards. Painted background plates are animated with camera movement, dust, pulses, and audio rather than being a static screenshot.

## Mobile controls

Landscape touch controls are constructed in `TouchControls.gd`: left thumb D-pad, right-side jump / attack / dash / Echo / Pulse buttons, pressed glow/sink feedback, and `Input.vibrate_handheld()` on high-value actions. The HUD keeps a 44px safe inset, so gesture bars and cutouts are not covered. Keyboard and gamepad InputMap actions remain available; Settings cycles Touch → Gamepad → Auto and remembers the choice.

## Save and validation

`GameState` persists unlocked abilities, health, Motes, last safe position, and current room to `user://echofang_save.json`. The title screen offers Continue and New Expedition. Tests run with:

```text
godot --headless --path . --script res://tests/run_tests.gd
```

The suite checks feel constants, state transitions for all five abilities, damage and i-frames, JSON save/load, and a main-scene entry smoke path. CI runs these checks before export; the project bootstrap then launches the configured main scene headlessly for three frames. The workflow then exports, signs, verifies, and ABI-checks the Android APK. Physical Android install/launch verification remains a device/emulator acceptance step rather than something the hosted runner can claim.

## Verification record

- Local structural verification: project, scenes, scripts, resources, docs, and CI are present and tracked.
- Headless verification: the deterministic suite and configured bootstrap/main-scene launch both pass in GitHub Actions run `36107601494` at commit `c2d6967`.
- Android artifact: that run uploads `echofang-android-debug` (artifact size 111,113,070 bytes); CI also enforces a 100,000,000-byte final APK floor, verifies the signature, and requires a `lib/armeabi-v7a/` payload.
- Android: export preset is landscape and explicitly targets `armeabi-v7a` (32-bit ARM) for Android 9 devices; the Compatibility renderer is used because Godot documents Android 6+ for Compatibility and Android 9+ for the heavier Mobile/Forward+ renderer. The CI runner generates an ephemeral debug keystore and signs/verifies the APK with Android SDK `apksigner`, and uploads it as `echofang-android-debug`.
- Full release work beyond this slice: playtest the art-forward one-level route, tune boss balance with telemetry, add controller remapping UI, review generated-art distribution terms, and configure a protected release keystore through GitHub Secrets.
