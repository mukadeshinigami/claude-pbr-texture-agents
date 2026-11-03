# claude-pbr-texture-agents

A set of [Claude Code](https://claude.com/claude-code) subagents and skills that turn a PBR texture set (zip of maps, or even a single albedo image) into a finished material presentation using headless Blender (Cycles), Python and Pillow:

- a **ball** (hemisphere-projected sphere) and a **plane** with real displaced relief,
- neutral-grey series stills (ball, ball equator, plane, close-up),
- a saved `.blend` scene after every stage so you can inspect the process,
- an optional GLB export, an optional turntable MP4,
- a "texture-guide" sheet and a social thread for the result.

## What is inside

```
agents/                      Claude Code subagents (copy to ~/.claude/agents)
  pbr-maps-prep.md           intake: unzip, integrity, EXR->PNG, tileability, compare with previous set
  pbr-color.md               albedo colour: baked-shadow measurement, de-baking, grading
  pbr-material.md            maps: fix/soften, masks, premium height, inferred or procedural maps, quilting
  pbr-geometry-bake.md       plane mesh, hemisphere ball atlas, bake, .blend scenes, optional GLB
  pbr-render.md              look-dev, stills, 4K, turntable (the only agent allowed to use the GPU)
  pbr-layout.md              texture-guide sheet, social thread, summary
  pbr-qa.md                  read-only reviewer
skills/                      Claude Code skills (copy to ~/.claude/skills)
  pbr-material-pipeline/     the coordinator workflow and hard-won rules
  pbr-lookdev-render/        the neutral series look and render rules
  pbr-texture-sheet/         the sheet layout
install.sh                   copies agents and skills into ~/.claude
```

## Install

```bash
git clone git@github.com:mukadeshinigami/claude-pbr-texture-agents.git
cd claude-pbr-texture-agents
./install.sh          # copies into ~/.claude/agents and ~/.claude/skills (asks before overwriting)
```

Restart Claude Code, then ask for example: *"build the scene as usual from ~/Downloads/rock_4k.zip"*. Claude loads the `pbr-material-pipeline` skill, asks once whether you want a `.blend` after every stage, and spawns the specialists.

## What you need on your machine

- Blender 4.x with Cycles (headless: `blender -b -P script.py -- args`); an NVIDIA GPU with OptiX is assumed for rendering, CPU works but is slow.
- Python 3 with numpy, scipy, Pillow and OpenCV (run scripts with `python -I`).
- ffmpeg for turntables.
- A project folder with `assets/`, `scripts/`, `models/`, `renders/`. The agents write their own scripts per project; they are not shipped here.

## Rules baked into the agents

- Ball = hemisphere projection from the pole. **Triplanar/box projection is never used** (it creates crossing layers that read as lumps). Cube = per-face UV crops. Plane = plain UV.
- A `.blend` scene is saved after every stage; heavy renders only after the user has seen it; GLB only if the user says yes at the end.
- Honest labelling: "stylised, not a scan" for procedural maps, "inferred" for maps derived from a single image, resample vs AI detail stated, stand-in maps declared.
- De-bake check on every albedo (correlation of luminance with height > 0.7 = shading painted into the colour).
- Source licences matter: many free packs forbid redistribution; derived maps are still derivatives, so credit the source.

## Notes

The agents were developed on Linux (Arch) with Blender and a mid-range RTX card; adjust paths and the GPU etiquette in `pbr-render.md` for your setup.
