# Echofang

A landscape-first Godot 4.x metroidvania vertical slice: precise CharacterBody2D movement, five traversal/combat abilities, pogo combat, an 8-archetype enemy roster, three-phase Pale Choir boss, 24-room graph, procedural silhouette art, touch/gamepad/keyboard controls, save/load, and Android CI export.

## Run

Open the repository in Godot 4.3+ and run `scenes/main.tscn` (or the project root). Keyboard: A/D move, Space jump, X attack/pogo, C dash, Z Echo Needle, V Umbral Pulse. The touch overlay is always landscape-safe.

## Verify

```bash
godot --headless --path . --script res://tests/run_tests.gd
godot --headless --path . --export-debug "Android" build/Echofang.apk
```

Read `DESIGN.md` for the 24-room map graph, gating examples, combat and art direction. `DECISIONS.md` records implementation choices and `SOURCES.md` records asset provenance.
