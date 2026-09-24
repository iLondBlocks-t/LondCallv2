# Echofang Engineering Decisions

This file records decisions made without blocking on clarification, as requested by the engineering brief.

- **2026-09-24 — Replaced the unrelated starter app with a Godot root project.** The requested product, CI, runtime, and test contract are Godot-specific; retaining the Firebase/Gradle starter would make the Android artifact and headless test misleading.
- **2026-09-24 — Targeted Godot 4.3 compatibility with Compatibility renderer.** This is the newest stable line available in the CI image and keeps Android GPU requirements low while retaining Light2D-compatible 2D rendering.
- **2026-09-24 — Used runtime procedural vector art instead of shipping raw generated pixels.** It makes the slice deterministic, keeps the repository small, and provides a clean silhouette cleanup pass; production art can replace the renderer without changing gameplay contracts.
- **2026-09-24 — Implemented a continuous authored corridor with 24 logical room cells.** A continuous collision space makes the vertical slice immediately playable in a headless build while the room graph and camera-cell labels preserve metroidvania topology.
- **2026-09-24 — Centralized progression in the `GameState` autoload.** Abilities, Motes, health, respawn position, and save/load need one source of truth across transitions and death.
- **2026-09-24 — Chose input buffering and coyote time in physics ticks, not render frames.** At 60Hz this directly honors the 150ms / 120ms design spec and remains deterministic under variable rendering load.
- **2026-09-24 — Kept the controller as `CharacterBody2D`.** It is the Godot-native collision primitive required by the brief and gives slopes, one-way platforms, and moving collision geometry a safe extension point.
- **2026-09-24 — Implemented ability definitions as `AbilityResource` assets.** Costs, cooldowns, gates, and presentation metadata can be tuned in the inspector without rewriting player state logic.
- **2026-09-24 — Built touch UI as a runtime-safe overlay.** A procedural Control layout respects landscape safe insets and works in editor/headless builds without importing platform-specific plugins.
- **2026-09-24 — CI uses `barichello/godot-ci:4.3.0`.** The image supplies Godot and Android export templates in a reproducible Linux runner; tests deliberately run before the export command.
- **2026-09-24 — CI exports a debug-signed APK when no release secret exists.** Godot 4.3's headless Android validator rejects an empty debug-key triplet, so the preset exports unsigned and the workflow generates a throwaway CI debug keystore with `keytool`, signs using the runner's `apksigner`, verifies the signature, and discards the key. A release keystore must never be committed; the workflow documents the `ANDROID_KEYSTORE_*` secret path for a future protected release build.
- **2026-09-24 — The procedural audio cue is intentionally a no-op in headless mode.** Gameplay emits named sound events through one service so real authored SFX can be dropped in later without coupling gameplay code to audio assets or making CI depend on an audio server.
- **2026-09-24 — The first boss telegraph is readable for 0.4 seconds.** This sits in the requested 0.3–0.5s window and leaves enough reaction time for Echo Needle parries on a touch screen.
