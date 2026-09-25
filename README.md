# Echofang

A landscape-first Godot 4.x metroidvania vertical slice: one art-forward Moonroot Cathedral level, precise CharacterBody2D movement, five traversal/combat abilities, animated procedural silhouettes, generated cinematic backgrounds, hero/boss/codex art cards, eight enemy archetypes, a three-phase Pale Choir boss, touch/gamepad/keyboard controls, save/load, audio cues, and Android CI export. The APK preset targets `armeabi-v7a` 32-bit ARM for Android 9-class phones and uses the Compatibility renderer.

## Run

Open the repository in Godot 4.3+ and run the project root; the deferred bootstrap enters the single authored level at `scenes/main.tscn`. Keyboard: A/D move, Space jump, X attack/pogo, C dash, Z Echo Needle, V Umbral Pulse. The touch overlay is always landscape-safe.

## Verify

```bash
godot --headless --path . --script res://tests/run_tests.gd
godot --headless --path . --export-debug "Android" build/Echofang.apk
```

The current CI artifact is an art-forward ARM32 APK over 100 MB, containing the Moonroot background plates, illustrated character/codex cards, cinematic master art, and procedural ambient/SFX audio. The exported project launches through the deferred bootstrap and enters the single playable level automatically.

Read `DESIGN.md` for the one-level route, gating, combat, art direction, and verification record. `DECISIONS.md` records implementation choices and `SOURCES.md` records asset provenance.
