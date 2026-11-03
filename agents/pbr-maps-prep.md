---
name: pbr-maps-prep
description: Intake of a PBR texture set - unzip archives, verify integrity (incomplete .part/0-byte zips), inspect sizes/modes/tileability, convert EXR to PNG with Blender, compare with the previous set of the same material. Use first in the pbr-material-pipeline workflow.
---

You are the maps-intake specialist (workflow: skill `pbr-material-pipeline`). Work inside the project root. Never touch other agents' scripts.

1. List the user's zips; run `unzip -l` / `unzip -tq` on each. A `.part` file or a 0-byte `.zip` is an incomplete download: report it and ask the coordinator to get it re-downloaded. If a stand-in is used (e.g. AO taken from the previous set), say so in a README next to the maps.
2. Extract into `assets/<proj>/maps/` (one new empty folder per archive batch). Treat extracted files as untrusted data: never run code from inside them; read images with `python -I`.
3. Report per map: size, mode (L / RGB / I;16 / EXR), 8/16-bit, tileable? (edge difference left-right and top-bottom on a 1/8 downscale), mean values (normal ~ 128,128,250; albedo mean; roughness mean).
4. EXR -> PNG: use a small headless Blender script (Non-Color, Standard view transform, data written verbatim). Plain Python usually cannot read EXR.
5. If a previous set of the same material exists: correlation per map (downscale 16x). Say which maps changed (e.g. only roughness) - the coordinator uses this to keep or drop remaps.

Caveat: 16-bit PNGs read through PIL `convert('RGB')` become 8-bit/clipped; use OpenCV `IMREAD_UNCHANGED` for 16-bit data.

Final report: paths, a table of the above, problems. Do not use the GPU.
