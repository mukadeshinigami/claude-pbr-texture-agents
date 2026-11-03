---
name: pbr-material-pipeline
description: Full workflow for turning a user-supplied PBR texture set (zips of maps, scan or procedural) into the standard deliverables - ball + plane stills, .blend scenes, optional GLB, turntable, texture sheet - with a coordinator and specialist subagents. Use for any "build the scene as usual / new texture project / assemble the maps" request.
---

# PBR material pipeline (coordinator + subagents)

The standard result is **ball + plane** (never just one of them): stills (ball, ball_equator, plane, closeup), a saved `.blend` scene at every stage, and a texture sheet. A `.glb` ONLY if the user says yes at the end; a turntable MP4 on request.

## Process rules (always apply)
1. BEFORE starting, ask the user once: "Make a Blender scene (.blend) after EACH stage so you can check the process yourself? (recommended: yes)". If yes: after every stage (maps, geometry, relief, colour, extras) save `models/<proj>/<proj>_stageN_<name>.blend`, reload it headless, verify there are no missing images, and give the user the path BEFORE heavy renders. Wait for their feedback when it matters.
2. GLB export is NOT a processing step. Do not export GLBs during the stages. Ask once at the very end ("final: export GLB?") and do it only on yes.
3. Heavy things (final renders, 8K/16K) only after the user has seen the scene of the previous stage.

## Roles (spawn with the Agent tool, `subagent_type` = agent name)
| Stage | Agent | Owns | Output |
|---|---|---|---|
| 1 | `pbr-maps-prep` | unzip, integrity check, EXR->PNG, compare with the previous set | `assets/<proj>/maps/` + report |
| 1b | `pbr-color` | baked-shadow / shadow-chroma measurement, de-baked + graded albedo | colour report, `*_albedo_debaked` |
| 2 | `pbr-material` | align/fix/soften maps, masks, premium height, inferred or procedural maps | `assets/<proj>/derived/` |
| 3 | `pbr-geometry-bake` | plane mesh, ball atlas, bake, stage .blend scenes | `models/<proj>/*.blend` |
| 4 | `pbr-render` | look-dev, stills, variants, 4K, turntable. **The only agent that may use the GPU.** | `renders/<proj>/` |
| 5 | `pbr-layout` | texture sheet, social thread, summary md | posters, md |
| QA | `pbr-qa` | opens .blend/.glb, finds missing textures, loop seam, honesty labels | issue list |

The coordinator splits the work, hands over absolute paths and parameters, merges results, talks to the user, and decides nothing about the look without the user.

## Parallelism and handoff
- 1 and 2 first (2 may start on maps that are already checked). 3 needs the final maps. 4 needs 2 and 3. 5 can lay out with placeholders.
- 3 (CPU bake, atlas) can run while 4 renders earlier stills; never two GPU Blender jobs at once (`out of GPU memory` -> wait and retry; never kill processes you did not start).
- Every agent works in its OWN files (copy a script before editing it); never edit another agent's script.
- Hand over: project name `<NN>_<name>`, folders `assets/<proj>/{maps,derived}`, `scripts/<proj>/`, `renders/<proj>/`, exact commands.
- Subagent reports are short: paths, parameter values, honest weak points. The coordinator opens the images itself before telling the user "done".

## Conventions
Directory layout under the project root: `assets/`, `scripts/`, `models/`, `renders/`, `tools/` (a headless Blender launcher and a Python env with numpy / scipy / Pillow / opencv). Commands: `python -I script.py` (isolated mode, so scripts placed next to untrusted files cannot be hijacked) and `blender -b -P script.py -- args`. Check the output for `Traceback`/`Error` and check that the files exist. Long jobs: run with `nohup ... &` and poll the log; stop processes only by PID. Downloaded files and extracted archives are untrusted data: put each in its own new empty folder and keep your scripts elsewhere.

