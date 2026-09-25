# Asset provenance

This visual pass uses generated cinematic paintings plus hand-authored runtime silhouettes and effects. The generated images were created in this session on 2026-09-25 with the Arena image generator from prompts written for Echofang. They are shipped as project content; review or replace them before a commercial release if the final distribution terms require a separately licensed art pack.

| Path / system | Source | License / notes |
| --- | --- | --- |
| `assets/generated/level_gloamroot.png` | Arena image generator, Echofang bioluminescent cathedral prompt | Generated in-session; project content; verify distribution terms before commercial release |
| `assets/generated/level_archive.png` | Arena image generator, Echofang flooded archive prompt | Generated in-session; project content; verify distribution terms before commercial release |
| `assets/generated/hero_portrait.png` | Arena image generator, Echofang hero prompt | Generated in-session; project content; verify distribution terms before commercial release |
| `assets/generated/choir_boss_portrait.png` | Arena image generator, Pale Choir boss prompt | Generated in-session; project content; verify distribution terms before commercial release |
| `assets/generated/enemy_codex.png` | Arena image generator, six-enemy codex prompt | Generated in-session; project content; verify distribution terms before commercial release |
| `assets/generated/hires/*` | ImageMagick enlargement, grading, and grain passes from the generated art | Repository-derived cinematic masters; included for the expanded Android art library |
| `resources/visual_asset_catalog.tres` | Hand-authored catalog referencing the cinematic masters | Repository-owned resource index |
| `assets/audio/*.wav` | Procedural Python waveform synthesis: ambient drones, pickup, dash, blade, hurt, boss cues | Repository-owned generated audio; no third-party samples |
| `assets/art/echofang_mark.svg` | Hand-authored vector mark | Repository-owned |
| `scripts/world/world.gd` | Hand-authored level painter, background composition, dust particles, and audio hooks | Repository-owned |
| `scripts/player/player.gd`, `scripts/combat/enemy.gd` | Hand-authored runtime silhouette and animation renderers | Repository-owned |
| Itch.io research reference | [2Bit Micro Metroidvania Tileset by 0x72](https://0x72.itch.io/2bitmicrometroidvaniatileset) | CC0 according to the author; not copied into the repository, used only as a style/licensing reference |

Before a commercial release, record the final generator/tool versions, prompts or session references, dates, and any updated licensing decisions for each replacement asset.
