# Asset provenance

Echofang's vertical slice intentionally contains no raw AI-generated pixels or third-party audio. The art pass is authored as deterministic GDScript vector drawing and the project mark is hand-authored SVG. This is the cleanup pass for the prototype slice: silhouettes are intentionally crisp at gameplay scale and avoid licensing ambiguity.

| Path / system | Source | License / notes |
| --- | --- | --- |
| `assets/art/echofang_mark.svg` | Hand-authored vector mark | Repository-owned; CC0-style internal source |
| `scripts/world/world.gd` | Hand-authored procedural environment painter | Repository-owned; no external asset |
| `scripts/player/player.gd` | Hand-authored procedural silhouette / pose renderer | Repository-owned; replaces raw generated sprite pixels |
| `scripts/ui/hud.gd`, `scripts/ui/touch_controls.gd` | Hand-authored runtime UI | Repository-owned |
| Audio event names | Hand-authored event contract; no binary audio in slice | Replace with commissioned/AI-assisted SFX after licensing review |
| `assets/animations/player_animation_library.tres` | Hand-authored animation contract | Repository-owned; procedural poses are runtime-driven |

For a full release, every commissioned or generated image, sound, and music file must add its model/tool, prompt or session reference, date, and license here before entering `assets/`.