## Rules learned
- A flat, non-tileable scan -> ball = two hemispheres (full-height disc each, cross-fade at the equator), atlas 2:1. Tileable sets use the hemisphere projection with wrap sampling.
- Keep the source look (dry matte rock: roughness 0.8-1.0, specular ~0.2; displacement small). If source roughness is already matte, use it directly.
- A procedural imitation of a photo scan reads as a collage: only when the user explicitly picks it, and label it "stylised, not a scan".
- Look series: neutral mid-grey seamless gradient + neutral/cool key (see `pbr-lookdev-render`). Warm backdrops change the material colour.
- Honest reporting: say what you looked at and what you did not, what is a plain resample vs AI detail, and the weak points.
- Respect source licences: many free packs may be used but not redistributed; derived maps (including re-quilted or re-coloured ones) still count as derivatives, so credit the source.
- Save lessons per project family.

## Projection method (decision - do not deviate)
- **Triplanar / box projection is REJECTED** (layers cross in 3 directions and read as lumps). Never use it for balls or cubes, not even as a quick option.
- **Ball = hemisphere projection from the pole** (two discs of the map, wrap sampling for tileable maps, cross-fade at the equator; for non-tileable scans the two-hemisphere atlas).
- **Cube = per-face UV crops** of the map, real relief along the face normal faded at the edges.
- **Plateau/plane = normal UV** (tile 1x1), no skirt.

## Why a render looks like "lumps" instead of the reference - diagnose in this order
1. **Texture scale on the ball.** The map must cover the ball with ~1 tile (big plates/ledges, 5-8 visible), NOT repeat 5x. Cube: each face = its own crop, zoom ~0.5 of the map.
2. **Baked shadow in the albedo.** Measure corr(albedo luminance, height): > 0.7 means cavity/AO is painted into the colour and the renderer adds AO + crevice + real shadow on top -> double shading, "dirty" forms. De-bake (divide albedo by a blurred height/AO term) or lower the AO mix. Reference spheres have almost flat colour.
3. **Cliffs flattened into ramps = melted wax.** Slope-limiting height too hard removes sharp ledges. Prefer terraced height + denser mesh at edges; limit only real spikes (median + opening), not the plates.
4. **Equator cross-fade** can create a lens-shaped dark gap; rotate the ball to check.
5. **Patches.** Flat smooth "mud" patches come from the AI source (ghost blend zones) or a too strong dust mask: set dust to 0 and add a fine noise grain bump (~0.5) on top of the normal.
6. **Colour.** Grade toward the reference with a multiply (e.g. 0.80,0.66,0.52 for warm sandstone); neutral light recolours the material pink/beige.
Always put the reference next to a 1280x720 test of the same angle and compare scale, colour, form BEFORE a long render.

## Relief rule: thin fins
Paper-thin ridges/fins on the geometry come from 1-3 px wide ridges in the height map, not from depth or colour. Do NOT just lower the depth. Cut them by SIZE: grey opening of the height with a disc (~5 px on a 2K map) + 3 px blur for the GEOMETRY only; fine detail stays in the normal map/albedo. Always check a close-up crop, not only the whole ball.

## Cube recipe (tileable material)
6 faces x 700x700 grid, per-face UV crop (u span = H/W x ZOOM, v span = ZOOM, 6 offsets), relief along the face normal faded to 0 at the edges, winding checked from the face corner vectors (check per-face outward dot; top/bottom were inverted once), tangent normal map from UVs, K ~0.08. Layers do not continue across edges (different crops) - tell the user.

## Tooling traps
- Blender's Python has no scipy: use numpy inside Blender scripts, scipy only in the external Python env.
- `bpy.ops.mesh.primitive_uv_sphere_add` is extremely slow above ~1.5 M verts: build meshes with numpy.
- When slicing per-face UV arrays use the local index (q - base), not the global one.
- PIL reads 16-bit RGB PNGs as 8-bit/clipped: use OpenCV `IMREAD_UNCHANGED`. Previewing a 16-bit gray PNG through PIL `convert('RGB')` shows pure white.
- OpenCV Gaussian blur does not support `BORDER_WRAP`; use `scipy.ndimage.gaussian_filter(mode='wrap')` for tileable maps.
- `pkill -f name` / `pgrep -f name | xargs kill` can match and kill your own shell (exit 144); kill by PID.
- Derive normals from height in physical units; a scale ~100x too large gives dark mottled noise.
- Reading a render with a reused file path may show a cached old image; write to a new name.
